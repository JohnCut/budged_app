class BudgetPlan {
  int id;
  String time;
  String ihOran;
  String isOran;
  String tasOran;

  BudgetPlan(this.id, this.time, this.ihOran, this.isOran, this.tasOran);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'time': time,
      'ihOran': ihOran,
      'isOran': isOran,
      'tasOran': tasOran,
    };
    return map;
  }

  BudgetPlan.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    time = map['time'];
    ihOran = map['ihOran'];
    isOran = map['isOran'];
    tasOran = map['tasOran'];
  }
}

class GelirDB {
  int id;
  String title;
  String unit;
  String time;
  int bpID;

  GelirDB(this.id, this.title, this.unit, this.time, this.bpID);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'unit': unit,
      'time': time,
      'bpID': bpID,
    };
    return map;
  }

  GelirDB.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    unit = map['unit'];
    time = map['time'];
    bpID = map['bpID'];
  }
}

class GiderDB {
  int id;
  String title;
  String unit;
  String type;
  String time;
  int bpID;

  GiderDB(this.id, this.title, this.unit, this.type, this.time, this.bpID);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'title': title,
      'unit': unit,
      'type': type,
      'time': time,
      'bpID': bpID,
    };
    return map;
  }

  GiderDB.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    title = map['title'];
    unit = map['unit'];
    type = map['type'];
    time = map['time'];
    bpID = map['bpID'];
  }
}
