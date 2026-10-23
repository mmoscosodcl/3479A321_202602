# Sprint 3: Material Design 3 y Diseño Visual (Visual Polish)

> **Módulo:** Identidad Visual, Temas y Renderizado de Componentes  
> **Objetivo:** Adaptar la aplicación a las directrices de Material Design 3, habilitar Modo Oscuro nativo y dotar al tablero de un acabado visual atractivo y realista.

---

## 1. Alcance y Objetivos del Sprint

1. **Soporte Oficial para Modo Oscuro (`ThemeMode.system` y `darkTheme`)**:
   - Actualmente solo existe `lightTheme`.
   - Definir `AppTheme.darkTheme` utilizando una paleta adaptada a tonos noche con tonos nogal ahumado (`#1E1B18`), contrastes suaves en celdas y texto con alta legibilidad.
   - Configurar `MaterialApp` para soportar `themeMode: ThemeMode.system` (o la preferencia guardada por el usuario en el Sprint 1).

2. **Diseño de Tablero Texturizado y Sensación Física**:
   - Enriquecer `PegCell`:
     - Clavijas ocupadas: degradado radial sutil (*RadialGradient*), sombra arrojada suave (*drop shadow*) para dar sensación tridimensional de pieza de madera o canica.
     - Huecos vacíos: efecto de hendidura en bajo relieve (*inner bevel* o sombra interna en el marco).
     - Borde del tablero: marco redondeado con color madera y ligera sombra de elevación.

3. **Consistencia Tipográfica y Micro-interacciones**:
   - Extender el uso de la fuente `TacoCrispy` a encabezados de pantalla, marcadores principales y títulos de diálogos.
   - Reforzar animaciones de transición: animación de escala suave (*ScaleTransition* o `AnimatedScale`) al pulsar y saltar piezas.

4. **Rediseño del Menú Principal (`MenuScreen`)**:
   - Pasar de una columna plana de botones a una pantalla de bienvenida inmersiva con logotipo, ilustración del tablero o gráfico de piezas, y botones con elevación y jerarquía visual clara.

---

## 2. Tareas de Implementación

### Tarea 3.1: Actualizar `lib/ui/theme/app_theme.dart`
- Definir `ThemeData get darkTheme`:
  ```dart
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeed,
        brightness: Brightness.dark,
        surface: const Color(0xFF1E1B18),
        surfaceContainerHighest: const Color(0xFF2C2825),
      ),
      scaffoldBackgroundColor: const Color(0xFF12100E),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E1B18),
        foregroundColor: Colors.white,
      ),
    );
  }
  ```

### Tarea 3.2: Refactorizar `lib/ui/widgets/peg_cell.dart`
- Agregar degradados y sombras dinámicas según el brillo actual (`Theme.of(context).brightness`).
- Mejorar el estado de selección con un halo pulsante o borde acentuado de Material 3.

### Tarea 3.3: Soporte en `main.dart`
- Inyectar el tema oscuro y enlazar la propiedad `themeMode` con el estado reactivo del usuario.

---

## 3. Criterios de Aceptación (DoD)

- [ ] La aplicación cambia fluidamente entre modo claro y modo oscuro según la configuración del sistema.
- [ ] Las clavijas y huecos del tablero lucen integrados y con profundidad visual sin perder rendimiento (manteniendo 60 FPS).
- [ ] El menú principal tiene identidad de marca consistente con los assets del juego.
- [ ] No existen textos ilegibles o bordes que desaparezcan al cambiar de tema.
