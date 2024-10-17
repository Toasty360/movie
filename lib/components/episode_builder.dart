// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:movie/model/model.dart';
import 'package:movie/pages/media.dart';

class Episodeviewer extends StatelessWidget {
  final List<Episode> episodes;
  final int id;
  const Episodeviewer({
    Key? key,
    required this.episodes,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return SizedBox(
      width: screen.width,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 10,
            mainAxisExtent: 100,
            mainAxisSpacing: 10,
            crossAxisCount: max(1, screen.width ~/ 200)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        itemCount: episodes.length,
        itemBuilder: (context, index) {
          Episode temp = episodes[index];
          return InkWell(
              splashFactory: NoSplash.splashFactory,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MediaPlayer(episode: temp..id = id)));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Stack(
                  children: [
                    Container(
                      height: 100,
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(temp.image!),
                            fit: BoxFit.cover,
                            opacity: 0.8,
                          )),
                    ),
                    Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                                colors: [Colors.transparent, Colors.black],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter)),
                        child: Text(temp.title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14))),
                  ],
                ),
              ));
        },
      ),
    );
  }
}
