
class MediaModel {
  String? id;
  String? url;
  String? path;
  String? name;
  String? extension;
  DateTime? date;
  int? volume;
  double? width;
  double? height;
  Map? extra;

  MediaModel();

  MediaModel.fromMap(Map map){
    id = map['id'] as String?;
    url = map['url'];
    path = map['path'];
    name = map['name'];
    extension = map['extension'];
    volume = map['volume'];
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
    map['name'] = name;
    map['extension'] = extension;
    map['volume'] = volume;
    map['width'] = width;
    map['height'] = height;
    map['extra'] = extra;
    map['date'] = date;

    return map;
  }
}