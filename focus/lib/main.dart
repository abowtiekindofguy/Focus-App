import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus/firebase_options.dart';
import 'package:focus/sudoku.dart';
import 'friends.dart';
import 'login.dart';
import 'track.dart';
import 'map.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:isolate';
import 'package:intl/intl.dart';
import 'storage.dart';
import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'track.dart';
import 'firebase_options.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'main_chuck.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:app_usage/app_usage.dart';
import 'package:workmanager/workmanager.dart';
import 'challenge.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';

const checkAppUsage = "checkAppUsage";
const fetchParentalControl = "fetchParentalControl";

const fetchBackground = "fetchBackground";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case fetchBackground:
        try {
          // Initialize Notification Plugin
          FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
          var android = AndroidInitializationSettings('@mipmap/ic_launcher');
          var settings = InitializationSettings(android: android);
          await flip.initialize(settings);

          // Check App Usage
          AppUsage appUsage = AppUsage();
          try {
            DateTime endDate = DateTime.now();
            DateTime startDate = endDate.subtract(Duration(hours: 1)); // check last hour usage
            List<AppUsageInfo> infoList = await appUsage.getAppUsage(startDate, endDate);
            bool isYouTubeActive = infoList.any((info) => info.packageName.contains('com.google.android.youtube') && info.usage.inMinutes > 1);
            
            if (isYouTubeActive) {
              // Send Notification if YouTube was active in the last hour
              var androidDetails = const AndroidNotificationDetails(
                'channel_id', 'YouTube Notification',
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, 'YouTube Checker', 'YouTube is active in the last hour!', platformDetails);
            }
          } catch (e) {
            print("Error fetching app usage: $e");
          }
        } catch (e) {
          print("Failed to send notification: $e");
        }
        break;
    }
    return Future.value(true); // Return true to indicate task completion
  });
}

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case fetchParentalControl:
//         try {
//           // Initialize Notification Plugin
//           await initLocalStorage();
//           print("Fetching Parental Controls initialized local storage");
//           String limitsJsonString = await localStorage.getItem('Limits') ?? '{}';
//           print(limitsJsonString);
//           final localLimits = jsonDecode(limitsJsonString);
//           FlutterLocalNotificationsPlugin flip =
//               FlutterLocalNotificationsPlugin();
//           var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//           var settings = InitializationSettings(android: android);
//           await flip.initialize(settings);
//           // initialize firebase
//           String email = inputData?['email'] ?? 'akshat@gmail.com';
//           await Firebase.initializeApp(
//               options: DefaultFirebaseOptions.currentPlatform);
//           final parentalControls = FirebaseFirestore.instance
//               .collection('parentalControls')
//               .where('userID', isEqualTo: email)
//               .where('active', isEqualTo: true)
//               .get();

//           Map<String, int> Limits = {};
//           parentalControls.then((QuerySnapshot querySnapshot) {
//             querySnapshot.docs.forEach((doc) {
//               final Limits = doc['limits'];
//             });
//           }).catchError((error) {
//             print("No parental controls found!");
//           });

//           // store Limits in local storage
//           print(Limits);
//           print("Local Limits: ");
//           print(localLimits);
//           localStorage.setItem('Limits', jsonEncode(Limits));
//           if (localLimits != Limits) {
//             var androidDetails = const AndroidNotificationDetails(
//                 'channel_id', 'Focus Alert',
//                 importance: Importance.max, priority: Priority.high, ticker: 'ticker');
//             var platformDetails = NotificationDetails(android: androidDetails);
//             await flip.show(
//               0,
//               'Focus Alert',
//               'You have received new parental locks for the following apps:\n${Limits.entries.map((entry) => '${entry.key}: ${entry.value}').join("\n")}',
//               platformDetails,
//             );

//           }
//         } catch (e) {
//           print(e);
//         }        
//         break;
//         case checkAppUsage:
//         try {
//           // Initialize Notification Plugin

//           FlutterLocalNotificationsPlugin flip =
//               FlutterLocalNotificationsPlugin();
//           var android = AndroidInitializationSettings('@mipmap/ic_launcher');
//           var settings = InitializationSettings(android: android);
//           await flip.initialize(settings);
//           String email = inputData?['email'] ?? 'akshat@gmail.com';
//           await Firebase.initializeApp(
//               options: DefaultFirebaseOptions.currentPlatform);
//           await initLocalStorage();
//           String limitsJsonString = await localStorage.getItem('Limits') ?? '{}';
//           final limits = jsonDecode(limitsJsonString);
//           final DateTime timeNow = DateTime.now();
//           final DateTime todayStart = DateTime(timeNow.year, timeNow.month, timeNow.day, 0, 0, 0);
//           var usage = await AppUsage().getAppUsage(todayStart, timeNow);
//           var usageMap = {};
//           usage.forEach((appUsageInfo) {
//             usageMap[appUsageInfo.packageName] = appUsageInfo.usage.inMinutes;
//           });
//           var exceededApps = {};
//           limits.forEach((app, limit) {
//             if (usageMap[app] > limit) {
//               exceededApps[app] = usageMap[app];
//             }
//           });
//           var halfExceededApps = {};
//           limits.forEach((app, limit) {
//             if (usageMap[app] > limit/2) {
//               halfExceededApps[app] = usageMap[app];
//             }
//           });
//           var androidDetails = const AndroidNotificationDetails(
//                 'channel_id', 'Focus Alert',
//                 importance: Importance.max, priority: Priority.high, ticker: 'ticker');
//           if (exceededApps.isNotEmpty) {
//             var platformDetails = NotificationDetails(android: androidDetails);
//             await flip.show(0, 'Focus Alert', 'You have exceeded the usage limit for the following apps: ${exceededApps.keys.join(", ")}', platformDetails);
//           }
//           else if(halfExceededApps.isNotEmpty){
//             var platformDetails = NotificationDetails(android: androidDetails);
//             await flip.show(0, 'Focus Alert', 'You have used more than 50% of the usage limit for the following apps: ${halfExceededApps.keys.join(", ")}', platformDetails);
//           }
          
//         } catch (e) {
//           print(e);
//         }
//         break;
//         default:
            
//     }
//     return Future.value(true); 
//   }
//   );
  
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String email = await Authentication.getEmail();
  Workmanager().initialize(
    callbackDispatcher, // The top-level function, aka callbackDispatcher
    isInDebugMode: true // If true, enables debugging to ensure it works correctly
  );
  Workmanager().registerPeriodicTask(
    "1",
    fetchBackground,
    frequency: Duration(seconds: 15), // defines the frequency in which your task should be called
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(
    MaterialApp(
      initialRoute: '/home',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/register': (context) => RegisterPage(),
        '/track': (context) => TrackPage(),
        '/friends': (context) => FriendsPage(currentUserId: email),
        '/friendrequests': (context) =>
            FriendRequestsPage(currentUserId: email),
        '/map': (context) => MapPage(),
        '/sudoku': (context) => SudokuPage(currentUserId: email),
        '/game': (context) => GameScreen(),
        '/inviteFriend': (context) => InviteFriendPage(currentUserId: email),
        '/challenges': (context) => ChallengePage(currentUserId: email),
        '/acceptedChallenges': (context) => AcceptedChallenges(currentUserId: email),
        '/issueChallenge': (context) => IssueChallenge(currentUserId: email),
      },
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FlutterLocalNotificationsPlugin _notificationsPlugin;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to the Home Screen',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Register'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/track'),
                child: Text('Track'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/friends'),
                child: Text('Friends'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/friendrequests'),
                child: Text('Friend Requests'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/map'),
                child: Text('Map'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/sudoku'),
                child: Text('Sudoku'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/game'),
                child: Text('Chuck Jump'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/inviteFriend'),
                child: Text('Invite Friends'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/challenges'),
                child: Text('Challenges'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/acceptedChallenges'),
                child: Text('Accepted Challenges'),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/issueChallenge'),
                child: Text('Issue Challenge'),
              ),
            ],
          ),
        ),
      ),
    );
  }}