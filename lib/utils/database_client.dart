import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/nottodo_item.dart';

class DatabaseHelper {

  DatabaseHelper.internal();
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  final String tableName = "nottodoTable";
  final String colId = "id";
  final String colItemName = "itemName";
  final String colDateCreated = "dateCreated";

  static Database _db;


  void _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $tableName($colId INTEGER PRIMARY KEY, $colItemName TEXT, $colDateCreated TEXT)"
    );
  }

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "nottodo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<int> saveItem(NotToDoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$tableName", item.toMap());
    return res;
  }


  Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName ORDER BY $colItemName ASC");

    return result.toList();
  }


  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery(
      "SELECT COUNT(*) FROM $tableName"
    ));
  }


  Future<NotToDoItem> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $tableName WHERE $colId = $id");
    if(result.length == 0){
      return null;
    }
    return new NotToDoItem.fromMap(result.first);
  }


  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableName, where: "$colId = ?", whereArgs: [id]);
  }


  Future<int> updateItem(NotToDoItem item) async {
    var dbClient = await db;
    return await dbClient.update(
      "$tableName", item.toMap(),
      where: "$colId = ?", whereArgs: [item.id]
    );
  }



  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }


}