import 'package:iris_tools/dateSection/dateHelper.dart';

class MediaModel {
  int? id;
  String? url;
  String? path;
  String? title;
  String? fileName;
  String? extension;
  DateTime? date;
  int? volume;
  int? duration;
  double? width;
  double? height;
  Map? extra;

  MediaModel();

  MediaModel.fromMap(Map map){
    id = map['id'];
    url = map['url'];
    path = map['path'];
    title = map['title'];
    fileName = map['file_name'];
    extension = map['extension'];
    volume = map['volume'];
    duration = map['duration'];
    width = map['width'];
    height = map['height'];
    extra = map['extra'];
    date = DateHelper.tsToSystemDate(map['date']);
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['url'] = url;
    map['path'] = path;
    map['title'] = title;
    map['file_name'] = fileName;
    map['extension'] = extension;
    map['duration'] = duration;
    map['volume'] = volume;
    map['width'] = width;
    map['height'] = height;
    map['extra'] = extra;

    if(date != null) {
      map['date'] = DateHelper.toTimestampNullable(date);
    }

    if(id != null){
      map['id'] = id;
    }

    return map;
  }

  void matchBy(MediaModel other){
    //id = other.id;
    url = other.url;
    path = other.path;
    title = other.title;
    fileName = other.fileName;
    extension = other.extension;
    volume = other.volume;
    duration = other.duration;
    width = other.width;
    height = other.height;
    extra = other.extra;
    date = other.date;
  }
}