import 'dart:math';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameStatistics {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void setGameScore(String gameName, String userId, int score) async {
    DateTime now = DateTime.now();
    String date = new DateTime(now.year, now.month, now.day).toString();
    await FirebaseFirestore.instance.collection(gameName).doc(userId+date).set({
        'score': score,
        'userId' : userId,
        'time': date,
      });
  }

  Future<int> getGameScore(String gameName, String userId, DateTime dateString) async {
    final requestsRef = await FirebaseFirestore.instance.collection(gameName).where('date', isEqualTo: dateString).where('userId', isEqualTo: userId).get();
    if (requestsRef.docs.isNotEmpty) {
      dynamic dataMap = requestsRef.docs[0].data();
      return dataMap['score'];
    } else {
      return -1;
    }
  }
}