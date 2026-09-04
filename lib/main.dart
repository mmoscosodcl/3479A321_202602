import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/ui/screens/history_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/menu_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/peg_solitaire_screen.dart';
import 'package:flutter_pegsolitaire/ui/screens/rules_screen.dart';
import 'package:flutter_pegsolitaire/ui/theme/app_theme.dart';


void main() {
  runApp(const MyApp());
}

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
        '/game': (context) => PegSolitaireScreen(),
        '/history': (context) => const HistoryScreen(),
        '/rules': (context) => const RulesScreen(),
      },
   );
 }
}
