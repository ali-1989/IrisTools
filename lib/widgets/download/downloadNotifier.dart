import 'package:iris_tools/api/notifiers/customChangeNotifier.dart';

enum DownloadNotifierState {
  isDownloaded,
  isDownloading,
  occurError,
  none,
}

class DownloadNotifier extends CustomChangeNotifier {
  static final _notifierList = <DownloadNotifier>[];

  late String url;
  double progress = 0;
  String owner = '';
  DownloadNotifierState _state = DownloadNotifierState.none;

  DownloadNotifier._();

  DownloadNotifierState get state => _state;

  factory DownloadNotifier(String url, String owner){
    for(final d in _notifierList){
      if(d.url == url){
        return d;
      }
    }

    final d = DownloadNotifier._();
    d.url = url;
    d.owner = owner;

    _notifierList.add(d);

    return d;
  }

  bool isIOwner(String tag){
    return tag == owner;
  }

  void setState(DownloadNotifierState state, {double? progress}){
    _state = state;

    if(progress != null){
      this.progress = progress;
    }

    if(_notifierList.indexWhere((element) => element.url == url) > -1) {
      notifyListeners();
    }
  }

  void delete(){
    _notifierList.removeWhere((element) => element.url == url);

    if(!hasListeners) {
      dispose();
    }
  }

  /*void delete(String owner){
    _list.removeWhere((element) => element.url == url);

    if(this.owner == owner) {
      dispose();
    }
  }*/
}