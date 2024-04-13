import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'validator.dart';
import 'package:localstorage/localstorage.dart';


List<String> packagesBlock = ['com.whatsapp','com.google.android.youtube', 'com.instagram.android'];

Future<void> addChallenge(String challengeId, Map<String, dynamic> challenge) async {
  await initLocalStorage();
  String challenges = localStorage.getItem('challenges') ?? '{}';
  String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
  Map<String,Map<String, dynamic>> challengesCollection = Map<String,Map<String, dynamic>>.from(jsonDecode(challengesList));
  Map<String, int> goalChallenge = Map<String, int>.from(jsonDecode(challenges));
  challengesCollection[challengeId] = challenge;
  for (String packageName in challenge.keys) {
    if (packagesBlock.contains(packageName)) {
      goalChallenge[packageName] = min(challenge[packageName] ?? 240000, goalChallenge[packageName] ?? 24000);
    }
  }
  localStorage.setItem('challenges', jsonEncode(goalChallenge));
  localStorage.setItem('challengesCollection', jsonEncode(challengesCollection));
}

Future<Map<String,dynamic>> challengeGoals() async{
  await initLocalStorage();
  String challenges = localStorage.getItem('challenges') ?? '{}';
  Map<String, int> challengesList = Map<String, int>.from(jsonDecode(challenges));
  return challengesList;
}

Future<Map<String, dynamic>> challengeGoalsCollection() async {
  await initLocalStorage();
  String challengesList = localStorage.getItem('challengesCollection') ?? '{}';
  Map<String,Map<String, dynamic>> challengesCollection = Map<String,Map<String, dynamic>>.from(jsonDecode(challengesList));
  return challengesCollection;
}

Future<void> issueChallenge(String challengeName, Map<String, dynamic> challenge, String currentUserId) async {
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
  //only take duration in minutes give only the apps written in the packagesBlock
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _youtubeController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _challengeNameController = TextEditingController();
  final TextEditingController _challengeDescriptionController = TextEditingController();
  final TextEditingController _challengeDurationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Issue Challenge'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _challengeNameController,
              decoration: InputDecoration(
                labelText: 'Challenge Name',
              ),
            ),
            TextField(
              controller: _challengeDescriptionController,
              decoration: InputDecoration(
                labelText: 'Challenge Description',
              ),
            ),
            TextField(
              controller: _challengeDurationController,
              decoration: InputDecoration(
                labelText: 'Challenge Duration (in minutes)',
              ),
            ),
            TextField(
              controller: _whatsappController,
              decoration: InputDecoration(
                labelText: 'Whatsapp Duration (in minutes)',
              ),
            ),
            TextField(
              controller: _youtubeController,
              decoration: InputDecoration(
                labelText: 'Youtube Duration (in minutes)',
              ),
            ),
            TextField(
              controller: _instagramController,
              decoration: InputDecoration(
                labelText: 'Instagram Duration (in minutes)',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> challenge = {
                  'com.whatsapp': int.tryParse(_whatsappController.text) ?? 0,
                  'com.google.android.youtube': int.tryParse(_youtubeController.text) ?? 0,
                  'com.instagram.android': int.tryParse(_instagramController.text) ?? 0,
                };
                await issueChallenge(_challengeNameController.text, challenge, currentUserId);
                Navigator.of(context).pop();
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

    const AcceptedChallenges({ required this.currentUserId});

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Accepted Challenges'),
        // ),
        body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Challenge Goals'),
            FutureBuilder<Map<String, dynamic>>(
              future: challengeGoals(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                Map<String, dynamic> challenges = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: challenges.keys.length,
                  itemBuilder: (context, index) {
                    String key = challenges.keys.elementAt(index);
                    return ListTile(
                      title: Text(key),
                      trailing: Text('${challenges[key]} minutes'),
                    );
                  },
                );
              },
            ),
          ],
        ),
        )
      );
    }
  }



class ChallengePage extends StatelessWidget {
  final String currentUserId;
  ChallengePage({required this.currentUserId});
  void _showBottomSheet(BuildContext context, Map<String, dynamic> dataMap, String challengeId, String currentUserId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => ListView.builder(
          controller: controller,
          itemCount: dataMap.keys.length,
          itemBuilder: (_, index) {
            String key = dataMap.keys.elementAt(index);
            return ListTile(
              title: Text(key),
              trailing: Text('${dataMap[key]}'+" minutes"),
            );
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
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          List<DocumentSnapshot> requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request_ori = requests[index];
              var request = requests[index].data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: getUserInfo(request['issuer']),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return ListTile(title: Text('Loading user data...'));
                  var userInfo = userSnapshot.data?.data() as Map<String, dynamic>?;
                  return ListTile(
                    title: Text(userInfo?['name'] ?? 'Unknown User'),  // Assuming 'name' is the field for user's name
                    subtitle: Text('Invites you to a challenge: ' + (request['challenge-name'] ?? 'Unknown Challenge')),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.info),
                          onPressed: () => _showBottomSheet(context, request['challenge'], request_ori.id, currentUserId),
                        ),
                        IconButton(
                          icon: Icon(Icons.check),
                          onPressed: () => acceptChallenge(request_ori.id, currentUserId, request['challenge']),
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



  Future<void> acceptChallenge(String challengeId, String challengee, Map<String, dynamic> challenge) async {
    //create a new document in the challengesPortal collection
    addChallenge(challengeId,challenge);
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