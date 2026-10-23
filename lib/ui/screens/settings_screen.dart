import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/services/audio_service.dart';
import 'package:flutter_pegsolitaire/services/preferences_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  late bool _vibrationEnabled;
  late bool _shakeResetEnabled;
  late String _themeModeName;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _soundEnabled = prefs.isSoundEnabled;
    _vibrationEnabled = prefs.isVibrationEnabled;
    _shakeResetEnabled = prefs.isShakeResetEnabled;
    _themeModeName = prefs.themeModeName;
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PreferencesService>();
    final audio = context.read<AudioService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SONIDO Y RESPUESTA HÁPTICA',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Efectos de sonido'),
            subtitle: const Text('Reproducir sonidos de selección, saltos y fin de partida'),
            value: _soundEnabled,
            onChanged: (value) async {
              setState(() => _soundEnabled = value);
              await prefs.setSoundEnabled(value);
              audio.isSoundEnabled = value;
            },
          ),
          SwitchListTile(
            secondary: Icon(
              _vibrationEnabled ? Icons.vibration_rounded : Icons.smartphone_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Vibración táctil'),
            subtitle: const Text('Retroalimentación háptica al pulsar las clavijas del tablero'),
            value: _vibrationEnabled,
            onChanged: (value) async {
              setState(() => _vibrationEnabled = value);
              await prefs.setVibrationEnabled(value);
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'SENSORES Y JUGABILIDAD',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            secondary: Icon(
              Icons.screen_rotation_rounded,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Agitar para reiniciar'),
            subtitle: const Text('Reiniciar automáticamente el tablero al agitar el teléfono cuando finaliza la partida'),
            value: _shakeResetEnabled,
            onChanged: (value) async {
              setState(() => _shakeResetEnabled = value);
              await prefs.setShakeResetEnabled(value);
            },
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'APARIENCIA',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.brightness_medium_rounded, color: theme.colorScheme.primary),
            title: const Text('Tema visual'),
            subtitle: Text(_getThemeLabel(_themeModeName)),
            trailing: DropdownButton<String>(
              value: _themeModeName,
              underline: const SizedBox.shrink(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  setState(() => _themeModeName = newValue);
                  await prefs.setThemeModeName(newValue);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tema guardado. Se aplicará según la configuración del sistema.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              items: const [
                DropdownMenuItem(value: 'system', child: Text('Predeterminado del sistema')),
                DropdownMenuItem(value: 'light', child: Text('Modo claro')),
                DropdownMenuItem(value: 'dark', child: Text('Modo oscuro')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeLabel(String mode) {
    switch (mode) {
      case 'light':
        return 'Modo claro forzado';
      case 'dark':
        return 'Modo oscuro forzado';
      case 'system':
      default:
        return 'Sincronizado con el sistema';
    }
  }
}
