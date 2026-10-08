import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/repositories/game_history_repository.dart';
import 'package:flutter_pegsolitaire/repositories/json_file_history_repository.dart';
import 'package:flutter_pegsolitaire/services/preferences_service.dart';
import 'package:flutter_pegsolitaire/ui/screens/history_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/menu_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/peg_solitaire_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/rules_screen.dart';
import 'package:flutter_pegsolitaire/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'viewmodels/peg_solitaire_viewmodel.dart';


Future<void> main() async {
  // 1. Asegurar la vinculación con el canal de plataforma nativo (Android/iOS)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Resolver dependencias de infraestructura de forma asíncrona
  final preferencesService = await PreferencesService.create();
  final historyRepository = JsonFileHistoryRepository();


// 3. Inyectar dependencias en la raíz del árbol
  runApp(
    MultiProvider(
      providers: [
        // Inyección por interfaz abstracta (DIP)
        Provider<IGameHistoryRepository>.value(value: historyRepository),
        Provider<PreferencesService>.value(value: preferencesService),
      ],
      child: const MyApp(),
    ),
  );}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
   @override
 Widget build(BuildContext context) {
   return MaterialApp(
     title: 'Solitario Ingles',
     theme: AppTheme.lightTheme,
     initialRoute: '/',
      routes: {
        '/': (context) => const MenuScreen(),
        '/game': (context) => ChangeNotifierProvider(
              create: (routeContext) => PegSolitaireViewModel(
                historyRepository: routeContext.read<IGameHistoryRepository>(),
                preferencesService: routeContext.read<PreferencesService>(),
              ),
              child: PegSolitaireScreen(),
            ),
        '/history': (context) => const HistoryScreen(),
        '/rules': (context) => const RulesScreen(),
      },
   );
 }
}
