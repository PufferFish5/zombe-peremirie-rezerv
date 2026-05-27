import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary        = Color(0xFF00E5FF);
  static const Color primaryDark    = Color(0xFF0097A7);
  static const Color accent         = Color(0xFF76FF03);

  static const Color background     = Color(0xFF0A0A0F);
  static const Color surface        = Color(0xFF13131A);
  static const Color surfaceVariant = Color(0xFF1C1C28);

  static const Color textPrimary    = Color(0xFFFFFFFF);
  static const Color textSecondary  = Color(0xFFB0B0C0);
  static const Color textDisabled   = Color(0xFF505060);

  static const Color seriesTropical = Color(0xFF00E5FF);
  static const Color seriesNoir     = Color(0xFF76FF03);
  static const Color seriesThug     = Color(0xFFFF6D00);
  static const Color seriesOg       = Color(0xFF7C4DFF);

  static const Color success        = Color(0xFF69F0AE);
  static const Color warning        = Color(0xFFFFD740);
  static const Color error          = Color(0xFFFF5252);

  static Color forSeries(String series) {
    switch (series.toLowerCase()) {
      case 'tropical':   return seriesTropical;
      case 'noir':      return seriesNoir;
      case 'thug': return seriesThug;
      case 'og':     return seriesOg;
      default:          return primary;
    }
  }
}