import 'package:flutter/material.dart';


class LevelsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 10,
        children: List.generate(100, (index) {
          return ElevatedButton(
            onPressed: () {
              // Handle button press
            },
            child: Text('Button ${index + 1}'),
          );
        }),
      ),
    );
  }
}