---
name: add-new-game
description: >-
  Adds a new game to the Flame boilerplate project. Use when the user wants to
  add a new game, create a new game mode, add a new gameplay type, or extend
  the boilerplate with another game. Covers GameType, config, delegate, routing,
  and assets.
---

# Add New Game to Flame Boilerplate

Follow this checklist when adding a new game to the project. The select game UI uses `GameType.values` and `GameCard`, so adding a `GameType` and config automatically shows the new card in the selection screen.

## Checklist

Copy and track progress:

```
- [ ] 1. Add GameType enum value
- [ ] 2. Add game config (displayName, iconPath, menuGradientColors)
- [ ] 3. Create gameplay delegate
- [ ] 4. Wire delegate in GameplayRoute
- [ ] 5. Add icon asset
```

---

## Step 1: Add GameType Enum Value

**File:** `lib/game/my_casual_game.dart`

Add the new value to the `GameType` enum:

```dart
enum GameType { tap, tap2, tap3, colorMatch, yourNewGame }
```

Use `camelCase` (e.g. `colorMatch`, `memoryCards`).

---

## Step 2: Add Game Config

**File:** `lib/game/config/game_type_config.dart`

Add a case for the new `GameType` in each switch expression: `displayName`, `iconPath` (if you use it), and `menuGradientColors`.

```dart
// displayName
GameType.yourNewGame => 'Your Game Name',

// iconPath
GameType.yourNewGame => 'assets/images/ic_your_game.png',

// menuGradientColors (top → mid → bottom for main menu background)
GameType.yourNewGame => const [
  Color(0xFF...),
  Color(0xFF...),
  Color(0xFF...),
],
```

Pick a distinct gradient (top lighter, bottom darkest). Existing example: blue stops for `colorMatch`.

---

## Step 3: Create Gameplay Delegate

**Location:** `lib/features/gameplay/your_game_name/your_game_delegate.dart`

Create a new folder and delegate class extending `GameplayDelegate`:

```dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../gameplay_delegate.dart';

class YourGameDelegate extends GameplayDelegate with TapCallbacks {
  YourGameDelegate({required super.onGameOver, required super.onScoreUpdated});

  @override
  Future<void> onLoad() async {
    // Add your game components
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void reset() {
    // Reset game state
  }
}
```

Implement: `onLoad`, `onGameResize` (set `this.size`), and `reset`. Use `onScoreUpdated(score)` and `onGameOver(isWin, score)` for callbacks.

---

## Step 4: Wire Delegate in GameplayRoute

**File:** `lib/game/routes/gameplay_route.dart`

1. Add import:
   ```dart
   import '../../features/gameplay/your_game_name/your_game_delegate.dart';
   ```

2. Add case in the switch:
   ```dart
   case GameType.yourNewGame:
     delegate = YourGameDelegate(
       onGameOver: onGameOverCB,
       onScoreUpdated: (score) => scoreText.text = 'Score: $score',
     );
     break;
   ```

Adjust the score label if needed (e.g. `'Level: ${score + 1}'` for level-based games).

---

## Step 5: Add Icon Asset

**Location:** `assets/images/ic_your_game.png`

Add a PNG icon (recommended ~160×160 or similar square). The `pubspec.yaml` includes `assets/images/`, so new files are picked up automatically. Run `flutter pub get` if the asset is not detected.

---

## Files Summary

| Step | File |
|------|------|
| 1 | `lib/game/my_casual_game.dart` |
| 2 | `lib/game/config/game_type_config.dart` |
| 3 | `lib/features/gameplay/<game_name>/<game>_delegate.dart` (new) |
| 4 | `lib/game/routes/gameplay_route.dart` |
| 5 | `assets/images/ic_<game>.png` (new) |

---

## No Changes Needed

- **Select game router / overlay**: `SelectGameRoute` and `SelectGameOverlay` iterate `GameType.values` and `GameCard(gameType)`, so new games appear automatically.
- **Routes**: `loading`, `intro`, `select_game`, `menu`, `play`, `pause`, `game_over` stay the same.
- **main.dart**: `overlayBuilderMap` only has `select_game`; no per-game overlay.
- **pubspec.yaml**: `assets/images/` already covers new icons.

---

## Optional: High Score Storage

High scores use `LocalStorage.getHighScore(gameName)` where `gameName` is `game.selectedGameType.name` (the enum `name`). No extra wiring needed.
