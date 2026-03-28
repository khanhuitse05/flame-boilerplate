import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

import 'routes/main_menu_route.dart';
import 'routes/gameplay_route.dart';
import 'routes/pause_route.dart';
import 'routes/game_over_route.dart';

enum GameType { colorMatch }

class MyCasualGame extends FlameGame {
  late final RouterComponent router;
  int lastScore = 0;
  bool lastGameWon = false;

  @override
  Future<void> onLoad() async {
    await FlameAudio.bgm.initialize();
    images.prefix = 'assets/';
    router = RouterComponent(
      initialRoute: 'menu',
      routes: {
        'menu': Route(MainMenuRoute.new),
        'play': Route(GameplayRoute.new),
        'pause': Route(PauseRoute.new),
        'game_over': Route(GameOverRoute.new, maintainState: false),
      },
    );
    add(router);
  }
}
