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
      return '{}';  // Return '{}' if no documents are found
    }

    for (var doc in querySnapshot.docs) {
      String p = doc['value'].toString();
      print(p);  // This should still show the correct output in console
      return p;  // Return the found value
    }
  } catch (e) {
    print("Error fetching data: $e");
    return '{}';  // Return '{}' in case of an error
  }
  return "{}";  // This is a fallback, technically unreachable
}

void FirebaseMapSet(String key, String value) async {
  try {
    // Query Firestore for documents with the matching key
    final querySnapshot = await FirebaseFirestore.instance
        .collection('focus-map')
        .where('key', isEqualTo: key)
        .get();

    if (querySnapshot.docs.isEmpty) {
      // If no document exists with the key, create a new document
      await FirebaseFirestore.instance
          .collection('focus-map')
          .doc(key) // It's crucial to specify the document ID when setting for the first time
          .set({'key': key, 'value': value});
    } else {
      // If documents exist, update all matching documents
      for (var doc in querySnapshot.docs) {
        await doc.reference.update({'value': value});
      }
    }
  } catch (e) {
    // Handle any errors that occur during the update process
    print("Error Occurred! $e");
  }
}
