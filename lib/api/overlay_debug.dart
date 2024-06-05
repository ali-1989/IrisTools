
import 'dart:math';

import 'package:flutter/material.dart';

class OverlayDebug {
  final List<Widget> _views = [];
  bool _isShow = false;
  late OverlayEntry _overlayEntry;
  final BuildContext _context;
  final _notifier = ValueNotifier<int>(0);
  CrossAxisAlignment alignment = CrossAxisAlignment.start;
  final Random _random = Random();

  OverlayDebug(BuildContext context) : _context = context {
    _overlayEntry = OverlayEntry(
        builder: (_){
          return ValueListenableBuilder(
            valueListenable: _notifier,
            builder: (_, value, __) {
              return Material(
                color: Colors.yellow.withAlpha(40),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: alignment,
                    children: [
                      const SizedBox(height: 30),

                      Card(
                        shape: const CircleBorder(),
                        child: CloseButton(
                          onPressed: (){remove();},
                          color: Colors.red,
                        ),
                      ),

                      Expanded(
                          child: ListView.builder(
                            itemCount: _views.length,
                              itemBuilder: viewBuilder
                          )
                      ),
                    ],
                  ),
                ),
              );
            }
          );
        }
    );
  }

  Widget viewBuilder(BuildContext _, int idx) {
    final itm = _views[idx];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      color: Color.fromARGB(230, _random.nextInt(180)+30, _random.nextInt(180)+30, _random.nextInt(150)+30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical:3.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${idx+1}: ', style: const TextStyle(fontWeight: FontWeight.w900),),
            Flexible(child: itm),
          ],
        ),
      ),
    );
  }
  void addView(Widget view){
    _views.add(view);
    _show();
  }

  void clearView(){
    _views.clear();
    _show();
  }

  void _show() async {
    if(!_context.mounted){
      return;
    }

    if(_isShow){
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _notifier.value++;
      });

      return;
    }

    await Future.delayed(const Duration(milliseconds: 10), (){});

    final isDirty = (_context as Element).dirty;

    if(isDirty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Overlay.of(_context).insert(_overlayEntry);
      });
    }
    else {
      Overlay.of(_context).insert(_overlayEntry);
    }

    _isShow = true;
  }

  void remove(){
    if(_isShow) {
      _overlayEntry.remove();
      _isShow = false;
    }
  }

  void dispose(BuildContext context){
    remove();
    //Overlay.of(context).dispose(); throw error
  }
}