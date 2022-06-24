import 'dart:async';
import 'package:flutter/material.dart';

typedef RefreshBuilder<T> = Widget Function(BuildContext context, RefreshController controller);
///=======================================================================================
class Refresh extends StatefulWidget {
	final RefreshBuilder builder;
	final RefreshController controller;

	Refresh({Key? key,
		required this.controller,
		required this.builder,
	}): super(key : key);

	@override
  State<StatefulWidget> createState() {
    return RefreshState();
  }
}
///=======================================================================================================
class RefreshState extends RefreshStateApi<Refresh> {

	@override
	void initState() {
		super.initState();

		widget.controller._state = this;
	}

	/// call before any build() if parent rebuild
	@override
	void didUpdateWidget(Refresh oldWidget) {
		//_controller = oldWidget.controller;
		super.didUpdateWidget(oldWidget);
	}

	/// this is call any time, like: init, screen on/off, rotation, ...
	/// call after [createState]
	/// no call in back route
  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, widget.controller);
  }

  @override
	void dispose() {
		widget.controller._disposeFromWidget();
		super.dispose();
	}

	@override
  void update() {
		setState(() {});
	}

	@override
  void disposeWidget() {
		dispose();
	}
}
///=======================================================================================================
abstract class RefreshStateApi<w extends StatefulWidget> extends State<w> {
	void update();
	void disposeWidget();
}
///=======================================================================================================
class RefreshController {
	RefreshStateApi? _state;
	Map<String, dynamic> objects = {};
	dynamic _attach;
	bool errorOccurred = false;
	bool usePrimaryView = true;
	String? _primaryTag;
	String? _extraTag;
	final List<Sink> _chainUpdate = [];
	final Map<Stream, StreamSubscription> _streamListeners = {};
	StreamController? _streamCtr;
	Function? _onData;
	Function? _onError;

	void update({Duration? delay, dynamic event}){
		if(_state != null && _state!.mounted){
			if(delay == null) {
			  _state!.update();
			} else {
			  Timer(delay, (){_state!.update();});
			}
		}

		for(var s in _chainUpdate) {
			try {
				s.add(event?? this);
			}
			catch(e){}
		}
	}

	Widget? get widget => _state?.widget;
	BuildContext? get context => _state?.context;

	bool isPrimaryTag(String tag) => _primaryTag != null && _primaryTag == tag;
	bool isExtraTag(String tag) => _extraTag != null && _extraTag == tag;

	void setPrimaryTag(String val){
		_primaryTag = val;
	}

	String? getPrimaryTag(){
		return _primaryTag;
	}

	void setExtraTag(String val){
		_extraTag = val;
	}

	String? getExtraTag(){
		return _extraTag;
	}

	void set(String key, dynamic val){
		objects[key] = val;
	}

	void addIfNotExist(String key, dynamic val){
		if(objects[key] == null) {
		  objects[key] = val;
		}
	}

	T get<T>(String key){
		return objects[key];
	}

	T getOrDefault<T>(String key, T defaultVal){
		return objects[key]?? defaultVal;
	}

	bool exist(String key){
		return objects[key] != null;
	}

	T attachment<T>(){
		return _attach;
	}

	void attach(dynamic val){
		_attach = val;
	}

	void setOnData(void Function(dynamic event, RefreshController controller) fun){
		_onData = fun;
	}

	void setOnError(void Function(Object event, RefreshController controller) fun){
		_onError = fun;
	}

	void fireOnData(event) {
		if(_onData != null) {
		  _onData!(event, this);
		}
	}

	void fireOnError(Object err) {
		if(_onError != null) {
		  _onError!(err, this);
		}
	}

	StreamSubscription listenTo(Stream stream) {
		if(_streamListeners.containsKey(stream)) {
		  return _streamListeners[stream]!;
		}

		final sc = stream.listen(fireOnData, onError: fireOnError);

		_streamListeners[stream] = sc;
		return sc;
	}

	void unListenTo(Stream stream) {
		_streamListeners.remove(stream)?.cancel();
	}

	void _disposeFromWidget() {
	}

	void dispose([bool disposeWidget = false]) {
		_streamListeners.forEach((key, value) {
			try {
				value.cancel();
			}
			catch(e) {}
			});

		_streamListeners.clear();
		_chainUpdate.clear();
		_streamCtr?.close();
		objects.clear();

		if(disposeWidget && _state != null) {
		  _state!.disposeWidget();
		}

		_state = null;
	}

	void chainUpdate(Sink sink){
		_chainUpdate.add(sink);
	}

	void unChainUpdate(Sink sink){
		_chainUpdate.remove(sink);
	}

	void _checkSink(){
		if(_streamCtr == null){
			_streamCtr = StreamController();

			_streamCtr!.stream.listen((event) {update(event: event);});
		}
	}

	Sink getSink(){
		_checkSink();

		return _streamCtr!.sink;
	}
}