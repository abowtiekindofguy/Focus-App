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
import 'ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'appicon.dart';

Future<Map<String,int>> getDayAppUsageInMinutes() async {
  DateTime endTime = DateTime.now();
  DateTime startTime = DateTime(endTime.year, endTime.month, endTime.day,0,0,0);
  List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startTime, endTime);
  Map<String,int> appUsageMinutes = {};
  for (AppUsageInfo appUsageInfo in infoList) {
    appUsageMinutes[appUsageInfo.packageName] = appUsageInfo.usage.inMinutes;
  }
  return appUsageMinutes;
}
  

Future<String> getDayAppUsageInMinutesString() async {
  DateTime endTime = DateTime.now();
  DateTime startTime = DateTime(endTime.year, endTime.month, endTime.day,0,0,0);
  List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startTime, endTime);
 int appUsageMinutes = 0;
  for (AppUsageInfo appUsageInfo in infoList) {
    appUsageMinutes+=appUsageInfo.usage.inMinutes;
  }

  int min = appUsageMinutes;
  return (min~/60).toString() + " hr " + (min%60).toString() + " min";
}

Future<String> getWeekAppUsageInMinutesString() async {
  DateTime endTime = DateTime.now();
  DateTime startTime = endTime.subtract(Duration(days: 7));
  List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startTime, endTime);
  int appUsageMinutes = 0;
  for (AppUsageInfo appUsageInfo in infoList) {
    appUsageMinutes+=appUsageInfo.usage.inMinutes;
  }

  int min = appUsageMinutes;
  return (min~/60).toString() + " hr " + (min%60).toString() + " min";
}

Future<String> getMonthAppUsageInMinutesString() async {
  DateTime endTime = DateTime.now();
  DateTime startTime = endTime.subtract(Duration(days: 30));
  List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startTime, endTime);
  int appUsageMinutes = 0;
  for (AppUsageInfo appUsageInfo in infoList) {
    appUsageMinutes+=appUsageInfo.usage.inMinutes;
  }

  int min = appUsageMinutes;
  return (min~/60).toString() + " hr " + (min%60).toString() + " min";
}


Future<Map<int,int>> hourlyUsage() async {
  DateTime endTime = DateTime.now();
  DateTime startTime = endTime.subtract(Duration(hours: 24));
  Map<int,int> hourlyUsage = {};
  for (int i = 0; i < 24; i++) {
    DateTime hourStart = startTime.add(Duration(hours: i));
    DateTime hourEnd = startTime.add(Duration(hours: i+1));
    List<AppUsageInfo> infoList = await AppUsage().getAppUsage(hourStart, hourEnd);
    int totalUsage = 0;
    for (AppUsageInfo appUsageInfo in infoList) {
      if (appUsageInfo.usage.inMinutes > 1 && appUsageInfo.packageName != "com.example.focus")
          totalUsage += appUsageInfo.usage.inMinutes;
    }
    hourlyUsage[i] = totalUsage;
  }
  return hourlyUsage;
}




Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }


Map<String, dynamic> appUsageInfoToMap(AppUsageInfo info) {
  return {
    'appName': info.appName,
    'packageName': info.packageName,
    'usageMinutes': info.usage.inMinutes, // Assuming `usage` is a Duration object
  };
}

void createUsagePDF(List<AppUsageInfo> appUsage, String filename, String suggestions) async { 
  final pdf = pw.Document();
   pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Header(
              level: 0,
              child: pw.Text('Screen Time Report', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          pw.Padding(
              padding: pw.EdgeInsets.only(bottom: 20),
              child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Screen Time: 3 hr, 8 min',
                        style: pw.TextStyle(fontSize: 36, fontWeight: pw.FontWeight.bold)),
                  ])),
          pw.Wrap(  // Using Wrap to handle overflow properly
            children: List<pw.Widget>.generate(appUsage.length, (index) {
              final item = appUsage[index];
              return pw.Container(
                  width: double.infinity,
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.appName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text("${item.usage.inMinutes} minutes"),
                      ]
                  )
              );
            })
        ),
          pw.Padding(
              padding: pw.EdgeInsets.only(top: 10),
              child: pw.Text(suggestions)),
        ];
      }));

  final String downloadsDirectory = await getDownloadPath() ?? "";
  final String path = '$downloadsDirectory/$filename';
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());
  print("PDF saved to $path");
}



class TrackPage extends StatefulWidget {
  const TrackPage({Key? key}) : super(key: key);

  @override
  _TrackPageState createState() => _TrackPageState();
}

class _TrackPageState extends State<TrackPage> {
  List<AppUsageInfo> info = [];
  Map<String,int> appUsageMinutes = {};
  late List<BarChartGroupData> barGroups;
  String suggestions = "Hello World!";

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
    // Map<int,int> hourlyUsageComputed = await hourlyUsage();
    // barGroups = getBarGroups(hourlyUsageComputed);
    uploadUsageStats();
    suggestions = await getResponse("The user has following App Usage times:"+appUsageMinutes.toString()+"Please suggest in detail 10000 words for the user in as many words as possible");
    //suggestions = "aapke liye kuch nahi";
    setState(() {});
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
      DateTime startDate = endDate.subtract(Duration(hours: 24));
      List<AppUsageInfo> infoList = await AppUsage().getAppUsage(startDate, endDate);
      setState (() {
        infoList.sort((a, b) => b.usage.inMinutes.compareTo(a.usage.inMinutes));
        info = infoList;
        for (AppUsageInfo appUsageInfo in infoList) {
          appUsageMinutes[appUsageInfo.packageName] = appUsageInfo.usage.inMinutes;
        }
      });
              
    } on AppUsageException catch (exception) {
      print(exception);
    }
  }


  String totalUsageInHoursandMinutes(List<AppUsageInfo> info) {
    int totalUsage = 0;
    for (AppUsageInfo appUsageInfo in info) {
      totalUsage += appUsageInfo.usage.inMinutes;
    }
    int hours = totalUsage ~/ 60;
    int minutes = totalUsage % 60;
    return '$hours hr, $minutes min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Dashboard"),
        // backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () async {
              createUsagePDF(info, "focus_screen_time_report.pdf", suggestions);
            },
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
            },
          ),
        ],
      ),
      // backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: 
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Screen Time (calculated for the past 24 hours)',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                totalUsageInHoursandMinutes(info),
                style: TextStyle(color: Colors.black, fontSize: 36),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: 10, // the number of items in your list
              itemBuilder: (context, index) {
                return AppTile(packageName: info[index].packageName, text: info[index].usage.inMinutes.toString() + ' minutes');
              },
            ),
            suggestions == "Hello World!" ? Center(child: Column(
              children: [
                Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Loading suggestions tailored for you...",
              // print(suggestions);,
                // style: TextStyle(color: Colors.white),
              ),
            ),
                CircularProgressIndicator(),
              ],
            )) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                suggestions,
              // print(suggestions);,
                // style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}