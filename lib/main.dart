import 'package:flutter/material.dart';
import 'package:tic_tac_app/screen/ui/guest_login_screen.dart';

void main() => runApp(TicTacToeProApp());

class TicTacToeProApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe Pro',
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (_) => GuestLoginScreen(),
      },
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _navigate);
  }

  void _navigate() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => GuestLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Tic-Tac-Toe Pro", style: TextStyle(fontSize: 28))),
    );
  }
}
