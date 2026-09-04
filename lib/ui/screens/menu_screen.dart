// lib/ui/screens/menu_screen.dart
import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(Icons.grid_4x4_rounded, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'PEG SOLITAIRE',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('NUEVA PARTIDA'),
                onPressed: () {
                  Navigator.pushNamed(context, '/game');
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.history_rounded),
                label: const Text('HISTORIAL DE PARTIDAS'),
                onPressed: () => Navigator.pushNamed(context, '/history'),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                icon: const Icon(Icons.help_outline_rounded),
                label: const Text('REGLAS DEL JUEGO'),
                onPressed: () => Navigator.pushNamed(context, '/rules'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}