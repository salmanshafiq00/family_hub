import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_hub/core/firebase/audit_writer.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:family_hub/core/firebase/server_time.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/core/utils/clock.dart';
import 'package:family_hub/core/utils/date_key.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/core/utils/quantity.dart';
import 'package:family_hub/features/bazar/advances/data/advance_mappers.dart';
import 'package:family_hub/features/bazar/advances/domain/member_advance.dart';
import 'package:family_hub/features/bazar/advances/domain/settlement.dart';
import 'package:family_hub/features/bazar/budgets/data/budget_mappers.dart';
import 'package:family_hub/features/bazar/budgets/domain/budget.dart';
import 'package:family_hub/features/bazar/contributions/data/contribution_mappers.dart';
import 'package:family_hub/features/bazar/contributions/domain/contribution.dart';
import 'package:family_hub/features/bazar/expenses/data/expense_mappers.dart';
import 'package:family_hub/features/bazar/expenses/domain/expense.dart';
import 'package:family_hub/features/bazar/expenses/domain/expense_repository.dart';
import 'package:family_hub/features/bazar/expenses/domain/funding.dart';
import 'package:family_hub/features/bazar/expenses/domain/trip.dart';
import 'package:family_hub/features/bazar/fund/data/fund_mappers.dart';
import 'package:family_hub/features/bazar/fund/data/month_closing_mappers.dart';
import 'package:family_hub/features/bazar/fund/domain/fund_transaction.dart';
import 'package:family_hub/features/bazar/fund/domain/month_closing.dart';
import 'package:family_hub/features/bazar/items_categories/data/catalog_mappers.dart';
import 'package:family_hub/features/bazar/items_categories/data/default_catalog_writes.dart';
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item_usage_bump.dart';
import 'package:family_hub/features/bazar/settings/data/bazar_settings_mappers.dart';
import 'package:family_hub/features/bazar/settings/domain/bazar_settings.dart';
import 'package:family_hub/features/chores/duty_groups/data/duty_group_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_event_mappers.dart';
import 'package:family_hub/features/chores/occurrences/data/occurrence_mappers.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_event.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_write_plan.dart';
import 'package:family_hub/features/chores/occurrences/domain/chore_occurrence.dart';
import 'package:family_hub/features/chores/occurrences/domain/occurrence_status.dart';
import 'package:family_hub/features/chores/duty_groups/domain/duty_group.dart';
import 'package:family_hub/features/chores/templates/data/chore_template_mappers.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/family/data/family_mappers.dart';
import 'package:family_hub/features/family/data/relationship_mappers.dart';
import 'package:family_hub/features/family/domain/family.dart';
import 'package:family_hub/features/family/domain/relationship_catalog.dart';
import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/core/audit/audit_event_type.dart';
import 'package:family_hub/core/audit/audit_ref_type.dart';
import 'package:family_hub/features/family/domain/invitation.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/domain/relationship.dart';
import 'package:family_hub/features/onboarding/data/firestore_profile_repository.dart';
import 'package:family_hub/features/onboarding/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// H5 contract fixtures: the REAL mapper output, written to disk for
/// `firebase/rules_test/contract.test.mjs` to push through the security rules.
///
/// Timestamps are encoded as `{"__ts": iso}` and the server-clock marker as
/// `{"__serverTime": true}`; the Node test rehydrates both.  The output is
/// deterministic (a fixed clock), so CI can run this test and then
/// `git diff --exit-code firebase/rules_test/fixtures` to catch drift.
void main() {
  test('writes the rules contract fixtures', () {
    final dir = Directory('firebase/rules_test/fixtures');
    dir.createSync(recursive: true);

    const encoder = JsonEncoder.withIndent('  ');
    for (final fixture in _fixtures()) {
      final file = File('${dir.path}/${fixture['scenario']}.json');
      file.writeAsStringSync('${encoder.convert(fixture)}\n');
    }

    expect(
      dir.listSync().whereType<File>().length,
      _fixtures().length,
      reason: 'one JSON file per scenario',
    );
  });
}

const _admin = 'fixAdmin';
const _joiner = 'fixJoiner';
const _member = 'fixMember';
const _familyId = 'fixFam';
const _code = 'ABCD2345';
const _newCode = 'NEWCODE1';
const _categoryId = 'cat_fixStaples';
const _itemId = 'item_fixRice';
final DateTime _at = DateTime.utc(2026, 10, 18, 10);

BaseDocumentMetadata _meta(String uid) =>
    BaseMapper.createMetadata(uid: uid, clock: FakeClock(_at));

List<Map<String, dynamic>> _fixtures() => <Map<String, dynamic>>[
  _createFamily(),
  _createFamilyCatalog(),
  _join(),
  _approve(),
  _roleChange(),
  _transferAdmin(),
  _createInvitation(),
  _revokeInvitation(),
  _profile(),
  _category(),
  _item(),
  _itemUsage(),
  _settingsBazar(),
  _budget(),
  _expenseFund(),
  _expenseMemberAdvance(),
  _expensePersonal(),
  _expenseEdit(),
  _expenseSoftDelete(),
  _expenseRestore(),
  _revision(),
  _trip(),
  _fundTxExpense(),
  _fundTxContribution(),
  _fundTxReimbursement(),
  _fundTxOpening(),
  _fundTxAdjustment(),
  _advance(),
  _settlement(),
  _monthClosing(),
  _contributionRequest(),
  _contributionRecorded(),
  _contributionPlan(),
  _choreTemplate(),
  _dutyGroup(),
  _choreOccurrence(),
  _choreOccurrenceReopen(),
  _choreOccurrenceRestore(),
];

Map<String, dynamic> _fixture(
  String scenario,
  String actor,
  List<Map<String, dynamic>> writes,
) => <String, dynamic>{'scenario': scenario, 'actor': actor, 'writes': writes};

Map<String, dynamic> _write(
  String op,
  String path,
  Map<String, dynamic> data,
) => <String, dynamic>{'op': op, 'path': path, 'data': _toJson(data)};

Map<String, dynamic> _createFamily() {
  const family = Family(id: _familyId, name: 'Fix Family');
  final meta = _meta(_admin);
  const owner = Member(
    uid: _admin,
    role: MemberRole.admin,
    status: MembershipStatus.active,
    fullName: 'Fix Admin',
    relationship: 'other',
  );
  final created = AuditEvent(
    id: 'ev1',
    type: 'family.created',
    actorId: _admin,
    summary: 'Family created',
    refType: 'family',
    refId: _familyId,
    at: _at,
    params: const {'familyName': 'Fix Family'},
  );
  return _fixture('create_family', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.familyDoc(_familyId),
      FamilyMappers.familyDocMap(family, meta),
    ),
    _write(
      'set',
      FirestorePaths.memberDoc(_familyId, _admin),
      FamilyMappers.memberToMap(owner, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'general'),
      FamilyMappers.generalSettingsMap(family, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'modules'),
      FamilyMappers.modulesMap(family.modules, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'permissions'),
      FamilyMappers.permissionsMap(PermissionSettings.defaults, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'rotationPolicy'),
      FamilyMappers.rotationPolicyMap(meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'notificationDefaults'),
      FamilyMappers.notificationDefaultsMap(meta),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev1'),
      FamilyMappers.eventMap(created),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev1'),
      FamilyMappers.eventMap(created),
    ),
    _write('merge', FirestorePaths.userDoc(_admin), <String, dynamic>{
      'familyId': _familyId,
    }),
  ]);
}

/// P2-06: the complete real starter catalog in the same batch that creates the
/// family.  This proves the actual mapper output fits the rules and stays far
/// below Firestore's 500-write batch limit (9 family docs + 65 catalog + 2 logs).
Map<String, dynamic> _createFamilyCatalog() {
  const family = Family(id: _familyId, name: 'Fix Family');
  final meta = _meta(_admin);
  const owner = Member(
    uid: _admin,
    role: MemberRole.admin,
    status: MembershipStatus.active,
    fullName: 'Fix Admin',
    relationship: 'other',
  );
  final created = AuditEvent(
    id: 'ev11',
    type: 'family.created',
    actorId: _admin,
    summary: 'Family created',
    refType: 'family',
    refId: _familyId,
    at: _at,
    params: const {'familyName': 'Fix Family'},
  );
  return _fixture('create_family_catalog', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.familyDoc(_familyId),
      FamilyMappers.familyDocMap(family, meta),
    ),
    _write(
      'set',
      FirestorePaths.memberDoc(_familyId, _admin),
      FamilyMappers.memberToMap(owner, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'general'),
      FamilyMappers.generalSettingsMap(family, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'modules'),
      FamilyMappers.modulesMap(family.modules, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'permissions'),
      FamilyMappers.permissionsMap(PermissionSettings.defaults, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'relationships'),
      RelationshipMappers.relationshipsMap(RelationshipCatalog.defaults, meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'rotationPolicy'),
      FamilyMappers.rotationPolicyMap(meta),
    ),
    _write(
      'set',
      FirestorePaths.settingsDoc(_familyId, 'notificationDefaults'),
      FamilyMappers.notificationDefaultsMap(meta),
    ),
    _write('merge', FirestorePaths.userDoc(_admin), <String, dynamic>{
      'familyId': _familyId,
    }),
    for (final write in buildDefaultCatalogWrites(
      familyId: _familyId,
      actorUid: _admin,
      now: _at,
    ))
      _write('set', write.path, write.data),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev11'),
      FamilyMappers.eventMap(created),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev11'),
      FamilyMappers.eventMap(created),
    ),
  ]);
}

/// P2-07: the real settings/bazar map plus its two log entries.
Map<String, dynamic> _settingsBazar() {
  final settings = BazarSettings(
    weekStartDay: 1,
    defaultMonthlyContribution: const Money.paisa(500000),
    contributionDueDay: 10,
    alertThresholds: const <int>[70, 90, 100],
    fundStartMonth: MonthKey(2026, 1),
  );
  final event = AuditEvent(
    id: 'ev12',
    type: AuditEventType.bazarSettingsUpdated,
    actorId: _admin,
    refType: AuditRefType.family,
    refId: _familyId,
    at: _at,
  );
  return _fixture('settings_bazar', _admin, <Map<String, dynamic>>[
    _write(
      'merge',
      FirestorePaths.bazarSettingsDoc(_familyId),
      BazarSettingsMappers.toMap(settings, _meta(_admin)),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev12'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev12'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

/// P2-17: the real budget map (a dry-grocery line plus a category estimate) and
/// its two log entries.
Map<String, dynamic> _budget() {
  final budget = Budget(
    month: MonthKey(2026, 10),
    totalEstimate: const Money.paisa(864000),
    categoryEstimates: const <String, Money>{
      'cat_dry_groceries': Money.paisa(350000),
    },
    lines: const <BudgetLine>[
      BudgetLine(
        name: 'Rice',
        plannedQty: Quantity.milli(50000),
        unit: Unit.kg,
        estimatedRate: Money.paisa(7000),
        estimatedTotal: Money.paisa(350000),
        stock: Quantity.milli(5000),
      ),
    ],
  );
  final event = AuditEvent(
    id: 'ev13',
    type: AuditEventType.bazarBudgetSaved,
    actorId: _admin,
    refType: AuditRefType.budget,
    refId: '2026-10',
    at: _at,
    params: const <String, String>{'month': '2026-10', 'amount': '864000'},
  );
  return _fixture('budget', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.budgetDoc(_familyId, '2026-10'),
      BudgetMappers.toMap(budget, _meta(_admin)),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev13'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev13'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

/// P2-10: the real expense/fund/advance maps and their log entries.
final DateKey _day = DateKey(2026, 10, 18);

List<Map<String, dynamic>> _eventWrites(AuditEvent event) =>
    <Map<String, dynamic>>[
      _write(
        'set',
        FirestorePaths.activityDoc(_familyId, event.id),
        FamilyMappers.eventMap(event),
      ),
      _write(
        'set',
        FirestorePaths.auditLogDoc(_familyId, event.id),
        FamilyMappers.eventMap(event),
      ),
    ];

AuditEvent _bazarEvent(
  String id,
  String type,
  String refType,
  String refId, {
  String actor = _member,
}) => AuditEvent(
  id: id,
  type: type,
  actorId: actor,
  refType: refType,
  refId: refId,
  at: _at,
);

Expense _expense(
  String id, {
  Money total = const Money.paisa(12000),
  FundingSource funding = FundingSource.fund,
  bool reimbursable = false,
  String? payer,
  String? tripId,
  DateTime? deletedAt,
  String? deletedBy,
}) => Expense(
  id: id,
  dateKey: _day,
  monthKey: _day.monthKey,
  occurredAt: _at,
  itemId: _itemId,
  itemName: 'Rice',
  categoryId: _categoryId,
  qty: const Quantity.milli(1000),
  unit: Unit.kg,
  unitPrice: const Money.paisa(12000),
  total: total,
  funding: funding,
  paidByMemberId: payer,
  reimbursable: reimbursable,
  purchaserId: _member,
  tripId: tripId,
  shop: 'Bazar',
  source: ExpenseSource.manual,
  deletedAt: deletedAt,
  deletedBy: deletedBy,
  createdBy: _member,
  createdAt: _at,
);

Map<String, dynamic> _expenseFund() {
  final expense = _expense('exp_fix1');
  final row = FundTransaction.forExpense(
    expenseId: expense.id,
    total: expense.total,
    dateKey: expense.dateKey,
    createdBy: _member,
    createdAt: _at,
  );
  final event = _bazarEvent(
    'ev20',
    AuditEventType.bazarExpenseCreated,
    AuditRefType.expense,
    expense.id,
  );
  return _fixture('expense_fund', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.expenseDoc(_familyId, expense.id),
      ExpenseMappers.expenseToMap(expense, _meta(_member)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _expenseMemberAdvance() {
  final expense = _expense(
    'exp_fix2',
    funding: FundingSource.member,
    payer: _member,
    reimbursable: true,
  );
  final advance = MemberAdvance(
    expenseId: expense.id,
    memberId: _member,
    amount: expense.total,
    settled: Money.zero,
    status: AdvanceStatus.pending,
    dateKey: expense.dateKey,
    monthKey: expense.monthKey,
  );
  final event = _bazarEvent(
    'ev21',
    AuditEventType.bazarExpenseCreated,
    AuditRefType.expense,
    expense.id,
  );
  return _fixture('expense_member_advance', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.expenseDoc(_familyId, expense.id),
      ExpenseMappers.expenseToMap(expense, _meta(_member)),
    ),
    _write(
      'set',
      FirestorePaths.memberAdvanceDoc(_familyId, advance.expenseId),
      AdvanceMappers.advanceToMap(advance, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _expensePersonal() {
  final expense = _expense(
    'exp_fix3',
    funding: FundingSource.member,
    payer: _member,
  );
  final event = _bazarEvent(
    'ev22',
    AuditEventType.bazarExpenseCreated,
    AuditRefType.expense,
    expense.id,
  );
  return _fixture('expense_personal', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.expenseDoc(_familyId, expense.id),
      ExpenseMappers.expenseToMap(expense, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _expenseEdit() {
  final updated = _expense('exp_fix4', total: const Money.paisa(15000));
  final event = _bazarEvent(
    'ev23',
    AuditEventType.bazarExpenseUpdated,
    AuditRefType.expense,
    updated.id,
  );
  final row = FundTransaction.adjustment(
    eventId: event.id,
    amount: const Money.paisa(-3000),
    dateKey: _day,
    refType: FundRefType.expense,
    refId: updated.id,
    createdBy: _member,
    createdAt: _at,
  );
  final revision = ExpenseRevision(
    id: event.id,
    before: const <String, Object?>{'itemName': 'Rice', 'totalPaisa': 12000},
    changedFields: const <String>['itemName', 'totalPaisa'],
    at: _at,
    by: _member,
  );
  return _fixture('expense_edit', _member, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.expenseDoc(_familyId, updated.id),
      ExpenseMappers.expenseChangeMap(updated, actorUid: _member, now: _at),
    ),
    _write(
      'set',
      FirestorePaths.expenseRevisionDoc(_familyId, updated.id, event.id),
      ExpenseMappers.revisionToMap(revision, _meta(_member)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _expenseSoftDelete() {
  final expense = _expense('exp_fix5', deletedAt: _at, deletedBy: _member);
  final event = _bazarEvent(
    'ev24',
    AuditEventType.bazarExpenseDeleted,
    AuditRefType.expense,
    expense.id,
  );
  final row = FundTransaction.adjustment(
    eventId: event.id,
    amount: expense.total,
    dateKey: _day,
    refType: FundRefType.expense,
    refId: expense.id,
    createdBy: _member,
    createdAt: _at,
    suffix: 'del',
  );
  final revision = ExpenseRevision(
    id: event.id,
    before: const <String, Object?>{'deletedAt': null, 'deletedBy': null},
    changedFields: const <String>['deletedAt', 'deletedBy'],
    at: _at,
    by: _member,
  );
  return _fixture('expense_soft_delete', _member, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.expenseDoc(_familyId, expense.id),
      ExpenseMappers.expenseSoftDeleteMap(expense, actorUid: _member, now: _at),
    ),
    _write(
      'set',
      FirestorePaths.expenseRevisionDoc(_familyId, expense.id, event.id),
      ExpenseMappers.revisionToMap(revision, _meta(_member)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _expenseRestore() {
  final expense = _expense('exp_fix6');
  final event = _bazarEvent(
    'ev25',
    AuditEventType.bazarExpenseRestored,
    AuditRefType.expense,
    expense.id,
  );
  final row = FundTransaction.adjustment(
    eventId: event.id,
    amount: const Money.paisa(-12000),
    dateKey: _day,
    refType: FundRefType.expense,
    refId: expense.id,
    createdBy: _member,
    createdAt: _at,
    suffix: 'res',
  );
  final revision = ExpenseRevision(
    id: event.id,
    before: <String, Object?>{
      'deletedAt': Timestamp.fromDate(_at),
      'deletedBy': _member,
    },
    changedFields: const <String>['deletedAt', 'deletedBy'],
    at: _at,
    by: _member,
  );
  return _fixture('expense_restore', _member, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.expenseDoc(_familyId, expense.id),
      ExpenseMappers.expenseSoftDeleteMap(expense, actorUid: _member, now: _at),
    ),
    _write(
      'set',
      FirestorePaths.expenseRevisionDoc(_familyId, expense.id, event.id),
      ExpenseMappers.revisionToMap(revision, _meta(_member)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _revision() {
  final revision = ExpenseRevision(
    id: 'ev26',
    before: const <String, Object?>{'note': null},
    changedFields: const <String>['note'],
    reason: 'typo',
    at: _at,
    by: _member,
  );
  return _fixture('revision', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.expenseRevisionDoc(_familyId, 'exp_fix7', revision.id),
      ExpenseMappers.revisionToMap(revision, _meta(_member)),
    ),
  ]);
}

Map<String, dynamic> _trip() {
  final trip = Trip(
    id: 'trip_fix1',
    dateKey: _day,
    monthKey: _day.monthKey,
    shop: 'Bazar',
    funding: FundingSource.fund,
    lineCount: 2,
    total: const Money.paisa(24000),
  );
  final first = _expense('exp_t1', tripId: trip.id);
  final second = _expense('exp_t2', tripId: trip.id);
  final event = _bazarEvent(
    'ev27',
    AuditEventType.bazarTripCreated,
    AuditRefType.trip,
    trip.id,
  );
  final rows = <FundTransaction>[
    for (final line in <Expense>[first, second])
      FundTransaction.forExpense(
        expenseId: line.id,
        total: line.total,
        dateKey: line.dateKey,
        createdBy: _member,
        createdAt: _at,
      ),
  ];
  return _fixture('trip', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.bazarTripDoc(_familyId, trip.id),
      ExpenseMappers.tripToMap(trip, _meta(_member)),
    ),
    for (final line in <Expense>[first, second])
      _write(
        'set',
        FirestorePaths.expenseDoc(_familyId, line.id),
        ExpenseMappers.expenseToMap(line, _meta(_member)),
      ),
    for (final row in rows)
      _write(
        'set',
        FirestorePaths.fundTransactionDoc(_familyId, row.id),
        FundMappers.fundTxToMap(row, _meta(_member)),
      ),
    ..._eventWrites(event),
  ]);
}

Map<String, dynamic> _fundTxExpense() {
  final row = FundTransaction.forExpense(
    expenseId: 'exp_fix8',
    total: const Money.paisa(5000),
    dateKey: _day,
    createdBy: _member,
    createdAt: _at,
  );
  return _fixture('fundtx_expense', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
  ]);
}

Map<String, dynamic> _fundTxContribution() {
  final row = FundTransaction.forContribution(
    contributionId: 'fixC1',
    amount: const Money.paisa(10000),
    dateKey: _day,
    createdBy: _admin,
    createdAt: _at,
  );
  return _fixture('fundtx_contribution', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_admin)),
    ),
  ]);
}

Map<String, dynamic> _fundTxReimbursement() {
  final row = FundTransaction.forReimbursement(
    settlementId: 'fixS1',
    amount: const Money.paisa(5000),
    dateKey: _day,
    createdBy: _admin,
    createdAt: _at,
  );
  return _fixture('fundtx_reimbursement', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_admin)),
    ),
  ]);
}

Map<String, dynamic> _fundTxOpening() {
  final row = FundTransaction.opening(
    monthKey: MonthKey(2026, 10),
    amount: const Money.paisa(50000),
    createdBy: _admin,
    createdAt: _at,
  );
  return _fixture('fundtx_opening', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_admin)),
    ),
  ]);
}

Map<String, dynamic> _fundTxAdjustment() {
  final row = FundTransaction.adjustment(
    eventId: 'ev28',
    amount: const Money.paisa(1000),
    dateKey: _day,
    refType: FundRefType.expense,
    refId: 'exp_fix9',
    createdBy: _member,
    createdAt: _at,
  );
  return _fixture('fundtx_adjustment', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_member)),
    ),
  ]);
}

Map<String, dynamic> _advance() {
  final advance = MemberAdvance(
    expenseId: 'exp_adv1',
    memberId: _member,
    amount: const Money.paisa(8000),
    settled: Money.zero,
    status: AdvanceStatus.pending,
    dateKey: _day,
    monthKey: _day.monthKey,
  );
  return _fixture('advance', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.memberAdvanceDoc(_familyId, advance.expenseId),
      AdvanceMappers.advanceToMap(advance, _meta(_member)),
    ),
  ]);
}

Map<String, dynamic> _settlement() {
  final settlement = Settlement(
    id: 'fixS1',
    advanceId: 'exp_adv2',
    memberId: _member,
    amount: const Money.paisa(3000),
    dateKey: _day,
    monthKey: _day.monthKey,
    fundTxId: 'stl_fixS1',
    method: 'cash',
  );
  final row = FundTransaction.forReimbursement(
    settlementId: settlement.id,
    amount: settlement.amount,
    dateKey: settlement.dateKey,
    createdBy: _admin,
    createdAt: _at,
  );
  return _fixture('settlement', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.settlementDoc(_familyId, settlement.id),
      AdvanceMappers.settlementToMap(settlement, _meta(_admin)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_admin)),
    ),
  ]);
}

Map<String, dynamic> _monthClosing() {
  final closing = MonthClosing(
    monthKey: MonthKey(2026, 10),
    status: MonthStatus.closed,
    closedAt: _at,
    closedBy: _admin,
    closingBalance: const Money.paisa(5000),
  );
  final event = _bazarEvent(
    'ev29',
    AuditEventType.bazarMonthClosed,
    AuditRefType.month,
    '2026-10',
    actor: _admin,
  );
  return _fixture('month_closing', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.monthClosingDoc(_familyId, '2026-10'),
      MonthClosingMappers.closingToMap(closing, _meta(_admin)),
    ),
    ..._eventWrites(event),
  ]);
}

/// P3-08: the REAL `ChoreTemplateMappers.toMap` payload (every optional field
/// set, two slots, two subtasks) plus its audit entry.  `contract.test.mjs`
/// pushes it through `templateOk()`; the maximum-shape case (6 slots, 30
/// subtasks, 4000-character instructions) is covered by
/// `chore_templates.test.mjs`.
Map<String, dynamic> _choreTemplate() {
  final draft = TemplateDraft(
    nameBn: 'থালা-বাসন ধোয়া',
    nameEn: 'Wash the dishes',
    groupId: 'kitchen',
    recurrence: EveryNDaysRecurrence(n: 2, anchor: DateKey(2026, 10, 1)),
    slots: const <TemplateSlot>[
      TemplateSlot(key: 'main', labelBn: 'সকাল', dueMinutes: 540),
      TemplateSlot(key: 'noon', labelBn: 'দুপুর', dueMinutes: 840),
    ],
    assignee: const AssigneeSpec(
      strategy: AssigneeStrategy.fixed,
      fixedMemberId: _member,
    ),
    instructions: '# নিয়ম\n- **সাবধানে** ধোয়া',
    subtasks: const <TemplateSubtask>[
      TemplateSubtask(id: 'rinse', title: 'ধোয়া', required: true),
      TemplateSubtask(id: 'dry', title: 'মুছা', hint: 'গামছা ব্যবহার করুন'),
    ],
    estimatedMinutes: 45,
    difficulty: Difficulty.hard,
    verification: VerificationMode.required,
    reminders: const ReminderConfig(
      enabled: true,
      offsetsMinutes: <int>[10, 30],
      overdueEnabled: true,
      overdueAfterMinutes: 90,
    ),
    startDate: DateKey(2026, 10, 1),
    endDate: DateKey(2027, 3, 31),
    colorIndex: 9,
    iconKey: 'dishes',
  );
  final template = ChoreTemplate(
    id: 'tpl_fixDishes',
    draft: draft,
    sortOrder: 2,
  );
  final event = AuditEvent(
    id: 'ev30',
    type: AuditEventType.choresTemplateCreated,
    actorId: _admin,
    refType: AuditRefType.choreTemplate,
    refId: template.id,
    at: _at,
    params: const <String, String>{'name': 'থালা-বাসন ধোয়া'},
  );
  return _fixture('chore_template', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.choreTemplateDoc(_familyId, template.id),
      ChoreTemplateMappers.toMap(template, _meta(_admin)),
    ),
    ..._eventWrites(event),
  ]);
}

/// P3-10: the REAL `DutyGroupMappers.toMap` payload plus its audit entry.
/// `contract.test.mjs` pushes it through `dutyGroupOk()`; the version-count and
/// roster-size boundaries live in `duty_groups.test.mjs`.
Map<String, dynamic> _dutyGroup() {
  final group = DutyGroup(
    id: 'group_fixKitchen',
    nameBn: 'দৈনিক রান্নাঘর ডিউটি',
    nameEn: 'Daily kitchen duty',
    colorIndex: 3,
    rotation: Rotation(
      versions: <RotationVersion>[
        RotationVersion(
          from: DateKey(2026, 9, 1),
          members: const <String>[_admin, _member, 'fixCara'],
          anchorDate: DateKey(2026, 10, 3),
          anchorIndex: 0,
          cycleUnit: CycleUnit.week,
          weekStartDay: DateTime.saturday,
        ),
      ],
    ),
    sortOrder: 1,
  );
  final event = AuditEvent(
    id: 'ev31',
    type: AuditEventType.choresDutyGroupCreated,
    actorId: _admin,
    refType: AuditRefType.dutyGroup,
    refId: group.id,
    at: _at,
    params: const <String, String>{'name': 'দৈনিক রান্নাঘর ডিউটি'},
  );
  return _fixture('duty_group', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.dutyGroupDoc(_familyId, group.id),
      DutyGroupMappers.toMap(group, _meta(_admin)),
    ),
    ..._eventWrites(event),
  ]);
}

/// P3-13: the REAL `OccurrenceMappers.toMap` payload (two ticks, a cover
/// owner, a verification requirement) plus its completion audit entry.
/// `contract.test.mjs` pushes it through `occurrenceOk()`; the state-machine
/// transitions live in `chore_occurrences.test.mjs`.
Map<String, dynamic> _choreOccurrence() {
  final occurrence = ChoreOccurrence(
    id: 'tpl_fixDishes_20261018',
    templateId: 'tpl_fixDishes',
    templateRev: 3,
    dateKey: _day,
    monthKey: _day.monthKey,
    dueAt: _at,
    dueMinutes: 540,
    nameBn: 'থালা-বাসন ধোয়া',
    nameEn: 'Wash the dishes',
    groupId: 'kitchen',
    instructions: '# নিয়ম\n- **সাবধানে** ধোয়া',
    subtasks: const <TemplateSubtask>[
      TemplateSubtask(id: 'rinse', title: 'ধোয়া', required: true),
      TemplateSubtask(id: 'dry', title: 'মুছা', hint: 'গামছা ব্যবহার করুন'),
    ],
    difficulty: Difficulty.hard,
    estimatedMinutes: 45,
    verification: VerificationMode.required,
    status: OccurrenceStatus.completed,
    plannedAssigneeId: _member,
    assigneeId: 'fixCara',
    coverForId: _member,
    assignmentSource: AssignmentSource.cover,
    subtaskDone: <String, SubtaskDone>{
      'rinse': SubtaskDone(at: _at, by: 'fixCara'),
      'dry': SubtaskDone(at: _at, by: 'fixCara'),
    },
    completedAt: _at,
    completedBy: 'fixCara',
    needsAttention: true,
    lastCommentAt: _at,
  );
  final event = AuditEvent(
    id: 'ev40',
    type: AuditEventType.choresOccurrenceCompleted,
    actorId: 'fixCara',
    refType: AuditRefType.occurrence,
    refId: occurrence.id,
    at: _at,
    params: const <String, String>{
      'name': 'থালা-বাসন ধোয়া',
      'date': '2026-10-18',
      'member': 'fixCara',
    },
  );
  return _fixture('chore_occurrence', 'fixCara', <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.choreOccurrenceDoc(_familyId, occurrence.id),
      // `SubtaskDone.toMap` keeps a raw DateTime, which the JSON encoder
      // cannot serialize; the stored value is a Timestamp, so stamp it here
      // exactly as the repository's `_wire` does.
      _timestampsInGrid(OccurrenceMappers.toMap(occurrence, _meta('fixCara'))),
    ),
    ..._eventWrites(event),
  ]);
}

/// B-04 / B-05: the REAL patch of one "Reopen" on a chore with two ticks
/// (dotted `subtaskDone.<id>` deletions, `redoSubtaskIds`, `lastEventId`) plus
/// the `reopened` event `OccurrenceEventMappers.toMap` writes for it.
///
/// `contract.test.mjs` pushes BOTH through the emulator in one batch, exactly
/// like `OccurrenceWriteStager`: if the rules and the patch ever disagree about
/// the keys, this fails.
Map<String, dynamic> _choreOccurrenceReopen() {
  final reopened = ChoreOccurrence(
    id: 'tpl_fixDishes_20261019',
    templateId: 'tpl_fixDishes',
    templateRev: 3,
    dateKey: DateKey(2026, 10, 19),
    monthKey: DateKey(2026, 10, 19).monthKey,
    dueAt: _at,
    dueMinutes: 540,
    nameBn: 'থালা-বাসন ধোয়া',
    subtasks: const <TemplateSubtask>[
      TemplateSubtask(id: 'rinse', title: 'ধোয়া', required: true),
      TemplateSubtask(id: 'dry', title: 'মুছা'),
    ],
    verification: VerificationMode.off,
    status: OccurrenceStatus.inProgress,
    plannedAssigneeId: _member,
    assigneeId: 'fixCara',
    assignmentSource: AssignmentSource.manual,
    subtaskDone: const <String, SubtaskDone>{},
    reopenCount: 1,
    redoSubtaskIds: const <String>['rinse', 'dry'],
  );
  final event = OccurrenceEvent(
    id: 'reopened_tokfix02',
    occurrenceId: reopened.id,
    type: OccurrenceEventType.reopened,
    actorId: 'fixCara',
    at: _at,
    reason: 'আবার ধুতে হবে',
    prevCompletedAt: _at,
    redoSubtaskIds: const <String>['rinse', 'dry'],
  );
  // The actor is the ADMIN: the rules only release the lock on treads that the
  // completing member can drop, while rule 12 (soft delete/restore) is a
  // manager action.  The patch itself is the real use-case patch.
  return _fixture('chore_occurrence_reopen', _admin, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.choreOccurrenceDoc(_familyId, reopened.id),
      <String, dynamic>{
        'status': reopened.status.id,
        'reopenCount': 1,
        'redoSubtaskIds': const <String>['rinse', 'dry'],
        'lastEventId': event.id,
        'completedAt': null,
        'completedBy': null,
        // The stager's own `FieldValue.delete()` for an unticked step (the
        // fixture format has no marker for it; the JS rehydration turns
        // `__delete` into `deleteField()`).
        'subtaskDone.rinse': <String, dynamic>{'__delete': true},
        'subtaskDone.dry': <String, dynamic>{'__delete': true},
        'updatedAt': BaseMapper.dateTimeToTimestamp(_at),
        'updatedBy': _admin,
      },
    ),
    _write(
      'set',
      FirestorePaths.occurrenceEventDoc(_familyId, reopened.id, event.id),
      // Same event shape the stager writes; only the actor is the manager.
      OccurrenceEventMappers.toMap(
        OccurrenceEvent(
          id: event.id,
          occurrenceId: event.occurrenceId,
          type: event.type,
          actorId: _admin,
          at: _at,
          reason: event.reason,
          prevCompletedAt: _at,
          redoSubtaskIds: event.redoSubtaskIds,
        ),
        _meta(_admin),
      ),
    ),
  ]);
}

/// B-06: the REAL `OccurrenceMappers.restoreMap` payload a resumed template
/// writes over a soft-deleted, never-started day (rule 12 · RESTORE).
Map<String, dynamic> _choreOccurrenceRestore() {
  final draft = ChoreOccurrence(
    id: 'tpl_fixDishes_20261102',
    templateId: 'tpl_fixDishes',
    templateRev: 4,
    dateKey: DateKey(2026, 11, 2),
    monthKey: DateKey(2026, 11, 2).monthKey,
    dueAt: _at,
    dueMinutes: 540,
    nameBn: 'থালা-বাসন ধোয়া',
    subtasks: const <TemplateSubtask>[
      TemplateSubtask(id: 'rinse', title: 'ধোয়া', required: true),
    ],
    verification: VerificationMode.off,
    status: OccurrenceStatus.scheduled,
    plannedAssigneeId: _member,
    assigneeId: _member,
    assignmentSource: AssignmentSource.rotation,
  );
  return _fixture('chore_occurrence_restore', _admin, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.choreOccurrenceDoc(_familyId, draft.id),
      OccurrenceMappers.restoreMap(draft, actorId: _admin, at: _at),
    ),
  ]);
}

/// The `subtaskDone` grid values as Firestore stores them (`Timestamp`, not
/// `DateTime`); the repository's patch path does the same conversion.
Map<String, dynamic> _timestampsInGrid(Map<String, dynamic> map) {
  final grid = map['subtaskDone'];
  if (grid is! Map) return map;
  map['subtaskDone'] = <String, dynamic>{
    for (final entry in grid.entries)
      '${entry.key}': <String, dynamic>{
        for (final field in (entry.value as Map).entries)
          '${field.key}': field.value is DateTime
              ? BaseMapper.dateTimeToTimestamp(field.value as DateTime)
              : field.value,
      },
  };
  return map;
}

Map<String, dynamic> _join() {
  final meta = _meta(_joiner);
  const member = Member(
    uid: _joiner,
    role: MemberRole.member,
    status: MembershipStatus.pending,
    fullName: 'Fix Joiner',
    relationship: 'other',
    inviteCode: _code,
  );
  final requested = AuditEvent(
    id: 'ev2',
    type: 'member.requested',
    actorId: _joiner,
    summary: 'Requested to join',
    refType: 'member',
    refId: _joiner,
    at: _at,
  );
  final used = FamilyMappers.invitationUsedMap(_joiner, _at);
  return _fixture('join', _joiner, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.memberDoc(_familyId, _joiner),
      FamilyMappers.memberToMap(member, meta),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev2'),
      FamilyMappers.eventMap(requested),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev2'),
      FamilyMappers.eventMap(requested),
    ),
    _write('update', FirestorePaths.inviteCodeDoc(_code), used),
    _write('update', FirestorePaths.invitationDoc(_familyId, _code), used),
    _write('merge', FirestorePaths.userDoc(_joiner), <String, dynamic>{
      'familyId': _familyId,
    }),
  ]);
}

Map<String, dynamic> _approve() {
  const member = Member(
    uid: _joiner,
    role: MemberRole.member,
    status: MembershipStatus.active,
    fullName: 'Fix Joiner',
    relationship: 'other',
  );
  final event = AuditEvent(
    id: 'ev3',
    type: 'member.approved',
    actorId: _admin,
    summary: 'Approved',
    refType: 'member',
    refId: _joiner,
    at: _at,
    params: const {'memberName': 'Fix Joiner'},
  );
  return _fixture('approve', _admin, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.memberDoc(_familyId, _joiner),
      FamilyMappers.memberChangeMap(member, actorUid: _admin, now: _at),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev3'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev3'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

Map<String, dynamic> _roleChange() {
  const member = Member(
    uid: _joiner,
    role: MemberRole.moderator,
    status: MembershipStatus.active,
    fullName: 'Fix Joiner',
    relationship: 'other',
  );
  final event = AuditEvent(
    id: 'ev4',
    type: 'member.role_changed',
    actorId: _admin,
    summary: 'Role changed',
    refType: 'member',
    refId: _joiner,
    at: _at,
    params: const {'memberName': 'Fix Joiner', 'newRole': 'moderator'},
  );
  return _fixture('role_change', _admin, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.memberDoc(_familyId, _joiner),
      FamilyMappers.memberChangeMap(member, actorUid: _admin, now: _at),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev4'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev4'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

/// H6: handing the admin role over rewrites both members AND `adminIds` in one
/// batch, exactly like `TransferAdmin`.
Map<String, dynamic> _transferAdmin() {
  const newAdmin = Member(
    uid: _joiner,
    role: MemberRole.admin,
    status: MembershipStatus.active,
    fullName: 'Fix Joiner',
    relationship: 'other',
  );
  const oldAdmin = Member(
    uid: _admin,
    role: MemberRole.member,
    status: MembershipStatus.active,
    fullName: 'Fix Admin',
    relationship: 'other',
  );
  final event = AuditEvent(
    id: 'ev7',
    type: 'member.admin_transferred',
    actorId: _admin,
    summary: 'Admin role moved',
    refType: 'member',
    refId: _joiner,
    at: _at,
    params: const {'memberName': 'Fix Joiner'},
  );
  return _fixture('transfer_admin', _admin, <Map<String, dynamic>>[
    _write(
      'update',
      FirestorePaths.memberDoc(_familyId, _joiner),
      FamilyMappers.memberChangeMap(newAdmin, actorUid: _admin, now: _at),
    ),
    _write(
      'update',
      FirestorePaths.memberDoc(_familyId, _admin),
      FamilyMappers.memberChangeMap(oldAdmin, actorUid: _admin, now: _at),
    ),
    _write(
      'update',
      FirestorePaths.familyDoc(_familyId),
      FamilyMappers.familyAdminIdsMap(
        <String>[_joiner],
        actorUid: _admin,
        now: _at,
      ),
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev7'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev7'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

Map<String, dynamic> _createInvitation() {
  final invitation = Invitation(
    code: _newCode,
    familyId: _familyId,
    role: MemberRole.member,
    expiresAt: _at.add(const Duration(days: 7)),
    createdBy: _admin,
    createdAt: _at,
  );
  final event = AuditEvent(
    id: 'ev5',
    type: 'invitation.created',
    actorId: _admin,
    summary: 'Invitation created',
    refType: 'invitation',
    refId: _newCode,
    at: _at,
  );
  final data = FamilyMappers.invitationToMap(invitation);
  return _fixture('create_invitation', _admin, <Map<String, dynamic>>[
    _write('set', FirestorePaths.inviteCodeDoc(_newCode), data),
    _write('set', FirestorePaths.invitationDoc(_familyId, _newCode), data),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev5'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev5'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

Map<String, dynamic> _revokeInvitation() {
  final revoked = FamilyMappers.invitationRevokedMap(_admin, _at);
  final event = AuditEvent(
    id: 'ev6',
    type: 'invitation.revoked',
    actorId: _admin,
    summary: 'Invitation revoked',
    refType: 'invitation',
    refId: _code,
    at: _at,
  );
  return _fixture('revoke_invitation', _admin, <Map<String, dynamic>>[
    _write('update', FirestorePaths.inviteCodeDoc(_code), revoked),
    _write('update', FirestorePaths.invitationDoc(_familyId, _code), revoked),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev6'),
      FamilyMappers.eventMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev6'),
      FamilyMappers.eventMap(event),
    ),
  ]);
}

Map<String, dynamic> _profile() {
  const profile = UserProfile(
    uid: _joiner,
    fullName: 'Fix Joiner',
    relationship: RelationshipId.other,
  );
  final stamp = BaseMapper.dateTimeToTimestamp(_at);
  return _fixture('profile', _joiner, <Map<String, dynamic>>[
    _write('merge', FirestorePaths.userDoc(_joiner), <String, dynamic>{
      ...FirestoreProfileRepository.profileToMap(profile),
      BaseMapper.keyUpdatedAt: stamp,
      BaseMapper.keyUpdatedBy: _joiner,
      BaseMapper.keyCreatedAt: stamp,
      BaseMapper.keyCreatedBy: _joiner,
      BaseMapper.keySchemaVersion: 1,
    }),
  ]);
}

Map<String, dynamic> _category() {
  const category = Category(
    id: _categoryId,
    nameBn: 'মুদি',
    nameEn: 'Staples',
    colorIndex: 2,
    emoji: '🌾',
    sortOrder: 0,
    builtIn: true,
    seedKey: 'staples',
  );
  final event = AuditEvent(
    id: 'ev8',
    type: AuditEventType.bazarCategoryCreated,
    actorId: _admin,
    refType: AuditRefType.category,
    refId: _categoryId,
    at: _at,
    params: const {'name': 'মুদি'},
  );
  final data = CatalogMappers.categoryToMap(category, _meta(_admin));
  return _fixture('category', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.bazarCategoryDoc(_familyId, _categoryId),
      data,
    ),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev8'),
      AuditWriter.toMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev8'),
      AuditWriter.toMap(event),
    ),
  ]);
}

Map<String, dynamic> _item() {
  final item = Item(
    id: _itemId,
    nameBn: 'চাল',
    nameEn: 'Rice',
    categoryId: _categoryId,
    defaultUnit: Unit.kg,
    aliases: const <String>['rice', 'chal'],
    emoji: '🍚',
    useCount: 2,
    lastPrice: const Money.paisa(12500),
    lastUnitPrice: const Money.paisa(6500),
    lastUsedAt: _at,
    builtIn: true,
    seedKey: 'rice',
  );
  final event = AuditEvent(
    id: 'ev9',
    type: AuditEventType.bazarItemCreated,
    actorId: _admin,
    refType: AuditRefType.item,
    refId: _itemId,
    at: _at,
    params: const {'name': 'চাল'},
  );
  final data = CatalogMappers.itemToMap(item, _meta(_admin));
  return _fixture('item', _admin, <Map<String, dynamic>>[
    _write('set', FirestorePaths.bazarItemDoc(_familyId, _itemId), data),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev9'),
      AuditWriter.toMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev9'),
      AuditWriter.toMap(event),
    ),
  ]);
}

/// A member's purchase bump.  `itemUsageMap` stages `useCount` as an increment;
/// the fixture encoder writes the equivalent `{"__increment": 1}` marker.
Map<String, dynamic> _itemUsage() {
  final bump = ItemUsageBump(
    itemId: _itemId,
    increments: 1,
    lastPrice: const Money.paisa(13000),
    lastUnitPrice: const Money.paisa(6500),
    at: _at,
  );
  final usage = <String, dynamic>{
    ...CatalogMappers.itemUsageMap(bump, actorUid: _member, now: _at),
    'useCount': const _Increment(1),
  };
  final event = AuditEvent(
    id: 'ev10',
    type: AuditEventType.bazarExpenseCreated,
    actorId: _member,
    refType: AuditRefType.expense,
    refId: 'exp1',
    at: _at,
    params: const {'item': 'চাল', 'amount': '13000', 'funding': 'fund'},
  );
  return _fixture('item_usage', _member, <Map<String, dynamic>>[
    _write('update', FirestorePaths.bazarItemDoc(_familyId, _itemId), usage),
    _write(
      'set',
      FirestorePaths.activityDoc(_familyId, 'ev10'),
      AuditWriter.toMap(event),
    ),
    _write(
      'set',
      FirestorePaths.auditLogDoc(_familyId, 'ev10'),
      AuditWriter.toMap(event),
    ),
  ]);
}

/// JSON-friendly: Timestamp -> `{"__ts": iso}`, ServerTime -> `{"__serverTime": true}`.
Object? _toJson(Object? value) {
  if (value is Timestamp) {
    return <String, dynamic>{'__ts': value.toDate().toUtc().toIso8601String()};
  }
  if (value is ServerTime) {
    return <String, dynamic>{'__serverTime': true};
  }
  if (value is _Increment) {
    return <String, dynamic>{'__increment': value.value};
  }
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _toJson(entry.value),
    };
  }
  if (value is List) {
    return value.map(_toJson).toList();
  }
  return value;
}

/// A `FieldValue.increment(n)` marker for the JSON fixture encoder.
final class _Increment {
  const _Increment(this.value);

  final int value;
}

/// P2-19: a member's own pending request (no ledger row) and its log entries.
Map<String, dynamic> _contributionRequest() {
  final contribution = Contribution(
    id: 'fixCon1',
    memberId: _member,
    monthKey: _day.monthKey,
    dateKey: _day,
    amount: const Money.paisa(100000),
    method: ContributionMethod.bkash,
    note: 'Monthly share',
    status: ContributionApproval.pending,
    requestedBy: _member,
    createdAt: _at,
  );
  final event = _bazarEvent(
    'ev30',
    AuditEventType.bazarContributionRequested,
    AuditRefType.contribution,
    'fixCon1',
  );
  return _fixture('contribution_request', _member, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.contributionDoc(_familyId, 'fixCon1'),
      ContributionMappers.toMap(contribution, _meta(_member)),
    ),
    ..._eventWrites(event),
  ]);
}

/// P2-19: a manager's record: the approved contribution and its `con_` row in
/// ONE batch.
Map<String, dynamic> _contributionRecorded() {
  final contribution = Contribution(
    id: 'fixCon2',
    memberId: _member,
    monthKey: _day.monthKey,
    dateKey: _day,
    amount: const Money.paisa(100000),
    status: ContributionApproval.approved,
    requestedBy: _admin,
    createdAt: _at,
    fundTxId: 'con_fixCon2',
    decidedBy: _admin,
    decidedAt: _at,
  );
  final row = FundTransaction.forContribution(
    contributionId: 'fixCon2',
    amount: const Money.paisa(100000),
    dateKey: _day,
    createdBy: _admin,
    createdAt: _at,
  );
  final event = _bazarEvent(
    'ev31',
    AuditEventType.bazarContributionRecorded,
    AuditRefType.contribution,
    'fixCon2',
    actor: _admin,
  );
  return _fixture('contribution_recorded', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.contributionDoc(_familyId, 'fixCon2'),
      ContributionMappers.toMap(contribution, _meta(_admin)),
    ),
    _write(
      'set',
      FirestorePaths.fundTransactionDoc(_familyId, row.id),
      FundMappers.fundTxToMap(row, _meta(_admin)),
    ),
    ..._eventWrites(event),
  ]);
}

/// P2-19: the generated equal-split plans.
Map<String, dynamic> _contributionPlan() {
  final plan = ContributionPlan(
    month: _day.monthKey,
    memberId: _member,
    expected: const Money.paisa(166700),
  );
  final event = _bazarEvent(
    'ev32',
    AuditEventType.bazarContributionPlanSet,
    AuditRefType.contributionPlan,
    plan.id,
    actor: _admin,
  );
  return _fixture('contribution_plan', _admin, <Map<String, dynamic>>[
    _write(
      'set',
      FirestorePaths.contributionPlanDoc(_familyId, plan.id),
      ContributionMappers.planToMap(plan, _meta(_admin)),
    ),
    ..._eventWrites(event),
  ]);
}
