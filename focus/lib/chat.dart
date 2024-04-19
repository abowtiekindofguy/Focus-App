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
import 'package:app_usage/app_usage.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:pdf/pdf.dart' as pw;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_usage/app_usage.dart';
import 'storage.dart';
import 'login.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ai.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:permission_handler/permission_handler.dart';
import 'appicon.dart';
import 'notifications.dart';
import 'package:pair/pair.dart';  
// void main() {
//   initializeDateFormatting().then((_) => runApp(const MyApp()));
// }



class ChatPage extends StatefulWidget {
  String start_message;
  // final String data;
  ChatPage({super.key,this.start_message = "babushka"});

  @override
  State<ChatPage> createState() => _ChatPageState(start_message: start_message);
}

class _ChatPageState extends State<ChatPage> {
  String start_message;
  _ChatPageState({required this.start_message});

  List<types.Message> _messages = [];
  List<Pair<String,String>> _messagesList = [];
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
    print("INIT STATE" + start_message);
    _loadMessages();
    if(start_message != "babushka"){simpleMessage(start_message);}
    super.initState();
    
  }

  @override
  void dispose() {
    initLocalStorage();
    localStorage.setItem('messages', jsonEncode(_messages));
    // localStorage.setItem('messagesList', jsonEncode(_messagesList));
    super.dispose();
  } 

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  void exportPDF(List<Pair<String,String>> messages, String filename) async { 
  final pdf = pw.Document();
  messages = messages.reversed.toList();
   pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return <pw.Widget>[
          pw.Wrap(  // Using Wrap to handle overflow properly
            children: List<pw.Widget>.generate(messages.length, (index) {
              final Pair<String,String> item = messages[index];
              return pw.Container(
                  width: double.infinity,
                  margin: pw.EdgeInsets.only(bottom: 10),
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(item.key, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(item.value),
                      ]
                  )
              );
            })
        ),
        ];
      }));

  final String downloadsDirectory = await getDownloadPath() ?? "";
  final String path = '$downloadsDirectory/$filename';
  final File file = File(path);
  await file.writeAsBytes(await pdf.save());
  fltoast("PDF saved to $path");
}



  void _addMessage(types.Message message, String messageString, String authorName) {
    setState(() {
      _messages.insert(0, message);
      _messagesList.insert(0, Pair<String,String>(authorName,messageString));
      initLocalStorage();
    localStorage.setItem('messages', jsonEncode(_messages));
    // localStorage.setItem('messagesList', jsonEncode(_messagesList));
    });
  }

  void _handleSendPressed(types.PartialText message) async {
    setState(() {
      _isLoading = true;  // Start loading
    });

    String responseText = await getResponse("You are a personal AI trainer that helps in focus, concentration, productivity and related things. If the question is highly irrelevant, politely say so. Here is the question: \n"+message.text);

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
      _addMessage(textMessage, message.text, "You");
      _addMessage(responseMessage, responseText, "Focus Bot");
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
      _addMessage(textMessage, message, "You");
      _addMessage(responseMessage,  responseText, "Focus Bot");
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
    final responseList = localStorage.getItem('messagesList') ?? '[]';
    final messagesList = (jsonDecode(responseList) as List)
        .map((e) => Pair<String,String>(e[0],e[1]))
        .toList();

    setState(() {
      _messages = messages;
      _messagesList = messagesList;
    });
  }

  void _clearMessages() {
    setState(() {
      _messages = [];
      localStorage.setItem('messages', jsonEncode(_messages));
      _messagesList = []; 
      localStorage.setItem('messagesList', jsonEncode(_messagesList));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromARGB(255, 18, 18, 18),
      appBar: AppBar(
                foregroundColor: Colors.white,

        backgroundColor: Color.fromARGB(255, 18, 18, 18),
        title: const Text('Focus Bot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearMessages,
          ),
          IconButton(onPressed: () => exportPDF(_messagesList,"chat_with_focus_bot.pdf"), icon: const Icon(Icons.download))
        ],
      ),
      
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
              // onPreviewDataFetched: _handlePreviewDataFetched,
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: const DefaultChatTheme(
                backgroundColor: Color.fromARGB(255, 18, 18, 18),
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