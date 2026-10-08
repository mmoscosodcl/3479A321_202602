import 'package:flutter/material.dart';
import 'package:flutter_pegsolitaire/repositories/game_history_repository.dart';
import 'package:flutter_pegsolitaire/repositories/json_file_history_repository.dart';
import '../../models/game_record.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  final IGameHistoryRepository _repository = JsonFileHistoryRepository();
  late Future<List<GameRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _historyFuture = _repository.getHistory();
    });
  }
  

  String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = _monthName(date.month);

  return '$day $month ${date.year}';
}

String formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$hour:$minute';
}

String formatDuration(int seconds) {
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
    
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Partidas')),
      body: FutureBuilder<List<GameRecord>>(
        future: _historyFuture,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          }

          final records = asyncSnapshot.data ?? [];

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];          
              return _buildRecordCard(context, record);
            },
          );
        }
      ),
    );
  }
}

Widget _buildRecordCard(BuildContext context, GameRecord record) {
    final theme = Theme.of(context);
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
          color: theme.colorScheme.primary,
          size: 32,
        ),
        title: Row(
          children: [
            Text(
              record.isVictory ? 'Victoria' : 'Derrota',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Text(
              '${record.date}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            '${record.durationSeconds} · Movimientos: ${record.totalMoves} · Clavijas restantes: ${record.remainingPegs}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }