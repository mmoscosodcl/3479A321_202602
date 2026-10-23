import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pegsolitaire/repositories/game_history_repository.dart';
import 'package:flutter_pegsolitaire/services/audio_service.dart';
import 'package:flutter_pegsolitaire/services/preferences_service.dart';
import 'package:flutter_pegsolitaire/ui/screens/menu_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/peg_solitaire_screen.dart';
import 'package:flutter_pegsolitaire/ui/theme/app_theme.dart';
import 'package:flutter_pegsolitaire/viewmodels/peg_solitaire_viewmodel.dart';
import 'package:provider/provider.dart';

import 'fakes/fake_audio_service.dart';
import 'fakes/fake_game_history_repository.dart';
import 'fakes/fake_preferences_service.dart';

void main() {
  testWidgets('A11y: MenuScreen cumple directrices de etiquetado y accesibilidad', (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    final fakeRepo = FakeGameHistoryRepository();
    final fakePrefs = FakePreferencesService();
    final fakeAudio = FakeAudioService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IGameHistoryRepository>.value(value: fakeRepo),
          ChangeNotifierProvider<PreferencesService>.value(value: fakePrefs),
          Provider<AudioService>.value(value: fakeAudio),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const MenuScreen(),
        ),
      ),
    );

    // Verificación de directrices de Flutter Accessibility
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('A11y: PegSolitaireScreen proporciona nodos semánticos por celda', (WidgetTester tester) async {
    final handle = tester.ensureSemantics();
    final fakeRepo = FakeGameHistoryRepository();
    final fakePrefs = FakePreferencesService();
    final fakeAudio = FakeAudioService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<IGameHistoryRepository>.value(value: fakeRepo),
          ChangeNotifierProvider<PreferencesService>.value(value: fakePrefs),
          Provider<AudioService>.value(value: fakeAudio),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: ChangeNotifierProvider(
            create: (_) => PegSolitaireViewModel(
              historyRepository: fakeRepo,
              preferencesService: fakePrefs,
              audioService: fakeAudio,
            ),
            child: const PegSolitaireScreen(),
          ),
        ),
      ),
    );

    // Verificar que los botones táctiles estén debidamente etiquetados para TalkBack
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
