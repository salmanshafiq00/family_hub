import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/membership_providers.dart';
import 'package:family_hub/modules/module_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one UI entry point to the permission matrix (H7, CLAUDE.md rule 19).
///
/// Screens never test a role: they ask `ref.can(Permission.x)` (or
/// `canProvider`) and hand the answer to `PermissionGate`.  The answer comes
/// from [PermissionPolicy] with the family's real switches, the same matrix the
/// use cases and the security rules apply.

/// A question for [canProvider].  Value equality, so the provider family
/// caches per question.
final class PermissionQuery {
  const PermissionQuery(this.permission, {this.ownerId, this.template});

  final Permission permission;

  /// The member a record belongs to (assignee, completer ...).
  final String? ownerId;

  final PermissionTemplate? template;

  @override
  bool operator ==(Object other) =>
      other is PermissionQuery &&
      other.permission == permission &&
      other.ownerId == ownerId &&
      other.template == template;

  @override
  int get hashCode => Object.hash(permission, ownerId, template);

  @override
  String toString() => 'PermissionQuery(${permission.name}, owner: $ownerId)';
}

/// The signed-in user as the permission policy sees them, or `null` before a
/// membership is known.
///
/// Derived from the membership stream, which already folds the member document
/// (role, status, removed/left) into one value: a removed member is
/// `Membership.none`, so `isActive` is simply "status is active".
final currentActorProvider = Provider<PermissionActor?>((ref) {
  final uid = ref.watch(currentUidProvider);
  final membership = ref.watch(membershipProvider).value;
  final role = membership?.role;
  if (uid == null || membership == null || role == null) return null;
  if (membership.status == MembershipStatus.none) return null;
  return PermissionActor(
    uid: uid,
    role: role,
    isActive: membership.status == MembershipStatus.active,
  );
});

final _permissionDocProvider =
    StreamProvider.family<PermissionSettings, String>((ref, familyId) {
      return ref
          .watch(familyRepositoryProvider)
          .watchPermissionSettings(familyId);
    });

/// The family's switches: `settings/permissions` plus the module flags.
///
/// Only an active member can read the settings, so everybody else (and the
/// first frame) gets the defaults.
final permissionSettingsProvider = Provider<PermissionSettings>((ref) {
  final membership = ref.watch(membershipProvider).value;
  final flags = ref.watch(moduleFlagsProvider);
  final familyId = membership?.familyId;
  final fromDoc =
      familyId == null || membership?.status != MembershipStatus.active
      ? null
      : ref.watch(_permissionDocProvider(familyId)).value;
  return (fromDoc ?? PermissionSettings.defaults).copyWith(
    bazarEnabled: flags.isEnabled('bazar'),
    choresEnabled: flags.isEnabled('chores'),
  );
});

/// Whether the signed-in user may do [PermissionQuery.permission] right now.
final canProvider = Provider.family<bool, PermissionQuery>((ref, query) {
  final actor = ref.watch(currentActorProvider);
  if (actor == null) return false;
  return PermissionPolicy.can(
    actor,
    query.permission,
    ownerId: query.ownerId,
    settings: ref.watch(permissionSettingsProvider),
    template: query.template,
  );
});

/// Whether the signed-in user may verify other people's chores at all (B-02):
/// what decides if the Verify tile and the Verify queue are shown. Whether ONE
/// chore can be verified also depends on its template (`ref.can(...,
/// template:)`), which this provider deliberately does not know.
final canVerifyAnyProvider = Provider<bool>((ref) {
  final actor = ref.watch(currentActorProvider);
  if (actor == null) return false;
  return PermissionPolicy.canVerifyOthers(
    actor,
    settings: ref.watch(permissionSettingsProvider),
  );
});

/// `ref.can(Permission.inviteMembers)` inside a widget's `build`.
extension WidgetRefPermissions on WidgetRef {
  bool can(
    Permission permission, {
    String? ownerId,
    PermissionTemplate? template,
  }) => watch(
    canProvider(
      PermissionQuery(permission, ownerId: ownerId, template: template),
    ),
  );
}

/// `ref.can(...)` inside another provider.
extension RefPermissions on Ref {
  bool can(
    Permission permission, {
    String? ownerId,
    PermissionTemplate? template,
  }) => watch(
    canProvider(
      PermissionQuery(permission, ownerId: ownerId, template: template),
    ),
  );
}
