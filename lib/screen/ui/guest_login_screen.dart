import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class GuestLoginScreen extends StatefulWidget {
  @override
  State<GuestLoginScreen> createState() => _GuestLoginScreenState();
}

class _GuestLoginScreenState extends State<GuestLoginScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  Future<void> _guestSignIn(String name) async {
    if (name.trim().isEmpty) return;

    setState(() => _isLoading = true);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('guest_name', name);
    await prefs.setBool('logged_in', true);

    await Future.delayed(Duration(seconds: 1));
    setState(() => _isLoading = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen(username: name)),
    );
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('logged_in') ?? false;
    if (loggedIn) {
      String? name = prefs.getString('guest_name');
      if (name != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(username: name)),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isLoading
              ? CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videogame_asset_rounded,
                        size: 80, color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      'Play as Guest',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter nickname',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _guestSignIn(_nameController.text),
                      child: Text('Start Playing'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
