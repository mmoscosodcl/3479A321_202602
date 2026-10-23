# Sprint 2: Usabilidad y Mecánicas de Juego (Game UX & State)

> **Módulo:** Experiencia del Jugador y Gestión de Estado  
> **Objetivo:** Aumentar la retención y satisfacción del jugador mediante mecánicas clave como Deshacer, Pistas visuales, Temporizador y Guardado de Partida.

---

## 1. Alcance y Objetivos del Sprint

1. **Mecánica de Deshacer Movimiento (`Undo`)**:
   - Permitir revertir el último movimiento realizado (volver a colocar la pieza saltada y mover la clavija a su posición previa).
   - Decrementar el contador de movimientos o registrar el evento en el historial de jugadas.
   - Proporcionar botón con icono `Icons.undo_rounded` en la barra superior o tablero.

2. **Resaltado de Movimientos Posibles (Hints / Visual Affordance)**:
   - Al seleccionar una clavija, calcular las posiciones destino válidas y resaltarlas visualmente (ej. borde punteado o halo tenue en las casillas vacías a 2 casillas de distancia ortogonal).
   - Ayuda a nuevos jugadores a comprender las reglas de salto del Solitario Inglés.

3. **Temporizador Visible en Vivo (Live Game Timer)**:
   - El modelo de datos ya almacena `durationSeconds`, pero la pantalla no muestra un reloj en ejecución.
   - Implementar un cronómetro reactivo (`Timer.periodic` de 1 segundo) visible en el `ScoreBoard` (`01:23`).
   - Pausar el cronómetro cuando la app pase a segundo plano o se abra el menú de ayuda.

4. **Persistencia y Recuperación de Partida en Curso (`Save & Resume`)**:
   - Guardar el estado del tablero (`List<List<CellType>>`), tiempo y movimientos en almacenamiento local (`PreferencesService`) ante interrupciones.
   - En el menú principal, habilitar el botón *"Continuar partida"* si existe una sesión pendiente no finalizada.

---

## 2. Tareas de Implementación

### Tarea 2.1: Lógica de `undo()` en `PegSolitaireViewModel`
- Implementar en [lib/viewmodels/peg_solitaire_viewmodel.dart](file:///Users/manuel/Documents/flutter_projects/3479A321_202602/flutter_pegsolitaire/lib/viewmodels/peg_solitaire_viewmodel.dart):
  ```dart
  bool get canUndo => _movesHistory.isNotEmpty && !_isGameOver;

  void undoLastMove() {
    if (!canUndo) return;
    final lastMove = _movesHistory.removeLast();
    // Revertir posiciones: origen pasa a occupiedPeg, destino a emptyHole, saltada a occupiedPeg
    _board[lastMove.from.row][lastMove.from.col] = CellType.occupiedPeg;
    _board[lastMove.to.row][lastMove.to.col] = CellType.emptyHole;
    _board[lastMove.jumped.row][lastMove.jumped.col] = CellType.occupiedPeg;
    _remainingPegs++;
    _moveCount--;
    notifyListeners();
  }
  ```

### Tarea 2.2: Cálculo de Movimientos Válidos
- Crear un método en el ViewModel: `List<BoardPosition> getValidDestinationsFor(BoardPosition pos)`.
- Pasar a `PegCell` una propiedad `isTargetHint` para renderizar el borde de destino disponible.

### Tarea 2.3: Cronómetro en ViewModel
- Inicializar y detener `Timer.periodic(const Duration(seconds: 1), ...)` en sincronía con el ciclo de vida de la partida.
- Exponer `String get formattedTime` hacia la UI.

### Tarea 2.4: Botón Deshacer en `PegSolitaireScreen`
- Agregar un `IconButton` con `Icons.undo` en la barra superior (`actions`) habilitado solo si `vm.canUndo`.

---

## 3. Criterios de Aceptación (DoD)

- [ ] El botón de Deshacer revierte exactamente el estado del tablero y restaura las clavijas.
- [ ] Al seleccionar una clavija con movimientos válidos, los huecos destino muestran una guía visual.
- [ ] El tiempo transcurrido avanza segundo a segundo en pantalla y se guarda fielmente en el historial.
- [ ] Al cerrar la aplicación accidentalmente, el jugador puede continuar la partida pendiente.
