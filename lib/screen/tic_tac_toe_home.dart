import 'package:flutter/material.dart';
import 'package:tic_tac_app/db/db_helper.dart';

class TicTacToeHomePage extends StatefulWidget {
  final String playerName;
  const TicTacToeHomePage({required this.playerName, Key? key}) : super(key: key);

  @override
  State<TicTacToeHomePage> createState() => _TicTacToeHomePageState();
}

class _TicTacToeHomePageState extends State<TicTacToeHomePage>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 3;
  List<List<String>> _board = [];
  String _currentPlayer = "X";
  String? _winner;
  bool _draw = false;
  final db = DatabaseHelper();
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initGame();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      lowerBound: 0.9,
      upperBound: 1.1,
    );
  }

  void _initGame() {
    _board = List.generate(gridSize, (_) => List.filled(gridSize, ""));
    _currentPlayer = "X";
    _winner = null;
    _draw = false;
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] == "" && _winner == null) {
      setState(() {
        _board[row][col] = _currentPlayer;
        _controller.forward(from: 0.9);
        _checkWinner();
        if (_winner == null && !_draw) {
          _currentPlayer = _currentPlayer == "X" ? "O" : "X";
        }
      });
    }
  }

  void _checkWinner() async {
    List<List<int>> wins = [
      [0, 0, 0, 1, 0, 2],
      [1, 0, 1, 1, 1, 2],
      [2, 0, 2, 1, 2, 2],
      [0, 0, 1, 0, 2, 0],
      [0, 1, 1, 1, 2, 1],
      [0, 2, 1, 2, 2, 2],
      [0, 0, 1, 1, 2, 2],
      [0, 2, 1, 1, 2, 0],
    ];

    for (var w in wins) {
      String a = _board[w[0]][w[1]];
      String b = _board[w[2]][w[3]];
      String c = _board[w[4]][w[5]];
      if (a != "" && a == b && b == c) {
        setState(() => _winner = a);
        await db.insertOrUpdatePlayer(widget.playerName, win: _winner == "X");
        return;
      }
    }

    if (_board.every((r) => r.every((c) => c.isNotEmpty))) {
      setState(() => _draw = true);
      await db.insertOrUpdatePlayer(widget.playerName, draw: true);
    }
  }

  void _restartGame() {
    setState(_initGame);
  }

  Widget _buildCell(int i, int j) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.0).animate(_controller),
      child: GestureDetector(
        onTap: () => _handleTap(i, j),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 1),
            color: Colors.white70,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _board[i][j] == "X"
                    ? Colors.pinkAccent
                    : _board[i][j] == "O"
                        ? Colors.amberAccent
                        : Colors.transparent,
              ),
              child: Text(_board[i][j]),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Tic-Tac-Toe Pro",
        style: TextStyle(color: Colors.indigo
        ),
          ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe3f2fd), Color(0xFFbbdefb)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _winner != null
                    ? "Winner: $_winner 🎉"
                    : _draw
                        ? "It's a Draw! 🤝"
                        : "Turn: $_currentPlayer",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  // color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                 
                ),
                child: GridView.builder(
                  itemCount: 9,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3),
                  itemBuilder: (context, idx) {
                    int i = idx ~/ 3;
                    int j = idx % 3;
                    return _buildCell(i, j);
                  },
                ),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  "Restart Game",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
