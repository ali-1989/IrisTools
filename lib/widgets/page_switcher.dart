import 'package:flutter/material.dart';

class PageSwitcher extends StatefulWidget {
  final PageSwitcherController controller;
  final List<Widget> pages;
  final Map<int, String> indexName;
  final int? initialIndex;

  const PageSwitcher({
    Key? key,
    required this.controller,
    required this.pages,
    this.initialIndex = 0,
    this.indexName = const {},
  }) : super(key: key);

  @override
  State createState() => _PageSwitcherState();
}
///===================================================================================
class _PageSwitcherState extends State<PageSwitcher> {
  int index = 0;

  @override
  void initState(){
    super.initState();

    index = widget.initialIndex?? 0;
    widget.controller._setState(this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.pages[index];
  }

  void changePageTo(int index){
    this.index = index;
    setState(() {});
  }
}
///===================================================================================
class PageSwitcherController {
  late _PageSwitcherState _state;

  int get index => _state.index;

  void _setState(_PageSwitcherState state){
    _state = state;
  }

  void changePageTo(int index){
    _state.changePageTo(index);
  }

  void next(){
    changePageTo(index+1);
  }

  void previous(){
    changePageTo(index-1);
  }

  void changePageByName(String name){
    for (final cou in _state.widget.indexName.entries) {
      if(cou.value == name){
        changePageTo(cou.key);
        break;
      }
    }
  }
}
