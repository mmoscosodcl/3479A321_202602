# Flutter Peg Solitaire (Solitario Inglés)

Aplicación móvil desarrollada en Flutter para el clásico juego de tablero y lógica **Solitario Inglés** (*Peg Solitaire*). El objetivo principal del juego es eliminar clavijas saltando sobre ellas de forma ortogonal hasta conservar una única pieza en el centro del tablero.

---

## Alcance

### Dentro del Alcance (In-Scope)
- **Implementación del Tablero Inglés**: Modelado y renderizado del tablero tradicional en cruz de 7x7 celdas (33 posiciones jugables y esquinas 2x2 bloqueadas/invisibles).
- **Mecánica de Juego e Interacción**: Selección interactiva de piezas con retroalimentación visual reactiva (bordes destacados y sombras dinámicas), validación de saltos ortogonales (arriba, abajo, izquierda, derecha) sobre casillas contiguas hacia huecos vacíos y eliminación de la pieza saltada.
- **Gestión del Estado de Partida**: Monitoreo en tiempo real del tiempo transcurrido, conteo de movimientos efectuados, piezas restantes en el tablero y detección automática de fin de juego (victoria al quedar una ficha o derrota si no quedan movimientos válidos).
- **Menú y Navegación de la Aplicación**: Navegación fluida y desacoplada mediante rutas nombradas hacia las pantallas de Menú Principal (`MenuScreen`), Partida Activa (`PegSolitaireScreen`), Historial de Partidas (`HistoryScreen`) y Reglas del Juego (`RulesScreen`).
- **Historial de Partidas**: Visualización de partidas concluidas detallando fecha, hora, duración formateada, cantidad de movimientos, fichas restantes y resultado (victoria o derrota).
- **Pantalla Informativa de Reglas**: Sección accesible tanto desde el menú principal como mediante un acceso directo en la barra superior del tablero durante la partida.
- **Identidad Visual y Tema**: Diseño visual con Material 3, soporte para paletas inspiradas en madera/nogal y tipografía personalizada (`TacoCrispy`).
- **Trazabilidad y Registro**: Integración de logging estructurado (`logger`) para seguimiento de eventos de interacción, selección y navegación en consola.

### Fuera del Alcance (Out-of-Scope)
- Modo multijugador en línea o partidas sincronizadas por red.
- Variantes alternativas de tablero (como el tablero continental/francés de 37 casillas o tableros triangulares).
- Persistencia de datos en bases de datos remotas en la nube (la persistencia o simulación se gestiona a nivel local).
- Sistema de monetización, anuncios o compras dentro de la aplicación (*in-app purchases*).

---

## Requerimientos Funcionales

Todos los requerimientos funcionales especifican el comportamiento esperado del sistema y cumplen la pauta de redacción requerida:

1. **RF-01**: **La aplicación** debe presentar un menú principal con accesos directos para iniciar una nueva partida, revisar el historial de partidas y consultar las reglas del juego.
2. **RF-02**: **La aplicación** debe renderizar un tablero de 7x7 casillas con la geometría en cruz del Solitario Inglés, omitiendo visual y funcionalmente las cuatro esquinas de 2x2 casillas.
3. **RF-03**: **La aplicación** debe inicializar cada nueva partida configurando 32 casillas con clavijas presentes y la casilla central como hueco vacío desocupado.
4. **RF-04**: **La aplicación** debe permitir seleccionar una clavija mediante pulsación táctil, reflejando de forma inmediata un indicador visual de selección activa con borde contrastado y resplandor.
5. **RF-05**: **La aplicación** debe permitir deseleccionar una clavija activa si el usuario pulsa nuevamente sobre la misma casilla seleccionada.
6. **RF-06**: **La aplicación** debe validar y ejecutar movimientos ortogonales válidos en los que una clavija salta sobre otra adyacente hacia un hueco vacío, retirando inmediatamente la clavija sobre la cual se saltó.
7. **RF-07**: **La aplicación** debe contabilizar y mostrar continuamente en la interfaz de juego la cantidad de piezas restantes, el número total de movimientos realizados y el tiempo transcurrido en segundos.
8. **RF-08**: **La aplicación** debe evaluar y notificar el fin de la partida, determinando victoria cuando quede exactamente una clavija en el tablero o derrota cuando no existan más movimientos ortogonales posibles.
9. **RF-09**: **La aplicación** debe registrar los datos finales de cada partida jugada, incluyendo identificador único, fecha y hora de finalización, duración total, movimientos acumulados, piezas restantes y estado de victoria o derrota.
10. **RF-10**: **La aplicación** debe presentar una pantalla de historial que liste las partidas registradas ordenadas cronológicamente, formateando las duraciones (minutos y segundos) y destacando el estado mediante iconografía y colores diferenciados.
11. **RF-11**: **La aplicación** debe disponer de una pantalla de reglas del juego con las instrucciones y objetivo, accesible desde el menú principal y mediante un botón de ayuda contextual en la barra de aplicación de la pantalla de juego.
12. **RF-12**: **La aplicación** debe emitir registros de depuración e información en consola ante eventos clave del ciclo de vida del juego (selección, deselección, navegación y estado del tablero).

---

## Requerimientos No Funcionales

A continuación se presentan los requerimientos no funcionales del sistema, incorporando de manera explícita su respectivo valor de medida y criterio de aceptación cuantificable:

| ID | Requerimiento | Descripción | Valor de Medida / Criterio de Aceptación Cuantificable |
| :--- | :--- | :--- | :--- |
| **RNF-01** | **Fluidez de Renderizado (Frame Rate)** | La interfaz de usuario, transiciones entre pantallas y animaciones de selección en el tablero deben ejecutarse con fluidez sostenida. | Mantener una tasa de refresco constante de **60 FPS** (tiempo de procesamiento por cuadro inferior a **16.6 ms**) sin caídas apreciables (*jank*). |
| **RNF-02** | **Latencia de Respuesta Táctil** | El tiempo de respuesta entre el toque del usuario en una casilla y el refresco visual en la interfaz debe ser prácticamente imperceptible. | Tiempo de respuesta táctil inferior a **100 milisegundos (ms)** desde la captura del evento `onTap`. |
| **RNF-03** | **Tiempo de Carga Inicial (Cold Start)** | El tiempo que tarda la aplicación en abrirse y dejar interactivo el menú principal desde un inicio en frío debe ser reducido. | Tiempo de arranque en frío menor a **2.0 segundos** en dispositivos móviles de gama media. |
| **RNF-04** | **Tamaño del Área Táctil (Touch Target Size)** | Las celdas jugables del tablero deben contar con un área de contacto suficiente para evitar toques accidentales o dificultad de pulsación en pantallas táctiles. | Cada casilla táctil interactiva debe cumplir con un tamaño mínimo de impacto de **48 x 48 dp (puntos lógicos)** según las directrices de Material Design. |
| **RNF-05** | **Compatibilidad de Plataformas Móviles** | La aplicación debe ser compatible y ejecutable en las versiones vigentes de los sistemas operativos móviles más utilizados. | Soporte garantizado para **Android 8.0 (API nivel 26) o superior** e **iOS 14.0 o superior** (abarcando más del 95% de dispositivos móviles en uso). |
| **RNF-06** | **Consumo de Memoria RAM** | La huella de memoria durante la ejecución de la aplicación debe ser contenida y libre de pérdidas de memoria (*leaks*). | Consumo de memoria RAM residente no superior a **120 MB** durante una partida activa en el dispositivo móvil. |
| **RNF-07** | **Tamaño del Paquete de Instalación** | El tamaño del paquete final compilado debe ser liviano para facilitar su descarga y almacenamiento en el dispositivo. | Peso del binario compilado en modo lanzamiento (*release*) inferior a **25 MB** para formato APK en Android. |
| **RNF-08** | **Calidad y Estilo del Código Fuente** | El código base debe cumplir los estándares y directrices recomendadas por el equipo de Flutter y Dart. | **0 errores de análisis estático y 0 advertencias severas** reportadas por la herramienta oficial `flutter analyze` bajo la configuración de `analysis_options.yaml`. |

---

## Arquitectura y Estructura del Proyecto

El código fuente se organiza siguiendo una separación limpia de responsabilidades:

```text
lib/
├── core/
│   └── enums/
│       └── cell_type.dart          # Definición de tipos de casilla (voidCell, emptyHole, occupiedPeg)
├── models/
│   └── game_record.dart            # Modelo de datos de partida completada
├── ui/
│   ├── screens/
│   │   ├── menu_screen.dart        # Menú principal de la aplicación
│   │   ├── peg_solitaire_screen.dart # Pantalla y tablero de juego interactivo
│   │   ├── history_screen.dart     # Listado y visualización del historial de partidas
│   │   └── rules_screen.dart       # Pantalla con las reglas e instrucciones del juego
│   ├── theme/
│   │   └── app_theme.dart          # Configuración del tema Material 3 y tipografías
│   └── widgets/
│       └── peg_cell.dart           # Widget individual para renderizar cada celda interactiva
└── main.dart                       # Entrada principal de la aplicación y enrutamiento
```

---

## Ejecución del Proyecto

1. Asegurarse de tener instalado Flutter (versión `>= 3.13.0`):
   ```bash
   flutter doctor
   ```
2. Obtener las dependencias del proyecto:
   ```bash
   flutter pub get
   ```
3. Ejecutar la aplicación en el dispositivo o simulador preferido:
   ```bash
   flutter run
   ```
4. Ejecutar el análisis estático de código:
   ```bash
   flutter analyze
   ```
