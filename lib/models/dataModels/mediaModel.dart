
class MediaModel {
  String? url;
  String? id;
  String? path;
  String? name;
  String? extension;
  double? volume;
  double? width;
  double? height;
  Map? extra;

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

    return map;
  }
}