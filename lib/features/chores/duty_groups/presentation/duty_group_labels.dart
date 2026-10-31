import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/duty_groups/domain/rotation.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/shared/widgets/avatar_stack.dart';
import 'package:family_hub/shared/widgets/person_picker.dart';
import 'package:flutter/widgets.dart';

/// The group's name in the reader's language (English falls back to the Bangla
/// name when there is no English one).
String dutyGroupName(BuildContext context, DutyGroup group) =>
    Localizations.localeOf(context).languageCode == 'bn'
    ? group.nameBn
    : (group.nameEn ?? group.nameBn);

/// A member id as a name; somebody who is not in the list shows as `?`, never
/// as a raw uid.
String memberName(Map<String, Member> index, String uid) =>
    index[uid]?.displayName ?? '?';

/// The people a screen lists for [ids], in the same order.
List<AvatarStackMember> stackMembers(
  Map<String, Member> index,
  Iterable<String> ids,
) => <AvatarStackMember>[
  for (final id in ids)
    AvatarStackMember(
      id: id,
      name: memberName(index, id),
      avatarKey: index[id]?.avatarKey,
    ),
];

/// Picker options for [members].
List<PersonOption> personOptions(Iterable<Member> members) => <PersonOption>[
  for (final member in members)
    PersonOption(
      id: member.uid,
      name: member.displayName,
      avatarKey: member.avatarKey,
    ),
];

/// A day as a `DateTime` for a date picker and the formatters (UTC midnight,
/// so no time zone can move it).
DateTime dateOfKey(DateKey key) => DateTime.utc(key.year, key.month, key.day);

/// The inverse of [dateOfKey].
DateKey keyOfDate(DateTime date) => DateKey(date.year, date.month, date.day);

/// `true` for a unit a NEW group may choose (the `occurrence` unit needs a
/// schedule, which a group does not own; existing groups keep it).
bool offersCycleUnit(CycleUnit unit) => unit != CycleUnit.occurrence;
