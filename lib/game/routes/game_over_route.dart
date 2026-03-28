import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../my_casual_game.dart';
import '../ui/background_gradient.dart';
import '../ui/menu_button.dart';
import '../../core/di/locator.dart';
import '../../core/storage/local_storage.dart';

class GameOverRoute extends Component with HasGameReference<MyCasualGame> {
  late TextComponent _resultText;
  late TextComponent _runScoreText;
  late TextComponent _bestScoreText;
  late BackgroundGradient _background;

  @override
  Future<void> onLoad() async {
    final score = game.lastScore;
    final isWin = game.lastGameWon;
    final gameName = GameType.colorMatch.name;

    final storage = getIt<LocalStorage>();
    final previousBest = storage.getHighScore(gameName);
    final isNewHigh = score > previousBest;
    if (isNewHigh) {
      await storage.setHighScore(gameName, score);
    }
    final best = storage.getHighScore(gameName);

    final resultLabel = isWin ? 'You Win!' : 'Game Over';
    final runLabel = isNewHigh && score > 0
        ? 'Score: $score (New best!)'
        : 'Score: $score';
    final bestLabel = 'Best: $best';

    _background = BackgroundGradient();
    add(_background);

    _resultText = TextComponent(
      text: resultLabel,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 36,
          color: Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Color(0x80000000), offset: Offset(2, 2), blurRadius: 4),
            Shadow(color: Color(0x40000000), offset: Offset(0, 4), blurRadius: 8),
          ],
        ),
      ),
    );
    _runScoreText = TextComponent(
      text: runLabel,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 26,
          color: const Color(0xFFFFFFFF),
          fontWeight: isNewHigh && score > 0 ? FontWeight.bold : FontWeight.w600,
          shadows: const [
            Shadow(color: Color(0x60000000), offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
    _bestScoreText = TextComponent(
      text: bestLabel,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 20,
          color: Color(0xFFB0B0B0),
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(color: Color(0x60000000), offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
    add(_resultText);
    add(_runScoreText);
    add(_bestScoreText);
    add(GameOverReplayButton(size: Vector2(220, 56)));
    add(GameOverMainMenuButton(size: Vector2(200, 48)));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _background
      ..size = size
      ..position = Vector2.zero();
    _resultText.position = size / 2 - Vector2(0, 118);
    _runScoreText.position = size / 2 - Vector2(0, 62);
    _bestScoreText.position = size / 2 - Vector2(0, 22);
    children.whereType<GameOverReplayButton>().forEach(
      (b) => b.position = size / 2 + Vector2(0, 44),
    );
    children.whereType<GameOverMainMenuButton>().forEach(
      (b) => b.position = size / 2 + Vector2(0, 110),
    );
  }
}

class GameOverReplayButton extends MenuButton with HasGameReference<MyCasualGame> {
  GameOverReplayButton({required super.size})
      : super(text: 'Replay', style: MenuButtonStyle.primary, fontSize: 24);

  @override
  void onTap() {
    game.router.pushReplacementNamed('play');
  }
}

class GameOverMainMenuButton extends MenuButton with HasGameReference<MyCasualGame> {
  GameOverMainMenuButton({required super.size})
      : super(text: 'Main Menu', style: MenuButtonStyle.secondary, fontSize: 20);

  @override
  void onTap() {
    game.router.pushReplacementNamed('menu');
  }
}
