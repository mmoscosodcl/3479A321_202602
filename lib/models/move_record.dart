// lib/models/move_record.dart
import 'package:flutter/foundation.dart';
import 'board_position.dart';

/// Representa una acción cinemática atómica de salto ortogonal en el tablero.
@immutable
class MoveRecord {
  final BoardPosition from;
  final BoardPosition to;
  final DateTime timestamp;

  const MoveRecord({
    required this.from,
    required this.to,
    required this.timestamp,
  });

  /// Serializa la jugada a un mapa clave-valor.
  Map<String, dynamic> toJson() => {
        'fromRow': from.row,
        'fromCol': from.col,
        'toRow': to.row,
        'toCol': to.col,
        'timestamp': timestamp.toIso8601String(),
      };

  /// Construye un registro de movimiento desde un mapa deserializado.
  factory MoveRecord.fromJson(Map<String, dynamic> json) {
    return MoveRecord(
      from: BoardPosition(json['fromRow'] as int, json['fromCol'] as int),
      to: BoardPosition(json['toRow'] as int, json['toCol'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  @override
  String toString() => 'MoveRecord($from -> $to at $timestamp)';
}