import 'package:flutter/material.dart';
import 'package:movie/components/snackbar.dart';
import 'package:movie/services/tmdb.dart';

class MySearchBar extends StatelessWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 12, 14, 17),
          borderRadius: BorderRadius.circular(50)),
      child: TextField(
          onSubmitted: (value) {
            mysnack(TMDB.fetchSearchData(value), context);
          },
          decoration: const InputDecoration(
              hintText: "Search",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search))),
    );
  }
}
