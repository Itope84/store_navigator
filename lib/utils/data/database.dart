import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

const DB_NAME = 'store_navigator.db';

class DatabaseHelper {
  DatabaseHelper.internal();

  static final DatabaseHelper _instance = DatabaseHelper.internal();

  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get db async {
    return _database ?? await initDb();
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), DB_NAME);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print(oldVersion);
    print("newVersion: $newVersion");
    if (oldVersion == 1) {
      // add column found to shopping_list_items
      // TODO: implement a version based changelog query inside each model class
      // await db.execute(
      //     'ALTER TABLE ${ShoppingListItem.tableName} ADD COLUMN found INTEGER');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(ShoppingList.createTableQuery);

    await db.execute(ShoppingListItem.createTableQuery);
  }
}
