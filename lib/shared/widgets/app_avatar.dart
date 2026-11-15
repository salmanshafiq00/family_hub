import 'package:family_hub/app/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Circular avatar: an optional image, or a preset colour (`avatarKey` like
/// `p3`), or — without either — a colour derived from [id] so a person looks
/// the same on every screen and every launch.  Shows the first grapheme cluster
/// of [name] (Bangla-safe).
///
/// An image that fails to load falls back to the initials placeholder with no
/// error text and no flicker: the placeholder is always painted underneath and
/// the image fades in on top only once a frame decodes.
///
/// Accessibility: pass a localized [semanticLabel] to have the avatar announced
/// to assistive technology; when it is null the avatar is decorative and hidden
/// from screen readers.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.id,
    required this.name,
    this.avatarKey,
    this.size = 40,
    this.imageUrl,
    this.imageProvider,
    this.semanticLabel,
    super.key,
  });

  final String id;
  final String name;
  final String? avatarKey;
  final double size;

  /// Network image to show when present.  Ignored when [imageProvider] is set.
  final String? imageUrl;

  /// Any image source (asset, memory, network); wins over [imageUrl].
  final ImageProvider? imageProvider;

  /// Localized screen-reader label.  Null makes the avatar decorative.
  final String? semanticLabel;

  /// Number of preset avatar colours offered by the profile picker.
  ///
  /// A subset of `placeholderPalette`: twenty-four circles would push the
  /// profile form's first field off a phone screen.
  static const int presetCount = 12;

  /// Stable (cross-run) hash: Dart's `String.hashCode` is not guaranteed so.
  static int stableHash(String s) {
    var h = 2166136261;
    for (final unit in s.codeUnits) {
      h = ((h ^ unit) * 16777619) & 0x7fffffff;
    }
    return h;
  }

  /// `p3` -> 3, otherwise `null`.
  static int? presetIndex(String? key) {
    if (key == null || !key.startsWith('p')) return null;
    final i = int.tryParse(key.substring(1));
    return (i != null && i >= 0 && i < presetCount) ? i : null;
  }

  /// Palette index this avatar resolves to for [id] / [avatarKey].
  ///
  /// Exposed so tests (and matching artwork) can assert that the same person
  /// keeps the same colour on every screen and every launch.
  static int colorIndex(String id, {String? avatarKey}) {
    const paletteLength = 24; // matches placeholderPalette.length
    return presetIndex(avatarKey) ?? stableHash(id) % paletteLength;
  }

  /// Contrasting text colour for a placeholder [background], from the theme's
  /// own `placeholderOnLight` / `placeholderOnDark` tokens (rule 22).
  static Color foregroundFor(Color background, AppTokens tokens) =>
      ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? tokens.placeholderOnDark
      : tokens.placeholderOnLight;

  @override
  Widget build(BuildContext context) {
    final palette = context.tokens.placeholderPalette;
    final index = colorIndex(id, avatarKey: avatarKey) % palette.length;
    final background = palette[index];

    final placeholder = _Initials(
      initial: _initialOf(name),
      background: background,
      foreground: foregroundFor(background, context.tokens),
      size: size,
    );

    final provider = _resolveProvider();
    final child = provider == null
        ? placeholder
        : Stack(
            fit: StackFit.expand,
            children: [
              // Painted first so a loading/failed image never leaves a gap.
              placeholder,
              Image(
                image: provider,
                fit: BoxFit.cover,
                // No error widget and no spinner: on failure the initials
                // underneath simply stay visible.
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
                frameBuilder: (_, widget, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return widget;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: context.tokens.durationFast,
                    curve: context.tokens.curveStandard,
                    child: widget,
                  );
                },
              ),
            ],
          );

    final clipped = ClipOval(
      child: SizedBox(width: size, height: size, child: child),
    );

    if (semanticLabel == null) return ExcludeSemantics(child: clipped);
    // excludeSemantics: announce the name once.  Without it the initials
    // glyph merges into this node and is read out after the name.
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: clipped,
    );
  }

  ImageProvider? _resolveProvider() {
    if (imageProvider != null) return imageProvider;
    final url = imageUrl;
    if (url == null || url.isEmpty) return null;
    return NetworkImage(url);
  }

  static String _initialOf(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.characters.first;
  }
}

/// The initials disc painted under (and instead of) an avatar image.
class _Initials extends StatelessWidget {
  const _Initials({
    required this.initial,
    required this.background,
    required this.foreground,
    required this.size,
  });

  final String initial;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initial,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w600,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
