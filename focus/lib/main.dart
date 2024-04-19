import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:focus/firebase_options.dart';
import 'package:focus/overlays/main_menu.dart';
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
import 'package:envied/envied.dart';
import 'package:dart_openai/dart_openai.dart';
import 'ai.dart';
import 'profile_page.dart';
import 'widgets/buttons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat.dart';
import 'breathe_game.dart';
import 'package:vibration/vibration.dart';
import 'levels.dart';
import 'widgets/row_button.dart';

const checkAppUsage = "checkAppUsage";
const fetchParentalControl = "fetchParentalControl";
const checkDistraction = "checkDistraction";


void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case checkDistraction:
        try {
          FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();
          var android = AndroidInitializationSettings('@mipmap/ic_launcher');
          var settings = InitializationSettings(android: android);
          await flip.initialize(settings);

          List<String> packagesBlock = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android', 'com.twitter.android', 'com.facebook.katana', 'com.snapchat.android', 'com.tinder', 'com.linkedin.android', 'com.pinterest', 'com.reddit.frontpage', 'com.spotify.music' ];
          AppUsage appUsage = AppUsage();
          try {
            DateTime endDate = DateTime.now();
            DateTime startDate = endDate.subtract(Duration(hours: 1)); // check last hour usage
            List<AppUsageInfo> infoList = await appUsage.getAppUsage(startDate, endDate);
            bool isDistractionActive = infoList.any((info) => packagesBlock.any((package) => info.packageName.contains(package)) && info.usage.inMinutes > 1);
            if (isDistractionActive) {
              var androidDetails = const AndroidNotificationDetails(
                'channel_id', 'Distraction Notification',
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, 'Distraction Checker', 'A distracting app is active in the last hour! Be sure to take regular breaks from work and avoid using these apps as much as possible. \n You can do it!', platformDetails);
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


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String email = await Authentication.getEmail();
  String name = await Authentication.getName();
  OpenAI.apiKey = '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';
  Workmanager().initialize(
    callbackDispatcher, // The top-level function, aka callbackDispatcher
    isInDebugMode: true // If true, enables debugging to ensure it works correctly
  );
  Workmanager().registerPeriodicTask(
    "1",
    checkDistraction,
    frequency: Duration(minutes: 15), // defines the frequency in which your task should be called
    constraints: Constraints(
      networkType: NetworkType.connected,
    ),
  );
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) => HomeScreen(currentUserId: email, name: name,),
        '/register': (context) => RegisterPage(),
        '/track': (context) => TrackPage(currentUserId: email,),
        '/friends': (context) => FriendsPage(currentUserId: email),
        '/friendrequests': (context) =>
            FriendRequestsPage(currentUserId: email),
        '/map': (context) => MapPage(),
        '/sudoku': (context) => SudokuPage(currentUserId: email),
        '/game': (context) => LevelsPage(),
        // '/inviteFriend': (context) => InviteFriendPage(currentUserId: email),
        '/challenges': (context) => AcceptedChallenges(currentUserId: email),
        '/acceptedChallenges': (context) => AcceptedChallenges(currentUserId: email),
        '/issueChallenge': (context) => IssueChallenge(currentUserId: email),
        '/profilePage': (context) => ProfilePage(currentUserId: email),
        '/chat' :(context) => ChatPage(start_message: "babushka"),
        '/breathe': (context) => BreatheGame(),

            },
          ),
        );
      }
//           0.75,
//           1.0,
//         ],
//       ),
//       boxShadow: [
//         BoxShadow(
//           color: color.withOpacity(0.5),
//           offset: Offset(0, 8),
//           blurRadius: 12,
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Icon(
//           icon,
//           size: 40,
//           color: Colors.white,
//         ),
//         SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildCard({required Color color, required IconData icon, required String label}) {
//   return Container(
//     decoration: BoxDecoration(
//       color: color,
//       borderRadius: BorderRadius.circular(20),
//       boxShadow: [
//         // Dark shadow on the bottom right
//         BoxShadow(
//           color: Colors.black.withOpacity(0.2),
//           offset: Offset(4, 4),
//           blurRadius: 8,
//           spreadRadius: 2,
//         ),
//         // Light shadow on the top left for a lifted edge illusion
//         BoxShadow(
//           color: Colors.white.withOpacity(0.7),
//           offset: Offset(-4, -4),
//           blurRadius: 8,
//           spreadRadius: 2,
//         ),
//       ],
//     ),
//     child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         Icon(
//           icon,
//           size: 40,
//           color: Colors.white,
//         ),
//         SizedBox(height: 8),
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget _buildCard({
  required Color color, 
  required IconData icon, 
  required String label, 
  required String route,
  required BuildContext context
}) {
  return GestureDetector(
    onTap: () {
      Navigator.pushNamed(context, route);
      // // Pushing a new route
      // Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (context) => , // Replace with your new page class
      //   ),
      // );
    },
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.9),
            offset: Offset(2, 2),
            blurRadius: 2,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
            offset: Offset(2, 2),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            icon,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    ),
  );
}

class SearchBar extends StatelessWidget {
  // Define a TextEditingController
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PhysicalModel(
        color: Colors.white,
        elevation: 8,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            controller: _controller,  // Set the controller to the TextField
            decoration: InputDecoration(
              hintText: "Get Personalized Suggestions, Chat Now",
              contentPadding: EdgeInsets.symmetric(vertical: 16),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  _submitSearch(context);  // Call _submitSearch when the search icon is pressed
                },
              ),
            ),
            style: TextStyle(fontSize: 12),
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              
              _submitSearch(context);  // Also handle submission on enter/key press
            },
          ),
        ),
      ),
    );
  }

  void _submitSearch(BuildContext context) {
    String value = _controller.text;  // Use the controller to get the text
    if (value.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a search query before submitting!",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 12.0,
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => ChatPage(start_message: value)),
      );
      _controller.clear();  // Clear the text field after submitting
    }
  }
}


// class _HomeScreenState extends State<HomeScreen> {
//   late FlutterLocalNotificationsPlugin _notificationsPlugin;

//   @override
//   void initState() {
//     super.initState();
//   }


class HomeScreen extends StatefulWidget {
  final currentUserId, name;

  HomeScreen({required this.currentUserId, required this.name});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {


@override
  void initState() {
    super.initState();
    // userDataFuture = getUserData(widget.emailID);
    // Locking the orientation to portrait mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

@override
  void dispose() {
    // Unlocking orientation changes back to default (rotational)
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(18, 18, 18, 255),
      
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        title: Text('Let\'s Focus!', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(Icons.settings),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Padding(
          padding: const EdgeInsets.all(12.0),
          child: SearchBar(),
        ),
          // Padding(padding: const EdgeInsets.all(12.0), child: Text(getResponse(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),

        //Gap(16),
            FutureBuilder(
              future: Future.wait([
                getDayAppUsageInMinutesString(),
                getMonthAppUsageInMinutesString(),
                getChallengeScore(widget.currentUserId)
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) { return CircularProgressIndicator(); }
                else if (snapshot.hasError) { return Text('Error: ${snapshot.error}'); }
                else {
                  return InfoRow(info: {
                    'Day Usage': snapshot.data?[0]?.toString() ?? '-',
                    'Month Usage': snapshot.data?[1]?.toString() ?? '-',
                    'Challenge Score': (snapshot.data?[2] as double?)?.toStringAsFixed(2) ?? '-',
                  });
                }
              },
            ),

            // FutureBuilder(future: Future.wait([getChallengeScore(widget.currentUserId)]), builder: (context, snapshot) {
            //   if (snapshot.connectionState == ConnectionState.waiting) {
            //     return CircularProgressIndicator();
            //   } else if (snapshot.hasError) {
            //     return Text('Error: ${snapshot.error}');
            //   } else {
            //     return InfoRow(info: {
            //       'Challenge Score': snapshot.data![0].toStringAsFixed(2),
            //     });
            //   }
            // }),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: <Widget>[
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),       
                    icon: Icons.track_changes,
                    label: 'Track Usage',
                    route: '/track',
                    context: context
                  ),
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),
                    icon: Icons.facebook,
                    label: 'Friends',
                    route: '/friends',
                    context: context
                  ),
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),
                    icon: Icons.gamepad,
                    label: 'Game',
                    route: '/game',
                    context: context
                  ),
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),
                    icon: Icons.alarm,
                    label: 'Challenges',
                    route: '/challenges',
                    context: context
                  ),
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),
                    icon: Icons.chat_bubble,
                    label: 'Focus Bot',
                    route: '/chat',
                    context: context
                  ),
                  _buildCard(
                    color: Color.fromARGB(255, 30, 30, 30),
                    icon: Icons.air,
                    label: 'Breathe',
                    route: '/breathe',
                    context: context
                  ),
                ],
              ),
            ),



// SingleChildScrollView(
//   scrollDirection: Axis.horizontal,
//   child: Row(children: [ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/chat'),
//                   child: Text('Chat'),
//                 ),
//     ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/register'),
//                   child: Text('Register'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/track'),
//                   child: Text('Track'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/friends'),
//                   child: Text('Friends'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () =>
//                       Navigator.pushNamed(context, '/friendrequests'),
//                   child: Text('Friend Requests'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/map'),
//                   child: Text('Map'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/sudoku'),
//                   child: Text('Sudoku'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/game'),
//                   child: Text('Chuck Jump'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/inviteFriend'),
//                   child: Text('Invite Friends'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pushNamed(context, '/challenges'),
//                   child: Text('Challenges'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () =>
//                       Navigator.pushNamed(context, '/acceptedChallenges'),
//                   child: Text('Accepted Challenges'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () =>
//                       Navigator.pushNamed(context, '/issueChallenge'),
//                   child: Text('Issue Challenge'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () =>
//                       Navigator.pushNamed(context, '/profilePage'),
//                   child: Text('Profile Page'),
//                 ),],),
// ),
            
          ],
        ),
      ),
    );
  }

  
}
