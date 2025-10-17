import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tic_tac_app/db/db_helper.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> _players = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    await Future.delayed(Duration(milliseconds: 800)); // simulate loading
    final list = await db.fetchLeaderboard();
    setState(() {
      _players = list;
      _loading = false;
    });
  }

  Widget _buildShimmer() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: ListTile(
            leading: CircleAvatar(backgroundColor: Colors.white, radius: 20),
            title: Container(height: 14, color: Colors.white),
            subtitle: Container(height: 10, width: 80, color: Colors.white),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leaderboard')),
      body: _loading
          ? _buildShimmer()
          : _players.isEmpty
              ? Center(child: Text('No records yet'))
              : ListView.builder(
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(player['player']),
                      subtitle: Text(
                          'Wins: ${player['wins']} | Losses: ${player['losses']} | Draws: ${player['draws']}'),
                    );
                  },
                ),
    );
  }
}
