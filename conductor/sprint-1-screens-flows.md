# Sprint 1: Pantallas y Flujos Faltantes (Information Architecture & Navigation)

> **Módulo:** Navegación, Ajustes y Diálogos de Sistema  
> **Objetivo:** Implementar los flujos y pantallas ausentes requeridos para una experiencia de usuario estándar en Google Play.

---

## 1. Alcance y Objetivos del Sprint

1. **Pantalla de Ajustes (`SettingsScreen`)**:
   - Conmutadores para silenciar/activar efectos de audio (`AudioService`).
   - Conmutador para activar/desactivar retroalimentación háptica (`HapticFeedback`).
   - Conmutador para activar/desactivar o calibrar la detección de agitación (`ShakeDetectorService`).
   - Selector de tema visual: Modo Claro, Modo Oscuro o Predeterminado del Sistema.
   - Persistencia de estas preferencias en `PreferencesService` (`shared_preferences`).

2. **Modal / Pantalla "Acerca de" (`AboutDialog` / `AboutScreen`)**:
   - Mostrar número de versión dinámica (`v1.0.0+1`), información legal, autoría.
   - Enlace directo a la Política de Privacidad (requisito de Play Console).
   - Acceso a licencias de paquetes abiertos mediante `showLicensePage`.

3. **Diálogo de Confirmación de Salida / Reinicio (`PopScope`)**:
   - Prevenir la pérdida accidental de progreso al pulsar el botón "Atrás" de Android o el botón de reiniciar durante una partida activa.
   - Implementar widget `PopScope` con diálogo de confirmación: *"¿Deseas salir? La partida en progreso se perderá o guardará."*

4. **Modal / BottomSheet Dedicado de Fin de Partida**:
   - Reemplazar la barra plana inferior por un `showModalBottomSheet` o diálogo estilizado con:
     - Título destacado: Victoria Perfecta o Sin Movimientos.
     - Estadísticas finales (tiempo, movimientos, clavijas restantes).
     - Botones de acción rápida: *Volver a Jugar*, *Compartir Resultado*, *Menú Principal*.

---

## 2. Tareas de Implementación

### Tarea 1.1: Ampliar `PreferencesService`
- Añadir claves y métodos para guardar y leer:
  - `bool getSoundEnabled()` / `Future<void> setSoundEnabled(bool value)`
  - `bool getHapticsEnabled()` / `Future<void> setHapticsEnabled(bool value)`
  - `bool getShakeResetEnabled()` / `Future<void> setShakeResetEnabled(bool value)`
  - `ThemeMode getThemeMode()` / `Future<void> setThemeMode(ThemeMode mode)`

### Tarea 1.2: Crear `lib/ui/screens/settings_screen.dart`
- Formulario limpio en `ListView` usando componentes `SwitchListTile` y `ListTile` con iconos Material 3.
- Integrar con el Provider del estado global de preferencias.

### Tarea 1.3: Conectar el Menú Principal
- En [lib/ui/screens/menu_screen.dart](file:///Users/manuel/Documents/flutter_projects/3479A321_202602/flutter_pegsolitaire/lib/ui/screens/menu_screen.dart), agregar accesos a:
  - `CONFIGURACIÓN` (`/settings`).
  - Botón de información / Acerca de en el `AppBar` (`Icons.info_outline`).

### Tarea 1.4: Protección de Navegación en `PegSolitaireScreen`
- Envolver el `Scaffold` de [lib/ui/screens/peg_solitaire_screen.dart](file:///Users/manuel/Documents/flutter_projects/3479A321_202602/flutter_pegsolitaire/lib/ui/screens/peg_solitaire_screen.dart) con `PopScope(canPop: !isGameInProgress, onPopInvokedWithResult: ...)` para desplegar confirmación.

---

## 3. Criterios de Aceptación (DoD)

- [ ] El usuario puede silenciar sonidos y la app respeta el estado inmediatamente.
- [ ] La opción "Acerca de" muestra la versión y el enlace a la política de privacidad.
- [ ] Al presionar atrás durante una partida activa, no se cierra la pantalla sin confirmación previa.
- [ ] El fin de partida despliega un diálogo o modal con acciones claras para el usuario.
