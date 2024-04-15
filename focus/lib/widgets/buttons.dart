import 'package:flutter/material.dart';

class MainMenuRoundedButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const MainMenuRoundedButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(text),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color, // Background color
        foregroundColor: Colors.white, // Text and icon color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Button padding
        textStyle: TextStyle(fontSize: 16),
      ),
    );
  }
}
