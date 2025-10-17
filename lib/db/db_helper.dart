import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, 'tictactoe.db');
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  void _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE leaderboard (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        player TEXT,
        wins INTEGER,
        losses INTEGER,
        draws INTEGER
      )
    ''');
  }

  Future<void> insertOrUpdatePlayer(String name, {bool win = false, bool draw = false}) async {
    final db = await database;
    var result = await db.query('leaderboard', where: 'player = ?', whereArgs: [name]);
    if (result.isEmpty) {
      await db.insert('leaderboard', {
        'player': name,
        'wins': win ? 1 : 0,
        'losses': (!win && !draw) ? 1 : 0,
        'draws': draw ? 1 : 0,
      });
    } else {
      var player = result.first;
      await db.update(
        'leaderboard',
        {
          'wins': (player['wins'] as int) + (win ? 1 : 0),
          'losses': (player['losses'] as int) + ((!win && !draw) ? 1 : 0),
          'draws': (player['draws'] as int) + (draw ? 1 : 0),
        },
        where: 'player = ?',
        whereArgs: [name],
      );
    }
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final db = await database;
    return await db.query('leaderboard', orderBy: 'wins DESC');
  }

  Future<void> clearData() async {
    final db = await database;
    await db.delete('leaderboard');
  }

  Future<Map<String, int>> getUserStats(String username) async {
    final db = await database;
    final result = await db.query(
      'leaderboard',
      where: 'player = ?',
      whereArgs: [username],
    );

    if (result.isEmpty) {
      return {
        'total_games': 0,
        'games_won': 0,
        'games_lost': 0,
        'games_draw': 0,
      };
    }

    final stats = result.first;
    final wins = stats['wins'] as int;
    final losses = stats['losses'] as int;
    final draws = stats['draws'] as int;

    return {
      'total_games': wins + losses + draws,
      'games_won': wins,
      'games_lost': losses,
      'games_draw': draws,
    };
  }
}
