import 'dart:async';

import 'package:family_hub/app/routing/app_routes.dart';
import 'package:family_hub/core/errors/app_failure.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permission.dart';
import 'package:family_hub/features/chores/calendar/presentation/calendar_screen.dart';
import 'package:family_hub/features/chores/presentation/chores_failure_messages.dart';
import 'package:family_hub/features/chores/templates/presentation/template_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/features/notifications/presentation/inbox_bell.dart';
import 'package:family_hub/shared/widgets/empty_state.dart';
import 'package:family_hub/shared/widgets/error_view.dart';
import 'package:family_hub/shared/widgets/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The Chores tab (P3-22): the family's chore calendar.
///
/// A family with no chore template yet keeps the friendly first-run empty state
/// (with "Manage" for a manager) instead of an empty grid. The app bar carries
/// the inbox bell, the shortcut to Today and, for a manager, the Manage hub.
class ChoresHomeScreen extends ConsumerWidget {
  const ChoresHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final canManage = ref.can(Permission.manageChoreTemplates);
    final templates = ref.watch(templatesStreamProvider);

    final Widget body;
    if (templates.hasValue && templates.requireValue.isEmpty) {
      body = EmptyState(
        icon: Icons.checklist_rounded,
        title: l10n.choresEmptyTitle,
        message: l10n.choresEmptyMessage,
        actionLabel: canManage ? l10n.choresManageAction : null,
        onAction: canManage ? () => context.push(AppRoutes.choresManage) : null,
      );
    } else if (templates.hasValue) {
      body = const CalendarScreen();
    } else if (templates.hasError) {
      final error = templates.error;
      body = ErrorView(
        message: l10n.choresFailureMessage(
          error is AppFailure ? error : Unknown(error),
        ),
        onRetry: () => ref.invalidate(templatesStreamProvider),
      );
    } else {
      body = const LoadingView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navChores),
        actions: [
          // P3-27: the inbox bell lives in the app bar, first in the list.
          const InboxBell(),
          IconButton(
            key: const Key('chores_open_today'),
            tooltip: l10n.calendarOpenToday,
            icon: const Icon(Icons.today_rounded),
            onPressed: () => unawaited(context.push(AppRoutes.choresToday)),
          ),
          if (canManage)
            IconButton(
              key: const Key('chores_open_manage'),
              tooltip: l10n.choresManageAction,
              icon: const Icon(Icons.tune_rounded),
              onPressed: () => unawaited(context.push(AppRoutes.choresManage)),
            ),
        ],
      ),
      body: body,
      // Only while the calendar shows: a manager adds a chore, a member jumps
      // to their own day (P3-29).
      floatingActionButton:
          templates.hasValue && templates.requireValue.isNotEmpty
          ? FloatingActionButton.small(
              key: Key(canManage ? 'chores_fab_new' : 'chores_fab_today'),
              tooltip: canManage
                  ? l10n.choresNewAction
                  : l10n.choresMyTodayAction,
              onPressed: () => unawaited(
                context.push(
                  canManage
                      ? AppRoutes.choresTemplateNew
                      : AppRoutes.choresToday,
                ),
              ),
              child: Icon(canManage ? Icons.add_rounded : Icons.today_rounded),
            )
          : null,
    );
  }
}
