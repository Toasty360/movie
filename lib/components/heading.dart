import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String title;
  const Heading(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 5,
            height: 20,
            decoration: BoxDecoration(
                color: Colors.red, borderRadius: BorderRadius.circular(1)),
          ),
          const SizedBox(width: 5),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }
}
