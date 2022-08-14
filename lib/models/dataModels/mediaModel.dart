
class MediaModel {
  String? id;
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
    id = map['id'] as String?;
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
    date = map['date'];
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};
    map['id'] = id;
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
    map['date'] = date;

    return map;
  }
}