import 'dart:async';
import 'package:flutter/material.dart';

/// usage: WidgetsBinding.instance.addObserver(AppEventListener());

class AppEventListener extends WidgetsBindingObserver {
	final List<FutureOr Function()> _resumeCallBackList = [];
	final List<Function> _pauseCallBackList = [];
	final List<Function> _detachedCallBackList = [];
	final List<Function> _inActiveCallBackList = [];
	final List<Function> _hiddenCallBackList = [];

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

	void addHiddenListener(Function() fn){
		if(!_hiddenCallBackList.contains(fn)){
			_hiddenCallBackList.add(fn);
		}
	}

	void removeHiddenListener(Function() fn){
		_hiddenCallBackList.remove(fn);
	}

	void addInactiveListener(Function() fn){
		if(!_inActiveCallBackList.contains(fn)){
			_inActiveCallBackList.add(fn);
		}
	}

	void removeInactiveListener(Function() fn){
		_inActiveCallBackList.remove(fn);
	}

	@override
	Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
		switch (state) {
			case AppLifecycleState.inactive:
				_inactiveCallBack();
				break;
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
			case AppLifecycleState.hidden:
				_hiddenCallBack();
		}
	}

	FutureOr _pauseCallBack(){
		for(Function fn in _pauseCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return true;
	}

	FutureOr _inactiveCallBack(){
		for(Function fn in _inActiveCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return true;
	}

	FutureOr _detachedCallBack(){
		for(Function fn in _detachedCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return true;
	}

	FutureOr _resumeCallBack() async{
		for(final fn in _resumeCallBackList){
			try{
				fn();
			}
			catch(e){}
		}

		return true;
	}

	Future _hiddenCallBack() async{
		for(final fn in _resumeCallBackList){
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

	/*@override
	Future<bool> didPopRoute(){
		return super.didPopRoute();
	}

	@override
	Future<bool> didPushRoute(String route){
		return super.didPushRoute(route);
	}*/
}