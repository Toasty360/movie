import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movie/components/watch_btn.dart';

class LogoSection extends StatelessWidget {
  final String logo;
  final int id;
  final String type;
  final String popularity;
  final String description;
  final String title;
  final int? maxLines;
  final Widget? addOn;

  const LogoSection(
      {super.key,
      required this.logo,
      required this.id,
      required this.type,
      required this.popularity,
      required this.title,
      required this.description,
      this.maxLines,
      this.addOn});

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Positioned(
        bottom: 50,
        left: screen.width > 700 ? 20 : screen.width * 0.1,
        child: Center(
          child: SizedBox(
            width: min(400, screen.width * 0.8),
            child: Column(
              crossAxisAlignment: screen.width > 700
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                logo.isNotEmpty
                    ? ConstrainedBox(
                        constraints: MediaQuery.of(context).size.width > 400
                            ? const BoxConstraints(
                                maxWidth: 300, maxHeight: 200)
                            : const BoxConstraints(
                                maxWidth: 200, maxHeight: 100),
                        child:
                            logo.isNotEmpty ? Image.network(logo) : Text(title),
                      )
                    : const Center(),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Wrap(
                    runSpacing: 10,
                    alignment: screen.width > 700
                        ? WrapAlignment.start
                        : WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(0.1)),
                        child: SelectableText(id.toString(),
                            style: const TextStyle(color: Colors.purple)),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: Colors.white.withOpacity(0.1)),
                        child: Text(
                          type.toUpperCase(),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                          width: 80,
                          padding: const EdgeInsets.symmetric(
                              vertical: 2, horizontal: 6),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: Colors.white.withOpacity(0.1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Icon(
                                Icons.local_fire_department_outlined,
                                color: Colors.red,
                              ),
                              Text(
                                "${popularity.split(".").first}K",
                                style: const TextStyle(color: Colors.white54),
                              ),
                            ],
                          )),
                      addOn ?? const Center()
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  child: Text(description,
                      overflow: TextOverflow.ellipsis,
                      textAlign: screen.width > 400 ? null : TextAlign.justify,
                      softWrap: true,
                      maxLines: maxLines ?? 10),
                ),
                WatchBtn(
                    id: id, title: title, isMovie: type.toLowerCase() != "tv")
              ],
            ),
          ),
        ));
  }
}
