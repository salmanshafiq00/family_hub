import 'dart:io';

import 'package:family_hub/core/permissions/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

/// H7: `docs/permission_matrix.md` is GENERATED from [PermissionPolicy], so it
/// cannot drift from the code.  The owner ratifies that file (decision D6).
///
/// After an intentional policy change regenerate it with
/// `UPDATE_PERMISSION_MATRIX=1 flutter test test/core/permissions/permission_matrix_doc_test.dart`.

/// (permission, family setting, project spec section 6, decision needed).
const List<(Permission, String, String, String?)>
_rows = <(Permission, String, String, String?)>[
  (
    Permission.inviteMembers,
    '`membersCanInvite` lets plain members invite',
    'Manage family and invitations: admin Yes, moderator Limited, member No',
    'Household Manager "Limited": is inviting enough, or should it be admin-only?',
  ),
  (
    Permission.approveMembers,
    '-',
    'Manage family and invitations: admin Yes, moderator Limited, member No',
    'Household Manager "Limited": approve and reject are allowed, roles are not. Confirm.',
  ),
  (
    Permission.removeMembers,
    '-',
    'Manage family and invitations: admin Yes, moderator Limited, member No',
    null,
  ),
  (
    Permission.changeRoles,
    '-',
    'Change member roles: admin Yes, moderator No, member No',
    null,
  ),
  (
    Permission.editFamilySettings,
    '-',
    'Change family settings: admin Yes, moderator Limited, member Personal settings',
    'Household Manager "Limited": code gives Household Managers nothing here. Which settings, if any?',
  ),
  (
    Permission.viewFamilyReports,
    '`membersViewFamilyReports` (default on)',
    'View reports: admin Yes, moderator Yes, member According to family policy',
    'Default for members is "on". Confirm or switch the default off.',
  ),
  (
    Permission.exportData,
    '-',
    '(not in spec section 6)',
    'Not in the spec: admin only. Confirm.',
  ),
  (
    Permission.manageCatalogAndBudgets,
    '`moderatorManagesFinance` (default on)',
    'Manage budgets/contributions: admin Yes, moderator Configurable, member View/add',
    'Default for Household Managers is "on". Confirm or switch the default off.',
  ),
  (
    Permission.addOwnExpense,
    '-',
    'Create/edit expenses: admin Yes, moderator Yes, member Yes',
    null,
  ),
  (
    Permission.editOthersExpense,
    '-',
    'Create/edit expenses: admin Yes, moderator Yes, member Yes',
    'Spec lets members create/edit expenses; code lets a member edit only their own. Confirm.',
  ),
  (
    Permission.recordContribution,
    '`moderatorManagesFinance` (default on)',
    'Manage budgets/contributions: admin Yes, moderator Configurable, member View/add',
    'Members "add" in the spec: should a member record their OWN contribution?',
  ),
  (
    Permission.viewAllContributions,
    '`membersViewAllContributions` (default off)',
    'Manage budgets/contributions: member View/add',
    'Project default is "members see only their own". Confirm.',
  ),
  (
    Permission.closeBazarMonth,
    '`moderatorManagesFinance` (default on)',
    '(not in spec section 6)',
    'Admin only, or Household Manager while the family allows finance? Confirm.',
  ),
  (
    Permission.importBazarData,
    '`moderatorManagesFinance` (default on)',
    '(not in spec section 6)',
    'Admin only, or Household Manager while the family allows finance? Confirm.',
  ),
  (
    Permission.requestContribution,
    '-',
    'Manage budgets/contributions: member View/add',
    null,
  ),
  (
    Permission.manageChoreTemplates,
    '-',
    'Manage chore templates: admin Yes, moderator Yes, member No',
    null,
  ),
  (
    Permission.reassignChore,
    '-',
    'Reassign chores: admin Yes, moderator Yes, member Request/exchange',
    null,
  ),
  (
    Permission.requestSwap,
    '-',
    'Reassign chores: member Request/exchange',
    null,
  ),
  (Permission.completeOwnChore, '-', 'Comment/complete chores: all Yes', null),
  (Permission.commentOnChore, '-', 'Comment/complete chores: all Yes', null),
  (
    Permission.verifyChore,
    '`choreVerificationEnabled` + the template switch',
    '(not in spec section 6)',
    'Not in the spec: verification is off by default and nobody verifies their own work. Confirm.',
  ),
  (
    Permission.completeChoreForOthers,
    '`membersCanCompleteForOthers` (default off)',
    'Reassign chores: admin Yes, moderator Yes, member Request/exchange',
    'Phase 3: may a plain member tick somebody else\'s chore? Default is no (assignee or manager). Confirm.',
  ),
  (Permission.recordOwnAvailability, '-', '(not in spec section 6)', null),
  (Permission.manageAvailability, '-', '(not in spec section 6)', null),
  (Permission.manageChoreOccurrences, '-', '(not in spec section 6)', null),
  (Permission.moderateChoreComments, '-', '(not in spec section 6)', null),
  (Permission.manageEngagement, '-', '(not in spec section 6)', null),
  (
    Permission.manageDashboardLayout,
    '`moderatorManagesFinance` (default on)',
    '(not in spec section 6)',
    null,
  ),
  (Permission.manageNotificationDefaults, '-', '(not in spec section 6)', null),
];

const PermissionSettings _defaults = PermissionSettings.defaults;

String _cell(Role role, Permission permission) {
  // The context in which only the role can make the answer false.
  final settings = _defaults.copyWith(choreVerificationEnabled: true);
  const template = PermissionTemplate(verificationEnabled: true);
  final answer = PermissionPolicy.can(
    PermissionActor(uid: 'me', role: role, isActive: true),
    permission,
    ownerId: switch (permission) {
      Permission.requestSwap ||
      Permission.completeOwnChore ||
      Permission.recordOwnAvailability => 'me',
      _ => 'other',
    },
    settings: permission == Permission.verifyChore ? settings : _defaults,
    template: permission == Permission.verifyChore ? template : null,
  );
  if (!answer) return 'no';
  return switch (permission) {
    Permission.requestSwap ||
    Permission.completeOwnChore ||
    Permission.recordOwnAvailability => 'own',
    Permission.verifyChore => 'other',
    _ => 'yes',
  };
}

String buildPermissionMatrixDoc() {
  final lines = <String>[
    '# Permission matrix',
    '',
    '<!-- GENERATED by test/core/permissions/permission_matrix_doc_test.dart from PermissionPolicy. Do not edit by hand: change the policy, then run `UPDATE_PERMISSION_MATRIX=1 flutter test test/core/permissions/permission_matrix_doc_test.dart`. -->',
    '',
    'Cells show the answer with the DEFAULT family settings for an active member. `own` = only for the record\'s owner, `other` = only for somebody else\'s work (and only when verification is switched on for the family and the template). Every cell is `no` for a member who is not active or while the module is switched off.',
    '',
    '| Permission | Admin | Household Manager | Member | Family setting that changes it | Project spec section 6 | Matches spec? |',
    '| --- | --- | --- | --- | --- | --- | --- |',
    for (final (p, setting, spec, decision) in _rows)
      '| `${p.name}` | ${_cell(Role.admin, p)} | ${_cell(Role.moderator, p)} | '
          '${_cell(Role.member, p)} | $setting | $spec | '
          '${decision == null ? 'yes' : 'DECIDE'} |',
    '',
    '## Cells the owner must decide',
    '',
    for (final (p, _, _, decision) in _rows)
      if (decision != null) '- `${p.name}`: $decision',
    '',
  ];
  return lines.join('\n');
}

void main() {
  test('every permission has exactly one row', () {
    expect(
      _rows.map((r) => r.$1).toList()..sort((a, b) => a.index - b.index),
      Permission.values,
    );
  });

  test('docs/permission_matrix.md is exactly what the policy produces', () {
    final file = File('docs/permission_matrix.md');
    final expected = buildPermissionMatrixDoc();
    if (Platform.environment['UPDATE_PERMISSION_MATRIX'] == '1') {
      file.writeAsStringSync(expected);
    }
    expect(file.existsSync(), isTrue, reason: 'docs/permission_matrix.md');
    expect(
      file.readAsStringSync(),
      expected,
      reason:
          'the matrix document drifted from PermissionPolicy; regenerate '
          'it with UPDATE_PERMISSION_MATRIX=1',
    );
  });
}
