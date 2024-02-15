import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{
  //This named constructor is to be defined here to be accessed inside the factory method
  DatabaseHelper._createInstance();
  //singleton Database instance
  Database? _database;
  //singleton Helper instance
  static DatabaseHelper? _databaseHelper;

  //define column name
  String tableName = "chats_table";
  String colId = "id";
  String colTopic = "topic";
  String colSender = "sender";
  String colReceiver = "receiver";
  String colMessage = "message";
  String colDate = "date";

  //Getters must be declared without a parameter list
  //since database is singleton check for null then only return
  Future<Database?> get database async{
    _database ??= await initializeDatabase();
    return _database;
  }
  factory DatabaseHelper(){
    //equivalent code
    // if(_databaseHelper == null){
    //   _databaseHelper = DatabaseHelper._createInstance();
    // }
    _databaseHelper ??= DatabaseHelper._createInstance();
    return _databaseHelper!;
  }

  Future<Database> initializeDatabase()async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}chats.db";
    var chatDatabase = openDatabase(path, version: 1, onCreate: _createDatabase);
    return chatDatabase;
  }

  void _createDatabase(Database db,int version)async{
    await db.execute('CREATE TABLE $tableName($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTopic TEXT, $colSender TEXT, $colReceiver TEXT, $colMessage TEXT, $colDate TEXT)');
  }
}