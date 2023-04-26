import 'package:flutter/material.dart';


/*
  textDirection: direction.getTextDirection(txtCtr.text),
  onChanged: (t){
      direction.onChangeText(t);
    },
  ------------- selection ----------------------------
onTap: (){
    dCtr.manageSelection(txtCtr);
  },
 */
typedef BuildTextField = Widget Function(BuildContext context, AutoDirectionController direction);
///==================================================================================
class AutoDirection extends StatefulWidget {
  final BuildTextField builder;

  AutoDirection({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AutoDirectionState();
  }
}
///====================================================================================
class AutoDirectionState extends State<AutoDirection> {
  late AutoDirectionController _controller;


  @override
  void initState() {
    super.initState();

    _controller = AutoDirectionController(this);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _controller);
  }

  void update(){
    setState(() {});
  }
}
///==================================================================================
class AutoDirectionController {
  late AutoDirectionState _state;
  TextDirection? _defaultDirection;
  TextDirection? _curDirection;
  int startSelection = 0;
  int endSelection = 0;
  int lastTap = 0;

  AutoDirectionController(AutoDirectionState state){
    _state = state;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _detectByContext();
      _state.update();
    });
  }

  void setDefaultDirection(TextDirection def){
    _defaultDirection = def;
  }

  TextDirection getTextDirection(String? text){
    _detectByText(text?? '');

    return _curDirection!;
  }

  Alignment getAlignment(String? text){
    _detectByText(text?? '');

    if(_curDirection! == TextDirection.ltr){
      return Alignment.centerLeft;
    }
    else {
      return Alignment.centerRight;
    }
  }

  void onChangeText(String text){
    _detectByText(text);

    _state.update();
  }

  void _detectByText(String text){
    _curDirection = null;

    text = text.trim();
    text = _removeNonViewable(text);

    if (text.isNotEmpty) {
      if (_hasRtlChar(text.substring(0, 1))) {
        _curDirection = TextDirection.rtl;
      }
      else {
        _curDirection = TextDirection.ltr;
      }
    }

    _detectByContext();
  }

  void _detectByContext(){
    try {
      _curDirection ??= Directionality.of(_state.context);
    }
    catch(e){
      _curDirection = _defaultDirection?? TextDirection.ltr;
    }
  }

  String _removeNonViewable(String str){ // All Control Char \u200E\u200F
    return str.replaceAll(RegExp(r'[\p{C}]', unicode: true, multiLine: true), '');
  }

  bool _hasRtlChar(String inp){
    final rtlChars = RegExp('[\u0600-\u06FF\u0750-\u077F\u08A0–\u08FF\uFB50–\uFBC1\uFBD3-\uFD3F\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFD\uFE70-\uFEFC\u0660-\u0669\u06F0-\u06F9]+',
        caseSensitive: false, multiLine: true);
    return rtlChars.hasMatch(inp);
  }

  void manageSelection(TextEditingController ctr){
    if(lastTap > 0 && (DateTime.now().millisecondsSinceEpoch - lastTap) < 1000) {
      lastTap = DateTime.now().millisecondsSinceEpoch;
      return;
    }

    lastTap = DateTime.now().millisecondsSinceEpoch;

    if(startSelection != endSelection){
      ctr.selection = TextSelection(baseOffset: ctr.text.length, extentOffset: ctr.text.length);
    }
    else {
      ctr.selection = TextSelection(baseOffset: 0, extentOffset: ctr.text.length);
    }

    startSelection = ctr.selection.start;
    endSelection = ctr.selection.end;
  }
}