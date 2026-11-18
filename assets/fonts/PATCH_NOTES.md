# Font patch notes

`HindSiliguri-Regular.ttf`, `-Medium.ttf` and `-SemiBold.ttf` were modified:
only the Bangla digit one glyph (`bnOne`, U+09E7 ১) was replaced. In the original
files these three weights draw ১ as a short hook that sits low next to the other
digits (Light and Bold were correct). The replacement outline is interpolated
between the Light and Bold outlines (25% / 50% / 75%) and its advance width
is interpolated the same way. Nothing else in the fonts changed.

The fonts stay under the SIL Open Font License 1.1 (see `OFL.txt`).
