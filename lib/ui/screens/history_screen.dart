import 'package:flutter/material.dart';
import '../../models/game_record.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  List<GameRecord> _getMockRecords() {
    return [
      GameRecord(
        id: 'REC-101',
        date: DateTime.now().subtract(const Duration(hours: 1)),
        remainingPegs: 1,
        totalMoves: 31,
        durationSeconds: 145,
        isVictory: true,
      ),
      GameRecord(
        id: 'REC-102',
        date: DateTime.now().subtract(const Duration(days: 1)),
        remainingPegs: 3,
        totalMoves: 29,
        durationSeconds: 215,
        isVictory: false,
      ),
      GameRecord(
        id: 'REC-103',
        date: DateTime.now().subtract(const Duration(days: 2)),
        remainingPegs: 1,
        totalMoves: 31,
        durationSeconds: 118,
        isVictory: true,
      ),
    ];
  }

  String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthName(date.month);

  return '$day $month ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String _formatDuration(int seconds) {
  if (seconds < 60) {
    return '$seconds s';
  }

  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;

  return '${minutes.toString().padLeft(2, '0')}:'
      '${remainingSeconds.toString().padLeft(2, '0')}';
}

String _monthName(int month) {
  const months = [
    'ene.',
    'feb.',
    'mar.',
    'abr.',
    'may.',
    'jun.',
    'jul.',
    'ago.',
    'sep.',
    'oct.',
    'nov.',
    'dic.',
  ];

  return months[month - 1];
}

  @override
  Widget build(BuildContext context) {
    final records = _getMockRecords();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          final colorScheme = Theme.of(context).colorScheme;

          final statusColor = record.isVictory
              ? colorScheme.primary
              : colorScheme.error;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              leading: Icon(
                record.isVictory
                    ? Icons.check_circle
                    : Icons.cancel,
                color: statusColor,
                size: 32,
              ),
              title: Row(
                children: [
                  Text(
                    record.isVictory ? 'Victoria' : 'Derrota',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${_formatDate(record.date)} · ${_formatTime(record.date)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${record.totalMoves} movimientos · '
                  '${record.remainingPegs} fichas restantes · '
                  '${_formatDuration(record.durationSeconds)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}