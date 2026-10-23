# Sprint 4: Accesibilidad y Estándares WCAG (A11y Compliance)

> **Módulo:** Accesibilidad Móvil, Lectores de Pantalla y Contraste  
> **Objetivo:** Garantizar que la aplicación sea plenamente accesible para todos los usuarios, compatible con TalkBack (Android) y conforme a las directrices WCAG 2.1 AA.

---

## 1. Alcance y Objetivos del Sprint

1. **Semántica para Lectores de Pantalla (TalkBack)**:
   - Actualmente las casillas en `PegCell` son contenedores mudos sin información semántica.
   - Envolver cada celda en `Semantics` informando:
     - Coordenada matricial o posición en el tablero (ej. *"Fila 4, Columna 4, Centro"*).
     - Estado de la casilla: *"Clavija presente"* o *"Hueco vacío"*.
     - Estado de interacción: *"Seleccionada. Toca para deseleccionar"* o *"Destino válido disponible para salto"*.

2. **Dimensiones de Área Táctil Mínima (Touch Target Size)**:
   - Material Design y WCAG requieren al menos **48x48 dp** de área táctil por elemento interactivo en Android.
   - Configurar `HitTestBehavior.opaque` y asegurar márgenes suficientes en la cuadrícula de 7x7 para que toda el área de celda capture el evento táctil sin zonas muertas.

3. **Corrección de Ratios de Contraste Visual (WCAG AA: 4.5:1)**:
   - Corregir el texto en `HistoryScreen`:
     ```dart
     // ANTES: Colors.amber sobre fondo claro no cumple ratio 4.5:1
     color: Colors.amber
     ```
     Sustituir por tokens de color accesibles del `ColorScheme` (`colorScheme.primary` o tonos con contraste verificado mayor a 4.5:1).
   - Revisar contraste de textos informativos en el `ScoreBoard` y `RulesScreen`.

4. **Escalabilidad de Texto (Text Scaling / FontScale)**:
   - Probar y adaptar layouts para que no ocurra desbordamiento (*RenderFlex overflow*) cuando el usuario activa fuentes grandes (130% - 200%) en la configuración de accesibilidad de Android.

---

## 2. Tareas de Implementación

### Tarea 4.1: Semántica en `lib/ui/widgets/peg_cell.dart`
- Envolver el widget de retorno en `Semantics`:
  ```dart
  String _buildSemanticLabel() {
    final rowNumber = position.row + 1;
    final colNumber = position.col + 1;
    final status = cellType == CellType.occupiedPeg ? 'Clavija ocupada' : 'Hueco vacío';
    final action = isSelected ? 'Seleccionada. Toca para cancelar.' : 'Toca para seleccionar.';
    return 'Posición fila $rowNumber columna $colNumber, $status. $action';
  }

  @override
  Widget build(BuildContext context) {
    if (cellType == CellType.voidCell) {
      return const ExcludeSemantics(child: SizedBox.shrink());
    }

    return Semantics(
      label: _buildSemanticLabel(),
      button: true,
      enabled: true,
      selected: isSelected,
      child: GestureDetector(...),
    );
  }
  ```

### Tarea 4.2: Auditoría y Corrección de Contrastes en `HistoryScreen`
- Modificar el título de resultado en [lib/ui/screens/history_screen.dart](file:///Users/manuel/Documents/flutter_projects/3479A321_202602/flutter_pegsolitaire/lib/ui/screens/history_screen.dart):
  ```dart
  color: record.isVictory ? Colors.green.shade800 : Colors.red.shade900,
  ```

### Tarea 4.3: Pruebas Automatizadas de Accesibilidad
- Crear prueba de widgets en `test/a11y_test.dart` utilizando los inspectores de accesibilidad de Flutter:
  ```dart
  testWidgets('Peg Solitaire cumple directrices de accesibilidad', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(const MyApp());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });
  ```

---

## 3. Criterios de Aceptación (DoD)

- [ ] Un usuario con TalkBack puede navegar por el tablero y comprender qué clavijas puede mover y hacia dónde.
- [ ] No existen textos con contraste inferior a 4.5:1 respecto a su fondo en modo claro y oscuro.
- [ ] Todos los botones y celdas táctiles cumplen el estándar de 48x48 dp.
- [ ] Las pruebas de accesibilidad con `meetsGuideline` pasan sin fallos.
