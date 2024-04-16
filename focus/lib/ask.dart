import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextRoundedBox extends StatelessWidget {
  final String text;
  final Color color;
  final int height;
  final int width;
  final VoidCallback onPressed;

  const TextRoundedBox({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.height,
    required this.width,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: TextStyle(fontSize: 16),
        fixedSize: Size(width.toDouble(), height.toDouble()),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  //   return ElevatedButton(
  //     child: Text(text),
  //     onPressed: onPressed,
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: color,
  //       foregroundColor: Colors.white,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(30.0),
  //       ),
  //       padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //       textStyle: TextStyle(fontSize: 16),
  //     ),
  //   );
  // }
}

// class AskPage extends StatefulWidget{
//   //stateful widget
  
//   @override
//   _AskPageState createState() => _AskPageState();

// }

// class _AskPageState extends State<AskPage> {
//   //stateful widget
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ask a Question'),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextFormField(
//               decoration: InputDecoration(
//                 labelText: 'Enter your question',
//               ),
//               keyboardType: TextInputType.text,
//             ),
//             SizedBox(height: 20),
//             TextRoundedBox(
//               text: 'Submit',
//               color: Colors.blue,
//               onPressed: () {