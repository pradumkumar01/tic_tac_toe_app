import 'package:flutter/material.dart';
import 'package:tic_tac_app/db/db_helper.dart';

class TicTacToeHomePage extends StatefulWidget {
  final String playerName;
  const TicTacToeHomePage({required this.playerName, Key? key}) : super(key: key);

  @override
  State<TicTacToeHomePage> createState() => _TicTacToeHomePageState();
}

class _TicTacToeHomePageState extends State<TicTacToeHomePage> {
  static const int gridSize = 3;
  List<List<String>> _board = [];
  String _currentPlayer = "X";
  String? _winner;
  bool _draw = false;
  final db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _initGame();
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
        if (_winner == "X") {
          await db.insertOrUpdatePlayer(widget.playerName, win: true);
        } else {
          await db.insertOrUpdatePlayer(widget.playerName, win: false);
        }
        return;
      }
    }

    if (_board.every((r) => r.every((c) => c.isNotEmpty))) {
      setState(() => _draw = true);
      await db.insertOrUpdatePlayer(widget.playerName, draw: true);
    }
    if (_winner != null) {
      if (_winner == widget.playerName) {
        await db.insertOrUpdatePlayer(widget.playerName, win: true);
      } else {
        await db.insertOrUpdatePlayer(widget.playerName, win: false);
      }
    } else if (_draw) {
      await db.insertOrUpdatePlayer(widget.playerName, draw: true);
    }
  }

 

  void _restartGame() {
    setState(() {
      _initGame();
    });
  }

  Widget _buildCell(int i, int j) {
    return GestureDetector(
      onTap: () => _handleTap(i, j),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 1),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            _board[i][j],
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: _board[i][j] == "X" ? Colors.deepPurple : Colors.orange,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Tic-Tac-Toe")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _winner != null
                  ? "Winner: $_winner"
                  : _draw
                      ? "It's a Draw!"
                      : "Turn: $_currentPlayer",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              width: 320,
              height: 320,
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _restartGame,
              child: const Text("Restart Game"),
            ),
          ],
        ),
      ),
    );
  }
}
