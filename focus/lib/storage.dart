
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


class FirebaseDatabase{
  Future<void> uploadData(String folder, String metadata, dynamic data) async {
  print("Uploading data: $data");
  //  String email = await Authentication.getEmail();
  String email = "hi";
  print("Uploading data: $data");
  print(email);
  // String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  // String email = await Authentication.getEmail();
  String fileName = '$folder/$email-$metadata.json';
  Reference ref = FirebaseStorage.instance.ref().child(fileName);
  try {
    await ref.putString(data);
    print("Upload successful");
  } catch (e) {
    print("Error uploading file: $e");
  }
}

Future<String> downloadData(String folder, String metadata) async {
  String fileName = '$folder/$metadata.json';
  try {
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    const maxSize = 10 * 1024 * 1024;
    final bytes = await ref.getData(maxSize);
    final stringData = String.fromCharCodes(bytes!);
    print(stringData);
    return stringData;
  } catch (e) {
    print("Error downloading file: $e");
    throw e;
  }
}

Future<void> deleteData(String metadata) async {
  String fileName = '$metadata.json';
  try {
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    await ref.delete();
    print("Delete successful");
  } catch (e) {
    print("Error deleting file: $e");
  }
}

Future<String> getDownloadURL (String metadata) async{
  String fileName = '$metadata.json';
  try {
    Reference ref = FirebaseStorage.instance.ref().child(fileName);
    String downloadURL = await ref.getDownloadURL();
    print(downloadURL);
    return downloadURL;
  } catch (e) {
    print("Error getting download URL: $e");
    throw e;
  }
}

}
