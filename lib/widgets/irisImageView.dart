import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/cache/sizedCacheMap.dart';
import 'package:iris_tools/widgets/download/downloadNotifier.dart';
import 'package:http/http.dart' as http;


class IrisImageView extends StatefulWidget {
  final String? url;
  final Uint8List? bytes;
  final FutureOr<String>? imagePath;
  final SizedCacheMap<String, Uint8List>? cacheManager;
  final String? cacheKey;
  final Widget Function()? beforeLoadFn;
  final Widget? beforeLoadWidget;
  final Widget? errorWidget;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool forceDownloadImage;
  final bool fadeAnimation;
  final int tryCount;
  final ShapeBorder? shape;
  final AlignmentGeometry alignment;
  final FilterQuality filterQuality;
  final void Function(Uint8List bytes, String? path)? onDownloadFn;
  final void Function(dynamic error)? onErrorFn;
  final void Function(Uint8List bytes)? onLoadFn;

  IrisImageView({
    Key? key,
    this.url,
    this.bytes,
    this.imagePath,
    this.cacheManager,
    this.cacheKey,
    this.width,
    this.height,
    this.onDownloadFn,
    this.onErrorFn,
    this.onLoadFn,
    this.beforeLoadFn,
    this.beforeLoadWidget,
    this.errorWidget,// = const SizedBox(width: 2, height: 2,)
    this.forceDownloadImage = false,
    this.filterQuality = FilterQuality.low,
    this.alignment = Alignment.center,
    this.fit = BoxFit.fill,
    this.fadeAnimation = true,
    this.tryCount = 4,
    this.shape,
  }) : assert(cacheManager == null || cacheKey != null, 'must set cacheKey for DownloadBuilder'),
        super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _IrisImageViewState();
  }
}
///=================================================================================================================
class _IrisImageViewState extends State<IrisImageView> with TickerProviderStateMixin {
  bool occurError = false;
  bool isSetPath = false;
  String? imgPath;
  Uint8List? imgBytes;
  int tried = 0;
  late AnimationController animController;
  late Animation<double> animation;
  bool _mustAnimate = false;
  //HttpClient? httpClient;
  http.Client? httpClient;
  String? cacheKey;
  DownloadNotifier? downloadNotifier;
  late Widget beforeLoadWidget;

  @override
  void initState() {
    super.initState();

    imgBytes = widget.bytes;
    cacheKey = widget.cacheKey?? '';

    _preparePath();

    beforeLoadWidget = widget.beforeLoadWidget?? SizedBox(width: widget.width?? 2, height: widget.height?? 2);

    animController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(animController);
  }

  @override
  void didUpdateWidget(IrisImageView oldWidget) {
    super.didUpdateWidget(oldWidget);

    animController.reset();
    cacheKey = widget.cacheKey?? '';

    if(widget.url != oldWidget.url || widget.imagePath != oldWidget.imagePath) {
      imgBytes = null;
      imgPath = null;

      _preparePath();
    }

    if(widget.bytes != null) {
      imgBytes = widget.bytes;
    }
  }

  @override
  Widget build(BuildContext context) {
    if(imgBytes == null && widget.cacheManager != null){
      if(imgPath != null || widget.url != null) {
        imgBytes = widget.cacheManager!.find((key, item) => (key == cacheKey));
      }
    }

    if(imgBytes != null) {
      widget.onLoadFn?.call(imgBytes!);

      if(!widget.fadeAnimation || !_mustAnimate) {
        if(widget.shape == null) {
          return getMemoryImage();
        }
        else {
          return clipView(getMemoryImage());
        }
      }
      else {
        _mustAnimate = false;
        animController.forward();

        return FadeTransition(
          opacity: animation,
          child: (widget.shape == null) ? getMemoryImage() : clipView(getMemoryImage()),
        );
      }
    }

    if(occurError) {
      return (widget.shape == null) ? getErrorView() : clipView(getErrorView());
    }

    if(imgPath != null) {
      if (widget.forceDownloadImage) {
        startDownload();
      }
      else {
        _checkFileAndRead(imgPath).then((exist) {
          if (exist) {
            updateState();
          }
          else {
            startDownload();
          }
        });
      }
    }
    else {
      startDownload();
    }

    return (widget.shape == null)? getBeforeView() : clipView(getBeforeView());
  }

  @override
  void dispose() {
    httpClient?.close(/*force: true*/);
    animController.dispose();

    if(downloadNotifier != null) {
      downloadNotifier!.removeListener(_listenDownloadState);

      if (downloadNotifier!.isIOwner('$hashCode')) {
        if(downloadNotifier!.state == DownloadNotifierState.isDownloading) {
          if(!kIsWeb){
            File(imgPath!).delete().catchError((e){return File('');});
          }
        }

        downloadNotifier!.setState(DownloadNotifierState.none, '$hashCode');
        downloadNotifier!.delete('$hashCode');
      }
    }

    super.dispose();
  }

  void updateState(){
    if(mounted) {
      setState(() {});
    }
  }

  void _preparePath(){
    isSetPath = widget.imagePath != null;

    if(widget.imagePath is Future) {
      (widget.imagePath as Future).then((address) {
        imgPath = address;
        updateState();
      });
    }
    else if(widget.imagePath is String) {
      imgPath = widget.imagePath! as String;
    }
  }

  Image getMemoryImage(){
    //sizeOfScreen = MediaQuery.of(context).size;

    return Image.memory(imgBytes!,
      width: widget.width,//?? sizeOfScreen!.width,
      height: widget.height,//?? sizeOfScreen!.height/2,
      fit: widget.fit,
      filterQuality: widget.filterQuality,
      alignment: widget.alignment,
    );
  }

  Widget clipView(Widget child){
    return ClipPath(
      clipper: ShapeBorderClipper(shape: widget.shape!),
      child: child,
    );
  }

  Widget getBeforeView(){
    if(widget.beforeLoadFn != null) {
      return widget.beforeLoadFn!();
    }
    else {
      return beforeLoadWidget;
    }
  }

  Widget getErrorView(){
    return widget.errorWidget?? getBeforeView();
  }

  Widget getFirstViewForFade() {
    return imgBytes != null ? getMemoryImage() : getBeforeView();
  }

  void _prepareDownloader(){
    if(widget.url != null) { // && isSetPath
      downloadNotifier = DownloadNotifier(widget.url!, '$hashCode');
      downloadNotifier!.addListener(_listenDownloadState);
    }
  }

  void disposeDownloadNotifier(){
    downloadNotifier!.removeListener(_listenDownloadState);
    downloadNotifier?.delete('$hashCode');
    downloadNotifier = null;
  }

  void _listenDownloadState() async {
    if(downloadNotifier?.state == DownloadNotifierState.none){
      startDownload();
      return;
    }

    if(downloadNotifier?.state == DownloadNotifierState.isDownloaded){
      if(isSetPath){
        await FileImage(File(imgPath!)).evict().catchError((err) {
          _onError(err);
          return false;
        });
      }

      _mustAnimate = true;
      updateState();
      disposeDownloadNotifier();
    }
  }

  void _onError(dynamic err){
    if(!mounted){
      return;
    }

    _mustAnimate = true;
    occurError = true;
    widget.onErrorFn?.call(err);
    updateState();
    disposeDownloadNotifier();
  }

  void startDownload() async {
    if (widget.url == null) {
      return;
    }

    _prepareDownloader();

    if (downloadNotifier != null && !downloadNotifier!.isIOwner('$hashCode')) {
      if (downloadNotifier!.state == DownloadNotifierState.isDownloaded || downloadNotifier!.state == DownloadNotifierState.isDownloading) {
        // this is a loop: update();
        return;
      }
    }

    if (!isSetPath || kIsWeb) {
      // ignore: unawaited_futures
      _downloadImageBytes(widget.url!).then((value) {
        _mustAnimate = true;
        updateState();
      }).catchError((err) {
        _onError(err);
      });
    }
    else {
      if (imgPath == null) {
        await (widget.imagePath as Future).then((value) => imgPath = value);
      }

      if (imgPath == null) {
        _onError(AssertionError('Image path is null to download'));
        return;
      }

      await _downloadAndSave(widget.url!, imgPath!);
    }
  }

  Future<dynamic> _downloadImageBytes(String url) async {
    try {
      httpClient = http.Client();
      downloadNotifier?.setState(DownloadNotifierState.isDownloading, '$hashCode');
      imgBytes = await httpClient!.readBytes(Uri.parse(url));

      if(widget.cacheManager != null) {
        widget.cacheManager!.add(cacheKey!, imgBytes!);
      }

      downloadNotifier?.setState(DownloadNotifierState.isDownloaded, '$hashCode');
      httpClient!.close();

      widget.onDownloadFn?.call(imgBytes!, imgPath!);
    }
    catch (err){
      tried++;

      if(!(err is HttpException || err is SocketException)) {
        rethrow;
      }

      if(tried < widget.tryCount) {
        return _downloadImageBytes(url);
      }
      else {
        rethrow;
      }
    }

    return imgBytes;
  }

  /*Future<dynamic> _downloadAsBytes(String url) async {
    httpClient = HttpClient();
    httpClient!.connectionTimeout = Duration(seconds: 30);
    httpClient!.maxConnectionsPerHost = 2;

    try {
      var httpRequest = await httpClient!.getUrl(Uri.parse(url));
      httpRequest.followRedirects = true;

      downloadNotifier?.setState(DownloadNotifierState.isDownloading, '$hashCode');
      final response = await httpRequest.close();
      httpClient!.close();

      if (response.statusCode == 200) {
        imgBytes = await consolidateHttpClientResponseBytes(response);

        if(widget.cacheManager != null) {
          widget.cacheManager!.add(cacheKey!, imgBytes!);
        }
      }
      else {
        throw Exception('err: ${response.statusCode}');
      }
    }
    catch (err){
      tried++;

      if(!(err is HttpException || err is SocketException)) {
        rethrow;
      }

      if(tried < widget.tryCount) {
        return _downloadAsBytes(url);
      }
      else {
        rethrow;
      }
    }

    return imgBytes;
  }*/

  Future<dynamic> _downloadAndSave(String url, String path) async {
    if(kIsWeb){
      return Future.value(null);
    }

    try {
      await _downloadImageBytes(url);
    }
    catch (err){
      _onError(err);
    }

    if(imgBytes != null) {
      final file = File(path);
      file.createSync(recursive: true);
      await file.writeAsBytes(imgBytes!);

      return Future.value(file);
    }

    return Future.value(null);
  }

  Future<bool> _checkFileAndRead(String? path) async{
    if(kIsWeb || path == null) {
      return false;
    }

    final file = File(path);
    final exist = await file.exists();

    if(!exist) {
      return false;
    }

    imgBytes = await file.readAsBytes();

    if(widget.cacheManager != null) {
      widget.cacheManager!.add(cacheKey!, imgBytes!);
    }

    return true;
  }
}





/*
Uint8List _readFile(String path){
  return File(path).readAsBytesSync();
}

String _writeFile(Map<String, dynamic> m){
  File file = File(m['path']);
  file.createSync(recursive: true);
  file.writeAsBytesSync(m['data']);
  return m['path'];
}*/
