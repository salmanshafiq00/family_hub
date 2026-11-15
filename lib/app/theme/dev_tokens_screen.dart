import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:family_hub/core/localization/l10n_ext.dart';
import 'package:flutter/material.dart';

/// Debug-only screen at `/dev/tokens`.
/// Shows every token as a labeled color swatch so designers can verify the
/// full palette in both themes.  Remove or gate behind a flag in production.
class DevTokensScreen extends StatelessWidget {
  const DevTokensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;

    final sections = <_Section>[
      _Section('Surfaces', [
        _Swatch('background', t.background),
        _Swatch('surface', t.surface),
        _Swatch('surfaceRaised', t.surfaceRaised),
        _Swatch('surfaceSunken', t.surfaceSunken),
        _Swatch('scrim', t.scrim),
      ]),
      _Section('Text', [
        _Swatch('textPrimary', t.textPrimary),
        _Swatch('textSecondary', t.textSecondary),
        _Swatch('textDisabled', t.textDisabled),
        _Swatch('textOnAccent', t.textOnAccent, bg: t.accent),
      ]),
      _Section('Brand', [
        _Swatch('accent', t.accent),
        _Swatch('accentSoft', t.accentSoft),
        _Swatch('accentStrong', t.accentStrong),
      ]),
      _Section('Status — Scheduled', [
        _Swatch('statusScheduled', t.statusScheduled),
        _Swatch('statusScheduledContainer', t.statusScheduledContainer),
        _Swatch(
          'statusScheduledOn',
          t.statusScheduledOn,
          bg: t.statusScheduledContainer,
        ),
      ]),
      _Section('Status — In Progress', [
        _Swatch('statusInProgress', t.statusInProgress),
        _Swatch('statusInProgressContainer', t.statusInProgressContainer),
        _Swatch(
          'statusInProgressOn',
          t.statusInProgressOn,
          bg: t.statusInProgressContainer,
        ),
      ]),
      _Section('Status — Completed', [
        _Swatch('statusCompleted', t.statusCompleted),
        _Swatch('statusCompletedContainer', t.statusCompletedContainer),
        _Swatch(
          'statusCompletedOn',
          t.statusCompletedOn,
          bg: t.statusCompletedContainer,
        ),
      ]),
      _Section('Status — Verified', [
        _Swatch('statusVerified', t.statusVerified),
        _Swatch('statusVerifiedContainer', t.statusVerifiedContainer),
        _Swatch(
          'statusVerifiedOn',
          t.statusVerifiedOn,
          bg: t.statusVerifiedContainer,
        ),
      ]),
      _Section('Status — Overdue', [
        _Swatch('statusOverdue', t.statusOverdue),
        _Swatch('statusOverdueContainer', t.statusOverdueContainer),
        _Swatch(
          'statusOverdueOn',
          t.statusOverdueOn,
          bg: t.statusOverdueContainer,
        ),
      ]),
      _Section('Feedback', [
        _Swatch('success', t.success),
        _Swatch('warning', t.warning),
        _Swatch('danger', t.danger),
        _Swatch('info', t.info),
      ]),
      _Section('Lines', [
        _Swatch('divider', t.divider),
        _Swatch('outline', t.outline),
        _Swatch('focusRing', t.focusRing),
      ]),
      _Section(
        'Data Viz (chart[0..9])',
        List.generate(10, (i) => _Swatch('chart[$i]', t.chart[i]))
          ..add(_Swatch('chartGrid', t.chartGrid)),
      ),
      _Section(
        'Placeholder Palette [0..23]',
        List.generate(
          t.placeholderPalette.length,
          (i) => _Swatch('placeholder[$i]', t.placeholderPalette[i]),
        ),
      ),
      _Section('Shape', [
        _ShapeRow('radiusSm', t.radiusSm),
        _ShapeRow('radiusMd', t.radiusMd),
        _ShapeRow('radiusLg', t.radiusLg),
        _ShapeRow('radiusPill', t.radiusPill),
      ]),
      _Section('Motion', [
        _TextRow('durationFast', '${t.durationFast.inMilliseconds} ms'),
        _TextRow('durationMedium', '${t.durationMedium.inMilliseconds} ms'),
        _TextRow('durationSlow', '${t.durationSlow.inMilliseconds} ms'),
        _TextRow('curveStandard', t.curveStandard.toString()),
      ]),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.devTokensTitle)),
      backgroundColor: t.background,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: sections
            .expand(
              (s) => [
                _SectionHeader(s.title),
                ...s.rows,
                const SizedBox(height: 16),
              ],
            )
            .toList(),
      ),
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _Section {
  const _Section(this.title, this.rows);
  final String title;
  final List<Widget> rows;
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: t.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color, {this.bg});
  final String name;
  final Color color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: bg ?? t.surface,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: t.divider),
      ),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: t.outline),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: bg != null ? color : t.textPrimary,
            fontSize: 13,
          ),
        ),
        trailing: Text(
          _hex(color),
          style: TextStyle(
            color: t.textSecondary,
            fontSize: 11,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

class _ShapeRow extends StatelessWidget {
  const _ShapeRow(this.name, this.radius);
  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: t.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: t.accentSoft,
              borderRadius: BorderRadius.circular(radius.clamp(0, 12)),
              border: Border.all(color: t.accent),
            ),
          ),
          const SizedBox(width: 12),
          Text(name, style: TextStyle(color: t.textPrimary, fontSize: 13)),
          const Spacer(),
          Text(
            '${radius}dp',
            style: TextStyle(color: t.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TextRow extends StatelessWidget {
  const _TextRow(this.name, this.value);
  final String name;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radiusSm),
        border: Border.all(color: t.divider),
      ),
      child: Row(
        children: [
          Text(name, style: TextStyle(color: t.textPrimary, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(color: t.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}
