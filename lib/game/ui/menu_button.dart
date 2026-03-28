import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show IconData;
import 'package:flutter/painting.dart';

/// Shared menu button colors and metrics.
class MenuButtonColors {
  static const primaryTop = Color(0xFF66BB6A);
  static const primaryMid = Color(0xFF43A047);
  static const primaryBottom = Color(0xFF2E7D32);
  static const primaryBevel = Color(0xFF1B5E20);

  static const secondaryTop = Color(0xFF757575);
  static const secondaryMid = Color(0xFF616161);
  static const secondaryBottom = Color(0xFF424242);
  static const secondaryBevel = Color(0xFF303030);

  static const shadowColor = Color(0x40000000);
  static const shadowBlur = 6.0;
}

enum MenuButtonStyle { primary, secondary }

/// Reusable styled menu button with gradient, shadow, and 3D bevel.
/// Supports tap feedback via scale animation.
abstract class MenuButton extends PositionComponent with TapCallbacks {
  MenuButton({
    required Vector2 size,
    required this.text,
    this.style = MenuButtonStyle.primary,
    this.fontSize = 24,
    this.labelStyle,
  }) : super(size: size, anchor: Anchor.center);

  final String text;
  final MenuButtonStyle style;
  final double fontSize;

  /// When set (e.g. Material Icons), used instead of [fontSize] for the label.
  final TextStyle? labelStyle;

  late TextComponent _label;

  List<Color> get _gradientColors {
    switch (style) {
      case MenuButtonStyle.primary:
        return [
          MenuButtonColors.primaryTop,
          MenuButtonColors.primaryMid,
          MenuButtonColors.primaryBottom,
        ];
      case MenuButtonStyle.secondary:
        return [
          MenuButtonColors.secondaryTop,
          MenuButtonColors.secondaryMid,
          MenuButtonColors.secondaryBottom,
        ];
    }
  }

  Color get _bevelColor {
    switch (style) {
      case MenuButtonStyle.primary:
        return MenuButtonColors.primaryBevel;
      case MenuButtonStyle.secondary:
        return MenuButtonColors.secondaryBevel;
    }
  }

  @override
  Future<void> onLoad() async {
    _label = TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: labelStyle ??
            TextStyle(
              fontSize: fontSize,
              color: const Color(0xFFFFFFFF),
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(
                  color: Color(0x601B5E20),
                  offset: Offset(2, 2),
                  blurRadius: 2,
                ),
              ],
            ),
      ),
    );
    add(_label);
  }

  void setLabelText(String value) {
    _label.text = value;
  }

  void setMaterialIcon(IconData icon) {
    _label.text = String.fromCharCode(icon.codePoint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(0.95);
    onTap();
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1.0);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1.0);
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final double radius = 10; // size.y / 2;

    // Box shadow (soft drop shadow)
    final shadowRect = rect.shift(const Offset(0, 4));
    final shadowRRect = RRect.fromRectAndRadius(
      shadowRect,
      Radius.circular(radius),
    );
    canvas.drawRRect(
      shadowRRect,
      Paint()
        ..color = MenuButtonColors.shadowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // 3D bevel (dark bottom edge ~15% height)
    final bevelHeight = size.y * 0.15;
    final bevelRect =
        Rect.fromLTWH(0, size.y - bevelHeight, size.x, bevelHeight);
    final bevelRRect = RRect.fromRectAndCorners(
      bevelRect,
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(radius),
    );
    canvas.drawRRect(bevelRRect, Paint()..color = _bevelColor);

    // Main face (gradient)
    final faceRect = Rect.fromLTWH(0, 0, size.x, size.y - bevelHeight);
    final faceRRect = RRect.fromRectAndCorners(
      faceRect,
      topLeft: Radius.circular(radius),
      topRight: Radius.circular(radius),
    );
    canvas.drawRRect(
      faceRRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _gradientColors,
        ).createShader(faceRect),
    );

    super.render(canvas);
  }

  void onTap();
}
