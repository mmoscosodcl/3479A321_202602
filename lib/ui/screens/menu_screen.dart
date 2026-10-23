import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/services/preferences_service.dart';
import 'package:flutter_pegsolitaire/viewmodels/peg_solitaire_viewmodel.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});


  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Solitario Inglés',
      applicationVersion: '1.0.0+1',
      applicationIcon: const Icon(Icons.extension_rounded, size: 48, color: Color.fromARGB(255, 12, 80, 157)),
      applicationLegalese: '© 2026 Manuel Moscoso. Todos los derechos reservados.\nJuego clásico de lógica y tablero para un jugador.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Elimina clavijas saltando sobre ellas de forma ortogonal hasta conservar una única pieza en el centro.',
        ),
        const SizedBox(height: 12),
        const Text(
          'Política de Privacidad: Esta aplicación no recopila ni transfiere datos personales a servidores externos.',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prefs = context.watch<PreferencesService>();
    final hasActiveGame = prefs.hasActiveGame;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solitario Inglés'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Acerca de',
            onPressed: () => _showAboutAppDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
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
              if (hasActiveGame) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Continuar Partida Activa'),
                    onPressed: () {
                      final snapshot = prefs.activeGameSnapshot;
                      if (snapshot != null) {
                        final vm = context.read<PegSolitaireViewModel>();
                        vm.restoreFromSnapshot(snapshot);
                        Navigator.pushNamed(context, '/game');
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
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
              OutlinedButton.icon(
                icon: const Icon(Icons.settings_outlined),
                label: const Text('CONFIGURACIÓN'),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
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