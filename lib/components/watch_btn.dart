// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:movie/model/model.dart';
import 'package:movie/pages/media.dart';

class WatchBtn extends StatelessWidget {
  final bool isMovie;
  final int id;
  final String title;
  const WatchBtn({
    Key? key,
    required this.isMovie,
    required this.id,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isMovie
        ? InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MediaPlayer(
                          episode:
                              Episode(type: "movie", id: id, title: title))));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              width: 200,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Text(
                "Watch now!",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.blueGrey),
              ),
            ),
          )
        : const Center();
  }
}
