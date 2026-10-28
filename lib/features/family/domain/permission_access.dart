import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/errors/result.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/family/domain/family_repository.dart';
import 'package:family_hub/features/family/domain/member.dart';

/// Loads the acting member, then asks [PermissionPolicy] whether they may act.
///
/// This is the `requirePermission` helper of Step 10: every mutating use case
/// calls it FIRST, before reading inputs or touching the repository.  It
/// replaces the Step 9 `requireActor` (which took a raw set of roles), so the
/// rule lives in exactly one matrix instead of in each use case.
///
/// [settings] defaults to the family's `settings/permissions` document (one
/// extra read per mutation, deliberate: a use case cannot forget it).
///
/// Returns `PermissionDenied` for a missing, rejected, pending or disabled
/// actor, and for an active actor the matrix does not allow.  A repository
/// failure is passed through unchanged.
Future<Result<Member>> requirePermission(
  FamilyRepository repository, {
  required String familyId,
  required String actorUid,
  required Permission permission,
  String? ownerId,
  PermissionSettings? settings,
  PermissionTemplate? template,
}) async {
  final result = await repository.getMember(familyId, actorUid);
  final failure = result.failureOrNull;
  if (failure != null) return Failure<Member>(failure);

  final actor = result.valueOrNull;
  if (actor == null || actor.isRemoved) {
    return const Failure<Member>(PermissionDenied());
  }
  // H7: the family's permission switches decide the configurable cells (a
  // moderator's finance rights, whether members may invite ...).  An unreadable
  // document falls back to the DEFAULTS, which never grant a member more than
  // the matrix's base cell (members may not invite by default).
  final effective = settings ?? await _loadSettings(repository, familyId);
  if (!PermissionPolicy.can(
    actor.permissionActor,
    permission,
    ownerId: ownerId,
    settings: effective,
    template: template,
  )) {
    return const Failure<Member>(PermissionDenied());
  }
  return Success<Member>(actor);
}

Future<PermissionSettings> _loadSettings(
  FamilyRepository repository,
  String familyId,
) async {
  final loaded = await repository.getPermissionSettings(familyId);
  return loaded.valueOrNull ?? PermissionSettings.defaults;
}

/// Loads the acting member and denies anyone who is not ACTIVE.
///
/// Used by the flows every active member may run but a pending, rejected,
/// disabled or removed member may not (`EnsureOccurrences`, D-P3-7). It does
/// not consult the permission matrix: there is no permission to check.
Future<Result<Member>> requireActiveMember(
  FamilyRepository repository, {
  required String familyId,
  required String actorUid,
}) async {
  final result = await repository.getMember(familyId, actorUid);
  final failure = result.failureOrNull;
  if (failure != null) return Failure<Member>(failure);

  final actor = result.valueOrNull;
  if (actor == null || !actor.isActive) {
    return const Failure<Member>(PermissionDenied());
  }
  return Success<Member>(actor);
}

/// True when applying [updated] to [members] leaves no active admin.
///
/// Firestore rules cannot enumerate a subcollection, so the last-admin guard
/// cannot be expressed there; it is enforced here and in the use cases that
/// change a role, disable a member or remove one (Step 9/10).
bool leavesNoActiveAdmin(List<Member> members, Member updated) {
  final after = [for (final m in members) m.uid == updated.uid ? updated : m];
  return !after.any((m) => m.isActiveAdmin);
}

/// Decision D4 (Step H6): a family may have at most three active admins.
///
/// `families/{f}.adminIds` holds 1..3 uids of ACTIVE admins and the security
/// rules enforce the same bound.  Enforced here as well so a promotion fails
/// with a localized `too_many_admins` conflict instead of a bare permission
/// error from the family-document write.
const int maxActiveAdmins = 3;

/// The uids of the active admins in [members], in roster order.
///
/// This is exactly what `families/{f}.adminIds` must contain after a write
/// (H6); the rules re-check every uid against its member document.
List<String> activeAdminIds(Iterable<Member> members) => <String>[
  for (final m in members)
    if (m.isActiveAdmin) m.uid,
];

/// [members] with [updated] replacing the member of the same uid.
List<Member> rosterWith(List<Member> members, Member updated) => <Member>[
  for (final m in members)
    if (m.uid == updated.uid) updated else m,
];

/// True when [a] and [b] contain the same uids (order-independent).
bool sameAdminSet(List<String> a, List<String> b) =>
    a.length == b.length && a.every(b.contains);
