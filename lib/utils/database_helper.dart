import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:notes_keeper_flutter/models/note.dart';

class DatabaseHelper {
  static DatabaseHelper _databasehelper;
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  DatabaseHelper._createInstance();

  // factory keyword allows constructor to return values
  factory DatabaseHelper() {
    if (_databasehelper == null) {
      _databasehelper = DatabaseHelper._createInstance();
    }
    return _databasehelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // get directory path for android and ios
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    // open/create database at given path
    var notesDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $noteTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // CRUD operations
  // CRUD operations can be done using two methods - Raw SQL & Helper Functions

  /*// fetch operation
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;
    //Raw SQL => var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    //Helper Function
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }*/

  // fetch operation
  Future<List<Note>> getNoteList() async {
    Database db = await this.database;
    // get notes in form of mapList
    var noteMapList = await db.query(noteTable, orderBy: '$colPriority ASC');
    // count the number of entries in the table
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    // for loop to create noteList from mapList
    for (int i = 0; i < count; i++) {
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }
    return noteList;
  }

  // insert operation
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // update operation
  Future<int> updateNote(Note note) async {
    Database db = await this.database;
    var result = await db.update(noteTable, note.toMap(),
        where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // delete operation
  Future<int> deleteNote(int id) async {
    Database db = await this.database;
    var result =
        await db.delete(noteTable, where: '$colId = ?', whereArgs: [id]);
    return result;
  }

  // get number of objects in the database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
