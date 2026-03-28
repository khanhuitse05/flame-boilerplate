import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../config/game_type_config.dart';
import '../my_casual_game.dart';
import '../ui/background_gradient.dart';
import '../ui/menu_button.dart';
import '../../core/di/locator.dart';
import '../../core/storage/local_storage.dart';
import '../../features/audio/audio_controller.dart';

class MainMenuRoute extends Component with HasGameReference<MyCasualGame> {
  late TextComponent _gameNameText;
  late TextComponent _highScoreText;
  late BackgroundGradient _background;
  late SoundToggleButton _soundToggle;
  late MusicToggleButton _musicToggle;

  @override
  Future<void> onLoad() async {
    _background = BackgroundGradient(
      colorsResolver: () => GameType.colorMatch.menuGradientColors,
    );
    add(_background);

    _gameNameText = TextComponent(
      text: '',
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
    _highScoreText = TextComponent(
      text: '',
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 22,
          color: Color(0xFFE0E0E0),
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(color: Color(0x60000000), offset: Offset(1, 1), blurRadius: 2),
          ],
        ),
      ),
    );
    add(_gameNameText);
    add(_highScoreText);
    add(PlayButton(size: Vector2(240, 56)));
    _soundToggle = SoundToggleButton(size: Vector2(56, 56));
    _musicToggle = MusicToggleButton(size: Vector2(56, 56));
    add(_soundToggle);
    add(_musicToggle);
  }

  @override
  void onMount() {
    super.onMount();
    final gameName = GameType.colorMatch.name;
    final displayName = GameType.colorMatch.displayName;
    final highScore = getIt<LocalStorage>().getHighScore(gameName);
    _gameNameText.text = displayName;
    _highScoreText.text = 'High Score: $highScore';
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _background
      ..size = size
      ..position = Vector2.zero();
    _gameNameText.position = size / 2 - Vector2(0, 90);
    _highScoreText.position = size / 2 - Vector2(0, 45);
    children.whereType<PlayButton>().forEach(
      (b) => b.position = size / 2 + Vector2(0, 30),
    );
    _soundToggle.position = size / 2 + Vector2(-52, 100);
    _musicToggle.position = size / 2 + Vector2(52, 100);
  }
}

class PlayButton extends MenuButton with HasGameReference<MyCasualGame> {
  PlayButton({required super.size})
      : super(text: '> Play', style: MenuButtonStyle.primary, fontSize: 28);

  @override
  void onTap() {
    game.router.pushReplacementNamed('play');
  }
}

const double _toggleIconFontSize = 28;

TextStyle _toggleMaterialIconStyle() => const TextStyle(
      fontFamily: 'MaterialIcons',
      fontSize: _toggleIconFontSize,
      color: Color(0xFFFFFFFF),
      shadows: [
        Shadow(
          color: Color(0x601B5E20),
          offset: Offset(2, 2),
          blurRadius: 2,
        ),
      ],
    );

IconData _soundIcon(bool enabled) =>
    enabled ? Icons.volume_up : Icons.volume_off;

IconData _musicIcon(bool enabled) =>
    enabled ? Icons.music_note : Icons.music_off;

class SoundToggleButton extends MenuButton {
  SoundToggleButton({required super.size})
      : super(
          text: String.fromCharCode(
            _soundIcon(getIt<LocalStorage>().getSoundEnabled()).codePoint,
          ),
          style: MenuButtonStyle.secondary,
          fontSize: _toggleIconFontSize,
          labelStyle: _toggleMaterialIconStyle(),
        );

  @override
  void onTap() {
    final storage = getIt<LocalStorage>();
    final next = !storage.getSoundEnabled();
    storage.setSoundEnabled(next);
    setMaterialIcon(_soundIcon(next));
  }
}

class MusicToggleButton extends MenuButton {
  MusicToggleButton({required super.size})
      : super(
          text: String.fromCharCode(
            _musicIcon(getIt<LocalStorage>().getMusicEnabled()).codePoint,
          ),
          style: MenuButtonStyle.secondary,
          fontSize: _toggleIconFontSize,
          labelStyle: _toggleMaterialIconStyle(),
        );

  @override
  void onTap() {
    final storage = getIt<LocalStorage>();
    final next = !storage.getMusicEnabled();
    storage.setMusicEnabled(next);
    setMaterialIcon(_musicIcon(next));
    getIt<AudioController>().onMusicSettingChanged(next);
  }
}

