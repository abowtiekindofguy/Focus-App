import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<dynamic> getFirebaseValue(String currentUserId, String storeId, String key) async { 
  final firebase_instance = FirebaseFirestore.instance.collection(storeId).where('userId',isEqualTo: currentUserId).get();
  await firebase_instance.then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      return doc[key];
    });
  }).catchError((error) {
    return null;
  });
  return null;
}

void setFirebaseValue(String currentUserId, String storeId, String key, dynamic value) async { 
  createFirebaseDoc(currentUserId, storeId);
  final firebase_instance = FirebaseFirestore.instance.collection(storeId).where('userId',isEqualTo: currentUserId).get();
  print("Setting Value!");
  await firebase_instance.then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      doc.reference.update({key: value});
      print("Value Updated!");
    });
  }).catchError((error) {
print("Error Occured!");  
});
}

void createFirebaseDoc(String currentUserId, String storeId) async { 
  final firebase_instance = FirebaseFirestore.instance.collection(storeId).where('userId',isEqualTo: currentUserId).get();
  await firebase_instance.then((QuerySnapshot querySnapshot) {
    if(querySnapshot.docs.isEmpty){
      FirebaseFirestore.instance.collection(storeId).doc(currentUserId).set({'userId': currentUserId});
    }
  }).catchError((error) {
    print("Error Occured!");
  });
}

void checkFirebaseKey(String currentUserId, String storeId, String key) async { 
  final firebase_instance = FirebaseFirestore.instance.collection(storeId).where('userId',isEqualTo: currentUserId).get();
  await firebase_instance.then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
      if(doc[key] == null){
        doc.reference.update({key: 0});
      }
    });
  }).catchError((error) { 
    print("Error Occured!");
  });       
}

Future<dynamic> getFirebaseKeyIfArgBool(String currentUserId, String storeId, String key, String arg, bool argval)  async{ 
  final firebase_instance = FirebaseFirestore.instance.collection(storeId).where('userId',isEqualTo: currentUserId).where(arg, isEqualTo: argval).get();
  await firebase_instance.then((QuerySnapshot querySnapshot) {
    querySnapshot.docs.forEach((doc) {
        return doc[key];
    });
  }).catchError((error) {
    return null;
  });
  return null;
}

Future<String> FirebaseMap(String key) async {
  try {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('focus-map')
        .where('key', isEqualTo: key)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return '{}';  
    }

    for (var doc in querySnapshot.docs) {
      String p = doc['value'].toString();
      print(p);  
      return p;  
    }
  } catch (e) {
    print("Error fetching data: $e");
    return '{}';  
  }
  return "{}";  
}

void FirebaseMapSet(String key, String value) async {
  try {
    // Query Firestore for documents with the matching key
    final querySnapshot = await FirebaseFirestore.instance
        .collection('focus-map')
        .where('key', isEqualTo: key)
        .get();

    if (querySnapshot.docs.isEmpty) {

      await FirebaseFirestore.instance
          .collection('focus-map')
          .doc(key) 
          .set({'key': key, 'value': value});
    } else {

      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'value': value});
      }
    }
  } catch (e) {
 
    print("Error Occurred! $e");
  }
}
