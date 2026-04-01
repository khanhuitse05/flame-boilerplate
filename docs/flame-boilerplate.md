# Flame boilerplate

---

## Why it exists

- **RouterComponent** routes match product screens: `menu`, `play`, `pause`, `game_over`.
- **GameplayDelegate** is the single contract for score, reset, and game over.
- **DI + cubits + `LocalStorage`** aligned with high-score keys and settings.

**In one sentence:** With template you can swap or add mini-games.

---

## Mental model

```
Flutter (MaterialApp, BLoC, settings)
       │
       └── GameWidget ──► FlameGame (root)
                              └── RouterComponent
                                    └── Route components (menu, play, pause, game over)
```

- **Menus and HUD in this template** are mostly **Flame components** (same world as gameplay), not Flutter routes—except where you add overlays later.
- **Flame** gives **`update(dt)` / `render`**, components, input mixins, and 2D-friendly APIs on top of Flutter’s ticker.

---

## Where things live (cheat sheet)

| Area                          | Path (high level)              |
| ----------------------------- | ------------------------------ |
| Entry + `GameWidget`          | `lib/main.dart`                |
| Game root, router, `GameType` | `lib/game/my_casual_game.dart` |
| Screens                       | `lib/game/routes/`             |
| Reusable in-game UI           | `lib/game/ui/`                 |
| Gameplay contract + games     | `lib/features/gameplay/`       |

---

## Extending (what we tell new contributors)

- **New mini-game:** Subclass **`GameplayDelegate`**, plug it in **`GameplayRoute`**, verify pause / restart / menu / game over.
- **Product rename:** Game class name, package/bundle IDs, replace **`assets/`** as needed.

---

## References

- [Flame docs](https://docs.flame-engine.org/)
- Project **`README.md`** for run/setup
- **`.cursor/skills/add-new-game/SKILL.md`** for multi-game checklist when using Cursor

---
