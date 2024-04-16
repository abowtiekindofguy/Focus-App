import 'package:flutter_local_notifications/flutter_local_notifications.dart';


Future<void> issueNotification(String description, String title, String notificationBody) async{
  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var androidDetails = AndroidNotificationDetails(
                'channel_id', description,
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, title, notificationBody, platformDetails);
}