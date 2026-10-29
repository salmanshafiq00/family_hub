import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:family_hub/core/permissions/permissions.dart';
import 'package:family_hub/features/bazar/expenses/domain/amount_input.dart';
import 'package:family_hub/features/bazar/expenses/presentation/widgets/form_banner.dart';
import 'package:family_hub/features/bazar/presentation/bazar_failure_messages.dart';
import 'package:family_hub/features/bazar/settings/domain/bazar_settings.dart';
import 'package:family_hub/features/bazar/settings/presentation/bazar_settings_providers.dart';
import 'package:family_hub/features/family/presentation/action_controller.dart';
import 'package:family_hub/features/family/presentation/family_providers.dart';
import 'package:family_hub/features/family/presentation/permission_providers.dart';
import 'package:family_hub/core/utils/money.dart';
import 'package:family_hub/shared/widgets/amount_field.dart';
import 'package:family_hub/shared/widgets/busy_button.dart';
import 'package:family_hub/shared/widgets/choice_wrap.dart';
import 'package:family_hub/shared/widgets/permission_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final ActionProvider _settingsActionProvider = newActionProvider();

/// Saturday first, as the Bangladeshi week runs (`DateTime` weekday numbers).
const List<int> _weekOrder = <int>[6, 7, 1, 2, 3, 4, 5];

/// Week start, monthly contribution target, due day and budget alert levels
/// (`/bazar/settings`).  Saving needs the server (it changes every device's
/// calculations), so offline shows the network message.
class BazarSettingsScreen extends ConsumerStatefulWidget {
  const BazarSettingsScreen({super.key});

  @override
  ConsumerState<BazarSettingsScreen> createState() =>
      _BazarSettingsScreenState();
}

class _BazarSettingsScreenState extends ConsumerState<BazarSettingsScreen> {
  final TextEditingController _target = TextEditingController();
  final TextEditingController _warn = TextEditingController();
  final TextEditingController _exceeded = TextEditingController();
  late int _weekStart;
  late int _dueDay;
  bool _loaded = false;
  String? _targetError;
  String? _thresholdError;

  @override
  void initState() {
    super.initState();
    final s = ref.read(bazarSettingsProvider);
    _weekStart = s.weekStartDay;
    _dueDay = s.contributionDueDay;
    _fill(s);
    // The live document may arrive after the first frame; fill the fields
    // once, and never overwrite what the user is typing.
    ref.listenManual<BazarSettings>(bazarSettingsProvider, (_, next) {
      if (_loaded) return;
      setState(() {
        _weekStart = next.weekStartDay;
        _dueDay = next.contributionDueDay;
        _fill(next);
      });
    });
  }

  void _fill(BazarSettings s) {
    _target.text = s.defaultMonthlyContribution.isZero
        ? ''
        : moneyEditText(s.defaultMonthlyContribution);
    _warn.text = s.alertThresholds.first.toString();
    _exceeded.text = s.alertThresholds.length > 1
        ? s.alertThresholds[1].toString()
        : '100';
  }

  @override
  void dispose() {
    _target.dispose();
    _warn.dispose();
    _exceeded.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    String? targetError;
    var target = Money.zero;
    if (_target.text.trim().isNotEmpty) {
      final parsed = Money.parse(_target.text);
      if (parsed.failureOrNull != null) {
        targetError = l10n.bazarErrInvalidAmount;
      } else {
        target = parsed.valueOrNull!;
      }
    }
    final warn = int.tryParse(_toDigits(_warn.text));
    final exceeded = int.tryParse(_toDigits(_exceeded.text));
    String? thresholdError;
    if (warn == null || exceeded == null || warn < 1 || exceeded > 200) {
      thresholdError = l10n.bazarSettingsThresholdRange;
    } else if (warn >= exceeded) {
      thresholdError = l10n.bazarSettingsThresholdOrder;
    }
    if (targetError != null || thresholdError != null) {
      setState(() {
        _targetError = targetError;
        _thresholdError = thresholdError;
      });
      return;
    }
    setState(() {
      _targetError = null;
      _thresholdError = null;
    });

    final familyId = ref.read(currentFamilyIdProvider);
    final uid = ref.read(currentUidProvider);
    if (familyId == null || uid == null) return;
    _loaded = true;
    final current = ref.read(bazarSettingsProvider);
    // Confusingly typed on purpose: `run` returns the action's value, and a
    // `Result<void>` value IS null even on success — so the controller's state
    // (not the return value) decides whether "saved" is shown.
    await ref.read(_settingsActionProvider.notifier).run<Object?>(
      () => ref.read(updateBazarSettingsProvider)(
        actorUid: uid,
        familyId: familyId,
        settings: current.copyWith(
          weekStartDay: _weekStart,
          defaultMonthlyContribution: target,
          contributionDueDay: _dueDay,
          alertThresholds: <int>[warn!, exceeded!],
        ),
      ),
    );
    if (!mounted) return;
    if (ref.read(_settingsActionProvider).failure != null) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
  }

  static String _toDigits(String text) => text.trim().replaceAllMapped(
    RegExp('[০-৯]'),
    (m) => '${m.group(0)!.codeUnitAt(0) - 0x09E6}',
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tokens;
    final formatters = ref.watch(appFormattersProvider);
    final canManage = ref.can(Permission.manageCatalogAndBudgets);
    final action = ref.watch(_settingsActionProvider);
    final failure = action.failure;
    final fundStart = ref.watch(bazarSettingsProvider).fundStartMonth;
    final label = Theme.of(
      context,
    ).textTheme.labelLarge?.copyWith(color: t.textSecondary);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bazarSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!canManage)
            FormBanner(
              icon: Icons.lock_outline,
              text: l10n.catalogReadOnly,
              color: t.textSecondary,
            ),
          PermissionGate(
            allowed: canManage,
            mode: PermissionGateMode.disable,
            deniedMessage: l10n.bazarErrNotAllowed,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bazarSettingsWeekStart, style: label),
                const SizedBox(height: 8),
                ChoiceWrap<int>(
                  selected: _weekStart,
                  onChanged: (d) => setState(() {
                    _loaded = true;
                    _weekStart = d;
                  }),
                  options: [
                    for (final d in _weekOrder)
                      ChoiceOption(d, formatters.weekdayName(d)),
                  ],
                ),
                const SizedBox(height: 20),
                AmountField(
                  key: const ValueKey('settings-target'),
                  controller: _target,
                  label: l10n.bazarSettingsTarget,
                  errorText: _targetError,
                  onChanged: (_) => _loaded = true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  key: const ValueKey('settings-due-day'),
                  initialValue: _dueDay,
                  decoration: InputDecoration(
                    labelText: l10n.bazarSettingsDueDay,
                  ),
                  items: [
                    for (var d = 1; d <= 28; d++)
                      DropdownMenuItem<int>(
                        value: d,
                        child: Text(formatters.number(d)),
                      ),
                  ],
                  onChanged: (d) => setState(() => _dueDay = d ?? _dueDay),
                ),
                const SizedBox(height: 20),
                Text(l10n.bazarSettingsAlerts, style: label),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AmountField(
                        key: const ValueKey('settings-warn'),
                        controller: _warn,
                        label: l10n.bazarSettingsWarnAt,
                        scale: 0,
                        showCurrencyPrefix: false,
                        onChanged: (_) => _loaded = true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AmountField(
                        key: const ValueKey('settings-exceeded'),
                        controller: _exceeded,
                        label: l10n.bazarSettingsExceededAt,
                        scale: 0,
                        showCurrencyPrefix: false,
                        errorText: _thresholdError,
                        onChanged: (_) => _loaded = true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l10n.bazarSettingsFundStart, style: label),
                const SizedBox(height: 4),
                Text(
                  fundStart == null
                      ? l10n.bazarSettingsFundStartUnset
                      : formatters.monthLabel(fundStart),
                ),
                if (failure != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      l10n.bazarFailureMessage(failure),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: t.danger),
                    ),
                  ),
                const SizedBox(height: 20),
                BusyButton(
                  key: const ValueKey('settings-save'),
                  label: l10n.actionSave,
                  busy: action.busy,
                  busyLabel: l10n.loadingSemantics,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
