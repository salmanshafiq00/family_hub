import 'package:family_hub/features/family/data/relationship_mappers.dart';
import 'package:family_hub/core/firebase/base_mapper.dart';
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
import 'package:family_hub/features/bazar/items_categories/domain/category.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item.dart';
import 'package:family_hub/features/bazar/items_categories/domain/item_usage_bump.dart';
import 'package:family_hub/features/bazar/settings/data/bazar_settings_mappers.dart';
import 'package:family_hub/features/bazar/settings/domain/bazar_settings.dart';
import 'package:family_hub/features/chores/settings/data/chore_settings_mappers.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/family/data/family_mappers.dart';
import 'package:family_hub/features/family/domain/family.dart';
import 'package:family_hub/core/audit/audit_event.dart';
import 'package:family_hub/features/family/domain/invitation.dart';
import 'package:family_hub/features/family/domain/member.dart';
import 'package:family_hub/features/family/domain/member_role.dart';
import 'package:family_hub/features/family/domain/membership.dart';
import 'package:family_hub/features/family/domain/module_flags.dart';
import 'package:family_hub/features/family/domain/relationship_catalog.dart';
import 'package:family_hub/features/dashboard/domain/card_access.dart';
import 'package:family_hub/features/dashboard/data/dashboard_policy_mappers.dart';
import 'package:family_hub/features/dashboard/domain/dashboard_policy.dart';
import 'package:family_hub/features/notifications/data/delivery_mappers.dart';
import 'package:family_hub/features/notifications/data/notification_defaults_mappers.dart';
import 'package:family_hub/features/notifications/domain/notification_defaults.dart';
import 'package:family_hub/features/notifications/domain/notification_delivery_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/rules_source.dart';

/// H5: the closed key sets live in the rules as `*Keys()` functions; every key a
/// real mapper can produce must be in the matching list.  A mapper change that
/// is not reflected in the rules (or vice versa) fails here.
void main() {
  final meta = BaseMapper.createMetadata(
    uid: 'u1',
    clock: FakeClock(DateTime.utc(2026, 10, 18)),
  );

  test('memberToMap keys == memberKeys()', () {
    const m = Member(
      uid: 'u1',
      role: MemberRole.member,
      status: MembershipStatus.pending,
      fullName: 'Karim',
      relationship: 'other',
      inviteCode: 'ABCD2345',
    );
    expect(
      FamilyMappers.memberToMap(m, meta).keys.toSet(),
      rulesList('memberKeys'),
    );
  });

  test('familyDocMap keys == familyKeys()', () {
    const family = Family(id: 'f1', name: 'Family');
    expect(
      FamilyMappers.familyDocMap(family, meta).keys.toSet(),
      rulesList('familyKeys'),
    );
  });

  test('invitationToMap keys == invitationKeys()', () {
    final invitation = Invitation(
      code: 'ABCD2345',
      familyId: 'f1',
      role: MemberRole.member,
      expiresAt: DateTime.utc(2026, 10, 25),
      createdBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 18),
    );
    expect(
      FamilyMappers.invitationToMap(invitation).keys.toSet(),
      rulesList('invitationKeys'),
    );
  });

  test('settings maps together cover settingsKeys()', () {
    const family = Family(id: 'f1', name: 'Family');
    final produced = <String>{
      ...FamilyMappers.generalSettingsMap(family, meta).keys,
      ...FamilyMappers.modulesMap(ModuleFlags.allOn, meta).keys,
      ...FamilyMappers.permissionsMap(PermissionSettings.defaults, meta).keys,
      ...RelationshipMappers.relationshipsMap(
        RelationshipCatalog.defaults,
        meta,
      ).keys,
      ...FamilyMappers.rotationPolicyMap(meta).keys,
      ...FamilyMappers.notificationDefaultsMap(meta).keys,
      ...NotificationDefaultsMappers.toMap(
        NotificationDefaults.defaults,
        meta,
      ).keys,
      ...DeliveryMappers.toMap(
        NotificationDeliverySettings.defaults(),
        meta,
      ).keys,
      ...BazarSettingsMappers.toMap(BazarSettings.defaults, meta).keys,
      // P3-06: settings/chores and settings/choreGeneration.
      ...ChoreSettingsMappers.toMap(ChoreSettings.defaults, meta).keys,
      'throughEpochDay',
      ...DashboardPolicyMappers.policyToMap(
        DashboardPolicy(
          roles: <Role, Map<String, CardAccess>>{
            Role.member: <String, CardAccess>{
              'chores_today': CardAccess.required,
            },
          },
        ),
        meta,
      ).keys,
    };
    expect(produced, rulesList('settingsKeys'));
  });

  test('notification defaults mapper keys == notificationDefaultsKeys()', () {
    expect(
      NotificationDefaultsMappers.toMap(
        NotificationDefaults.defaults,
        meta,
      ).keys.toSet(),
      rulesList('notificationDefaultsKeys'),
    );
  });

  test('delivery mapper keys == notificationDeliveryKeys()', () {
    expect(
      DeliveryMappers.toMap(
        NotificationDeliverySettings.defaults(),
        meta,
      ).keys.toSet(),
      rulesList('notificationDeliveryKeys'),
    );
  });

  test('eventMap keys == eventKeys()', () {
    final event = AuditEvent(
      id: 'e1',
      type: 'family.created',
      actorId: 'u1',
      summary: 'created',
      refType: 'family',
      refId: 'f1',
      at: DateTime.utc(2026, 10, 18),
      params: const {'familyName': 'Family'},
    );
    expect(FamilyMappers.eventMap(event).keys.toSet(), rulesList('eventKeys'));
  });

  test('categoryToMap keys == categoryKeys()', () {
    const category = Category(
      id: 'c1',
      nameBn: 'মুদি',
      nameEn: 'Staples',
      colorIndex: 2,
      emoji: '🌾',
      imageData: 'abc',
      sortOrder: 0,
      builtIn: true,
      seedKey: 'staples',
    );
    expect(
      CatalogMappers.categoryToMap(category, meta).keys.toSet(),
      rulesList('categoryKeys'),
    );
  });

  test('itemToMap keys == itemKeys()', () {
    final item = Item(
      id: 'i1',
      nameBn: 'চাল',
      nameEn: 'Rice',
      categoryId: 'c1',
      defaultUnit: Unit.kg,
      aliases: const <String>['rice'],
      emoji: '🍚',
      imageData: 'abc',
      useCount: 2,
      lastPrice: const Money.paisa(12500),
      lastUnitPrice: const Money.paisa(6500),
      lastUsedAt: DateTime.utc(2026, 10, 18, 9),
      builtIn: true,
      seedKey: 'rice',
    );
    expect(
      CatalogMappers.itemToMap(item, meta).keys.toSet(),
      rulesList('itemKeys'),
    );
  });

  test('itemUsageMap keys stay inside itemKeys()', () {
    final bump = ItemUsageBump(
      itemId: 'i1',
      increments: 1,
      lastPrice: const Money.paisa(12500),
      lastUnitPrice: const Money.paisa(6500),
      at: DateTime.utc(2026, 10, 18, 9),
    );
    final keys = CatalogMappers.itemUsageMap(
      bump,
      actorUid: 'u1',
      now: DateTime.utc(2026, 10, 18, 9),
    ).keys.toSet();
    expect(rulesList('itemKeys').containsAll(keys), isTrue);
  });

  test('budgetToMap keys == budgetKeys()', () {
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
        ),
      ],
    );
    expect(
      BudgetMappers.toMap(budget, meta).keys.toSet(),
      rulesList('budgetKeys'),
    );
  });

  test('expenseToMap keys == expenseKeys()', () {
    final expense = Expense(
      id: 'e1',
      dateKey: DateKey(2026, 10, 18),
      monthKey: MonthKey(2026, 10),
      occurredAt: DateTime.utc(2026, 10, 18, 9),
      itemId: 'i1',
      itemName: 'Rice',
      categoryId: 'c1',
      qty: const Quantity.milli(1000),
      unit: Unit.kg,
      unitPrice: const Money.paisa(6000),
      total: const Money.paisa(6000),
      funding: FundingSource.member,
      paidByMemberId: 'u1',
      reimbursable: true,
      purchaserId: 'u1',
      tripId: 't1',
      shop: 'Bazar',
      note: 'note',
      importBatchId: 'ib1',
      createdBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 18, 9),
    );
    expect(
      ExpenseMappers.expenseToMap(expense, meta).keys.toSet(),
      rulesList('expenseKeys'),
    );
  });

  test(
    'expenseChangeMap and expenseSoftDeleteMap stay inside expenseKeys()',
    () {
      final expense = Expense(
        id: 'e1',
        dateKey: DateKey(2026, 10, 18),
        monthKey: MonthKey(2026, 10),
        occurredAt: DateTime.utc(2026, 10, 18, 9),
        itemName: 'Rice',
        categoryId: 'c1',
        total: const Money.paisa(6000),
        funding: FundingSource.fund,
        createdBy: 'u1',
        createdAt: DateTime.utc(2026, 10, 18, 9),
      );
      final allowed = rulesList('expenseKeys');
      expect(
        allowed.containsAll(
          ExpenseMappers.expenseChangeMap(
            expense,
            actorUid: 'u1',
            now: DateTime.utc(2026, 10, 18, 9),
          ).keys,
        ),
        isTrue,
      );
      expect(
        allowed.containsAll(
          ExpenseMappers.expenseSoftDeleteMap(
            expense,
            actorUid: 'u1',
            now: DateTime.utc(2026, 10, 18, 9),
          ).keys,
        ),
        isTrue,
      );
    },
  );

  test('revisionToMap keys == revisionKeys()', () {
    final revision = ExpenseRevision(
      id: 'r1',
      before: const <String, Object?>{'itemName': 'Rice'},
      changedFields: const <String>['itemName'],
      reason: 'typo',
      at: DateTime.utc(2026, 10, 18, 9),
      by: 'u1',
    );
    expect(
      ExpenseMappers.revisionToMap(revision, meta).keys.toSet(),
      rulesList('revisionKeys'),
    );
  });

  test('tripToMap keys == tripKeys()', () {
    final trip = Trip(
      id: 't1',
      dateKey: DateKey(2026, 10, 18),
      monthKey: MonthKey(2026, 10),
      shop: 'Bazar',
      funding: FundingSource.fund,
      lineCount: 2,
      total: const Money.paisa(6000),
      note: 'note',
    );
    expect(
      ExpenseMappers.tripToMap(trip, meta).keys.toSet(),
      rulesList('tripKeys'),
    );
  });

  test('fundTxToMap keys == fundTxKeys()', () {
    final row = FundTransaction.forExpense(
      expenseId: 'e1',
      total: const Money.paisa(6000),
      dateKey: DateKey(2026, 10, 18),
      createdBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 18, 9),
      note: 'note',
    );
    expect(
      FundMappers.fundTxToMap(row, meta).keys.toSet(),
      rulesList('fundTxKeys'),
    );
  });

  test('closingToMap keys == closingKeys()', () {
    final closing = MonthClosing(
      monthKey: MonthKey(2026, 10),
      status: MonthStatus.closed,
      closedAt: DateTime.utc(2026, 10, 18, 9),
      closedBy: 'u1',
      closingBalance: const Money.paisa(6000),
      reopenedAt: DateTime.utc(2026, 10, 18, 10),
      reopenedBy: 'u1',
      reopenNote: 'note',
      reopenCount: 1,
    );
    expect(
      MonthClosingMappers.closingToMap(closing, meta).keys.toSet(),
      rulesList('closingKeys'),
    );
  });

  test('advanceToMap keys == advanceKeys()', () {
    final advance = MemberAdvance(
      expenseId: 'e1',
      memberId: 'u1',
      amount: const Money.paisa(6000),
      settled: Money.zero,
      status: AdvanceStatus.pending,
      dateKey: DateKey(2026, 10, 18),
      monthKey: MonthKey(2026, 10),
    );
    expect(
      AdvanceMappers.advanceToMap(advance, meta).keys.toSet(),
      rulesList('advanceKeys'),
    );
    expect(
      rulesList('advanceKeys').containsAll(
        AdvanceMappers.advanceChangeMap(
          advance,
          actorUid: 'u1',
          now: DateTime.utc(2026, 10, 18, 9),
        ).keys,
      ),
      isTrue,
    );
  });

  test('settlementToMap keys == settlementKeys()', () {
    final settlement = Settlement(
      id: 's1',
      advanceId: 'e1',
      memberId: 'u1',
      amount: const Money.paisa(3000),
      dateKey: DateKey(2026, 10, 18),
      monthKey: MonthKey(2026, 10),
      fundTxId: 'stl_s1',
      method: 'cash',
      note: 'note',
    );
    expect(
      AdvanceMappers.settlementToMap(settlement, meta).keys.toSet(),
      rulesList('settlementKeys'),
    );
  });

  test('contribution toMap keys == contributionKeys()', () {
    final full = Contribution(
      id: 'c1',
      memberId: 'u1',
      monthKey: MonthKey(2026, 10),
      dateKey: DateKey(2026, 10, 5),
      amount: const Money.paisa(100000),
      method: ContributionMethod.cash,
      note: 'n',
      status: ContributionApproval.approved,
      requestedBy: 'u1',
      createdAt: DateTime.utc(2026, 10, 5),
      fundTxId: 'con_c1',
      decidedBy: 'u2',
      decidedAt: DateTime.utc(2026, 10, 5),
      rejectReason: 'r',
      pendingChange: ContributionChange(
        amount: const Money.paisa(1),
        date: DateKey(2026, 10, 6),
        requestedAt: DateTime.utc(2026, 10, 6),
      ),
      voidedAt: DateTime.utc(2026, 10, 7),
      voidedBy: 'u2',
    );
    expect(
      ContributionMappers.toMap(full, meta).keys.toSet(),
      rulesList('contributionKeys'),
    );
  });

  test('contribution plan toMap keys == contributionPlanKeys()', () {
    final plan = ContributionPlan(
      month: MonthKey(2026, 10),
      memberId: 'u1',
      expected: const Money.paisa(100),
    );
    expect(
      ContributionMappers.planToMap(plan, meta).keys.toSet(),
      rulesList('contributionPlanKeys'),
    );
  });
}
