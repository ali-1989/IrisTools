import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/logger/logger.dart';
export 'package:g_json/g_json.dart';

class DatabaseHelper {
  late IrisDB _irisDB;

  DatabaseHelper(){
    _irisDB = IrisDB();
  }

  void setDatabasePath(String address){
    _irisDB.setDatabasePath(address);
  }

  void closeTable(String name) {
    return _irisDB.closeDoc(name);
  }

  Future<bool> openTable(String name) {
    return _irisDB.openDoc(name);
  }

  Future<String> deleteTableFile(String tbName) async {
    return _irisDB.deleteDocFile(tbName);
  }

  String? getTableFilePath(String tbName) {
    return _irisDB.getDocFilePath(tbName);
  }

  bool isOpen(String name) {
    return _irisDB.isOpen(name);
  }

  void setDebug(bool state) {
    _irisDB.setDebug(state);
  }

  int getRowCount(String tbName) {
    return query(tbName, null).length;
  }

  List<dynamic> query(String tbName, Conditions? conditions, {
    List path = const [],
    int? limit,
    int? offset,
    OutType outType = OutType.MapOrDynamic,
    OrderBy? orderBy,
  }) {
    return _irisDB.find(tbName, conditions,
        path: path,
        limit: limit,
        offset: offset,
        outType: outType,
        orderBy: orderBy,
    );
  }

  dynamic queryFirst(String tbName,Conditions? conditions, {List path = const [],}) {
    return _irisDB.first(tbName, conditions, path: path);
  }

  Future<int> insert(String tbName, Map<dynamic, dynamic> value) {
    return _irisDB.insert(tbName, value);
  }

  List insertMany(String tbName, List<Map<dynamic, dynamic>> values) {
    var res = [];

    for(var x in values){
      res.add(insert(tbName, x));
    }

    return res;
  }

  //
  Future<int> update(String tbName, dynamic value, Conditions? conditions, {List path = const []}) {
    return _irisDB.update(tbName, value, conditions, path: path);
  }

  /// replace value for whole (key or row)
  Future<int> replace(String tbName, dynamic value, Conditions? conditions, {List path = const []}) {
    return _irisDB.replace(tbName, value, conditions, path: path);
  }

  ///
  Future<int> insertOrUpdate(String tbName, dynamic value, Conditions conditions) async {
    if(_irisDB.exist(tbName, conditions, path: [])){
      return update(tbName, value, conditions);
    }
    else {
      return insert(tbName, value);
    }
  }

  Future<int> insertOrUpdateEx(String tbName, dynamic value, Conditions conditions, dynamic Function(dynamic old, dynamic cur) beforeUpdate) async {
    if(_irisDB.exist(tbName, conditions, path: [])){
      value = beforeUpdate(_irisDB.first(tbName, conditions), value);

      return update(tbName, value, conditions);
    }
    else {
      return insert(tbName, value);
    }
  }

  Future<int> insertOrReplace(String tbName, dynamic value, Conditions conditions) async {
    if(_irisDB.exist(tbName, conditions, path: [])){
      return replace(tbName, value, conditions);
    }
    else {
      return insert(tbName, value);
    }
  }

  Future<int> insertOrIgnore(String tbName, dynamic value, Conditions conditions) async {
    if(_irisDB.exist(tbName, conditions, path: [])){
      return 1;
    }
    else {
      return insert(tbName, value);
    }
  }

  Future<int> delete(String tbName, Conditions? conditions, {List path = const []}) {
    return _irisDB.delete(tbName, conditions, path: path);
  }

  Future<int> deleteKey(String tbName, Conditions? conditions, String key) {
    return _irisDB.deleteKey(tbName, conditions, key);
  }

  bool exist(String tbName, Conditions conditions, {List path = const []}) {
    return _irisDB.exist(tbName, conditions, path: path);
  }

  Future<dynamic> clearTable(String name) {
    return _irisDB.truncateDoc(name);
  }

  Future<String?> tableAsText(String name) {
    return _irisDB.docFileAsText(name);
  }

  static Map<dynamic, dynamic> fetchSomeElements(Map<dynamic, dynamic> src, List<String> cols) {
    return { for (var e in src.keys.where((k) {
      return cols.contains(k);
    })) e : src[e] };
    //return t.cast<String, dynamic>();
  }

  void logRows(String tbName) async{
    var rows = query(tbName, null);
    Logger.L.logToScreen('Rows of: $tbName');
    Logger.L.logToScreen('-------------------------');

    for (var map in rows) {
      Logger.L.logToScreen('Row >>   ${map.toString()}');
    }
  }
}



/** %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DOC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


--------------------------------------------------------------------------------
 value[Op.increment] = {LKeys.deposit: deposit};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DOC %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% */