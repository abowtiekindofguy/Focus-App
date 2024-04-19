import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

Future<void> playLocalAsset(String fileName) async {
  AudioPlayer audioPlayer = AudioPlayer();
  final path = 'music/$fileName'; 
  try {
    await audioPlayer.setSource(AssetSource(path));
    await audioPlayer.resume();  
  } catch (e) {
    print('Error loading or playing $path: $e');
  }
}


void vibrateHard() async {
  Vibration.vibrate();
              HapticFeedback.heavyImpact();
}

void vibrateSoft() async {
  Vibration.vibrate();
              HapticFeedback.lightImpact();
}

void vibrateMedium() async {
  Vibration.vibrate();
              HapticFeedback.mediumImpact();
}
