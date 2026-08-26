import 'package:flutter/material.dart';

abstract final class StrotColors {
  static const forest = Color(0xFF12372A);
  static const gold = Color(0xFFC9983E);
  // Derived gold tone for accessible foreground text on cream surfaces.
  static const goldText = Color(0xFF906820);
  static const cream = Color(0xFFF7F3EA);
  static const charcoal = Color(0xFF222624);
  static const forestMuted = Color(0x2912372A);
  static const goldMuted = Color(0x3DC9983E);
  static const charcoalMuted = Color(0xA3222624);
  static const disabled = Color(0x61222624);
}

abstract final class StrotSpacing {
  static const xs = 4.0, sm = 8.0, md = 16.0, lg = 24.0, xl = 32.0, xxl = 48.0;
}

abstract final class StrotRadius {
  static const sm = 4.0, md = 8.0, lg = 12.0;
}

abstract final class StrotElevation {
  static const none = 0.0, raised = 1.0;
}
