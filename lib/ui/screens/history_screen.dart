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

  String _formatDuration(int totalSeconds) {
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final records = _getMockRecords();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            child: Text('Record: ${record.id}'),
          );
        },
      ),
    );
  }
}