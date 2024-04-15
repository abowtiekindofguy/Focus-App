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

class AppUsageLimits{
    Future<Map<String,int>> getLocalLimits() async {
        initLocalStorage();
        String limitString = localStorage.getItem('limits') ?? '{}';
        Map<String, int> limits = jsonDecode(limitString);
        return limits;
    }

    void setLocalLimits(Map<String, int> limits) async {
        initLocalStorage();
        localStorage.setItem('limits', jsonEncode(limits));
    }

    Future<Map<String,int>> fetchParentalLimits(String currentUserId) async {
        await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
          final parentalControls = FirebaseFirestore.instance
              .collection('parentalControls')
              .where('userID', isEqualTo: currentUserId)
              .where('active', isEqualTo: true)
              .get();

          Map<String, int> Limits = {};
          parentalControls.then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              final Limits = doc['limits'];
            });
          }).catchError((error) {
            print("No parental controls found!");
          });
          return Limits;
    }

}