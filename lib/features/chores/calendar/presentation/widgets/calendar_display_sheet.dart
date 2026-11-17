import 'dart:async';

import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens the display options of the calendar (P3-24).
Future<void> showCalendarDisplaySheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => const CalendarDisplaySheet(),
    );

/// How the calendar looks, kept on this device only (D-P3-21).
class CalendarDisplaySheet extends ConsumerWidget {
  const CalendarDisplaySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final followsFamily = ref.watch(calendarUsesFamilyDefaultsProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.calendarDisplayOptions,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (!followsFamily)
              TextButton(
                key: const Key('calendar_use_family_defaults'),
                onPressed: () => unawaited(
                  ref.read(calendarPrefsProvider.notifier).useFamilyDefaults(),
                ),
                child: Text(l10n.calendarUseFamilyDefaults),
              ),
          ],
        ),
      ),
    );
  }
}
