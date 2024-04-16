import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:focus/ai.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:io';
// void main() {
//   initializeDateFormatting().then((_) => runApp(const MyApp()));
// }



class ChatPage extends StatefulWidget {
  String start_message;
  ChatPage({super.key, this.start_message = "babushka"});

  @override
  State<ChatPage> createState() => _ChatPageState(start_message: start_message);
}

class _ChatPageState extends State<ChatPage> {
  String start_message;
  _ChatPageState({required this.start_message});

  List<types.Message> _messages = [];
  bool _isLoading = false;
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
    // id: '82091008-a484-4a89-ae75-a22bf7d6f3ac',
  );

  final _chat = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d0f3ac',
    // id: '82091008-a484-4a89-ae75-a22bf7d6f3ac',
  );

  @override
  void initState() {
    
    _loadMessages();
    if(start_message != "babushka"){simpleMessage(start_message);}
    super.initState();
    
  }

  @override
  void dispose() {
    
    super.dispose();
  } 

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
      initLocalStorage();
    localStorage.setItem('messages', jsonEncode(_messages));
    });
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      final message2 = types.ImageMessage(
        author: _chat,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: const Uuid().v4(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );
      _addMessage(message);
      _addMessage(message2);
    }
  }
  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage).copyWith(
      previewData: previewData,
    );

    setState(() {
      _messages[index] = updatedMessage;
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    setState(() {
      _isLoading = true;  // Start loading
    });

    String responseText = await getResponse("Answer the following question in reference to productivity and focus and concentration and phone usage. If it does not relate it, simply answer Not Relevant \n"+message.text);

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    final responseMessage = types.TextMessage(
      author: _chat,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: responseText,
    );

    setState(() {
      _addMessage(textMessage);
      _addMessage(responseMessage);
      _isLoading = false;  // Stop loading
    });
  }


  void simpleMessage(String message) async {
    setState(() {
      _isLoading = true;  // Start loading
    });

    String responseText = await getResponse(message);

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message,
    );

    final responseMessage = types.TextMessage(
      author: _chat,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: responseText,
    );

    setState(() {
      _addMessage(textMessage);
      _addMessage(responseMessage);
      _isLoading = false;  // Stop loading
    });
  }

  void _loadMessages() async {
    initLocalStorage();
    // await localStorage.init;
    final response = localStorage.getItem('messages') ?? '[]';
    final messages = (jsonDecode(response) as List)
        .map((e) => types.Message.fromJson(e as Map<String, dynamic>))
        .toList();

    setState(() {
      _messages = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
            ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Loading curated suggestions for you..'),
                ),
                CircularProgressIndicator(),
              ],
              ),
             )// Show loading indicator
          : Chat(
              messages: _messages,
              onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: const DefaultChatTheme(
                seenIcon: Text(
                  'read',
                  style: TextStyle(
                    fontSize: 10.0,
                  ),
                ),
              ),
            ),
    );
  }
}