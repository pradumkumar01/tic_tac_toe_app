import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tic_tac_toe_home.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  const HomeScreen({required this.username});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $username'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Play Tic-Tac-Toe'),
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (_) => TicTacToeHomePage()),
            // );
          },
        ),
      ),
    );
  }
}
