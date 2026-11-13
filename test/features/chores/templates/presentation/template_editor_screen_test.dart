import 'package:family_hub/core/localization/app_formatters.dart';
import 'package:family_hub/core/localization/generated/app_localizations_bn.dart';
import 'package:family_hub/core/localization/generated/app_localizations_en.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/chores/settings/domain/chore_catalog_entries.dart';
import 'package:family_hub/features/chores/settings/domain/chore_settings.dart';
import 'package:family_hub/features/chores/templates/domain/chore_template.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence.dart';
import 'package:family_hub/features/chores/templates/domain/recurrence/recurrence_describe.dart';
import 'package:family_hub/features/chores/templates/domain/template_parts.dart';
import 'package:family_hub/features/chores/templates/domain/usecases/create_template.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_controller.dart';
import 'package:family_hub/features/chores/templates/presentation/template_editor_screen.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/recurrence_summary_text.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/slots_editor.dart';
import 'package:family_hub/features/chores/templates/presentation/widgets/subtasks_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../chores_test_helpers.dart';
import '../../presentation/chores_p3_15_support.dart';

/// P3-16: the template editor screen against the in-memory chores backend.
void main() {
  const familyId = ChoresFixture.familyId;

  /// The screen is pushed, not the home route, so a successful save can pop.
  Widget pushed({String? templateId}) => Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TemplateEditorScreen(templateId: templateId),
            ),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    await tester.scrollUntilVisible(
      target,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey<String>('editor_next')));
    await tester.pumpAndSettle();
  }

  /// Walks the wizard to [step] (0 = Basics, 3 = the last one).
  Future<void> goToStep(WidgetTester tester, int step) async {
    for (var i = 0; i < step; i++) {
      await next(tester);
    }
  }

  Future<ChoreTemplate> seed(
    ChoresFixture fixture, {
    TemplateDraft? draft,
  }) async {
    final create = CreateTemplate(
      templates: fixture.chores,
      families: fixture.families,
      clock: fixture.clock,
      newId: fixture.ids.call,
    );
    final result = await create(
      actorUid: 'alice',
      familyId: familyId,
      draft: draft ?? aTemplate(),
    );
    return result.valueOrNull!;
  }

  Future<void> tapSave(WidgetTester tester) async {
    // Save lives on the last step; walk forward until it is reached.
    while (find
        .byKey(const ValueKey<String>('editor_next'))
        .evaluate()
        .isNotEmpty) {
      await next(tester);
    }
    // enterText does not pump, and an unchanged draft keeps the button
    // disabled: without this frame the tap lands on a dead button.
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey<String>('editor_save')));
    await tester.pumpAndSettle();
  }

  testWidgets('a plain member cannot open the editor', (tester) async {
    await pumpP3Screen(tester, home: pushed());
    await open(tester);

    expect(
      find.text(AppLocalizationsEn().choreTemplatesNotAllowed),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey<String>('editor_save')), findsNothing);
  });

  testWidgets('the wizard moves between steps and keeps typed values', (
    tester,
  ) async {
    await pumpP3Screen(tester, role: Role.admin, uid: 'alice', home: pushed());
    await open(tester);
    final en = AppLocalizationsEn();

    expect(find.text(en.choreEditorStepOf('1', '4')), findsOneWidget);
    expect(find.text(en.choreEditorSectionBasics), findsOneWidget);
    expect(find.text(en.choreEditorSectionSchedule), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey<String>('name_bn')),
      'জল দেওয়া',
    );
    await next(tester);

    expect(find.text(en.choreEditorStepOf('2', '4')), findsOneWidget);
    expect(find.text(en.choreEditorSectionSchedule), findsOneWidget);
    expect(find.text(en.choreEditorSectionBasics), findsNothing);

    await tester.tap(find.byKey(const ValueKey<String>('editor_back')));
    await tester.pumpAndSettle();

    expect(find.text(en.choreEditorStepOf('1', '4')), findsOneWidget);
    expect(find.text('জল দেওয়া'), findsOneWidget);
  });

  testWidgets('creates a daily chore with three times a day', (tester) async {
    final fixture = await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: pushed(),
    );
    await open(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('name_bn')),
      'ওষুধ খাওয়ানো',
    );
    await goToStep(tester, 1);
    final add = find.byKey(const ValueKey<String>('slot_add'));
    final label2 = find.byKey(const ValueKey<String>('slot_label_s2'));
    final label3 = find.byKey(const ValueKey<String>('slot_label_s3'));
    await scrollTo(tester, add);
    // Every step settles before the next: the editor's buttons write the slot
    // list they were built with, so a tap in an unpainted frame would drop the
    // text typed a moment earlier.
    await tester.tap(add);
    await tester.pumpAndSettle();
    // A second slot needs a label (template_validator_test asserts the rule),
    // so the editor asks for one before it will save.
    await scrollTo(tester, label2);
    await tester.enterText(label2, 'দুপুর');
    await tester.pumpAndSettle();
    await scrollTo(tester, add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    await scrollTo(tester, label3);
    await tester.enterText(label3, 'সন্ধ্যা');
    await tester.pumpAndSettle();

    await tapSave(tester);

    final stored = fixture.chores.templates[familyId]!.values.single;
    expect(stored.draft.nameBn, 'ওষুধ খাওয়ানো');
    expect(stored.draft.slots, hasLength(3));
    expect(
      stored.draft.slots.map((s) => s.key).toSet(),
      hasLength(3),
      reason: 'slot keys are unique',
    );
    expect(stored.draft.slots.first.key, TemplateLimits.mainSlotKey);
  });

  testWidgets('an empty name is refused with a localized message', (
    tester,
  ) async {
    final fixture = await pumpP3Screen(
      tester,
      role: Role.admin,
      uid: 'alice',
      home: pushed(),
    );
    await open(tester);

    await tapSave(tester);

    expect(
      find.text(AppLocalizationsEn().choresFailure_required),
      findsOneWidget,
    );
    expect(fixture.chores.templates[familyId] ?? const {}, isEmpty);
  });

  for (final scope in <String>[
    'replan_future_only',
    'replan_include_upcoming',
  ]) {
    testWidgets('editing asks for the replan scope ($scope)', (tester) async {
      final fixture = ChoresFixture();
      final template = await seed(fixture);
      await pumpP3Screen(
        tester,
        sharedFixture: fixture,
        role: Role.admin,
        uid: 'alice',
        home: pushed(templateId: template.id),
      );
      await open(tester);

      await tester.enterText(
        find.byKey(const ValueKey<String>('name_bn')),
        'নতুন নাম',
      );
      await tapSave(tester);

      // Both choices are offered; the chosen one lets the save through.
      expect(
        find.byKey(const ValueKey<String>('replan_future_only')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('replan_include_upcoming')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(ValueKey<String>(scope)));
      await tester.pumpAndSettle();

      final stored = fixture.chores.templates[familyId]![template.id]!;
      expect(stored.draft.nameBn, 'নতুন নাম');
      expect(stored.revision, template.revision + 1);
    });
  }

  testWidgets('cancelling the replan dialog saves nothing', (tester) async {
    final fixture = ChoresFixture();
    final template = await seed(fixture);
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: pushed(templateId: template.id),
    );
    await open(tester);

    await tester.enterText(
      find.byKey(const ValueKey<String>('name_bn')),
      'নতুন নাম',
    );
    await tapSave(tester);
    await tester.tap(find.text(AppLocalizationsEn().actionCancel));
    await tester.pumpAndSettle();

    final stored = fixture.chores.templates[familyId]![template.id]!;
    expect(stored.revision, template.revision);
  });

  testWidgets('the 31st step cannot be added', (tester) async {
    await pumpP3Screen(tester, role: Role.admin, uid: 'alice', home: pushed());
    await open(tester);
    await goToStep(tester, 2);

    final add = find.byKey(const ValueKey<String>('subtask_add'));
    await scrollTo(tester, add);
    for (var i = 0; i < TemplateLimits.maxSubtasks + 1; i++) {
      await tester.ensureVisible(add);
      // The scroll offset only reaches the paint transform after a frame.
      await tester.pump();
      await tester.tap(add, warnIfMissed: false);
      await tester.pump();
    }

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TemplateEditorScreen)),
    );
    final state = container.read(templateEditorProvider(null));
    expect(state.draft.subtasks, hasLength(TemplateLimits.maxSubtasks));
    expect(
      state.draft.subtasks.map((s) => s.id).toSet(),
      hasLength(TemplateLimits.maxSubtasks),
    );
  });

  testWidgets('an inactive group stays selectable for a chore that has it', (
    tester,
  ) async {
    final fixture = ChoresFixture();
    final group = ChoreSettings.defaults.groups.first;
    fixture.settings.settings = ChoreSettings.defaults.copyWith(
      groups: <ChoreGroup>[
        for (final g in ChoreSettings.defaults.groups)
          g.id == group.id ? g.copyWith(active: false) : g,
      ],
    );
    final template = await seed(fixture, draft: aTemplate(groupId: group.id));
    await pumpP3Screen(
      tester,
      sharedFixture: fixture,
      role: Role.admin,
      uid: 'alice',
      home: pushed(templateId: template.id),
    );
    await open(tester);

    // The chore-group chooser is part of the Basics step.
    expect(find.byKey(ValueKey<String>('group_${group.id}')), findsOneWidget);
  });

  group('helpers', () {
    test('slot keys are generated and never reused', () {
      expect(SlotsEditor.nextSlotKey(<String>['main']), 's2');
      expect(SlotsEditor.nextSlotKey(<String>['main', 's2', 's4']), 's3');
    });

    test('step ids are generated and never reused', () {
      expect(SubtasksEditor.nextStepId(<String>[]), 'step_1');
      expect(SubtasksEditor.nextStepId(<String>['step_1', 'step_3']), 'step_2');
    });

    test('the nth-weekday sentence reads right in English and Bangla', () {
      const summary = RecurrenceSummary(
        kind: RecurrenceKind.nthWeekday,
        nth: 2,
        weekday: DateTime.saturday,
      );
      const en = AppFormatters(languageCode: 'en', useBanglaDigits: false);
      const bn = AppFormatters(languageCode: 'bn', useBanglaDigits: true);

      expect(
        RecurrenceSummaryText.text(AppLocalizationsEn(), en, summary),
        'Every second ${en.weekdayName(DateTime.saturday)} of the month',
      );
      expect(
        RecurrenceSummaryText.text(AppLocalizationsBn(), bn, summary),
        'প্রতি মাসের দ্বিতীয় ${bn.weekdayName(DateTime.saturday)}',
      );
    });
  });

  group('layout', () {
    for (final language in <String>['en', 'bn']) {
      testWidgets('$language at text scale 2.0 does not overflow', (
        tester,
      ) async {
        final fixture = ChoresFixture();
        final template = await seed(
          fixture,
          draft: aTemplate(
            subtasks: <TemplateSubtask>[
              aSubtask(required: true, hint: 'ইঙ্গিত'),
            ],
          ),
        );
        await pumpP3Screen(
          tester,
          sharedFixture: fixture,
          role: Role.admin,
          uid: 'alice',
          languageCode: language,
          textScale: 2,
          home: pushed(templateId: template.id),
        );
        await open(tester);

        for (var step = 0; step < 4; step++) {
          final list = find.byType(Scrollable).first;
          for (var i = 0; i < 12; i++) {
            await tester.drag(list, const Offset(0, -400));
            await tester.pump();
          }
          if (step < 3) await next(tester);
        }
        expect(tester.takeException(), isNull);
      });
    }
  });
}
