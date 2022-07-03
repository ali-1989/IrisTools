import 'package:flutter/material.dart';

//typedef OnNoData = Widget Function(BuildContext context);
typedef DataBuilder = Widget Function(BuildContext context, dynamic data);
///==========================================================================================
class CommonRefresh extends StatefulWidget {
  static final _commons = <_CommonHolder>[];
  final DataBuilder builder;
  final String tag;

  const CommonRefresh({
    Key? key,
    required this.tag,
    required this.builder,
  }) : super(key: key);

  @override
  _CommonRefreshState createState() => _CommonRefreshState();

  static _CommonHolder? _findCommonHolder(String tag){
    for(var c in _commons){
      if(c.tag == tag){
        return c;
      }
    }
  }

  static void _addState(_CommonRefreshState state){
    _CommonHolder? c = _findCommonHolder(state.widget.tag);

    if(c == null){
      c = _CommonHolder();
      c.tag = state.widget.tag;
      c.states.add(state);

      _commons.add(c);
    }
    else {
      c.states.add(state);
    }
  }

  static void _removeState(_CommonRefreshState state){
    _CommonHolder? c = _findCommonHolder(state.widget.tag);

    if(c != null){
      c.states.remove(state);

      /*no: if(c.states.isEmpty){
        _commons.remove(c);
      }*/
    }
  }

  static void refresh(String tag, dynamic data){
    _CommonHolder? common = _findCommonHolder(tag);

    if(common != null){
      common.data = data;

      for(var f in common.states){
        f.update();
      }
    }
  }

  static void changeTag(String tag, String newTag){
    _CommonHolder? common = _findCommonHolder(tag);

    if(common != null){
      if(common.tag == tag) {
        common.tag = newTag;
      }
    }
  }
}
///===========================================================================================
class _CommonRefreshState extends State<CommonRefresh> {
  late _CommonHolder _commonHolder;

  @override
  void initState() {
    super.initState();

    CommonRefresh._addState(this);
    _commonHolder = CommonRefresh._findCommonHolder(widget.tag)!;
  }

  @override
  void didUpdateWidget(CommonRefresh oldWidget) {
    if (oldWidget.tag != widget.tag) {
      CommonRefresh._removeState(this);
      CommonRefresh._addState(this);
      _commonHolder = CommonRefresh._findCommonHolder(widget.tag)!;
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    /*if(_commonHolder.data == null){
      return widget.onNoData.call(context);
    }

    */return widget.builder.call(context, _commonHolder.data);
  }

  @override
  void dispose() {
    CommonRefresh._removeState(this);

    super.dispose();
  }
  void update(){
    if(mounted){
      setState(() {});
    }
  }
}
///===========================================================================================
class _CommonHolder {
  late String tag;
  List<_CommonRefreshState> states = [];
  dynamic data;
}