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


class InviteFriendPage extends StatelessWidget {
  final String currentUserId;
  final TextEditingController emailController = TextEditingController();

  InviteFriendPage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final usersRef = FirebaseFirestore.instance.collection('users');
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Friends'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
        TextFormField(
          controller: emailController,
          validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
          decoration: InputDecoration(
            labelText: 'Enter your friend\'s Focus ID',
            suffixIcon: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (emailController.text.isNotEmpty) {
              sendFriendRequest(emailController.text, currentUserId);
              emailController.clear(); // Clear the text field after sending request
            }
          },
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
          ],
        ),
      ),
    );
  }

  Future<void> sendFriendRequest(String receiverId, String senderId) async {
    await FirebaseFirestore.instance.collection('friendRequests').add({
      'senderId': senderId,
      'receiverId': receiverId,  // Typo corrected from 'recieverId' to 'receiverId'
      'status': 'pending',
    });
    //when the friend request is sent, user will receive a local notification
              FlutterLocalNotificationsPlugin flip = FlutterLocalNotificationsPlugin();

    var androidDetails = const AndroidNotificationDetails(
                'channel_id', 'Friend Request Sent',
                importance: Importance.max, priority: Priority.high, ticker: 'ticker');
              var platformDetails = NotificationDetails(android: androidDetails);
              await flip.show(0, 'Focus Friend Request Sent', 'Friend Request Sent to '+receiverId+"\nYour Friend List would be updated once the request is accepted", platformDetails);

  }
}
class FriendsPage extends StatelessWidget {
  final String currentUserId;

  FriendsPage({required this.currentUserId});


  @override
Widget build(BuildContext context) {
  final friendsRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
  return Scaffold(
    appBar: AppBar(
      title: Text('Friends List'),
    ),
    body: Column(
      children: [
        Expanded( // Wrap the StreamBuilder in an Expanded widget
          child: StreamBuilder<DocumentSnapshot>(
            stream: friendsRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              var data = snapshot.data?.data() as Map<String, dynamic>?;
              var friendsMap = data?['friends'] as Map<String, dynamic>?;
              if (friendsMap == null || friendsMap.isEmpty) {
                return Center(child: Text('No friends found.'));
              }

              List<String> friends = friendsMap.keys.toList();

              return ListView.builder(
                itemCount: friends.length,
                itemBuilder: (context, index) {
                  String friendUserId = friends[index];
                  return ListTile(
                    title: Text("Friend ID: $friendUserId"),
                  );
                },
              );
            },
          ),
        ),
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/friendrequests'); // Ensure this route is defined in your MaterialApp routes
              },
              child: Text('Friend Requests'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inviteFriend'); // Ensure this route is defined in your MaterialApp routes
              },
              child: Text('Invite Friends'),
            ),
          ],
        ),
      ],
    ),
  );
}

  }



 class FriendRequestsPage extends StatelessWidget {
  final String currentUserId;
  FriendRequestsPage({required this.currentUserId});
  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance.collection('friendRequests').where('recieverId', isEqualTo: currentUserId).where('status', isEqualTo: 'pending');
    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: requestsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          
          List<DocumentSnapshot> requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index];
              return FutureBuilder<DocumentSnapshot>(
  future: getUserInfo(request['senderId']), // Corrected to call getUserInfo
  builder: (context, userSnapshot) {
    if (!userSnapshot.hasData) return ListTile(title: Text('Loading...'));
    var userInfo = userSnapshot.data?.data() as Map<String, dynamic>?;
    return ListTile(
      title: Text(userInfo?['name'] ?? 'Unknown'), // Use null-aware operators to handle possible nulls
      subtitle: Text('Wants to be friends'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () => acceptFriendRequest(request.id, currentUserId, request['senderId']),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => declineFriendRequest(request.id),
          ),
        ],
      ),
    );
  },
);
            },
          );
        },
      ),
    );
  }

  Future<DocumentSnapshot> getUserInfo(String userId) async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  Future<void> acceptFriendRequest(String requestId, String currentUserId, String senderId) async {
    // Add each user to the other's friends collection
    // await FirebaseFirestore.instance.collection('users').doc(currentUserId).collection('friends').doc(senderId).set({});
    // await FirebaseFirestore.instance.collection('users').doc(senderId).collection('friends').doc(currentUserId).set({});
    // Update the request status to "accepted"
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'accepted'});
  }

  Future<void> declineFriendRequest(String requestId) async {
    // Update the request status to "declined"
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'declined'});
  }
} 
