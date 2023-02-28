import 'package:iris_tools/api/notifiers/customChangeNotifier.dart';

enum DownloadNotifierState {
  isDownloaded,
  isDownloading,
  occurError,
  none,
}

class DownloadNotifier extends CustomChangeNotifier {
  static final _list = <DownloadNotifier>[];

  late String url;
  double progress = 0;
  String owner = '';
  DownloadNotifierState _state = DownloadNotifierState.none;

  DownloadNotifier._();

  factory DownloadNotifier(String url, String owner){
    for(final d in _list){
      if(d.url == url){
        return d;
      }
    }

    final d = DownloadNotifier._();
    d.url = url;
    d.owner = owner;

    _list.add(d);

    return d;
  }

  DownloadNotifierState get state => _state;

  bool isIOwner(String tag){
    return tag == owner;
  }

  void setState(DownloadNotifierState state, String tag, {double? progress}){
    if(tag != owner){
      return;
    }

    _state = state;

    if(progress != null){
      this.progress = progress;
    }

    if(_list.indexWhere((element) => element.url == url) > -1) {
      notifyListeners();
    }
  }

  void delete(String owner){
    _list.removeWhere((element) => element.url == url);

    if(this.owner == owner) {
      dispose();
    }
  }

  /*static void deleteNotifier(DownloadNotifier dn){
    _list.removeWhere((element) => element.url == dn.url);
  }*/
}