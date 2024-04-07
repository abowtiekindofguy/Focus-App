import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_usage/app_usage.dart';
import 'storage.dart';
import 'login.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<AppUsageInfo> info = [];
  @override
  void initState() {
    super.initState();
    getUsageStats();
    // uploadUsageStats();
  }

  // Future<void> uploadUsageStats() async {
  //   String email = await Authentication.getEmail();
  //   String currentDate = DateTime.now().toString();
  //   String metadata = 'usage-$email-$currentDate';
  //   print(info);
  //   FirebaseDatabase().uploadData(metadata, info);
  // }

  Future<void> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      setState (() {
        infoList.sort((a, b) => b.usage.inMinutes.compareTo(a.usage.inMinutes));
        info = infoList;
    String metadata = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(info);
    FirebaseDatabase().uploadData("usage",metadata, info);
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Track Page'),
      ),
      body: 
      ListView.builder(
        itemCount: info.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(info[index].appName),
            subtitle: Text(info[index].packageName),
            trailing: Text(info[index].usage.inMinutes.toString() + ' minutes'),
          );
        },
      ),

      
    );
  }
}