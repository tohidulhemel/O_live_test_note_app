import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/note.dart';

class DatabaseHelper {
  // Singleton setup — only one instance/connection for the whole app.
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  static const String _tableName = 'notes';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'notes_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  /// Insert a new note. Returns the generated id.
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert(
      _tableName,
      note.toMap()..remove('id'), // let SQLite auto-generate the id
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Update an existing note. Returns number of rows affected.
  Future<int> updateNote(Note note) async {
    final db = await database;
    if (note.id == null) {
      throw ArgumentError('Cannot update a note without an id');
    }
    return await db.update(
      _tableName,
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  /// Delete a note by id. Returns number of rows affected.
  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all notes, most recently updated first.
  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }

  /// Search notes by title (case-insensitive partial match).
  Future<List<Note>> searchNotesByTitle(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updatedAt DESC',
    );
    return maps.map((map) => Note.fromMap(map)).toList();
  }
}
