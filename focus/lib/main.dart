
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


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  String email = await Authentication.getEmail();
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/home': (context) =>  HomeScreen(),
        '/register': (context) => RegisterPage(),
       '/track': (context) => TrackPage(),
       '/friends': (context) => FriendsPage(currentUserId: email),
       '/friendrequests': (context) => FriendRequestsPage(currentUserId: email),
       '/map':(context) => MapPage(),
       '/sudoku':(context) => SudokuPage(),
       '/game':(context) => GameScreen(),
      },
    ),
  );
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Isolate isolate;
  late ReceivePort receivePort;
  bool isIsolateRunning = false;

  @override
  void initState() {
    super.initState();
    // initializeNotifications();
    // startIsolate();
  }




  void startIsolate() async {
    receivePort = ReceivePort();
    isolate = await Isolate.spawn(uploadDataEntryPoint, receivePort.sendPort);
    isIsolateRunning = true;
    receivePort.listen((data) {
      if (data is String) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data)),
        );
      }
    });
  }

  static void uploadDataEntryPoint(SendPort sendPort) async {
  ReceivePort port = ReceivePort();
  sendPort.send(port.sendPort);

  Timer.periodic(Duration(seconds: 10), (Timer timer) async {
    try {
      print("Uploading data____>>>>>>");

      print("Data uploaded successfully");
      sendPort.send("Data uploaded successfully");
    } catch (e) {
      sendPort.send("Failed to upload data: $e");
    }
  });
}

  void stopIsolate() {
    if (isIsolateRunning) {
      receivePort.close();
      isolate.kill(priority: Isolate.immediate);
      setState(() {
        isIsolateRunning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Isolate has been stopped')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Welcome to the Home Screen',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/register'),
            child: Text('Register'),
          ),
          ElevatedButton(
            onPressed: isIsolateRunning ? stopIsolate : null,
            child: Text('Stop Background Task'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/track'),
            child: Text('Track'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/friends'),
            child: Text('Friends'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/friendrequests'),
            child: Text('Friend Requests'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/map'),
            child: Text('Map'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/sudoku'),
            child: Text('Sudoku'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/game'),
            child: Text('Chuck Jump'),
          ),
        ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:focus/firebase_options.dart';
// import 'friends.dart';
// import 'login.dart';
// import 'track.dart';
// import 'map.dart';
// import 'package:flutter/services.dart'; 
// import 'dart:async';
// import 'dart:isolate';
// import 'package:intl/intl.dart';
// import 'storage.dart';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'login.dart';
// import 'track.dart';
// import 'firebase_options.dart';
// import 'dart:convert';
// import 'package:intl/intl.dart';


// Future<void> main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   String email = await Authentication.getEmail();
//   runApp(
//     MaterialApp(
//       initialRoute: '/',
//       routes: {
//         '/': (context) => LoginScreen(),
//         '/home': (context) =>  HomeScreen(),
//         '/register': (context) => RegisterPage(),
//        '/track': (context) => TrackPage(),
//        '/friends': (context) => FriendsPage(currentUserId: email),
//        '/friendrequests': (context) => FriendRequestsPage(currentUserId: email),
//        '/map':(context) => MapPage(),
//       },
//     ),
//   );
// }


// class HomeScreen extends StatefulWidget {
//  @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// // class MyHomePage extends StatefulWidget {
  
// // } 


// class _MyHomePageState extends State<HomeScreen> {

//   late Isolate isolate;
//   late ReceivePort receivePort;
//   bool isIsolateRunning = false;

//   @override
//   void initState() {
//     super.initState();
//     startIsolate();
//   }

//   void startIsolate() async {
//     receivePort = ReceivePort();
//     isolate = await Isolate.spawn(uploadDataEntryPoint, receivePort.sendPort);
//     isIsolateRunning = true;
//     receivePort.listen((message) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(message.toString())),
//       );
//     });
//   }

//   static void uploadDataEntryPoint(SendPort sendPort) async {
//     // WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//     ReceivePort port = ReceivePort();
//     sendPort.send(port.sendPort);
//     print("Isolate started");    
//     Timer.periodic(Duration(seconds: 10), (Timer timer) async {
//       try {
//         print("Uploading data____>>>>>>");
//         //FirebaseDatabase db = FirebaseDatabase();
//         FirebaseDatabase().uploadData("testFolder", "testMetadata", ("{'time': DateTime.now().toString()}"));
//         print("Data uploaded successfully");
//         port.sendPort.send("Data uploaded successfully");
//       } catch (e) {
//         port.sendPort.send("Failed to upload data: $e");
//       }
//     });
//   }

//   void stopIsolate() {
//     if (isIsolateRunning) {
//       receivePort.close();
//       isolate.kill(priority: Isolate.immediate);
//       setState(() {
//         isIsolateRunning = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Isolate has been stopped')),
//       );
//     }
//   }

//    @override
//   void dispose() {
//     if (isIsolateRunning) {
//       stopIsolate();  // Ensure the isolate is stopped when the widget is disposed
//     }
//     super.dispose();
//   }
  





//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title:  Text('Hello HomeScreen G'),
//       ),
//       body:  Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Welcome to the HomeScreen',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/register');
//               },
//               child: Text('Register'),
//             ),
//             ElevatedButton(
//               onPressed: isIsolateRunning ? stopIsolate : null,
//               child: Text('Stop Isolate'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/track');
//               },
//               child:  Text('Track'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/friends');
//               },
//               child:  Text('Friends'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/friendrequests');
//               },
//               child:  Text('Friend Requests'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/map');
//               },
//               child:  Text('Map'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // class FirebaseDatabase {
// //   Future<void> uploadData(String folder, String metadata, dynamic data) async {
// //     String fileName = '$folder/$metadata.json';
// //     Reference ref = FirebaseStorage.instance.ref().child(fileName);
// //     try {
// //       await ref.putString(data);
// //       print("Upload successful");
// //     } catch (e) {
// //       print("Error uploading file: $e");
// //       throw e;  // Rethrowing the exception to the caller
// //     }
// //   }

// //   Future<String> downloadData(String folder, String metadata) async {
// //     String fileName = '$folder/$metadata.json';
// //     try {
// //       Reference ref = FirebaseStorage.instance.ref().child(fileName);
// //       const maxSize = 10 * 1024 * 1024;  // 10 MB max file size
// //       final bytes = await ref.getData(maxSize);
// //       final stringData = String.fromCharCodes(bytes!);
// //       return stringData;
// //     } catch (e) {
// //       print("Error downloading file: $e");
// //       throw e;
// //     }
// //   }

// //   Future<void> deleteData(String metadata) async {
// //     String fileName = '$metadata.json';
// //     try {
// //       Reference ref = FirebaseStorage.instance.ref().child(fileName);
// //       await ref.delete();
// //       print("Delete successful");
// //     } catch (e) {
// //       print("Error deleting file: $e");
// //       throw e;
// //     }
// //   }

// //   Future<String> getDownloadURL(String metadata) async {
// //     String fileName = '$metadata.json';
// //     try {
// //       Reference ref = FirebaseStorage.instance.ref().child(fileName);
// //       String downloadURL = await ref.getDownloadURL();
// //       return downloadURL;
// //     } catch (e) {
// //       print("Error getting download URL: $e");
// //       throw e;
// //     }
// //   }
// // }



// // class HomeScreen extends StatelessWidget {
// //   const HomeScreen({super.key});

// //   // This widget is the root of your application.
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Flutter Demo',
// //       theme: ThemeData(
// //         // This is the theme of your application.
// //         //
// //         // TRY THIS: Try running your application with "flutter run". You'll see
// //         // the application has a purple toolbar. Then, without quitting the app,
// //         // try changing the seedColor in the colorScheme below to Colors.green
// //         // and then invoke "hot reload" (save your changes or press the "hot
// //         // reload" button in a Flutter-supported IDE, or press "r" if you used
// //         // the command line to start the app).
// //         //
// //         // Notice that the counter didn't reset back to zero; the application
// //         // state is not lost during the reload. To reset the state, use hot
// //         // restart instead.
// //         //
// //         // This works for code too, not just values: Most code changes can be
// //         // tested with just a hot reload.
// //         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
// //         useMaterial3: true,
// //       ),
// //       home: const MyHomePage(title: 'Flutter Demo Home Page'),
// //     );
// //   }
// // }

// // class MyHomePage extends StatefulWidget {
// //   const MyHomePage({super.key, required this.title});

// //   // This widget is the home page of your application. It is stateful, meaning
// //   // that it has a State object (defined below) that contains fields that affect
// //   // how it looks.

// //   // This class is the configuration for the state. It holds the values (in this
// //   // case the title) provided by the parent (in this case the App widget) and
// //   // used by the build method of the State. Fields in a Widget subclass are
// //   // always marked "final".

// //   final String title;

// //   @override
// //   State<MyHomePage> createState() => _MyHomePageState();
// // }

// // class _MyHomePageState extends State<MyHomePage> {
// //   int _counter = 0;

// //   void _incrementCounter() {
// //     setState(() {
// //       // This call to setState tells the Flutter framework that something has
// //       // changed in this State, which causes it to rerun the build method below
// //       // so that the display can reflect the updated values. If we changed
// //       // _counter without calling setState(), then the build method would not be
// //       // called again, and so nothing would appear to happen.
// //       _counter++;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // This method is rerun every time setState is called, for instance as done
// //     // by the _incrementCounter method above.
// //     //
// //     // The Flutter framework has been optimized to make rerunning build methods
// //     // fast, so that you can just rebuild anything that needs updating rather
// //     // than having to individually change instances of widgets.
// //     return Scaffold(
// //       appBar: AppBar(
// //         // TRY THIS: Try changing the color here to a specific color (to
// //         // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
// //         // change color while the other colors stay the same.
// //         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
// //         // Here we take the value from the MyHomePage object that was created by
// //         // the App.build method, and use it to set our appbar title.
// //         title: Text(widget.title),
// //       ),
// //       body: Center(
// //         // Center is a layout widget. It takes a single child and positions it
// //         // in the middle of the parent.
// //         child: Column(
// //           // Column is also a layout widget. It takes a list of children and
// //           // arranges them vertically. By default, it sizes itself to fit its
// //           // children horizontally, and tries to be as tall as its parent.
// //           //
// //           // Column has various properties to control how it sizes itself and
// //           // how it positions its children. Here we use mainAxisAlignment to
// //           // center the children vertically; the main axis here is the vertical
// //           // axis because Columns are vertical (the cross axis would be
// //           // horizontal).
// //           //
// //           // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
// //           // action in the IDE, or press "p" in the console), to see the
// //           // wireframe for each widget.
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: <Widget>[
// //             const Text(
// //               'You have pushed the button this many times:',
// //             ),
// //             Text(
// //               '$_counter',
// //               style: Theme.of(context).textTheme.headlineMedium,
// //             ),
// //           ],
// //         ),
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: _incrementCounter,
// //         tooltip: 'Increment',
// //         child: const Icon(Icons.add),
// //       ), // This trailing comma makes auto-formatting nicer for build methods.
// //     );
// //   }
// // }
