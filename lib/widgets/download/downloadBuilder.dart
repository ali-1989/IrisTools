import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/cache/sizedCacheMap.dart';
import 'package:iris_tools/widgets/download/downloadNotifier.dart';
import 'package:http/http.dart' as http;

typedef OnDownload = Widget Function(Uint8List? bytes);
///================================================================================================
class DownloadBuilder extends StatefulWidget{
  final String? url;
  final FutureOr<String>? filePath;
  final OnDownload builder;
  final SizedCacheMap<String, Uint8List>? cacheManager;
  final String? cacheKey;
  final Widget Function()? beforeLoadFn;
  final Widget? beforeLoadWidget;
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
    this.beforeLoadWidget,
    this.errorWidget,
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
class _DownloadBuilderState extends State<DownloadBuilder> {
  bool occurError = false;
  bool isSetPath = false;
  String? filePath;
  Uint8List? fileBytes;
  int tried = 0;
  http.Client? httpClient;
  String? cacheKey;
  DownloadNotifier? downloadNotifier;
  late Widget beforeLoadWidget;

  @override
  void initState() {
    super.initState();

    cacheKey = widget.cacheKey?? '';

    _preparePath();

    beforeLoadWidget = widget.beforeLoadWidget?? SizedBox(width: 2, height: 2);
  }

  @override
  void didUpdateWidget(DownloadBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    cacheKey = widget.cacheKey?? '';

    if(widget.url != oldWidget.url || widget.filePath != oldWidget.filePath) {
      fileBytes = null;
      filePath = null;
      disposeDownloadNotifier();

      _preparePath();
    }
  }
  
  @override
  void dispose() {
    disposeDownloadNotifier();

    httpClient?.close(/*force: true*/);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(fileBytes == null){
      if(widget.cacheManager != null) {
        if (filePath != null || widget.url != null) {
          fileBytes = widget.cacheManager!.find((key, item) => (key == cacheKey));
        }
      }

      if(fileBytes == null && downloadNotifier?.state == DownloadNotifierState.isDownloaded){
        downloadNotifier?.setState(DownloadNotifierState.none);
        startDownload();
      }
    }

    if(fileBytes != null) {
      return widget.builder(fileBytes);
    }

    if(occurError) {
      return getErrorView();
    }

    if(filePath != null) {
      if (widget.forceDownload) {
        startDownload();
      }
      else {
        _checkFileAndRead(filePath).then((exist) {
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

    return getBeforeView();
  }

  void updateState(){
    if(mounted) {
      setState(() {});
    }
  }

  void _preparePath(){
    isSetPath = widget.filePath != null;

    if(widget.filePath is Future) {
      (widget.filePath as Future).then((address) {
        filePath = address;
        updateState();
      });
    }
    else if(widget.filePath is String) {
      filePath = widget.filePath! as String;
    }
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
    return getBeforeView();
  }

  void _prepareDownloadNotifier(){
    if(widget.url != null && downloadNotifier == null) {
      downloadNotifier = DownloadNotifier(widget.url!, '$hashCode');
      downloadNotifier!.addListener(_listenerToDownload);
    }

    if(widget.forceDownload){
      downloadNotifier?.setState(DownloadNotifierState.none);
    }
  }

  void disposeDownloadNotifier(){
    downloadNotifier?.removeListener(_listenerToDownload);
    downloadNotifier?.delete();
    downloadNotifier = null;
  }

  void _listenerToDownload() async {
    if(downloadNotifier?.state == DownloadNotifierState.isDownloaded){
      updateState();
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
    updateState();
  }

  void startDownload() async {
    if (widget.url == null) {
      return;
    }

    _prepareDownloadNotifier();

    if (downloadNotifier != null) {
      if (downloadNotifier!.state == DownloadNotifierState.isDownloaded || downloadNotifier!.state == DownloadNotifierState.isDownloading) {
        // this is a loop: update();
        return;
      }
    }

    if (!isSetPath || kIsWeb) {
      try{
        await _downloadAsBytes(widget.url!);
        updateState();
      }
      catch (e) {
        _onError(e);
      }
    }
    else {
      if (filePath == null) {
        await (widget.filePath as Future).then((value) => filePath = value);
      }

      if (filePath == null) {
        _onError(AssertionError('file path is null to download'));
        return;
      }

      await _downloadAndSave(widget.url!, filePath!);
    }
  }

  Future<dynamic> _downloadAsBytes(String url) async {
    try {
      downloadNotifier?.setState(DownloadNotifierState.isDownloading);
      httpClient = http.Client();
      fileBytes = await httpClient!.readBytes(Uri.parse(url));

      if(widget.cacheManager != null) {
        widget.cacheManager!.add(cacheKey!, fileBytes!);
      }

      downloadNotifier?.setState(DownloadNotifierState.isDownloaded);
      httpClient!.close();

      widget.onDownloadFn?.call(fileBytes!, filePath);
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

  Future<dynamic> _downloadAndSave(String url, String path) async {
    if(kIsWeb){
      return Future.value(null);
    }

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
    if(kIsWeb || path == null) {
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