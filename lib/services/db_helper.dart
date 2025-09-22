import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            role TEXT NOT NULL,
            password TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE attendance (
            id TEXT PRIMARY KEY,
            userId INTEGER NOT NULL,
            status TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            checkout_time TEXT,
            checkin_location TEXT,
            checkout_location TEXT,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  // ========== USERS ==========

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert(
      'users',
      user,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getUser(String name, String password) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [name, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'id ASC');
  }

  Future<void> seedUsers() async {
    final db = await database;
    final existing = await db.query('users');

    if (existing.isEmpty) {
      final users = [
        {'name': 'Admin', 'role': 'Admin', 'password': 'admin123'},
        {
          'name': 'Priyanshi Srivastava',
          'role': 'Employee',
          'password': 'emp123',
        },
        {
          'name': 'Prinshi Srivastava',
          'role': 'Employee',
          'password': 'emp456',
        },
        {'name': 'Riya Sharma', 'role': 'Employee', 'password': 'emp789'},
        {'name': 'Arun Sharma', 'role': 'Employee', 'password': 'arun123'},
        {
          'name': 'Shashank Upadhyay',
          'role': 'Employee',
          'password': 'shashank123',
        },
      ];

      for (var user in users) {
        await db.insert('users', user);
      }

      print("✅ Default users seeded into DB");
    }
  }

  // ========== ATTENDANCE ==========

  Future<int> insertAttendance(
    int userId,
    String status,
    String location,
  ) async {
    final db = await database;

    return await db.insert('attendance', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'userId': userId,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
      'checkout_time': null,
      'checkin_location': location,
      'checkout_location': null,
    });
  }

  Future<bool> hasCheckedInToday(int userId) async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final res = await db.rawQuery(
      '''
      SELECT * FROM attendance
      WHERE userId = ? AND substr(timestamp, 1, 10) = ?
      ''',
      [userId, today],
    );

    return res.isNotEmpty;
  }

  Future<bool> markCheckout(int userId, String location) async {
    final db = await database;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final result = await db.query(
      'attendance',
      where:
          'userId = ? AND substr(timestamp, 1, 10) = ? AND checkout_time IS NULL',
      whereArgs: [userId, today],
    );

    if (result.isEmpty) return false;

    await db.update(
      'attendance',
      {
        'checkout_time': DateTime.now().toIso8601String(),
        'checkout_location': location,
      },
      where: 'id = ?',
      whereArgs: [result.first['id']],
    );

    return true;
  }

  Future<List<Map<String, dynamic>>> getAttendance(int userId) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getAllAttendance() async {
    final db = await database;
    return await db.query('attendance', orderBy: 'timestamp DESC');
  }

  Future<List<Map<String, dynamic>>> getDailyAttendance(DateTime date) async {
    final db = await database;
    final day = DateFormat('yyyy-MM-dd').format(date);

    return await db.rawQuery(
      '''
      SELECT a.*, u.name 
      FROM attendance a
      JOIN users u ON a.userId = u.id
      WHERE substr(a.timestamp, 1, 10) = ?
      ORDER BY u.name ASC
      ''',
      [day],
    );
  }
}
