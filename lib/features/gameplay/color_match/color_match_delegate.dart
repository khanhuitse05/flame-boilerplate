import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../../../core/di/locator.dart';
import '../../audio/audio_controller.dart';
import '../gameplay_delegate.dart';

class _RoundProgressBar extends PositionComponent {
  _RoundProgressBar() : super(anchor: Anchor.topLeft);

  double progress = 1.0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = size.toRect();
    final radius = Radius.circular(size.y / 2);
    final track = RRect.fromRectAndRadius(rect, radius);
    canvas.drawRRect(track, Paint()..color = Colors.white24);
    if (progress <= 0) return;
    canvas.save();
    canvas.clipRRect(track);
    final fillWidth = rect.width * progress;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, rect.top, fillWidth, rect.height),
      Paint()..color = Colors.white,
    );
    canvas.restore();
  }
}

class ColorMatchDelegate extends GameplayDelegate {
  static const _roundDuration = 3.0;
  static const _progressBarHeight = 12.0;
  static const _progressGap = 14.0;
  static const _scoreGap = 20.0;
  static const _scoreFontSize = 56.0;
  static const _horizontalMargin = 24.0;
  static const _verticalMargin = 20.0;

  final Random _random = Random();
  int _currentLevel = 1;
  double _timeRemaining = _roundDuration;
  bool _isPlaying = false;

  late _RoundProgressBar _progressBar;
  late TextComponent _scoreText;

  double _boardSize = 0;
  Vector2 _gridStart = Vector2.zero();

  ColorMatchDelegate({
    required super.onGameOver,
    required super.onScoreUpdated,
  });

  @override
  Future<void> onLoad() async {
    _progressBar = _RoundProgressBar();
    add(_progressBar);

    _scoreText = TextComponent(
      text: '0',
      anchor: Anchor.topCenter,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: _scoreFontSize,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
    add(_scoreText);
  }

  void _updateLayout() {
    if (size.x <= 0 || size.y <= 0) return;

    final stackExtra = _progressBarHeight +
        _progressGap +
        _scoreGap +
        _scoreFontSize;
    final maxByHeight = size.y - _verticalMargin * 2 - stackExtra;
    final maxByWidth = size.x - _horizontalMargin * 2;
    _boardSize = min(maxByWidth, maxByHeight);
    if (_boardSize <= 0) {
      _boardSize = 0;
      return;
    }

    final totalStackH = _progressBarHeight + _progressGap + _boardSize + _scoreGap + _scoreFontSize;
    final startY = (size.y - totalStackH) / 2;
    final startX = (size.x - _boardSize) / 2;

    _progressBar
      ..position = Vector2(startX, startY)
      ..size = Vector2(_boardSize, _progressBarHeight);

    _gridStart = Vector2(startX, startY + _progressBarHeight + _progressGap);

    _scoreText.position = Vector2(
      size.x / 2,
      startY + _progressBarHeight + _progressGap + _boardSize + _scoreGap,
    );
  }

  void _syncScoreLabel() {
    _scoreText.text = '${_currentLevel - 1}';
  }

  @override
  void reset() {
    _currentLevel = 1;
    _timeRemaining = _roundDuration;
    _isPlaying = true;
    _progressBar.progress = 1.0;
    onScoreUpdated(_currentLevel - 1);
    _syncScoreLabel();
    if (size.x > 0 && size.y > 0) {
      _generateBoard();
    } else {
      children.whereType<ColorTile>().toList().forEach(
        (c) => c.removeFromParent(),
      );
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    if (_isPlaying) {
      _generateBoard();
    } else {
      _updateLayout();
    }
  }

  void _generateBoard() {
    _updateLayout();
    children.whereType<ColorTile>().toList().forEach(
      (c) => c.removeFromParent(),
    );

    if (_boardSize <= 0) return;

    int gridSize = _getGridSize(_currentLevel);

    int r = _random.nextInt(200);
    int g = _random.nextInt(200);
    int b = _random.nextInt(200);
    Color baseColor = Color.fromARGB(255, r, g, b);

    int diff = max(10, 50 - (_currentLevel * 2));
    Color diffColor = Color.fromARGB(255, r + diff, g + diff, b + diff);

    int diffIndex = _random.nextInt(gridSize * gridSize);

    double padding = 4.0;
    double tileSize = (_boardSize - (padding * (gridSize - 1))) / gridSize;

    for (int i = 0; i < gridSize * gridSize; i++) {
      int row = i ~/ gridSize;
      int col = i % gridSize;
      Vector2 pos =
          _gridStart +
          Vector2(col * (tileSize + padding), row * (tileSize + padding));

      bool isDiff = (i == diffIndex);
      add(
        ColorTile(
          position: pos,
          size: Vector2.all(tileSize),
          color: isDiff ? diffColor : baseColor,
          isDifferent: isDiff,
          onTap: (correct) {
            if (!_isPlaying) return;
            if (correct) {
              getIt<AudioController>().playSfx('ting.mp3');
              _currentLevel++;
              _timeRemaining = _roundDuration;
              onScoreUpdated(_currentLevel - 1);
              _syncScoreLabel();
              _generateBoard();
            } else {
              _isPlaying = false;
              onGameOver(false, _currentLevel - 1);
            }
          },
        ),
      );
    }
  }

  int _getGridSize(int level) {
    if (level <= 3) return 2;
    if (level <= 6) return 4;
    if (level <= 9) return 5;
    if (level <= 12) return 6;
    if (level <= 15) return 7;
    if (level <= 18) return 8;
    if (level <= 21) return 9;
    return 10;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isPlaying) {
      _timeRemaining -= dt;
      if (_timeRemaining <= 0) {
        _timeRemaining = 0;
        _isPlaying = false;
        onGameOver(false, _currentLevel - 1);
      }
      _progressBar.progress =
          (_timeRemaining / _roundDuration).clamp(0.0, 1.0);
    }
  }
}

class ColorTile extends PositionComponent with TapCallbacks {
  final Color color;
  final bool isDifferent;
  final void Function(bool) onTap;

  ColorTile({
    required super.position,
    required super.size,
    required this.color,
    required this.isDifferent,
    required this.onTap,
  });

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(8)),
      Paint()..color = color,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(isDifferent);
  }
}
