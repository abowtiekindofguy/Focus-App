import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

Future<void> issueNotification(String description, String title, String notificationBody) async{
  FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var androidDetails = AndroidNotificationDetails(
                'channel_id', description,
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, title, notificationBody, platformDetails);
}

void fltoast(String msg){
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
    fontSize: 12.0
  );
}