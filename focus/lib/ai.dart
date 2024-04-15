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
import 'package:dart_openai/dart_openai.dart';

Future<String> getResponse(String prompt) async {
  OpenAI.apiKey = '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';

  try {
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
          ],
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    // String response = chatCompletion.choices.first.message.content?[0]??'return';
    String response = chatCompletion.choices.first.message.content.toString();
    String response1 = response.substring(1, response.length - 2);
    //find the substring after text:
    int index = response1.indexOf("text:");
    String response2 = response1.substring(index + 6);
    return response2;

  } catch (e) {
    return "Failed to get completion: $e";
  }
}



// class GPT{
//    generate(String prompt) async{
//     final systemMessage = OpenAIChatCompletionChoiceMessageModel(
//   content: [
//     OpenAIChatCompletionChoiceMessageContentItemModel.text(
//       "return any message you are given as JSON.",
//     ),
//   ],
//   role: OpenAIChatMessageRole.assistant,
// );

//   // the user message that will be sent to the request.
//  final userMessage = OpenAIChatCompletionChoiceMessageModel(
//    content: [
//      OpenAIChatCompletionChoiceMessageContentItemModel.text(
//        prompt,
//      ),

//     //  //! image url contents are allowed only for models with image support such gpt-4.
//     //  OpenAIChatCompletionChoiceMessageContentItemModel.imageUrl(
//     //    "https://placehold.co/600x400",
//     //  ),
//    ],
//    role: OpenAIChatMessageRole.user,
//  );

// // all messages to be sent.
// final requestMessages = [
//   systemMessage,
//   userMessage,
// ];

// // the actual request.
// OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
//   model: "gpt-3.5-turbo-1106",
//   responseFormat: {"type": "json_object"},
//   seed: 6,
//   messages: requestMessages,
//   temperature: 0.2,
//   maxTokens: 500,
// );
//     print(chatCompletion.choices.first.message); // ...
//     print(chatCompletion.systemFingerprint); // ...
//     print(chatCompletion.usage.promptTokens); // ...
//     print(chatCompletion.id);
//     return chatCompletion.choices.first.message;
//   }
// }

