import 'dart:async';
import 'package:flutter/material.dart';

/// usage: WidgetsBinding.instance.addObserver(AppEventListener());

class AppEventListener extends WidgetsBindingObserver {
	List<FutureOr Function()> _resumeCallBackList = [];
	List<Function> _pauseCallBackList = [];
	List<Function> _detachedCallBackList = [];

	AppEventListener();

	void addResumeListener(Function() fn){
		if(!_resumeCallBackList.contains(fn)){
			_resumeCallBackList.add(fn);
		}
	}

	void removeResumeListener(Function() fn){
		_resumeCallBackList.remove(fn);
	}

	void addPauseListener(Function() fn){
		if(!_pauseCallBackList.contains(fn)){
			_pauseCallBackList.add(fn);
		}
	}

	void removePauseListener(Function() fn){
		_pauseCallBackList.remove(fn);
	}

	void addDetachListener(Function() fn){
		if(!_detachedCallBackList.contains(fn)){
			_detachedCallBackList.add(fn);
		}
	}

	void removeDetachListener(Function() fn){
		_detachedCallBackList.remove(fn);
	}

	@override
	Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
		switch (state) {
			case AppLifecycleState.inactive:
			case AppLifecycleState.paused:
				/// screenOff, homeKeyPress, closeApp
				_pauseCallBack();
				break;
			case AppLifecycleState.detached:
				/// closeApp
				_detachedCallBack();
				break;
			case AppLifecycleState.resumed:
				_resumeCallBack();
				break;
		}
	}

	Future _pauseCallBack(){
		for(Function fn in _pauseCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return Future.value(true);
	}

	Future _detachedCallBack(){
		for(Function fn in _detachedCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return Future.value(true);
	}

	Future _resumeCallBack() async{

		for(var fn in _resumeCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return Future.value(true);
	}

	//  @override
	//  void didChangeLocale(Locale locale)

	//  @override
	//  void didChangeTextScaleFactor()

	//  @override
	//  void didChangeMetrics();

	//  @override
	//  void didHaveMemoryPressure()

	@override
	Future<bool> didPopRoute(){
		return super.didPopRoute();
	}

	@override
	Future<bool> didPushRoute(String route){
		return super.didPushRoute(route);
	}
}