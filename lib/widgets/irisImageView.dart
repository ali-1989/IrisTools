import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/cache/cacheMap.dart';
import 'package:iris_tools/widgets/download/downloadNotifier.dart';


class IrisImageView extends StatefulWidget{
  final String? url;
  final Uint8List? bytes;
  final FutureOr<String>? imagePath;
  final CacheMap<String, Uint8List>? cacheManager;
  final String? cacheKey;
  final Widget Function()? beforeLoadFn;
  final Widget beforeLoadWidget;
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
    this.width, this.height,
    this.onDownloadFn,
    this.onErrorFn,
    this.onLoadFn,
    this.beforeLoadFn,
    this.beforeLoadWidget = const SizedBox(width: 2, height: 2),
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
  bool notSetPath = true;
  String? imgPath;
  Uint8List? imgBytes;
  int tried = 0;
  //Size? sizeOfScreen;
  late AnimationController animController;
  late Animation<double> animation;
  bool _mustAnimate = false;
  HttpClient? httpClient;
  String? cacheKey;
  DownloadNotifier? downloadNotifier;

  void _preparePath(){
    if(widget.imagePath is Future) {
      (widget.imagePath as Future).then((address) {
        imgPath = address;
        update();
      });
    }
    else if(widget.imagePath is String) {
      imgPath = widget.imagePath! as String;
    }
  }

  void _prepareDownloader(){
    if(widget.url != null && !notSetPath) {
      downloadNotifier = DownloadNotifier(widget.url!, '$hashCode');
    }
  }

  @override
  void initState() {
    super.initState();

    imgBytes = widget.bytes;
    cacheKey = widget.cacheKey?? '';
    notSetPath = widget.imagePath == null;

    _preparePath();

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
      _checkFileAndRead(imgPath).then((exist) {
        if (exist) {
          if (widget.forceDownloadImage) {
            startDownload();
          }

          update();
        }
        else if(widget.url != null) {
          startDownload();
        }
      });
    }
    else if(widget.url != null) {
      startDownload();
    }

    return (widget.shape == null)? getBeforeView() : clipView(getBeforeView());
  }

  @override
  void dispose() {
    httpClient?.close(force: true);
    animController.dispose();

    if(downloadNotifier != null) {
      if (downloadNotifier!.isIOwner('$hashCode')) {
        if(downloadNotifier!.state == DownloadNotifierState.isDownloading) {
          File(imgPath!).delete().catchError((e){return File('');});
        }

        downloadNotifier!.setState(DownloadNotifierState.none, '$hashCode');
        downloadNotifier!.delete('$hashCode');
      }
      else {
        downloadNotifier!.removeListener(_listenToDownload);
      }
    }

    super.dispose();
  }

  void update(){
    if(mounted) {
      setState(() {});
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

  Image getFileImage(){
    /*FileImage fi = FileImage();
    ImageStream newStream =
    fi.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null ? Size(widget.width, widget.height) : null,
    )).addListener((listener){});*/
    //sizeOfScreen = MediaQuery.of(context).size;

    return Image.file(File(imgPath!),
      //width: widget.width?? sizeOfScreen!.width,
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
    //if use [BoxFit.scaleDown] must set width,height to some widget like: Image widget
    //if use [BoxFit.contain] loading widget is big
    // return FittedBox(child: widget.beforeLoadFn(), fit: BoxFit.contain)
    if(widget.beforeLoadFn != null) {
      return widget.beforeLoadFn!();
    } else {
      return widget.beforeLoadWidget;
    }
  }

  Widget getErrorView(){
    //return FittedBox(child: widget.errorWidget, fit: BoxFit.scaleDown,);
    return widget.errorWidget?? getBeforeView();
  }

  Widget getFirstViewForFade() {
    return imgBytes != null ? getMemoryImage() : getBeforeView();
  }

  void _listenToDownload(){
    if(downloadNotifier?.state == DownloadNotifierState.isDownloaded){
      downloadNotifier!.removeListener(_listenToDownload);
      update();
    }
    else if(downloadNotifier?.state == DownloadNotifierState.none){
      startDownload();
    }
  }

  void _onError(dynamic err){
    if(!mounted){
      return;
    }

    _mustAnimate = true;
    occurError = true;
    widget.onErrorFn?.call(err);
    update();
    downloadNotifier?.delete('$hashCode');
    downloadNotifier = null;
  }

  void startDownload() async {
    if (widget.url == null) {
      return;
    }

    _prepareDownloader();

    if (downloadNotifier != null && !downloadNotifier!.isIOwner('$hashCode')) {
      if (downloadNotifier!.state == DownloadNotifierState.isDownloaded) {
        // this is a loop: update();
        return;
      }

      if (downloadNotifier!.state == DownloadNotifierState.isDownloading) {
        downloadNotifier!.addListener(_listenToDownload);
        return;
      }
    }

    if (notSetPath) {
      // ignore: unawaited_futures
      _downloadAsBytes(widget.url!).then((value) {
        widget.onDownloadFn?.call(imgBytes!, imgPath);
        _mustAnimate = true;
        update();
      })
          .catchError((err) {
        _onError(err);
      });
    }
    else {
      if (imgPath == null) {
        await (widget.imagePath as Future).then((value) => imgPath = value);
      }

      if (imgPath == null) {
        _onError(AssertionError('Image path is null to download'));
      }

      // ignore: unawaited_futures
      _downloadAsFile(widget.url!, imgPath!).then((value) {
        widget.onDownloadFn?.call(imgBytes!, imgPath!);

        FileImage(File(imgPath!)).evict().then((value) {
          _mustAnimate = true;
          update();
          downloadNotifier?.setState(DownloadNotifierState.isDownloaded, '$hashCode');
          downloadNotifier?.delete('$hashCode');
          downloadNotifier = null;
        }).catchError((err) {
          _onError(err);
        });
      });
    }
  }

  Future<dynamic> _downloadAsBytes(String url) async {
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
        throw Exception('err: ' + response.statusCode.toString());
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
  }

  Future<dynamic> _downloadAsFile(String url, String path) async{
    try {
      await _downloadAsBytes(url);
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
    if(path == null) {
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
