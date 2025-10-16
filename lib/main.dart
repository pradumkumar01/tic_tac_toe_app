import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(TicTacToeApp());

class TicTacToeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic-Tac-Toe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TicTacToeHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TicTacToeHomePage extends StatefulWidget {
  @override
  _TicTacToeHomePageState createState() => _TicTacToeHomePageState();
}

class _TicTacToeHomePageState extends State<TicTacToeHomePage>
    with SingleTickerProviderStateMixin {
  static const int gridSize = 3;
  late List<List<String>> _board;
  String _currentPlayer = "X";
  String? _winner;
  bool _draw = false;
  bool _showWinHighlight = false;
  List<List<int>>? _winningLine;
  late AnimationController _animationController;
  late Animation<Color?> _colorTween;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _colorTween = ColorTween(
      begin: Colors.blue,
      end: Colors.greenAccent,
    ).animate(_animationController);
    // Keep UI in sync while animation runs
    _animationController.addListener(() {
      setState(() {});
    });

    _initGame();
  }

  void _initGame({bool swapPlayers = false}) {
    _board = List.generate(gridSize, (_) => List.filled(gridSize, ''));
    _winner = null;
    _draw = false;
    _winningLine = null;
    _showWinHighlight = false;

    if (swapPlayers) {
      _currentPlayer = _currentPlayer == "X" ? "O" : "X";
    }

    _animationController.reset();
  }

  void _handleTap(int row, int col) {
    if (_board[row][col] != '' || _winner != null) return;

    setState(() {
      _board[row][col] = _currentPlayer;
      _checkWinner();
      if (_winner == null && !_draw) {
        _currentPlayer = _currentPlayer == "X" ? "O" : "X";
      }
    });
  }

  void _checkWinner() {
    // Check Rows and Columns
    for (int i = 0; i < gridSize; i++) {
      // Rows
      if (_board[i][0] != '' &&
          _board[i][0] == _board[i][1] &&
          _board[i][1] == _board[i][2]) {
        _setWinner(_board[i][0], [
          [i, 0],
          [i, 1],
          [i, 2],
        ]);
        return;
      }
      // Columns
      if (_board[0][i] != '' &&
          _board[0][i] == _board[1][i] &&
          _board[1][i] == _board[2][i]) {
        _setWinner(_board[0][i], [
          [0, i],
          [1, i],
          [2, i],
        ]);
        return;
      }
    }
    // Diagonals
    if (_board[0][0] != '' &&
        _board[0][0] == _board[1][1] &&
        _board[1][1] == _board[2][2]) {
      _setWinner(_board[0][0], [
        [0, 0],
        [1, 1],
        [2, 2],
      ]);
      return;
    }
    if (_board[0][2] != '' &&
        _board[0][2] == _board[1][1] &&
        _board[1][1] == _board[2][0]) {
      _setWinner(_board[0][2], [
        [0, 2],
        [1, 1],
        [2, 0],
      ]);
      return;
    }
    // Draw
    if (_board.every((row) => row.every((cell) => cell != ''))) {
      setState(() {
        _draw = true;
      });
    }
  }

  void _setWinner(String winner, List<List<int>> line) {
    setState(() {
      _winner = winner;
      _winningLine = line;
      _showWinHighlight = true;
    });
    _animationController.forward();
  }

  Widget _buildCell(int row, int col, double fontSize) {
    bool highlight = false;
    if (_showWinHighlight && _winningLine != null) {
      highlight = _winningLine!.any((pos) => pos[0] == row && pos[1] == col);
    }

    return GestureDetector(
      onTap: () => _handleTap(row, col),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black54, width: 1),
          color: highlight ? _colorTween.value : Colors.white,
        ),
        child: Center(
          child: AnimatedScale(
            scale: _board[row][col] != '' ? 1.08 : 1.0,
            duration: Duration(milliseconds: 150),
            child: Text(
              _board[row][col],
              style: TextStyle(
                fontSize: fontSize,
                color:
                    _board[row][col] == "X" ? Colors.deepPurple : Colors.orange,
                fontWeight: FontWeight.bold,
                shadows:
                    highlight
                        ? [Shadow(color: Colors.green, blurRadius: 20)]
                        : [],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For win animation refresh
    _animationController.addListener(() {
      setState(() {});
    });

    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final base = min(screenWidth, screenHeight);
    // computed sizes
    final buttonFont = max(14.0, base * 0.035);
    final winnerFont = max(22.0, base * 0.06);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tic-Tac-Toe"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initGame();
              });
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Current Player Display
          GestureDetector(
            onTap: () {
              if (_winner != null || _draw) return;
              setState(() {
                _currentPlayer = _currentPlayer == "X" ? "O" : "X";
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Current: ", style: TextStyle(fontSize: 22)),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      _currentPlayer,
                      key: ValueKey(_currentPlayer),
                      style: TextStyle(
                        fontSize: 36,
                        color:
                            _currentPlayer == "X"
                                ? Colors.deepPurple
                                : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Icon(Icons.swap_horiz, color: Colors.grey),
                ],
              ),
            ),
          ),
          // Game Grid (responsive)
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontalMargin = min(40.0, screenWidth * 0.05);
              final maxBoard = min(
                constraints.maxWidth - horizontalMargin,
                screenHeight * 0.5,
              );
              final boardSize = min(maxBoard, 600.0);
              final cellFont = max(18.0, boardSize / (gridSize * 1.6));

              return Container(
                margin: EdgeInsets.symmetric(horizontal: horizontalMargin / 2),
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  border: Border.all(width: 3, color: Colors.black87),
                ),
                child: Center(
                  child: SizedBox(
                    width: boardSize,
                    height: boardSize,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: gridSize * gridSize,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        int row = index ~/ gridSize;
                        int col = index % gridSize;
                        return _buildCell(row, col, cellFont);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 40),
          // Win/Draw Display
          _winner != null
              ? AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 400),
                child: Column(
                  children: [
                    Text(
                      "Player $_winner Wins!",
                      style: TextStyle(
                        fontSize: winnerFont,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Icon(
                      Icons.celebration,
                      color: Colors.green,
                      size: winnerFont + 20,
                    ),
                  ],
                ),
              )
              : _draw
              ? AnimatedOpacity(
                opacity: 1,
                duration: Duration(milliseconds: 400),
                child: Column(
                  children: [
                    Text(
                      "It's a Draw!",
                      style: TextStyle(
                        fontSize: winnerFont - 4,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    Icon(
                      Icons.sentiment_satisfied,
                      color: Colors.blueGrey,
                      size: winnerFont + 6,
                    ),
                  ],
                ),
              )
              : Container(),
          SizedBox(height: 26),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _initGame();
              });
            },
            child: Text("Restart Game", style: TextStyle(fontSize: buttonFont)),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _initGame(
                  swapPlayers: true,
                ); // Creative feature: swap first-move player
              });
            },
            child: Text(
              "Swap X/O First",
              style: TextStyle(fontSize: buttonFont - 2),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Tap Current Player to swap turn\nTry the Swap X/O First for a twist!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: max(12.0, buttonFont - 2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
