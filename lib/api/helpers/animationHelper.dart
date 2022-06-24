import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimationHelper {
  AnimationHelper._();

  static Animation<Color> getValueColor(Color color){
    return AlwaysStoppedAnimation<Color>(color);
  }

  static Tween<Color?> getColorTween(Color begin, Color end){
    return ColorTween(begin: begin, end: end);
  }

  static Animation<T> getStoppedAnimation<T>(T value){
    return AlwaysStoppedAnimation<T>(value);
  }

  static Ticker createTicker(BuildContext context, void Function(Duration onTick) tickerCallback) {
    NavigatorState nav = Navigator.of(context);
    return nav.createTicker(tickerCallback);
  }

  /* use:
    @override
    void didChangeDependencies() {
      didChangeDependenciesNotifier.value = context;
      didChangeDependenciesNotifier.notifyListeners();
    }
   */
  static AnimationController getAnimationController(ValueNotifier didChangeDependenciesNotifier) {
    PublicVSync vSync = PublicVSync();
    didChangeDependenciesNotifier.addListener(() {
      vSync.onDidChangeDependencies(didChangeDependenciesNotifier.value);
    });

    AnimationController res = AnimationController(vsync: vSync);
    // usable: res.drive(Tween(begin: , end: ))
    return res;
  }
}
///==========================================================================================================
class SimpleVSync implements TickerProvider {

  const SimpleVSync();

  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}
///==========================================================================================================
class PublicVSync implements TickerProvider { //TickerProviderStateMixin
  final Set<Ticker> _tickers = <_WidgetTicker>{};

  PublicVSync();

  @override
  Ticker createTicker(TickerCallback onTick) {
    final _WidgetTicker result = _WidgetTicker(onTick, this, debugLabel: 'created by $this');
    _tickers.add(result);

    return result;
  }

  void _removeTicker(_WidgetTicker ticker) {
    _tickers.remove(ticker);
  }

  void onDidChangeDependencies(BuildContext context) {
    final bool muted = !TickerMode.of(context);

    for (final Ticker ticker in _tickers) {
      ticker.muted = muted;
    }
  }
}
///-------------------------------------------------------------------------------------------------
class _WidgetTicker extends Ticker {
  final PublicVSync _holder;

  _WidgetTicker(TickerCallback onTick, this._holder, { String? debugLabel }) : super(onTick, debugLabel: debugLabel);


  @override
  void dispose() {
    _holder._removeTicker(this);
    super.dispose();
  }
}
///==========================================================================================================


/* Doc:

  Theme(
      data: Theme.of(context).copyWith(accentColor: Colors.yellow),
      child: new CircularProgressIndicator(),
    );

 */