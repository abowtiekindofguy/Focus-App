import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_usage/app_usage.dart';
import 'storage.dart';
import 'login.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';




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
  late List<BarChartGroupData> barGroups;



  List<BarChartGroupData> getBarGroups(Map<int, int> rawMap) {
  return rawMap.entries.map((entry) {
    return BarChartGroupData(
      x: entry.key,
      barRods: [
        BarChartRodData(
          toY: entry.value.toDouble(),
          color: Colors.blue,
          width: 15 // Set the width of the bars
        )
      ],
      showingTooltipIndicators: [0]
    );
  }).toList();
}


  @override
  void initState(){
    super.initState();
    initAsync();


  }

  Future<void> initAsync() async {
    await getUsageStats();
    Map<int,int> hourlyUsageComputed = await hourlyUsage();
    barGroups = getBarGroups(hourlyUsageComputed);
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

List<String> packagesBlock = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android'];

  Future<Map<int,int>> hourlyUsage() async {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day, 0, 0, 0);
    int hour = now.hour;
    Map<int, int> hourlyUsage = {};
    for (int i = 0; i < hour; i++) {
      DateTime end = start.add(Duration(hours: i + 1));
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(start, end);
      int totalUsage = 0;
      for (AppUsageInfo info in infoList) {
        if (packagesBlock.contains(info.packageName)) {
          totalUsage += info.usage.inMinutes;
        }
      }
      hourlyUsage[i] = totalUsage;
    }
    return hourlyUsage; 
  }

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



//             BarChart(
//           BarChartData(
//   titlesData: FlTitlesData(
//     show: true,
//     bottomTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 30, // specifies the space reserved for titles
//       getTextStyles: (context, value) => const TextStyle(
//         color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
//       margin: 10, // space between the titles and the bars
//       getTitles: (double value) {
//         // Assuming the map keys are integers and used directly as x-axis
//         return 'Q$value'; // Prefix 'Q' or any other formatter based on your requirements
//       },
//     ),
//     leftTitles: SideTitles(
//       showTitles: true,
//       reservedSize: 40, // space reserved for the left titles
//       getTextStyles: (context, value) => const TextStyle(
//         color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
//       getTitles: (value) {
//         if (value == 0) {
//           return '0';
//         }
//         if (value % 10 == 0) {
//           return '${value.toInt()}'; // Only show labels for values that are multiples of 10
//         }
//         return '';
//       },
//     ),
//   ),
//   borderData: FlBorderData(
//     show: true,
//     border: Border.all(color: const Color(0xff37434d), width: 1)),
//   barGroups: barGroups,
//   alignment: BarChartAlignment.spaceAround,
//   maxY: 30,  // assuming 30 is the maximum y value
// )
//         ),



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