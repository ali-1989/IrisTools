import 'dart:async';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/navigatorHelper.dart';
import 'package:iris_tools/api/timerTools.dart';
import 'package:flutter/material.dart';

class OverlayDialog {
	OverlayDialog._internal();
	static final OverlayDialog _instance = OverlayDialog._internal();

	factory OverlayDialog() => _instance;

	Future<T?> show<T>(BuildContext context, OverlayScreenView view, {
		bool canBack = true,
		Color background = Colors.transparent,
	}) {
		// showDialog => Navigator.of().push<T>(DialogRoute<T>(view))
		return showDialog<T>(
			context: context,
			useSafeArea: false,
			useRootNavigator: false, // if true:error in internal Navigator
			barrierDismissible: canBack,
			barrierColor: background,
			routeSettings: RouteSettings(name: view.routeName),
			builder: (BuildContext context) {
				if(canBack) {
				  return view;
				} else {
				  return WillPopScope(child: view, onWillPop: () async {return false;});
				}
			},
		);
	}

	Future<T?> showMiniInfo<T>(BuildContext context, Widget infoView, String name, {
		Duration? autoClose,
		Color background = Colors.transparent,
		bool center = true,
		double? top,
		double? bottom,
		double? start,
		double? end,
		Color? dimColor,
	}) {

		final temp = Theme.of(context);
		dimColor ??= ColorHelper.isDarkColor(temp.backgroundColor)?
			Colors.white.withAlpha(80): Colors.black.withAlpha(120);

		final size = MediaQuery.of(context).size;
		final stableCtx = NavigatorHelper.getStableContext(context);

		final view = OverlayScreenView(
			content: GestureDetector(
				behavior: HitTestBehavior.translucent,
				onTap: (){
					OverlayDialog().hideByName(stableCtx, name);
				},
				child: SizedBox(
					width: size.width,
					height: size.height,
					child: ColoredBox(
						color: background,
						child: Stack(
							fit: StackFit.expand,
							children: [
								if(center)
									Center(
										child: infoView,
									),

								if(!center)
									Positioned.directional(
										textDirection: Directionality.of(context),
										start: start,
										end: end,
										bottom: bottom,
										child: infoView,
									),
							],
						),
					),
				),
			),
			routingName: name,
		);

		if(autoClose != null) {
			TimerTools.waitThen(autoClose, () {
				hideByOverlay(context, view);
			});
		}

		return showDialog<T>(
			context: context,
			useSafeArea: false,
			barrierDismissible: true,
			barrierColor: dimColor,
			routeSettings: RouteSettings(name: view.routeName),
			builder: (BuildContext context) {
				return view;
			},
		);
	}

	void hideByOverlay(BuildContext context, OverlayScreenView view) {
		final route = NavigatorHelper.accessModalRouteByRouteName(context, view.routeName);

		if(route == null) {
			return;
		}

		try {
			Navigator.of(context).removeRoute(route);
		}
		catch (e){}
	}

	void hideByName(BuildContext context, String screenName) {
		final route = NavigatorHelper.accessModalRouteByRouteName(context, screenName);

		if(route == null) {
		  return;
		}

		Navigator.of(context).removeRoute(route);
	}

	void hideByPop(BuildContext context, {dynamic data}) {
		Navigator.of(context).pop(data);
	}

	void hide(BuildContext context) {
		final os = NavigatorHelper.findAncestorWidgetOfExactType<OverlayScreenView>(context);

		if(os != null) {
			hideByOverlay(context, os);
		}

		//Navigator.pop(context);
	}

	bool existEnyOverlay(BuildContext context) {
		final os = NavigatorHelper.findAncestorWidgetOfExactType<OverlayScreenView>(context);
		return os != null;
	}
}
///=============================================================================================================
class OverlayScreenView extends StatelessWidget {
	final String routeName;
	final Color backgroundColor;
	final Widget content;
	final bool scrollable;

	OverlayScreenView({
		Key? key,
		required this.content,
		this.backgroundColor = Colors.transparent,
		this.scrollable = false,
		String? routingName,
	}) : routeName = routingName?? Generator.generateKey(8), super(key: key);

	@override
	Widget build(BuildContext context) {
		final size = MediaQuery.of(context).size;

		return Material(
			color: backgroundColor,
		  child: SizedBox(
		  		height: size.height,
		  		width: size.width,
		  		child: content, //Align()
		  ),
		);




		/*return AlertDialog(
			clipBehavior: Clip.none,
			shape: Border.fromBorderSide(BorderSide.none),
			elevation: 0,
			backgroundColor: backgroundColor,
			contentPadding: EdgeInsets.zero,
			insetPadding: EdgeInsets.zero,
			actionsPadding: EdgeInsets.zero,
			buttonPadding: EdgeInsets.zero,
			scrollable: scrollable,

			content: SizedBox(
				height: size.height,
				width: size.width,
				child: content,
			),
		);*/
	}
}