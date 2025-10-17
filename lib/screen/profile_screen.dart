import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_app/db/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';


class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen({required this.username, Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseHelper();
  Map<String, dynamic>? _playerData;
  bool _loading = true;
  String? displayName;

  @override
  void initState() {
    super.initState();
    displayName = widget.username;
    _loadPlayerData();
  }

  Widget _buildWinPieChart() {
  final wins = _playerData!['wins'] as int;
  final losses = _playerData!['losses'] as int;
  final draws = _playerData!['draws'] as int;
  final total = (wins + losses + draws).toDouble().clamp(1, double.infinity);

  return SizedBox(
    height: 148,
    child: PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: Colors.green,
            value: wins / total,
            title: "Wins",
          ),
          PieChartSectionData(
            color: Colors.redAccent,
            value: losses / total,
            title: "Losses",
          ),
          PieChartSectionData(
            color: Colors.blueAccent,
            value: draws / total,
            title: "Draws",
          ),
        ],
      ),
    ),
  ).animate().fadeIn(duration: 700.ms).scale();
}

Widget _buildProgressBars() {
  int wins = _playerData!['wins'];
  int losses = _playerData!['losses'];
  int draws = _playerData!['draws'];
  int total = wins + losses + draws;

  double winPercent = total > 0 ? wins / total : 0;
  double drawPercent = total > 0 ? draws / total : 0;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Win Ratio: ${(winPercent * 100).toStringAsFixed(1)}%"),
      LinearProgressIndicator(
        value: winPercent,
        color: Colors.green,
        backgroundColor: Colors.grey.shade200,
        minHeight: 10,
      ),
      SizedBox(height: 10),
      Text("Draw Ratio: ${(drawPercent * 100).toStringAsFixed(1)}%"),
      LinearProgressIndicator(
        value: drawPercent,
        color: Colors.blueAccent,
        backgroundColor: Colors.grey.shade200,
        minHeight: 10,
      ),
    ],
  ).animate().fadeIn(duration: 600.ms).slide();
}


  Future<void> _loadPlayerData() async {
    final results = await db.fetchLeaderboard();
    final player = results.firstWhere(
      (p) => p['player'] == widget.username,
      orElse: () => {},
    );
    setState(() {
      _playerData = player.isNotEmpty ? player : null;
      _loading = false;
    });
  }

  Future<void> _updateNickname(BuildContext context) async {
    final controller = TextEditingController(text: displayName);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Nickname"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Enter new name"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Save"),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('guest_name', controller.text.trim());
                setState(() => displayName = controller.text.trim());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _resetData() async {
    await db.clearData();
    setState(() => _playerData = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Data cleared")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile & Stats"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPlayerData,
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      displayName![0].toUpperCase(),
                      style: TextStyle(fontSize: 38, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    displayName ?? "",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _updateNickname(context),
                    icon: Icon(Icons.edit),
                    label: Text("Edit Name"),
                  ),
                  Divider(height: 20),
                  _playerData != null
                      ? Column(
                          children: [
                            _statTile("Wins", _playerData!['wins'].toString()),
                            _statTile(
                                "Losses", _playerData!['losses'].toString()),
                            _statTile("Draws", _playerData!['draws'].toString()),
                          ],
                        )
                      : Text("No game history yet.",
                          style: TextStyle(color: Colors.grey)),
                  ElevatedButton.icon(
                    onPressed: _resetData,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent),
                    icon: Icon(Icons.delete_forever),
                    label: Text("Clear All Stats"),
          
                  ),
                  Divider(height: 40),
          if (_playerData != null) ...[
            Text("Performance Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildWinPieChart(),
            SizedBox(height: 32),
            _buildProgressBars(),
          ],
          
                ],
              ),
            ),
    );
  }

  Widget _statTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20)),
          Text(value,
              style:
                  TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
