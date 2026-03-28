import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';

import '../../core/di/locator.dart';
import '../../features/audio/audio_controller.dart';
import '../../features/gameplay/color_match/color_match_delegate.dart';
import '../../features/gameplay/gameplay_delegate.dart';
import '../my_casual_game.dart';

class GameplayRoute extends Component with HasGameReference<MyCasualGame> {
  late GameplayDelegate delegate;

  @override
  Future<void> onLoad() async {
    void onGameOverCB(bool isWin, int score) {
      if (!isWin) {
        getIt<AudioController>().playSfx('game-over.mp3');
      }
      game.lastScore = score;
      game.lastGameWon = isWin;
      game.router.pushReplacementNamed('game_over');
    }

    delegate = ColorMatchDelegate(
      onGameOver: onGameOverCB,
      onScoreUpdated: (_) {},
    );
    add(delegate);

    await FlameAudio.audioCache.loadAll([
      'background.mp3',
      'ting.mp3',
      'game-over.mp3',
    ]);

    add(PauseButton(position: Vector2(game.size.x - 60, 20)));
  }

  @override
  void onMount() {
    super.onMount();
    getIt<AudioController>().playBgm('background.mp3');
    delegate.reset();
  }

  @override
  void onRemove() {
    getIt<AudioController>().stopBgm();
    super.onRemove();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    delegate.size = size;
    children.whereType<PauseButton>().forEach((b) {
      if (size.x > 60) {
        b.position = Vector2(size.x - 60, 20);
      }
    });
  }
}

class PauseButton extends PositionComponent
    with TapCallbacks, HasGameReference<MyCasualGame> {
  PauseButton({required Vector2 position})
    : super(position: position, size: Vector2.all(40));

  @override
  Future<void> onLoad() async {
    add(TextComponent(text: 'II', position: size / 2, anchor: Anchor.center));
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.router.pushNamed('pause');
  }
}
