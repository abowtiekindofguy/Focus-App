
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileCard extends StatelessWidget {
  final String userID;
  final double height;
  final double width;
  final VoidCallback onPressed;

  const ProfileCard({
    Key? key,
    required this.userID,
    required this.height,
    required this.width,
    required this.onPressed,
  }) : super(key: key);

  Future<Map<String, String>> getUserData(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'name': 'Unknown',
          'email': 'No Email',
          'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO6-lzbtwuwRF4nnDCGyWoxCRvvJcJq30kVVVJwqxYWg&s'
        };
      }

      var doc = snapshot.docs.first;
      print(doc.data());
      return {
        'name': doc['name'] ?? 'Unknown',
        'email': doc['email'] ?? 'No Email',
        'image': doc['pic'] ?? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO6-lzbtwuwRF4nnDCGyWoxCRvvJcJq30kVVVJwqxYWg&s'
      };
    } catch (e) {
      return {
        'name': 'Error',
        'email': 'Error',
        'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSO6-lzbtwuwRF4nnDCGyWoxCRvvJcJq30kVVVJwqxYWg&s'
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: getUserData(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(child: Text("No user data found"));
        }

        var userData = snapshot.data!;
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
           backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: TextStyle(fontSize: 16),
            // fixedSize: Size(width, height),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(userData['image']!),
                radius: 30,
              ),
              SizedBox(width: 10),
              Expanded(  // Use Expanded to avoid overflow when the text is too long
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,  // To align the text to the top
                  children: [
                    Text(
                      userData['name']!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,  // Prevents text overflow
                    ),
                    Text(
                      userData['email']!,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,  // Prevents text overflow
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
