import 'package:flutter/material.dart';

import '../my_casual_game.dart';

/// Color scheme for menu background gradient.
class GameCardColors {
  const GameCardColors({
    required this.top,
    required this.mid,
    required this.bottom,
    required this.bevel,
  });

  final Color top;
  final Color mid;
  final Color bottom;
  final Color bevel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameCardColors &&
          top == other.top &&
          mid == other.mid &&
          bottom == other.bottom &&
          bevel == other.bevel;

  @override
  int get hashCode => Object.hash(top, mid, bottom, bevel);
}

/// Config for the single game mode: display name and menu colors.
extension GameTypeConfig on GameType {
  String get displayName => switch (this) {
        GameType.colorMatch => 'Color Match',
      };

  GameCardColors get cardColors => switch (this) {
        GameType.colorMatch => const GameCardColors(
            top: Color(0xFF42A5F5),
            mid: Color(0xFF1E88E5),
            bottom: Color(0xFF1565C0),
            bevel: Color(0xFF0D47A1),
          ),
      };
}
