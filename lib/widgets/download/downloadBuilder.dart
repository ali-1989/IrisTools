import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/cache/sizedCacheMap.dart';
import 'package:iris_tools/widgets/download/downloadNotifier.dart';

typedef OnDownload = Widget Function(Uint8List? bytes);
///================================================================================================
class DownloadBuilder extends StatefulWidget{
  final String? url;
  final FutureOr<String>? filePath;
  final OnDownload builder;
  final SizedCacheMap<String, Uint8List>? cacheManager;
  final String? cacheKey;
  final Widget Function()? beforeLoadFn;
  final Widget beforeLoadWidget;
  final Widget? errorWidget;
  final bool forceDownload;
  final int tryCount;
  final void Function(Uint8List bytes, String? path)? onDownloadFn;
  final void Function(dynamic error)? onErrorFn;

  DownloadBuilder({
    Key? key,
    required this.builder,
    this.url,
    this.filePath,
    this.cacheManager,
    this.cacheKey,
    this.onDownloadFn,
    this.onErrorFn,
    this.beforeLoadFn,
    this.beforeLoadWidget = const SizedBox(width: 2, height: 2,),
    this.errorWidget,// = const SizedBox(width: 2, height: 2,)
    this.forceDownload = false,
    this.tryCount = 4,
  }) : assert(cacheManager == null || cacheKey != null, 'must set cacheKey for DownloadBuilder'),
        super(key : key);

  @override
  State<StatefulWidget> createState() {
    return _DownloadBuilderState();
  }
}
///=================================================================================================================
class _DownloadBuilderState extends State<DownloadBuilder>{
  bool occurError = false;
  bool notSetPath = true;
  String? filePath;
  Uint8List? fileBytes;
  int tried = 0;
  HttpClient? httpClient;
  String? cacheKey;
  DownloadNotifier? downloadNotifier;

  void _preparePath(){
    if(widget.filePath is Future) {
      (widget.filePath as Future).then((address) {
        filePath = address;
        update();
      });
    }
    else if(widget.filePath is String) {
      filePath = widget.filePath! as String;
    }
  }

  void _prepareDownloader(){
    if(widget.url != null && !notSetPath) {
      downloadNotifier = DownloadNotifier(widget.url!, '$hashCode');
      downloadNotifier!.addListener(_listenToDownload);
    }
  }

  @override
  void initState() {
    super.initState();

    cacheKey = widget.cacheKey?? '';
    notSetPath = widget.filePath == null;

    _preparePath();

  }

  @override
  void didUpdateWidget(DownloadBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    cacheKey = widget.cacheKey?? '';

    if(widget.url != oldWidget.url || widget.filePath != oldWidget.filePath) {
      fileBytes = null;
      _preparePath();
    }
  }

  @override
  Widget build(BuildContext context) {
    if(fileBytes == null && widget.cacheManager != null){
      if(filePath != null || widget.url != null) {
        fileBytes = widget.cacheManager!.find((key, item) => (key == cacheKey));
      }
    }

    if(fileBytes != null) {
      return widget.builder(fileBytes);
    }

    if(occurError) {
      return getErrorView();
    }

    if(filePath != null) {
      _checkFileAndRead(filePath).then((exist) {
        if (exist) {
          if (widget.forceDownload) {
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

    return getBeforeView();
  }

  @override
  void dispose() {
    httpClient?.close(force: true);

    if(downloadNotifier != null) {
      downloadNotifier!.removeListener(_listenToDownload);
      downloadNotifier!.delete();
    }

    super.dispose();
  }

  void update(){
    if(mounted) {
      setState(() {});
    }
  }

  Widget getBeforeView(){
    if(widget.beforeLoadFn != null) {
      return widget.beforeLoadFn!();
    }
    else {
      return widget.beforeLoadWidget;
    }
  }

  Widget getErrorView(){
    return widget.errorWidget?? getBeforeView();
  }

  Widget getFirstViewForFade() {
    return getBeforeView();
  }

  void _listenToDownload(){
    if(downloadNotifier?.state == DownloadNotifierState.isDownloaded){
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

    occurError = true;
    widget.onErrorFn?.call(err);
    update();
  }

  void startDownload() async {
    if (widget.url == null) {
      return;
    }

    _prepareDownloader();

    if (downloadNotifier != null) {
      if (downloadNotifier!.state == DownloadNotifierState.isDownloaded) {
        // this is a loop: update();
        return;
      }
    }

    if (notSetPath) {
      // ignore: unawaited_futures
      _downloadAsBytes(widget.url!).then((value) {
        widget.onDownloadFn?.call(fileBytes!, filePath);
        update();
      }).catchError((err) {
        _onError(err);
      });
    }
    else {
      if(filePath == null) {
        await (widget.filePath as Future).then((value) => filePath = value);
      }

      if(filePath == null){
        _onError(AssertionError('file path is null to download'));
      }

      // ignore: unawaited_futures
      _downloadAsFile(widget.url!, filePath!).then((value) {
        widget.onDownloadFn?.call(fileBytes!, filePath!);

        update();
        downloadNotifier?.setState(DownloadNotifierState.isDownloaded);
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

      downloadNotifier?.setState(DownloadNotifierState.isDownloading);
      final response = await httpRequest.close();
      httpClient!.close();

      if (response.statusCode == 200) {
        fileBytes = await consolidateHttpClientResponseBytes(response);

        if(widget.cacheManager != null) {
          widget.cacheManager!.add(cacheKey!, fileBytes!);
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

    return fileBytes!;
  }

  Future<dynamic> _downloadAsFile(String url, String path) async{
    try {
      await _downloadAsBytes(url);
    }
    catch (err){
      _onError(err);
    }

    if(fileBytes != null) {
      final file = File(path);
      file.createSync(recursive: true);
      await file.writeAsBytes(fileBytes!);

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

    fileBytes = await file.readAsBytes();

    if(widget.cacheManager != null) {
      widget.cacheManager!.add(cacheKey!, fileBytes!);
    }

    return true;
  }
}