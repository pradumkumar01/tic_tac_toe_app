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
    double winRate = totalGames > 0 ? (gamesWon / totalGames) * 100 : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFFbbdefb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard('Total Games', totalGames, Colors.indigo, Icons.sports_esports),
              _buildStatCard('Games Won', gamesWon, Colors.green, Icons.emoji_events),
              _buildStatCard('Games Lost', gamesLost, Colors.redAccent, Icons.close_rounded),
              _buildStatCard('Games Draw', gamesDraw, Colors.orange, Icons.handshake_rounded),

              if (totalGames > 0) ...[
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.bar_chart_rounded, color: Colors.blueAccent, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'Win Rate',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${winRate.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
