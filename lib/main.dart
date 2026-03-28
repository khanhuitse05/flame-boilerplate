import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
import 'package:flame/game.dart';

import 'core/di/locator.dart';
import 'core/storage/local_storage.dart';
import 'features/audio/audio_controller.dart';
import 'features/settings/settings_cubit.dart';
import 'features/score/score_cubit.dart';
import 'game/my_casual_game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              SettingsCubit(getIt<LocalStorage>(), getIt<AudioController>()),
        ),
        BlocProvider(create: (_) => ScoreCubit(getIt<LocalStorage>())),
      ],
      child: MaterialApp(
        title: 'Casual Game',
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(body: GameView()),
      ),
    );
  }
}

class GameView extends StatelessWidget {
  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return GameWidget.controlled(gameFactory: MyCasualGame.new);
  }
}
