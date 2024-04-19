import 'package:flutter/material.dart';


class InfoRow extends StatelessWidget {
  final Map<String,String> info;
  const InfoRow({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      constraints: const BoxConstraints(maxWidth: 400),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: info.entries.map((entry) => _singleItem(context, entry.key, entry.value)).toList(),
      ),
    );
  }

  Widget _singleItem(BuildContext context, String key, String value) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            key,
            style: const TextStyle(color: Color.fromARGB(255, 71, 71, 71)),
          )
        ],
      );
}