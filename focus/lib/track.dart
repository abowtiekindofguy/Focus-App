import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_usage/app_usage.dart';
import 'storage.dart';
import 'login.dart';
import 'dart:convert';
import 'package:intl/intl.dart';




Map<String, dynamic> appUsageInfoToMap(AppUsageInfo info) {
  return {
    'appName': info.appName,
    'packageName': info.packageName,
    'usageMinutes': info.usage.inMinutes, // Assuming `usage` is a Duration object
  };
}



class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<AppUsageInfo> info = [];
  @override
  void initState(){
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await getUsageStats();
    uploadUsageStats();
  }

  Future<void> uploadUsageStats() async {
    String metadata = DateFormat('yyyy-MM-dd').format(DateTime.now());
    print(info);
    List<Map<String, dynamic>> infoListMapped = info.map((appUsageInfo) => appUsageInfoToMap(appUsageInfo)).toList();
    String jsonEncodedData = jsonEncode(infoListMapped);
    FirebaseDatabase().uploadData("usage",metadata, jsonEncodedData);
  }

  Future<void> getUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      setState (() {
        infoList.sort((a, b) => b.usage.inMinutes.compareTo(a.usage.inMinutes));
        info = infoList;
    
      });
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Track Page'),
  //     ),
  //     body: 
  //     ListView.builder(
  //       itemCount: info.length,
  //       itemBuilder: (context, index) {
  //         return ListTile(
  //           title: Text(info[index].appName),
  //           subtitle: Text(info[index].packageName),
  //           trailing: Text(info[index].usage.inMinutes.toString() + ' minutes'),
  //         );
  //       },
  //     ),

      
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        // backgroundColor: Colors.black,
        actions: [
          // Add action buttons if needed
        ],
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Screen time',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            // Add your bar chart widget here
            // You can use a package like fl_chart or charts_flutter to render charts
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '3 hr, 8 min',
                style: TextStyle(color: Colors.white, fontSize: 36),
              ),
            ),
            // Create a list view for the apps list
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 5, // the number of items in your list
              itemBuilder: (context, index) {
                return ListTile(
            title: Text(info[index].appName),
            subtitle: Text(info[index].packageName),
            trailing: Text(info[index].usage.inMinutes.toString() + ' minutes'),
          );
              },
            ),
          ],
        ),
      ),
    );
  }
}