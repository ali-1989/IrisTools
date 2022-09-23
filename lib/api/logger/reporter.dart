import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/pathHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class Reporter {
  int _counter = 1;
  final String _dirPath;
  final String _filePrefix;

  Reporter(String dirPath, String prefixName): _dirPath = dirPath, _filePrefix = prefixName;

  void addReport(Report report){
    _save(report);
  }

  Future<bool> addReportWait(Report report){
    return _save(report);
  }

  Future<bool> _save(Report report) async {
    final f = FileHelper.getFile(await _getFilePath());

    if(!await f.exists()){
      f.createSync(recursive: true);
    }

    String contents = '';
    contents += report.reportTs.toString();
    contents += '##';
    contents += report.type.name;
    contents += '##';
    contents += TextHelper.scapeNewLine(report.description);
    contents += '\n';

    return f.writeAsString(contents, mode: FileMode.append, flush: true).then((value) => true);
  }

  Future<String> _getFilePath([String? dir]) async {
    //dir ??= await AppDirectories.getDatabasesDir();
    var p = '$_dirPath${PathHelper.getSeparator()}$_filePrefix$_counter.txt';
    var f = FileHelper.getFile(p);

    if(!f.existsSync()) {
      await FileHelper.createNewFile(p);
      return p;
    }
    else {
      var size = await f.length();

      if(size < 500000){
        return p;
      }

      _counter++;
      return _getFilePath(dir);
    }
  }

  Future<List<Report>> getRangReports(DateTime utcDate1, DateTime utcDate2) {
    return _getReports(utcDate1, utcDate2, false);
  }

  Future<List<Report>> getDayReports(DateTime utcDate) {
    return _getReports(utcDate, null, true);
  }

  Future<List<Report>> _getReports(DateTime date1, DateTime? date2, bool onlyDay) async {
    List<Report> res = [];

    List<FileSystemEntity> list = await FileHelper.getDirContents(_dirPath);
    List<FileSystemEntity> reportList = [];

    for(var item in list){
      var s = await item.stat();

      if(s.type == FileSystemEntityType.file) {
        if(item.path.contains(RegExp(r'report'))){
          reportList.add(item);
        }
      }
    }

    /// sort
    /*SplayTreeMap<FileSystemEntity, FileStat> sMap = SplayTreeMap<FileSystemEntity, FileStat>.from(map,
            (dynamic k1, dynamic k2){
      // sort: newDate first

    });*/

    //Completer<List<Report>> c = Completer();

    for(var item in reportList){
      var added = false;

      await FileHelper.getFile(item.path).openRead()
          .map(utf8.decode) // or .transform(utf8.decoder)
          .transform(LineSplitter())
          .any((String line) {

              List<String> sp = line.split(RegExp(r'##'));

              if(sp.length >= 3){
                var ts = DateTime.parse(sp[0]);

                bool isSame;

                if(onlyDay){
                  isSame = ts.year == date1.year && ts.month == date1.month && ts.day == date1.day;
                }
                else {
                  isSame = (ts.year > date1.year
                  || (ts.year == date1.year && ts.month > date1.month)
                  || (ts.year == date1.year && ts.month == date1.month && ts.day >= date1.day));

                  isSame &= (ts.year < date2!.year
                      || (ts.year == date2.year && ts.month < date2.month)
                      || (ts.year == date2.year && ts.month == date2.month && ts.day <= date2.day));
                }

                if(isSame){
                  var r = Report();
                  r.reportTs = ts;
                  r.type = ReportType.appInfo.byName(sp[1]);
                  r.description = sp[2];
                  res.add(r);

                  added = true;
                }
                else {
                  if(added) {
                    return true; // = break
                  }
                }
              }

              return false;
          });
    }

    return res;
  }
}
///=================================================================================================
enum ReportType {
  appInfo,
  error,
  database,
}

extension TypeOfCalendarExtension on ReportType {

  String get name {
    switch (this) {
      case ReportType.appInfo:
        return 'AppInfo';
      case ReportType.error:
        return 'Error';
      case ReportType.database:
        return 'Database';
      default:
        return 'unknown';
    }
  }

  ReportType byName(String name){
    if(name == 'AppInfo') {
      return ReportType.appInfo;
    }
    else if(name == 'Error') {
      return ReportType.error;
    }
    else {
      return ReportType.database;
    }
  }
}
///=================================================================================================
class Report {
  DateTime reportTs = DateHelper.getNowToUtc();
  ReportType type = ReportType.appInfo;
  String description = 'none';

  Report();

  factory Report.appInfo(String description){
    var r = Report();
    r.description = description;

    return r;
  }

  factory Report.database(String description){
    var r = Report();
    r.description = description;
    r.type = ReportType.database;

    return r;
  }

  factory Report.error(String description){
    var r = Report();
    r.description = description;
    r.type = ReportType.error;

    return r;
  }
}
