import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'profile-card.dart';
import 'package:flutter/services.dart'; // Required for setting orientations
import 'package:qr_code_scanner/qr_code_scanner.dart';
// import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';



class InviteFriendPage extends StatelessWidget {
  final String currentUserId;
  final TextEditingController emailController = TextEditingController();
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  InviteFriendPage({required this.currentUserId});

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) {
      emailController.text = scanData.code ?? 'No data scanned';
      controller.dispose();
      Navigator.of(qrKey.currentContext!).pop();
    });
  }

  void _openQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextFormField(
            style: TextStyle(color: Colors.white),
            controller: emailController,
            validator: (value) {
              // Implement validateEmail where necessary or ensure it is imported
              return Validator.validateEmail(email: value);
            },
            decoration: InputDecoration(
              labelText: 'Send Friend Request with Focus ID',
              labelStyle: TextStyle(color: Colors.white),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.camera_alt),
                    onPressed: () => _openQRScanner(context),
                  ),
                  IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (emailController.text.isNotEmpty) {
                        sendFriendRequest(emailController.text, currentUserId);
                      }
                    },
                  ),
                ],
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Future<void> sendFriendRequest(String receiverId, String senderId) async {
    if (receiverId == senderId) {
      Fluttertoast.showToast(
        msg: "You are your own friend already :)",
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 12.0
    );
                  emailController.clear();

    return; // Don't allow sending friend request to self
    }
    // Check if the receiver ID exists
    var receiver = await FirebaseFirestore.instance.collection('users').where('email',isEqualTo: receiverId).get();
    if (receiver.docs.isEmpty) {
      Fluttertoast.showToast(
        msg: "User "+receiverId+" not found",
        toastLength: Toast.LENGTH_SHORT,
        // gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 12.0
    );
                  emailController.clear();

    return; // Don't allow sending friend request to self
    }

    // Check if the friend request already exists
    var request = await FirebaseFirestore.instance.collection('friendRequests').where('senderId', isEqualTo: senderId).where('receiverId', isEqualTo: receiverId).get();
    if (request.docs.isNotEmpty) {
      Fluttertoast.showToast(
        msg: "Friend request already sent to "+receiverId,
        toastLength: Toast.LENGTH_SHORT,
        // gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 12.0
    );
                  emailController.clear();

    return; // Don't allow sending duplicate friend requests  
    }

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
                            emailController.clear();

              await flip.show(0, 'Focus Friend Request Sent', 'Friend Request Sent to '+receiverId+"\nYour Friend List would be updated once the request is accepted", platformDetails);

  }
}



class FriendsPage extends StatefulWidget {
  final String currentUserId;

  FriendsPage({required this.currentUserId});

  @override
  _FriendsPageState createState() => _FriendsPageState(currentUserId: currentUserId);

}

class _FriendsPageState extends State<FriendsPage> {
  final String currentUserId;
  List<String> friends = [];
  _FriendsPageState({required this.currentUserId});

@override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    getFriendsList();
  }


  void getFriendsList() async {
    List<String> temp = [];
    final friendsRef = FirebaseFirestore.instance.collection('friendRequests').where('senderId', isEqualTo: currentUserId).where('status', isEqualTo: 'accepted').get();
    await friendsRef.then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      temp.add(doc['receiverId']);
    });
  }).catchError((error) { 
    print("Error Occured!");
  });
    final friendsRefReceiver = FirebaseFirestore.instance.collection('friendRequests').where('receiverId', isEqualTo: currentUserId).where('status', isEqualTo: 'accepted').get();
    await friendsRefReceiver.then((QuerySnapshot querySnapshot) { 
    querySnapshot.docs.forEach((doc) {
      temp.add(doc['senderId']);
    });
  }).catchError((error) {
    print("Error Occured!");
  });

    setState(() {
      friends = temp.toSet().toList();
    });
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
    backgroundColor: Color.fromARGB(255, 18, 18, 18),
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 18, 18, 18),
      foregroundColor: Colors.white ,  
      title: Text('Friends'),
      actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/friendrequests'); // Ensure this route is defined in your MaterialApp routes
              },
              child: Text('Friend Requests'),
            ),
        ],
    ),
    body: Column(
      children: [
        InviteFriendPage(currentUserId: currentUserId,),
 // Wrap the StreamBuilder in an Expanded widget
           Expanded(
             child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    String friendUserId = friends[index];
                    return ProfileCard(
                      userID: friendUserId,
                      height: MediaQuery.of(context).size.height / 10,
                      width: 0.4 * MediaQuery.of(context).size.width,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(friendUserId),
                            content: Text('Click here to unfriend this user.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  unfriend(friendUserId);
                                  Navigator.of(context).pop();
                                  Future.delayed(Duration.zero, () => setState(() {
                                    friends.remove(friendUserId);
                                  }));
                                  Navigator.of(context).pushNamed('/friends', arguments: FriendsPage(currentUserId: currentUserId));
                                },
                                child: Text('Unfriend'),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Perform any action you want when the dialog is closed
                                  Navigator.of(context).pop();
                                  
                                },
                                child: Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  ),
            ),
        //    ),        Row(
        //   children: [
        //     ElevatedButton(
        //       onPressed: () {
        //         Navigator.pushNamed(context, '/friendrequests'); // Ensure this route is defined in your MaterialApp routes
        //       },
        //       child: Text('Friend Requests'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         Navigator.pushNamed(context, '/inviteFriend'); // Ensure this route is defined in your MaterialApp routes
        //       },
        //       child: Text('Invite Friends'),
        //     ),
        //   ],
        // ),
      ],
    ),
  );
}

 Future<void> unfriend(String friendId) async {
    await FirebaseFirestore.instance.collection('friendRequests').where('senderId', isEqualTo: currentUserId).where('receiverId', isEqualTo: friendId).get().then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
  }

}

 class FriendRequestsPage extends StatelessWidget {
  final String currentUserId;
  FriendRequestsPage({required this.currentUserId});
  @override
  Widget build(BuildContext context) {
    final requestsRef = FirebaseFirestore.instance.collection('friendRequests').where('receiverId', isEqualTo: currentUserId).where('status', isEqualTo: 'pending');
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
            onPressed: () => acceptFriendRequest(request.id),
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

  Future<void> acceptFriendRequest(String requestId) async {
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'accepted'});
  }

  Future<void> declineFriendRequest(String requestId) async {
    await FirebaseFirestore.instance.collection('friendRequests').doc(requestId).update({'status': 'declined'});
  }
} 
