import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:focus/appicon.dart';
import 'package:focus/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'track.dart';
import 'package:firebase_database/firebase_database.dart';
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
import 'track.dart';
import 'validator.dart';
import 'package:localstorage/localstorage.dart';
import 'widgets/row_button.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'firebase_map.dart';

import 'validator.dart';

List<String> packagesBlock = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android', 'com.twitter.android', 'com.facebook.katana', 'com.snapchat.android', 'com.tinder', 'com.linkedin.android', 'com.pinterest', 'com.reddit.frontpage', 'com.spotify.music' ];

Future<Map<String,int>> getAllChallengeMinimum(String userId) async{
  Map<String,int> challengeMinimum = {};
  // await initLocalStorage();
   Map<String, Map<String, int>> challengesCollection = await getAllChallenges(userId);
  for (String challengeId in challengesCollection.keys){
    Map<String, int> challenge = challengesCollection[challengeId]!;
    for (String packageName in packagesBlock){
      if (challenge.containsKey(packageName)){
        challengeMinimum[packageName] = min(challengeMinimum[packageName] ?? 24000, challenge[packageName] ?? 24000);
      }
    }
  }
  return challengeMinimum;
}

// Future<Map<String, Map<String, int>>> getAllChallenges(String userId) async {
//   String challengesList = await FirebaseMap(userId + 'challengesCollection');
//   if (challengesList == 'null' || challengesList == '{}') {
//     return {}; // Returns an empty map if there's no data
//   }
  
//   Map<String, dynamic> jsonMap = jsonDecode(challengesList);
//   Map<String, Map<String, int>> challengesCollection = {};
  
//   jsonMap.forEach((key, value) {
//     // Ensure the nested maps are properly cast to Map<String, int>
//     Map<String, int> innerMap = {};
//     if (value is Map) {
//       value.forEach((innerKey, innerValue) {
//         if (innerValue is int) {
//           innerMap[innerKey] = innerValue;
//         } else {
//           throw FormatException('Expected integer values in inner map, found: $innerValue');
//         }
//       });
//     }
//     challengesCollection[key] = innerMap;
//   });
//   print("AYDDFSFDFSDFFD");
//   print(challengesCollection);
//   return challengesCollection;
// }


Future<Map<String, Map<String, int>>> getAllChallenges(String userId) async {
  String challengesList = await FirebaseMap(userId + 'challengesCollection');
  if (challengesList == 'null' || challengesList == '{}') {
    return {};
  }
  
  Map<String, dynamic> jsonMap = jsonDecode(challengesList);
  Map<String, Map<String, int>> challengesCollection = {};

  jsonMap.forEach((key, dynamic nestedValue) {
    if (nestedValue is Map) {
      Map<String, int> innerMap = {};
      nestedValue.forEach((innerKey, innerVal) {
        if (innerVal is int) {
          innerMap[innerKey.toString()] = innerVal;
        } else {
          throw FormatException('Expected integer values for user challenge counts, found: $innerVal');
        }
      });
      challengesCollection[key.toString()] = innerMap;
    } else {
      throw FormatException('Expected map for user challenges, found: $nestedValue');
    }
  });

  return challengesCollection;
}



Future<int> numActiveChallenges(String userId) async{
  Map<String, Map<String, int>> challengesCollection = await getAllChallenges(userId);
  return challengesCollection.length;
}

Future<Map<String,int>> getChallengeStats(String userId, String challengeId) async{
  Map<String, Map<String, int>> challengesCollection = await getAllChallenges(userId);
  return challengesCollection[challengeId] ?? {};
}

Future<void> addChallengeToLocal(String userId, String challengeId, Map<String, int> challenge) async {
    Map<String, Map<String, int>> challengesCollection = await getAllChallenges(userId);
  challengesCollection[challengeId] = challenge;
FirebaseMapSet(userId+'challengesCollection',jsonEncode(challengesCollection));
}

Future<double> getChallengeScore(String userId) async {
  Map<String,int> appUsageinMinutes = await getDayAppUsageInMinutes();
  Map<String,int> challengeMinimum = await getAllChallengeMinimum(userId);
  print(challengeMinimum);
  double score = 0;
  for (String packageName in packagesBlock){
    int appUsage = appUsageinMinutes[packageName] ?? 0;
    if (challengeMinimum.containsKey(packageName)){
      if (appUsage < challengeMinimum[packageName]!){
        score += 1;
      }
      else{
        score += 1 + (challengeMinimum[packageName]! - appUsage) / challengeMinimum[packageName]!;
      }
    }
    else{
       score += (appUsageinMinutes[packageName] ?? 0) / 60;
    }
  }
  int activeChallenges = await numActiveChallenges(userId);
  if (activeChallenges == 0){
    return score/(packagesBlock.length) * 100;
  }
  return (score/(packagesBlock.length))*100;
}

Future<void> issueChallenge(String challengeName, Map<String, int> challenge, String currentUserId) async {
  await FirebaseFirestore.instance.collection('challenges').add({
    'challenge-name': challengeName,
    'challenge': challenge,
    'issuer': currentUserId,
    'status': 'open',
  });
   FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var androidDetails = const AndroidNotificationDetails(
                'channel_id', 'challenge Accepted',
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, 'Challenge Issued', 'Challenge '+challengeName+" issued\nLet's start focusing!", platformDetails);
}

class IssueChallenge extends StatelessWidget {
  final String currentUserId;
  IssueChallenge({required this.currentUserId});

  final TextEditingController _challengeNameController = TextEditingController();
  final TextEditingController _challengeDescriptionController = TextEditingController();
  final TextEditingController _challengeDurationController = TextEditingController();

  final Map<String, TextEditingController> _appControllers = {
    'com.whatsapp': TextEditingController(),
    'com.google.android.youtube': TextEditingController(),
    'com.instagram.android': TextEditingController(),
  };

  String? _validateDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a duration';
    }
    int? duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return 'Please enter a valid duration';
    }
    return null;
  }

  String? _validateAppDuration(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a duration';
    }
    int? duration = int.tryParse(value);
    if (duration == null || duration < 0) {
      return 'Please enter a valid duration';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Challenge'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _challengeNameController,
              decoration: InputDecoration(
                labelText: 'Challenge Name',
              ),
              validator: (value) => Validator.validateTextInput(),
            ),
            TextFormField(
              controller: _challengeDescriptionController,
              decoration: InputDecoration(
                labelText: 'Challenge Description',
              ),
              validator: (value) => Validator.validateTextInput(),
            ),
            TextFormField(
              controller: _challengeDurationController,
              decoration: InputDecoration(
                labelText: 'Challenge Duration (in minutes)',
              ),
              validator: _validateDuration,
            ),
            for (var app in _appControllers.keys)
              TextFormField(
                controller: _appControllers[app],
                decoration: InputDecoration(
                  labelText: '${app.split('.').last} Duration (in minutes)',
                ),
                validator: _validateAppDuration,
              ),
            ElevatedButton(
              onPressed: () async {
                if (Form.of(context)!.validate()) {
                  Map<String, int> challenge = {
                    'com.whatsapp': int.tryParse(_appControllers['com.whatsapp']!.text) ?? 0,
                    'com.google.android.youtube': int.tryParse(_appControllers['com.google.android.youtube']!.text) ?? 0,
                    'com.instagram.android': int.tryParse(_appControllers['com.instagram.android']!.text) ?? 0,
                  };
                  await issueChallenge(_challengeNameController.text, challenge, currentUserId);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Issue Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}



  class AcceptedChallenges extends StatelessWidget {
  final String currentUserId;

  const AcceptedChallenges({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 18, 18, 18), 
        foregroundColor: Colors.white,
        title: const Text('Challenges'),
      ),
      body: SingleChildScrollView(
        
        child: Column(
          children: [
            FutureBuilder<int>(
              future: numActiveChallenges(currentUserId),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator(); // Show loading indicator while data is fetching
                }
                final numActive = snapshot.data ?? 0; // Default to 0 if data is null
                return FutureBuilder<double>(
                  future: getChallengeScore(currentUserId),
                  builder: (context, snapshot) {
                    print(numActive);
                    print(getAllChallenges(currentUserId));
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const CircularProgressIndicator(); // Show loading indicator while data is fetching
                    }
                    final score = snapshot.data ?? 0; // Default to 0 if data is null
                    return InfoRow(info: {'Active Challenges': numActive.toString(), 'Score': score.toStringAsFixed(3)});
                  },
                );
              },
            ),
            const Tooltip(
              message: "Calculated based on the Challenges accepted",
              child: Expanded(
                child: Text(
                  'Limit Goals',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            FutureBuilder<Map<String, int>>(
              future: getAllChallengeMinimum(currentUserId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator(); // Show loading indicator while data is fetching
                }
                Map<String, dynamic> challenges = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: challenges.keys.length,
                  itemBuilder: (context, index) {
                    String key = challenges.keys.elementAt(index);
                    return AppTile(packageName: key, text: '${challenges[key]} minutes');
                  },
                );
              },
            ),
            const Tooltip(
              message: "Calculated based on the Challenges accepted",
              child: Expanded(
                child: Text(
                  'All Active Challenges',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            ChallengesListWidget(currentUserId: currentUserId),
            

            // ElevatedButton(
            //   onPressed: () => Navigator.pushNamed(context, '/challenges'),
            //   child: const Text('View All Challenges'),
            // ),
          ],
        ),
      ),
    );
  }
}




class ChallengePage extends StatelessWidget {
  final String currentUserId;
  
  ChallengePage({required this.currentUserId});

void _showBottomSheet(BuildContext context, Map<String, int> dataMap, String challengeId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: dataMap.keys.length,
          itemBuilder: (_, index) {
            String key = dataMap.keys.elementAt(index);
            return AppTile(packageName: key, text: '${dataMap[key]} minutes');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance.collection('challenges').where('status', isEqualTo: 'open');
    return Scaffold(
      appBar: AppBar(
        title: Text('Challenges'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          
          var requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: getUserInfo(request['issuer']),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const ListTile(title: Text('Loading user data...'));
                  var userInfo = userSnapshot.data!.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(userInfo['name'] ?? 'Unknown User'),
                    subtitle: Text('Invites you to a challenge: ' + (request['challenge-name'] ?? 'Unknown Challenge')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () {
                            Map<String, int> challengeMap = Map<String, int>.from(request['challenge']);
                            _showBottomSheet(context, challengeMap, requests[index].id);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () {
                            Map<String, int> challengeMap = Map<String, int>.from(request['challenge']);
                            acceptChallenge(currentUserId, requests[index].id, currentUserId, challengeMap);
                          },
                        ),
                      ],
                    ),
                  );
                }
              );
            },
          );
        },
      ),
    );
  }

}



class ChallengesListWidget extends StatelessWidget {
  final String currentUserId;

  ChallengesListWidget({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance.collection('challenges').where('status', isEqualTo: 'open');
    return StreamBuilder<QuerySnapshot>(
      stream: requestsRef.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        var requests = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,  // Important to ensure it fits within the Column
          physics: NeverScrollableScrollPhysics(),  // to disable scrolling within the ListView
          itemCount: requests.length,
          itemBuilder: (context, index) {
            var request = requests[index].data() as Map<String, dynamic>;
            return FutureBuilder<DocumentSnapshot>(
              future: getUserInfo(request['issuer']),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const ListTile(title: Text('Loading user data...'));
                var userInfo = userSnapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(userInfo['name'] ?? 'Unknown User', style: TextStyle(color: Colors.white)),
                  subtitle: Text('Invites you to a challenge: ' + (request['challenge-name'] ?? 'Unknown Challenge'), style: TextStyle(color: Colors.white)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.info),
                        onPressed: () {
                          Map<String, int> challengeMap = Map<String, int>.from(request['challenge']);
                          _showBottomSheet(context, challengeMap, requests[index].id);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          Map<String, int> challengeMap = Map<String, int>.from(request['challenge']);
                          acceptChallenge(currentUserId, requests[index].id, currentUserId, challengeMap);
                        },
                      ),
                    ],
                  ),
                );
              }
            );
          },
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context, Map<String, int> dataMap, String challengeId) {
    showModalBottomSheet(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      context: context,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: dataMap.keys.length,
          itemBuilder: (_, index) {
            String key = dataMap.keys.elementAt(index);
            return AppTile(packageName: key, text: '${dataMap[key]} minutes');
          },
        ),
      ),
    );
  }
}





  Future<void> acceptChallenge(String userId, String challengeId, String challengee, Map<String, int> challenge) async {
    //create a new document in the challengesPortal collection
    Map <String, Map<String, int>> allChallenges = await getAllChallenges(userId);
    print(allChallenges);
    List<String> activeChallenges = allChallenges.keys.toList();
    print(activeChallenges);
    print(challengeId);
    if (activeChallenges.contains(challengeId)){
      Fluttertoast.showToast(
        msg: "You have accepted this challenge already :)",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 12.0
    );
      return;
    }
    addChallengeToLocal(userId,challengeId,challenge);
      await FirebaseFirestore.instance.collection('challengesPortal').doc(challengeId).set({
        'status': 'accepted',
        'taker' : challengee,
        'time': DateTime.now().toString(),
      });

     FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var androidDetails = const AndroidNotificationDetails(
                'channel_id', 'challenge Accepted',
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, 'Challenge Accepted', 'Challenge ID '+challengeId+" accepted\nLet's start focusing!", platformDetails);

      
  }

  Future<DocumentSnapshot> getUserInfo(String userId) async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Future<void> acceptFriendRequest(String requestId, String currentUserId, String senderId) async {
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'accepted'});
  }

  Future<void> declineFriendRequest(String requestId) async {
    // Update the request status to "declined"
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'declined'});
  }


// import 'dart:collection';
// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:focus/appicon.dart';
// import 'package:focus/firebase_options.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'login.dart';
// import 'track.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'login.dart';
// import 'track.dart';
// import 'firebase_options.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'track.dart';
// import 'validator.dart';
// import 'package:localstorage/localstorage.dart';
// import 'widgets/row_button.dart';
// import 'firebase_map.dart';

// import 'validator.dart';

// List<String> packagesBlock = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android', 'com.twitter.android', 'com.facebook.katana', 'com.snapchat.android', 'com.tinder', 'com.linkedin.android', 'com.pinterest', 'com.reddit.frontpage', 'com.spotify.music' ];

// Future<Map<String,int>> getAllChallengeMinimum() async{
//   Map<String,int> challengeMinimum = {};
//   await initLocalStorage();
//   String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
//   Map<String,Map<String, dynamic>> challengesCollection = Map<String,Map<String, dynamic>>.from(jsonDecode(challengesList));
//   for (String challengeId in challengesCollection.keys){
//     Map<String, dynamic> challenge = challengesCollection[challengeId]!;
//     for (String packageName in packagesBlock){
//       if (challenge.containsKey(packageName)){
//         challengeMinimum[packageName] = min(challengeMinimum[packageName] ?? 24000, challenge[packageName]);
//       }
//     }
//   }
//   return challengeMinimum;
// }

// Future<Map<String,Map<String,dynamic>>> getAllChallenges() async{
//   await initLocalStorage();
//   String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
//   Map<String,Map<String, dynamic>> challengesCollection = Map<String,Map<String, dynamic>>.from(jsonDecode(challengesList));
//   return challengesCollection;
// }

// Future<int> numActiveChallenges() async{
//   await initLocalStorage();
//   String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
//   Map<String,Map<String, int>> challengesCollection = Map<String,Map<String, int>>.from(jsonDecode(challengesList));
//   return challengesCollection.length;
// }

// Future<Map<String,int>> getChallengeStats(String challengeId) async{
//   await initLocalStorage();
//   String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
//   Map<String,Map<String, int>> challengesCollection = Map<String,Map<String, int>>.from(jsonDecode(challengesList));
//   return challengesCollection[challengeId] ?? {};
// }

// Future<void> addChallengeToLocal(String challengeId, Map<String, dynamic> challenge) async {
//    await initLocalStorage();
//   String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
//   Map<String,Map<String, dynamic>> challengesCollection = Map<String,Map<String, dynamic>>.from(jsonDecode(challengesList));
//   challengesCollection[challengeId] = challenge;
//   localStorage.setItem('challengesCollection', jsonEncode(challengesCollection));
// }

// Future<List<String>> getActiveChallengeId() async {
//   Map<String,Map<String,dynamic>> activeChallenges = await getAllChallenges();
//   return activeChallenges.keys.toList();
// }

// Future<double> getChallengeScore() async {
//   Map<String,int> appUsageinMinutes = await getDayAppUsageInMinutes();
//   Map<String,int> challengeMinimum = await getAllChallengeMinimum();
//   print(challengeMinimum);
//   print(appUsageinMinutes);
//   double score = 0;
//   for (String packageName in packagesBlock){
//     int appUsage = appUsageinMinutes[packageName] ?? 0;
//     if (challengeMinimum.containsKey(packageName)){
//       if (appUsage < challengeMinimum[packageName]!){
//         score += 1;
//       }
//       else{
//         score += 1 + (challengeMinimum[packageName]! - appUsage) / challengeMinimum[packageName]!;
//       }
//     }
//     else{
//        score += (appUsageinMinutes[packageName] ?? 0) / 60;
//     }
//   }
//   int activeChallenges = await numActiveChallenges();
//   if (activeChallenges == 0){
//     return score/(packagesBlock.length) * 100;
//   }
//   return (score/(packagesBlock.length))*100;
// }

// Future<void> issueChallenge(String challengeName, Map<String, dynamic> challenge, String currentUserId) async {
//   await FirebaseFirestore.instance.collection('challenges').add({
//     'challenge-name': challengeName,
//     'challenge': challenge,
//     'issuer': currentUserId,
//     'status': 'open',
//   });
//    FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

//     var androidDetails = const AndroidNotificationDetails(
//                 'channel_id', 'challenge Issued',
//                 importance: Importance.max, priority: Priority.high, ticker: 'ticker');
//               var platformDetails = NotificationDetails(android: androidDetails);
//               await flip.show(0, 'Challenge Issued', 'Challenge '+challengeName+" issued\nLet's start focusing!", platformDetails);
// }

// class IssueChallenge extends StatelessWidget {
//   final String currentUserId;
//   IssueChallenge({required this.currentUserId});

//   final TextEditingController _challengeNameController = TextEditingController();
//   final TextEditingController _challengeDescriptionController = TextEditingController();
//   final TextEditingController _challengeDurationController = TextEditingController();

//   final Map<String, TextEditingController> _appControllers = {
//     'com.whatsapp': TextEditingController(),
//     'com.google.android.youtube': TextEditingController(),
//     'com.instagram.android': TextEditingController(),
//   };

//   String? _validateDuration(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter a duration';
//     }
//     int? duration = int.tryParse(value);
//     if (duration == null || duration <= 0) {
//       return 'Please enter a valid duration';
//     }
//     return null;
//   }

//   String? _validateAppDuration(String? value) {
//     if (value == null || value.isEmpty) {
//       return 'Please enter a duration';
//     }
//     int? duration = int.tryParse(value);
//     if (duration == null || duration < 0) {
//       return 'Please enter a valid duration';
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Issue Challenge'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _challengeNameController,
//               decoration: InputDecoration(
//                 labelText: 'Challenge Name',
//               ),
//               validator: (value) => Validator.validateTextInput(),
//             ),
//             TextFormField(
//               controller: _challengeDescriptionController,
//               decoration: InputDecoration(
//                 labelText: 'Challenge Description',
//               ),
//               validator: (value) => Validator.validateTextInput(),
//             ),
//             TextFormField(
//               controller: _challengeDurationController,
//               decoration: InputDecoration(
//                 labelText: 'Challenge Duration (in minutes)',
//               ),
//               validator: _validateDuration,
//             ),
//             for (var app in _appControllers.keys)
//               TextFormField(
//                 controller: _appControllers[app],
//                 decoration: InputDecoration(
//                   labelText: '${app.split('.').last} Duration (in minutes)',
//                 ),
//                 validator: _validateAppDuration,
//               ),
//             ElevatedButton(
//               onPressed: () async {
//                 if (Form.of(context)!.validate()) {
//                   Map<String, dynamic> challenge = {
//                     'com.whatsapp': int.tryParse(_appControllers['com.whatsapp']!.text) ?? 0,
//                     'com.google.android.youtube': int.tryParse(_appControllers['com.google.android.youtube']!.text) ?? 0,
//                     'com.instagram.android': int.tryParse(_appControllers['com.instagram.android']!.text) ?? 0,
//                   };
//                   await issueChallenge(_challengeNameController.text, challenge, currentUserId);
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: Text('Issue Challenge'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



//   class AcceptedChallenges extends StatelessWidget {
//   final String currentUserId;

//   const AcceptedChallenges({required this.currentUserId});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Accepted Challenges'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             FutureBuilder<int>(
//               future: numActiveChallenges(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState != ConnectionState.done) {
//                   return const CircularProgressIndicator(); // Show loading indicator while data is fetching
//                 }
//                 final numActive = snapshot.data ?? 0; // Default to 0 if data is null
//                 return FutureBuilder<double>(
//                   future: getChallengeScore(),
//                   builder: (context, snapshot) {
//                     print(numActive);
//                     print(getAllChallenges());
//                     if (snapshot.connectionState != ConnectionState.done) {
//                       return const CircularProgressIndicator(); // Show loading indicator while data is fetching
//                     }
//                     final score = snapshot.data ?? 0; // Default to 0 if data is null
//                     return InfoRow(info: {'Active Challenges': numActive.toString(), 'Score': score.toStringAsFixed(3)});
//                   },
//                 );
//               },
//             ),
//             const Tooltip(
//               message: "Calculated based on the Challenges accepted",
//               child: Expanded(
//                 child: Text(
//                   'Limit Goals',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//             ),
//             FutureBuilder<Map<String, dynamic>>(
//               future: getAllChallengeMinimum(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const CircularProgressIndicator(); // Show loading indicator while data is fetching
//                 }
//                 Map<String, dynamic> challenges = snapshot.data!;
//                 return ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: challenges.keys.length,
//                   itemBuilder: (context, index) {
//                     String key = challenges.keys.elementAt(index);
//                     return AppTile(packageName: key, text: '${challenges[key]} minutes');
//                   },
//                 );
//               },
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pushNamed(context, '/challenges'),
//               child: const Text('View All Challenges'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




// class ChallengePage extends StatefulWidget {
//   final String currentUserId;
//   ChallengePage({required this.currentUserId});

  
//   @override
//   _ChallengePageState createState() => _ChallengePageState();
// }

// class _ChallengePageState extends State<ChallengePage> {
//   List<String> activeChallenges = [];
//   void initState() {
//     super.initState();
//     getActiveChallengeIdtoPage();
//   }

//   void getActiveChallengeIdtoPage() async {
//     activeChallenges = await getActiveChallengeId();
//     setState(() {});
//   }

//   void _showBottomSheet(BuildContext context, Map<String, dynamic> dataMap, String challengeId, String currentUserId) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => DraggableScrollableSheet(
//         expand: false,
//         builder: (_, controller) => ListView.builder(
//           controller: controller,
//           itemCount: dataMap.keys.length,
//           itemBuilder: (_, index) {
//             String key = dataMap.keys.elementAt(index);
//             return AppTile(packageName: key, text: '${dataMap[key]}'+" minutes");
            
//           },
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final requestsRef = FirebaseFirestore.instance.collection('challenges').where('status', isEqualTo: 'open');
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Challenges'),
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: requestsRef.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
//           List<DocumentSnapshot> requests = snapshot.data!.docs;
//           if (requests.isEmpty) return const Center(child: const Text('No challenges available'));
//           return ListView.builder(
//             itemCount: requests.length,
//             itemBuilder: (context, index) {
//               var request_ori = requests[index];
//                 if (request_ori['issuer'] == widget.currentUserId || activeChallenges.contains(request_ori.id)) return Container(); 

//               var request = requests[index].data() as Map<String, dynamic>;
//               return FutureBuilder<DocumentSnapshot>(
//                 future: getUserInfo(request['issuer']),
//                 builder: (context, userSnapshot) {
//                   if (!userSnapshot.hasData) return ListTile(title: Text('Loading user data...'));
//                   var userInfo = userSnapshot.data?.data() as Map<String, dynamic>?;
//                   return ListTile(
//                     title: Text(userInfo?['name'] ?? 'Unknown User'),  // Assuming 'name' is the field for user's name
//                     subtitle: Text('Invites you to a challenge: ' + (request['challenge-name'] ?? 'Unknown Challenge')),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.info),
//                           onPressed: () => _showBottomSheet(context, request['challenge'], request_ori.id, widget.currentUserId),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.check),
//                           onPressed: () => acceptChallenge(request_ori.id, widget.currentUserId, request['challenge']),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



//   Future<void> acceptChallenge(String challengeId, String challengee, Map<String, dynamic> challenge) async {
//     //create a new document in the challengesPortal collection
//     List<String> allChallenges = await getActiveChallengeId();
//     print("all challenges");
//     print(allChallenges);
//     if (allChallenges.contains(challengeId)){
//       Fluttertoast.showToast(
//         msg: "You have already accepted this challenge!",
//         toastLength: Toast.LENGTH_SHORT,
//         timeInSecForIosWeb: 1,
//         backgroundColor: Colors.black,
//         textColor: Colors.white,
//         fontSize: 12.0
//     );
//     return;
//     }

//     addChallengeToLocal(challengeId,challenge);
//       await FirebaseFirestore.instance.collection('challengesPortal').doc(challengeId).set({
//         'status': 'accepted',
//         'taker' : challengee,
//         'time': DateTime.now().toString(),
//       });

//      FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

//     var androidDetails = const AndroidNotificationDetails(
//                 'channel_id', 'challenge Accepted',
//                 importance: Importance.max, priority: Priority.high, ticker: 'ticker');
//               var platformDetails = NotificationDetails(android: androidDetails);
//               await flip.show(0, 'Challenge Accepted', 'Challenge ID '+challengeId+" accepted\nLet's start focusing!", platformDetails);
//   }

//   Future<DocumentSnapshot> getUserInfo(String userId) async {
//     return await FirebaseFirestore.instance.collection('users').doc(userId).get();
//   }

//   Future<void> acceptFriendRequest(String requestId, String currentUserId, String senderId) async {
//     await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'accepted'});
//   }

//   Future<void> declineFriendRequest(String requestId) async {
//     // Update the request status to "declined"
//     await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'declined'});
//   }