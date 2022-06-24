import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// https://github.com/MaikuB/flutter_local_notifications/blob/master/flutter_local_notifications/example/lib/main.dart

class Notification {
	static FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

	Notification ._();

	static get notificationPlugin => _notificationsPlugin;

	static Future<NotificationAppLaunchDetails?> checkAppLunchedByNotificationBy(FlutterLocalNotificationsPlugin plg) {
		return plg.getNotificationAppLaunchDetails();
	}

	static Future<NotificationAppLaunchDetails?> checkAppLunchedByNotification() {
		return checkAppLunchedByNotificationBy(_notificationsPlugin);
	}

	static Future<void>? createNotificationChannelBy(FlutterLocalNotificationsPlugin plg, String id, String name, String description) {
		var androidNotificationChannel = AndroidNotificationChannel(id, name, description: description,);
		return plg.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
				?.createNotificationChannel(androidNotificationChannel);
	}

	static Future<void>? createNotificationChannel(String id, String name, String description) {
		return createNotificationChannelBy(_notificationsPlugin, id, name, description);
	}

	static Future<void>? deleteNotificationChannelBy(FlutterLocalNotificationsPlugin plg, String id) {
		return plg.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
				?.deleteNotificationChannel(id);
	}

	static Future<void>? deleteNotificationChannel(String id) {
		return deleteNotificationChannelBy(_notificationsPlugin, id);
	}

	static Future<bool?>? requestIOSPermissionsBy(FlutterLocalNotificationsPlugin plg) {
		return plg.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
				?.requestPermissions(alert: true, badge: true, sound: true,);
	}

	static Future<bool?>? requestIOSPermissions() {
		return requestIOSPermissionsBy(_notificationsPlugin);
	}

	static Future<void> cancelNotificationBy(FlutterLocalNotificationsPlugin plg, int id) {
		return plg.cancel(id);
	}

	static Future<void> cancelNotification(int id) {
		return _notificationsPlugin.cancel(id);
	}

	static Future<void> cancelAllBy(FlutterLocalNotificationsPlugin plg) {
		return plg.cancelAll();
	}

	static Future<void> cancelAll() {
		return _notificationsPlugin.cancelAll();
	}

	static Future<void> showNotificationBy(FlutterLocalNotificationsPlugin plg, NotificationDetails details
			, int id, String title, String message) {
		return plg.show(id, title, message, details, payload: '$id');
	}

	static Future<void> showNotification(NotificationDetails details, int id, String title, String message) {
		return _notificationsPlugin.show(id, title, message, details, payload: '$id');
	}

	static Future<void> showProgressNotification(FlutterLocalNotificationsPlugin plg, int id, int maxProgress,
			int progress, String title, String message) async {
		var androidDetails = AndroidNotificationDetails(
				'123003213', 'ProgressBar',
				channelShowBadge: false,
				playSound: false,
				importance: Importance.defaultImportance,
				priority: Priority.defaultPriority,
				onlyAlertOnce: true,
				showProgress: true,
				maxProgress: maxProgress,
				progress: progress);
		//var iOSPlatformChannelSpecifics = IOSNotificationDetails();
		var platformChannelSpecifics = NotificationDetails(android: androidDetails);

		await plg.show(id, title, message,
				platformChannelSpecifics, payload: '$id');
	}

	static Future<void> showMultiMessageNotification(int id, String title) async {
		var messages = List<Message>.empty(growable: true);
		//String imageUri = await platform.invokeMethod('drawableToUri', 'app_icon');

		var first = Person(
			name: 'علی',
			key: '1',
			uri: 'tel:1234567890',
			icon: DrawableResourceAndroidIcon('app_icon'),
		);

		var coworker = Person(
			name: 'Coworker',
			key: '2',
			uri: 'tel:9876543210',
			//icon: FlutterBitmapAssetAndroidIcon('images/ico_clock.png'),
			icon: DrawableResourceAndroidIcon('app_icon'),
		);

		messages.add(Message('What\'s up?', DateTime.now().add(Duration(minutes: 5)), coworker));
		messages.add(Message('Lunch?', DateTime.now().add(Duration(minutes: 10)), first));//, dataMimeType: 'image/png', dataUri: ''

		var messagingStyle = MessagingStyleInformation(first,
				groupConversation: true,
				htmlFormatContent: true,
				htmlFormatTitle: true,
				conversationTitle: title,
				messages: messages);

		var androidDetails = AndroidNotificationDetails(
				'123003214', 'Messaging',
				channelShowBadge: false,
				playSound: true,
				importance: Importance.defaultImportance,
				priority: Priority.defaultPriority,
				onlyAlertOnce: false,
				category: 'msg',
				styleInformation: messagingStyle);
		var platformChannelSpecifics = NotificationDetails(android: androidDetails);

		await _notificationsPlugin.show(id, title, '', platformChannelSpecifics, payload: '$id');

		await Future.delayed(Duration(seconds: 5), () async {
			messages.add(Message('new msg', DateTime.now().add(Duration(minutes: 11)), null));
			await _notificationsPlugin.show(id, title, '', platformChannelSpecifics, payload: '$id');
		});
	}

	static Future<void> showInboxNotification(int id, String title, String summary) async {
		var lines = List<String>.empty(growable: true);
		lines.add('line <b>1</b> &#9787;');
		lines.add('line <b>2</b> &#9996;');
		var inboxStyleInformation = InboxStyleInformation(lines,
			htmlFormatLines: true,
			htmlFormatContent: true,
			htmlFormatContentTitle: true,
			htmlFormatSummaryText: true,
			htmlFormatTitle: true,
			contentTitle: title, //'overridden <b>inbox</b> context title'
			summaryText: summary,
		);
		var androidPlatformChannelSpecifics = AndroidNotificationDetails(
				'123003215', 'InboxMessaging',
				styleInformation: inboxStyleInformation);
		var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
		await _notificationsPlugin.show(id, title, '', platformChannelSpecifics);
	}
}