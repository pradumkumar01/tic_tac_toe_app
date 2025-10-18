import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tic_tac_app/db/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

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
      builder:
          (context) => AlertDialog(
            title: const Text("Edit Nickname"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Enter new name"),
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text("Save"),
                onPressed: () async {
                  if (controller.text.trim().isNotEmpty) {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Data cleared")));
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('guest_name'); // clear saved username
    if (!mounted) return;

    // Navigate back to login or home page
    Navigator.pushReplacementNamed(context, '/login');
    // 🔹 Replace '/login' with your actual login route name
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Stats"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPlayerData,
          ),
        ],
      ),
      body: _loading ? _buildShimmer() : Center(child: _buildProfileContent()),
    );
  }

  // 🟢 SHIMMER LOADER
  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const CircleAvatar(radius: 45, backgroundColor: Colors.white),
            const SizedBox(height: 20),
            Container(height: 18, width: 120, color: Colors.white),
            const SizedBox(height: 10),
            Container(height: 14, width: 80, color: Colors.white),
            const SizedBox(height: 30),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(height: 150, width: double.infinity, color: Colors.white),
            const SizedBox(height: 30),
            Container(height: 50, width: double.infinity, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // 🟢 ACTUAL PROFILE CONTENT WITH CARDS
  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blueAccent,
              child: Text(
                displayName![0].toUpperCase(),
                style: const TextStyle(fontSize: 38, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              displayName ?? "",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _updateNickname(context),
              icon: const Icon(Icons.edit),
              label: const Text("Edit Name"),
            ),
            const SizedBox(height: 20),

            // 🟢 Stats Cards
            if (_playerData != null)
              Column(
                children: [
                  _buildStatCard("Wins", _playerData!['wins']),
                  _buildStatCard("Losses", _playerData!['losses']),
                  _buildStatCard("Draws", _playerData!['draws']),
                ],
              )
            else
              const Text(
                "No game history yet.",
                style: TextStyle(color: Colors.grey),
              ),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              icon: const Icon(Icons.delete_forever),
              label: const Text("Clear All Stats"),
            ),
            const SizedBox(height: 16),

            // 🔹 LOGOUT BUTTON
            ElevatedButton.icon(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),

            const SizedBox(height: 40),

            if (_playerData != null) ...[
              const Text(
                "Performance Overview",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPieCard(),
              const SizedBox(height: 32),
              _buildProgressCard(),
            ],
          ],
        ),
      ),
    );
  }

  // 🟢 Card for individual stat
  Widget _buildStatCard(String title, int value) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20)),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1);
  }

  // 🟢 Card for Pie chart
  Widget _buildPieCard() {
    final wins = _playerData!['wins'] as int;
    final losses = _playerData!['losses'] as int;
    final draws = _playerData!['draws'] as int;
    final total = (wins + losses + draws).toDouble().clamp(1, double.infinity);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 180,
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
        ),
      ),
    ).animate().fadeIn(duration: 700.ms).scale();
  }

  // 🟢 Card for Progress Bars
  Widget _buildProgressCard() {
    int wins = _playerData!['wins'];
    int draws = _playerData!['draws'];
    int losses = _playerData!['losses'];
    int total = wins + losses + draws;
    double winPercent = total > 0 ? wins / total : 0;
    double drawPercent = total > 0 ? draws / total : 0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Win Ratio: ${(winPercent * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: winPercent,
              color: Colors.green,
              backgroundColor: Colors.grey.shade200,
              minHeight: 10,
            ),
            const SizedBox(height: 12),
            Text("Draw Ratio: ${(drawPercent * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: drawPercent,
              color: Colors.blueAccent,
              backgroundColor: Colors.grey.shade200,
              minHeight: 10,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).slideY();
  }
}
