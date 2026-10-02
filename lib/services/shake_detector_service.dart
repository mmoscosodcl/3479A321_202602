import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Servicio desacoplado para detectar agitación física con gestión de ciclo de vida del SO.
class ShakeDetectorService {
  final double shakeThreshold;
  final VoidCallback onShake;
  final Duration debounceDuration;
  final Logger _logger = Logger();

  StreamSubscription<UserAccelerometerEvent>? _subscription;
  late final AppLifecycleListener _lifecycleListener;
  DateTime _lastShakeTime = DateTime.now();
  bool _isListening = false;

  /// Creates a new instance of [ShakeDetectorService].
  ///
  /// The [onShake] callback is required and will be invoked when a shake gesture
  /// is detected based on the configured [shakeThreshold].
  ///
  /// Parameters:
  ///   * [onShake] - Required callback function that is triggered when a shake
  ///     event occurs.
  ///   * [shakeThreshold] - The acceleration threshold in m/s² that triggers a
  ///     shake event. Defaults to 3 m/s².
  ///   * [debounceDuration] - The minimum time interval between consecutive shake
  ///     detections to prevent multiple triggers. Defaults to 1200 milliseconds.
  ///
  /// Upon initialization, the lifecycle listener is automatically set up to manage
  /// the service's lifecycle events.
  ShakeDetectorService({
    required this.onShake,
    this.shakeThreshold = 3, // Umbral en m/s²
    this.debounceDuration = const Duration(milliseconds: 1200),
  }) {
    _initLifecycleListener();
  }

  /// Vincula la escucha del hardware a los estados del Sistema Operativo
  void _initLifecycleListener() {
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _logger.i('SO Resumed: Reanudando sensor de aceleración');
        startListening();
      },
      onPause: () {
        _logger.i('SO Paused: Suspendiendo sensor para mitigar consumo de batería');
        stopListening();
      },
      onDetach: () => dispose(),
    );
  }

  /// Inicia la suscripción al stream de eventos del sensor
  void startListening() {
    if (_isListening) return;

    _subscription = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        // Cálculo de la norma euclidiana del vector
        final double magnitude = sqrt(
          event.x * event.x + event.y * event.y + event.z * event.z,
        );
        _logger.i('magnitude ${magnitude} shakeThreshold ${shakeThreshold}> ');
        if (magnitude > shakeThreshold) {
          final now = DateTime.now();
          if (now.difference(_lastShakeTime) > debounceDuration) {
            _lastShakeTime = now;
            _logger.i('¡Shake detectado! Magnitud: ${magnitude.toStringAsFixed(2)} m/s²');
            onShake();
          }
        }
      },
      onError: (error) {
        _logger.e('Error en el flujo del acelerómetro: $error');
      },
      cancelOnError: false,
    );

    _isListening = true;
    _logger.i('ShakeDetectorService: Escucha activa');
  }

  /// Detiene la suscripción al stream liberando el hilo de eventos
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
    _logger.i('ShakeDetectorService: Escucha detenida');
  }

  /// Liberación completa de recursos
  void dispose() {
    stopListening();
    _lifecycleListener.dispose();
  }
}