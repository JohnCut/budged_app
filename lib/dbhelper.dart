import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'bpDB.dart';
import 'dart:convert';

class DBHelper {
  static Database _db;
  static const String BPID = 'id';
  static const String BPTIME = 'time';
  static const String BPIHORAN = 'ihOran';
  static const String BPISORAN = 'isOran';
  static const String BPTASORAN = 'tasOran';
  static const String BPTABLE = 'BudgetPlan';
  static const String DB_NAME = 'budgetplan04.db';
  static const String GEID = 'id';
  static const String GETITLE = 'title';
  static const String GEUNIT = 'unit';
  static const String GETIME = 'time';
  static const String GEBPID = 'bpID';
  static const String GETABLE = 'GelirDB';
  static const String GIID = 'id';
  static const String GITITLE = 'title';
  static const String GIUNIT = 'unit';
  static const String GITYPE = 'type';
  static const String GITIME = 'time';
  static const String GIBPID = 'bpID';
  static const String GITABLE = 'GiderDB';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $BPTABLE ($BPID INTEGER PRIMARY KEY, $BPTIME TEXT, $BPIHORAN TEXT, $BPISORAN TEXT, $BPTASORAN TEXT)");

    await db.execute(
        "CREATE TABLE $GETABLE ($GEID INTEGER PRIMARY KEY, $GETITLE TEXT, $GEUNIT TEXT, $GETIME TEXT, $GEBPID INTEGER)");

    await db.execute(
        "CREATE TABLE $GITABLE ($GIID INTEGER PRIMARY KEY, $GITITLE TEXT, $GIUNIT TEXT, $GITYPE TEXT, $GITIME TEXT, $GIBPID INTEGER)");
  }

  Future<BudgetPlan> insertBP(BudgetPlan budgetplan) async {
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

  Future<GelirDB> insertGE(GelirDB gelir) async {
    var dbClient = await db;
    gelir.id = await dbClient.insert(GETABLE, gelir.toMap());

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

  Future<GiderDB> insertGI(GiderDB gider) async {
    var dbClient = await db;
    gider.id = await dbClient.insert(GITABLE, gider.toMap());

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

  Future<List<BudgetPlan>> getPlans() async {
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

  Future<List<GelirDB>> getGelirler() async {
    var dbClient = await db;
    List<Map> maps = await dbClient
        .query(GETABLE, columns: [GEID, GETITLE, GEUNIT, GETIME, GEBPID]);
    // List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<GelirDB> gelirler = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        gelirler.add(GelirDB.fromMap(maps[i]));
      }
    }
    return gelirler;
  }

  Future<List<GiderDB>> getGiderler() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(GITABLE,
        columns: [GEID, GETITLE, GEUNIT, GITYPE, GITIME, GEBPID]);
    // List<Map> maps = await dbClient.rawQuery("SELECT * FROM $TABLE");
    List<GiderDB> giderler = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        giderler.add(GiderDB.fromMap(maps[i]));
      }
    }
    return giderler;
  }

  Future<int> deleteGelirler(int bpID) async {
    var dbClient = await db;
    return await dbClient
        .delete(GETABLE, where: '$GEBPID = ?', whereArgs: [bpID]);
  }

  Future<int> deleteGiderler(int bpID) async {
    var dbClient = await db;
    return await dbClient
        .delete(GITABLE, where: '$GIBPID = ?', whereArgs: [bpID]);
  }

  Future<int> deletePlan(int id) async {
    var dbClient = await db;
    deleteGelirler(id);
    deleteGiderler(id);
    return await dbClient.delete(BPTABLE, where: '$BPID = ?', whereArgs: [id]);
  }

  /* Future<int> update(BudgetPlan budgetPlan) async {
    var dbClient = await db;
    return await dbClient.update(BPTABLE, budgetPlan.toMap(),
        where: '$BPID = ?', whereArgs: [budgetPlan.id]);
  } */

  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
