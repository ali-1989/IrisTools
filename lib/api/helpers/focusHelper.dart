import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// https://stackoverflow.com/questions/44991968/how-can-i-dismiss-the-on-screen-keyboard
/// https://medium.com/flutterdevs/focusnode-in-flutter-4a8613d7e4f6  : textField & keyboard
/// https://medium.com/codechai/flutter-keyboard-actions-and-next-focus-field-3260dc4c694

  /* Doc:

    *  rootScope:
      - any [focusManager.rootScope] reference to same object
      - WidgetsBinding.instance.focusManager.rootScope  ==  ctx.owner.focusManager.rootScope
      - rootScope.context ~is Always null
   */
class FocusHelper{
  FocusHelper._();

  static FocusScopeNode getNavigatorFocusScopeNode(BuildContext context) {
    return Navigator.of(context).focusNode.enclosingScope!;
  }

  static FocusScopeNode? getRootScopeNodeOf(BuildContext context) {
    return context.owner?.focusManager.rootScope;
  }

  static FocusScopeNode? getNearestScopeNodeOf(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.nearestScope;
  }

  static FocusScopeNode? getNearestAboveScopeNodeOf(BuildContext context){
    return context.owner?.focusManager.rootScope.enclosingScope;
  }
  ///...............................................................................................
  static void unFocusNavigator(BuildContext context) {
    Navigator.of(context).focusNode.unfocus();
  }

  static void unFocusRootScope(BuildContext context){
    context.owner?.focusManager.rootScope.unfocus();
  }

  static void unFocus(BuildContext context){
    try {
      final fs = FocusScope.of(context);

      if(fs.hasFocus && !fs.hasPrimaryFocus){
        if (fs.focusedChild != null) {
          fs.focusedChild?.unfocus();
        }
        else {
          fs.unfocus();
        }
      }
    }
    catch(e){}
  }

  // FocusScope.of(context).requestFocus(FocusNode());
  /// use this if has textField
  static void hideKeyboardByUnFocusRoot(){
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<void> hideKeyboardByUnFocusRootWait(){
    FocusManager.instance.primaryFocus?.unfocus();
    return Future.delayed(Duration(milliseconds: 250));
  }

  static void hideKeyboardByUnFocus(BuildContext context){
    /// is nearest scope or rootScope
    final currentScope = FocusScope.of(context);

    if(currentScope.hasFocus) {
      if (currentScope.hasPrimaryFocus) {
        currentScope.unfocus();//maybe occur exception
      }
      else {
        if (currentScope.focusedChild != null) {
          currentScope.focusedChild?.unfocus();
        }
        else {
          currentScope.unfocus();
        }
      }
    }
  }

  /// not use this if has textField
  static void hideKeyboardByService(){
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void hideKeyboardByChangeFocus(BuildContext context, FocusNode node){
    FocusScope.of(context).requestFocus(node); // node = FocusNode() : must dispose node [memory lake]
  }

  static void showKeyboardByRequest(BuildContext context, FocusNode node){
    FocusScope.of(context).requestFocus(node); // must dispose node [memory lake]
  }

  static void showKeyboardByService(){
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  static void setCanRequestFocus(BuildContext context, bool state){
    context.owner?.focusManager.rootScope.canRequestFocus = state;
  }

  static void requestFocus(BuildContext ctx){
    ctx.owner?.focusManager.rootScope.requestFocus();
  }

  static void requestFocusFor(BuildContext ctx, FocusNode node){
    ctx.owner?.focusManager.rootScope.requestFocus(node);
  }

  static FocusNode? getFocusedChild(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.focusedChild;
  }

  static bool? nextFocus(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.nextFocus();
  }

  static bool? previousFocus(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.previousFocus();
  }

  static FocusNode? getParentRootScope(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.parent;
  }

  static bool? rootHasFocus(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.hasFocus;
  }

  static bool? rootHasPrimaryFocus(BuildContext ctx){
    return ctx.owner?.focusManager.rootScope.hasPrimaryFocus;
  }

  static bool isFocusInWidget(BuildContext ctx){
    return Focus.isAt(ctx);
  }
}