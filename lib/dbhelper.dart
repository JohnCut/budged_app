import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'bpDB.dart';

class DBHelper {
  static Database _db;
  static const String BPID = 'id';
  static const String BPTIME = 'time';
  static const String BPIHORAN = 'ihOran';
  static const String BPISORAN = 'isOran';
  static const String BPTASORAN = 'tasOran';
  static const String BPTABLE = 'BudgetPlan';
  static const String BPDB_NAME = 'budgetplan.db';
  static const String GEID = 'id';
  static const String GETITLE = 'title';
  static const String GEUNIT = 'unit';
  static const String GEBPID = 'bpID';
  static const String GETABLE = 'GelirDB';
  static const String GEDB_NAME = 'gelirdb.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, BPDB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $BPTABLE ($BPID INTEGER PRIMARY KEY, $BPTIME TEXT, $BPIHORAN TEXT, $BPISORAN TEXT, $BPTASORAN TEXT)");
  }

  Future<BudgetPlan> save(BudgetPlan budgetplan) async {
    var dbClient = await db;
    budgetplan.id = await dbClient.insert(BPTABLE, budgetplan.toMap());

    /* await dbClient.transaction((txn) async {
      var query =
          "INSERT INTO $TABLE ($TIME, $IHORAN, $ISORAN, $TASORAN) VALUES ('" +
              budgetplan.time +
              "'), ('" +
              budgetplan.ihOran +
              "'), ('" +
              budgetplan.isOran +
              "'), ('" +
              budgetplan.tasOran +
              "')";
      return await txn.rawInsert(query);
    }); */
  }

  Future<List<BudgetPlan>> getBudgetPlan() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(BPTABLE, columns: [BPID, BPTIME, BPIHORAN, BPISORAN, BPTASORAN]);
    // List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<BudgetPlan> budgetPlans = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        budgetPlans.add(BudgetPlan.fromMap(maps[i]));
      }
    }
    return budgetPlans;
  }

  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(BPTABLE, where: '$BPID = ?', whereArgs: [id]);
  }

  Future<int> update(BudgetPlan budgetPlan) async {
    var dbClient = await db;
    return await dbClient.update(BPTABLE, budgetPlan.toMap(),
        where: '$BPID = ?', whereArgs: [budgetPlan.id]);
  }

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
