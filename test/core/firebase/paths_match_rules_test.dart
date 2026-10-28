import 'package:family_hub/core/firebase/firestore_paths.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/rules_source.dart';

/// H12: the collection names used by `FirestorePaths` and the `match` lines of
/// `firestore.rules` must agree, so a renamed collection can never silently fall
/// into the rules' default-deny.
///
/// Phase 2 collections are listed in `FirestorePaths` before their rules exist
/// (they are denied by default until their step adds rules + tests); they are
/// the only paths allowed to be missing from the rules.
void main() {
  // Collections whose rules arrive in Phase 2/3 (CLAUDE.md: the step that adds
  // a collection extends the rules in the same commit and removes it here).
  const pending = <String>{
    FirestorePaths.choreOccurrencesSubcollection,
    FirestorePaths.memberAvailabilitySubcollection,
    FirestorePaths.swapRequestsSubcollection,
    FirestorePaths.notificationInboxSubcollection,
    FirestorePaths.memberStatsSubcollection,
    FirestorePaths.importBatchesSubcollection,
  };

  late Set<String> matched;

  setUpAll(() {
    matched = RegExp(r'match\s+/([A-Za-z]+)/\{')
        .allMatches(rulesSource())
        .map((m) => m.group(1)!)
        .toSet();
  });

  test('every implemented collection has a match block', () {
    const implemented = <String>[
      FirestorePaths.usersCollection,
      FirestorePaths.familiesCollection,
      FirestorePaths.inviteCodesCollection,
      FirestorePaths.membersSubcollection,
      FirestorePaths.settingsSubcollection,
      FirestorePaths.invitationsSubcollection,
      FirestorePaths.activitySubcollection,
      FirestorePaths.auditLogsSubcollection,
      FirestorePaths.bazarCategoriesSubcollection,
      FirestorePaths.bazarItemsSubcollection,
      FirestorePaths.budgetsSubcollection,
      FirestorePaths.expensesSubcollection,
      FirestorePaths.bazarTripsSubcollection,
      FirestorePaths.fundTransactionsSubcollection,
      FirestorePaths.memberAdvancesSubcollection,
      FirestorePaths.settlementsSubcollection,
      FirestorePaths.monthClosingsSubcollection,
      FirestorePaths.contributionsSubcollection,
      FirestorePaths.contributionPlansSubcollection,
      FirestorePaths.choreTemplatesSubcollection,
      FirestorePaths.dutyGroupsSubcollection,
    ];
    for (final name in implemented) {
      expect(matched, contains(name), reason: 'rules lack match /$name/');
    }
  });

  test('a collection with rules is no longer listed as pending', () {
    expect(pending.intersection(matched), isEmpty);
  });
}
