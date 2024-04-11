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

class FriendsPage extends StatelessWidget {
  final String currentUserId;

  FriendsPage({required this.currentUserId});

  // @override
  //   Widget build(BuildContext context) {
  //     final friendsRef = FirebaseFirestore.instance.collection('users').doc(currentUserId);
      
  //     return StreamBuilder<DocumentSnapshot>(
  //       stream: friendsRef.snapshots(),
  //       builder: (context, snapshot) {
  //         if (!snapshot.hasData) return CircularProgressIndicator();

  //         Map<String, dynamic> friendsMap = snapshot.data!.data()?.['friends'] as Map<String, dynamic>;
  //         List<String> friends = friendsMap.keys.toList();

  //         return ListView.builder(
  //           itemCount: friends.length,
  //           itemBuilder: (context, index) {
  //             String friendUserId = friends[index];        
  //             return ListTile(
  //               title: Text("Friend ID: $friendUserId"),
  //             );
  //           },
  //         );
  //       },
  //     );
  //   }

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
        ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/friendrequests'); // Ensure this route is defined in your MaterialApp routes
          },
          child: Text('Friend Requests'),
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
