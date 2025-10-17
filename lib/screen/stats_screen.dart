import 'package:flutter/material.dart';
import '../db/db_helper.dart';

class StatsScreen extends StatefulWidget {
  final String username;
  
  const StatsScreen({super.key, required this.username});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int totalGames = 0;
  int gamesWon = 0;
  int gamesLost = 0;
  int gamesDraw = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final dbHelper = DatabaseHelper();
    // Load user statistics from the database
    final stats = await dbHelper.getUserStats(widget.username);
    setState(() {
      totalGames = stats['total_games'] ?? 0;
      gamesWon = stats['games_won'] ?? 0;
      gamesLost = stats['games_lost'] ?? 0;
      gamesDraw = stats['games_draw'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatCard('Total Games', totalGames),
            _buildStatCard('Games Won', gamesWon),
            _buildStatCard('Games Lost', gamesLost),
            _buildStatCard('Games Draw', gamesDraw),
            if (totalGames > 0) ...[
              const SizedBox(height: 20),
              Text(
                'Win Rate: ${((gamesWon / totalGames) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}