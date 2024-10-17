import 'package:flutter/material.dart';
import 'package:movie/model/model.dart';

import 'episode_builder.dart';

class SeasonViewer extends StatefulWidget {
  final List<Seasons> seasons;
  final int id;
  const SeasonViewer({super.key, required this.seasons, required this.id});

  @override
  State<SeasonViewer> createState() => _SeasonViewerState();
}

class _SeasonViewerState extends State<SeasonViewer> {
  int activeSeason = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        children: [
          if (widget.seasons.length > 1)
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: const Text(
                "Seasons",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey),
              ),
            ),
          if (widget.seasons.length > 1)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.seasons.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            if (activeSeason != index) {
                              activeSeason = index;
                              setState(() {});
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 100,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: index == activeSeason
                                    ? Border.all(
                                        width: 2,
                                        color: Colors.blueGrey.withOpacity(0.4))
                                    : null,
                                image: DecorationImage(
                                    image: NetworkImage(
                                        widget.seasons[index].image!),
                                    fit: BoxFit.cover)),
                            child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Text(
                                  "S${widget.seasons[index].season}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.white.withOpacity(0.9)),
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                  ...overview(widget.seasons[activeSeason])
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              "Episodes",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
          ),
          Episodeviewer(
            episodes: widget.seasons[activeSeason].episodes!,
            id: widget.id,
          )
        ]);
  }
}

List<Widget> overview(Seasons season) {
  return season.overview.isNotEmpty
      ? [
          const SizedBox(height: 10),
          const Text(
            "Season Overview",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(season.overview,
              style:
                  TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)))
        ]
      : [];
}
