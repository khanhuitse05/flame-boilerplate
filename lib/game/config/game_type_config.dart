import 'package:flutter/material.dart';

import '../my_casual_game.dart';

/// Config for the single game mode: display name and menu background gradient.
extension GameTypeConfig on GameType {
  String get displayName => switch (this) {
        GameType.colorMatch => 'Color Match',
      };

  /// Three-stop vertical gradient for the main menu background (top → mid → bottom).
  List<Color> get menuGradientColors => switch (this) {
        GameType.colorMatch => const [
            Color(0xFF42A5F5),
            Color(0xFF1E88E5),
            Color(0xFF1565C0),
          ],
      };
}
