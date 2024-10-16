import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie/components/watch_btn.dart';
import 'package:movie/pages/media.dart';
import 'package:movie/services/tmdb.dart';
import '../model/model.dart';

class DetailsPage extends StatefulWidget {
  final HomeData data;

  const DetailsPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late HomeData data;
  bool gotError = false;
  bool isFetched = false;
  int activeSeason = 0;
  bool isTv = false;
  late Movie info;
  late Future<String> futureLogo;

  @override
  void initState() {
    super.initState();
    data = widget.data;
    print(data.type.toLowerCase());
    isTv = data.type.toLowerCase() == "tv";
    futureLogo = TMDB.getLogo(data.id, isTv);
    try {
      TMDB.fetchMovieDetails(data.id, isTv).then((value) async {
        info = value;
        isFetched = true;
        info.logo = (await futureLogo).trim();
        print("logo: ${info.logo!} ${info.logo!.isNotEmpty}");
        setState(() {});
      });
    } catch (e) {
      setState(() {});
      print("got error: ");
      gotError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.escape): () {
          Navigator.pop(context);
        }
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
            floatingActionButton: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            backgroundColor: Colors.black,
            body: ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                children: [
                  Stack(
                    children: [
                      //cover
                      Container(
                        width: screen.width,
                        height: screen.height,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(isFetched
                                    ? info.cover!.contains("originalnull") ||
                                            info.cover!
                                                .contains("originalundefined")
                                        ? data.image
                                        : info.cover!
                                    : data.image),
                                fit: BoxFit.cover)),
                      ),
                      Container(
                        width: screen.width,
                        height: screen.height,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromARGB(89, 0, 0, 0),
                              Colors.black
                            ])),
                      ),
                      isTv
                          ? Positioned(
                              bottom: 0,
                              child: Container(
                                width: screen.width,
                                alignment: Alignment.bottomCenter,
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            )
                          : const Center(),
                      Positioned(
                          bottom: screen.height * 0.2,
                          left: screen.width > 400
                              ? 50
                              : (screen.width - 300) / 2,
                          child: SizedBox(
                            width: max(screen.width * 0.5, 300),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: screen.width > 400
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.center,
                              children: [
                                isFetched
                                    ? ConstrainedBox(
                                        constraints: screen.width > 400
                                            ? const BoxConstraints(
                                                maxWidth: 300, maxHeight: 200)
                                            : const BoxConstraints(
                                                maxWidth: 200, maxHeight: 100),
                                        child: info.logo!.isNotEmpty
                                            ? Image.network(info.logo!)
                                            : Text(
                                                info.title!,
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w900,
                                                    color:
                                                        Colors.yellow.shade600),
                                              ),
                                      )
                                    : const Center(),
                                Container(
                                  margin: const EdgeInsets.only(top: 20),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 6),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color:
                                                Colors.white.withOpacity(0.1)),
                                        child: Text(
                                          widget.data.id.toString(),
                                          style: const TextStyle(
                                              color: Colors.purple),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4, horizontal: 6),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            color:
                                                Colors.white.withOpacity(0.1)),
                                        child: Text(
                                          data.type.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white54),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 6),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Icon(
                                                Icons
                                                    .local_fire_department_outlined,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                "${data.popularity.split(".").first}K",
                                                style: const TextStyle(
                                                    color: Colors.white54),
                                              ),
                                            ],
                                          )),
                                    ],
                                  ),
                                ),
                                isFetched
                                    ? Container(
                                        alignment: Alignment.bottomLeft,
                                        margin: const EdgeInsets.only(top: 10),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Text(
                                          info.geners?.join(", ") ?? "Unknown",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white54),
                                        ),
                                      )
                                    : const Center(),
                                Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: Text(
                                      isFetched
                                          ? info.description!
                                          : data.description,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: screen.width > 400
                                          ? null
                                          : TextAlign.justify,
                                      softWrap: true,
                                      maxLines: 10),
                                ),
                                WatchBtn(
                                  isMovie: !isTv,
                                  id: widget.data.id,
                                  title: widget.data.title,
                                )
                              ],
                            ),
                          )),
                    ],
                  ),
                  //bottom section
                  isFetched & isTv
                      ? ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: screen.width > 400 ? 20 : 5),
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          children: [
                            info.seasons!.length > 1
                                ? Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    child: const Text(
                                      "Seasons",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey),
                                    ),
                                  )
                                : const Center(),
                            info.seasons!.length > 1
                                ? Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.1))),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 100,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const ClampingScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount: info.seasons!.length,
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
                                                  margin: const EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: index ==
                                                              activeSeason
                                                          ? Border.all(
                                                              width: 2,
                                                              color: Colors
                                                                  .blueGrey
                                                                  .withOpacity(
                                                                      0.4))
                                                          : null,
                                                      image: DecorationImage(
                                                          image: NetworkImage(info
                                                              .seasons![index]
                                                              .image!),
                                                          fit: BoxFit.cover)),
                                                  child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10,
                                                          vertical: 5),
                                                      child: Text(
                                                        "S${info.seasons![index].season}",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 25,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.9)),
                                                      )),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        ...overview(info, activeSeason)
                                      ],
                                    ),
                                  )
                                : const Center(),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: const Text(
                                "Episodes",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey),
                              ),
                            ),
                            SizedBox(
                              width: screen.width,
                              child: GridView.builder(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisSpacing: 10,
                                        mainAxisExtent: 100,
                                        mainAxisSpacing: 10,
                                        crossAxisCount:
                                            max(1, screen.width ~/ 200)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 5),
                                scrollDirection: Axis.vertical,
                                physics: const ClampingScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: info
                                    .seasons?[activeSeason].episodes?.length,
                                itemBuilder: (context, index) {
                                  Episode temp = info
                                      .seasons![activeSeason].episodes![index];
                                  return InkWell(
                                      splashFactory: NoSplash.splashFactory,
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaPlayer(
                                                        episode: temp
                                                          ..id = data.id)));
                                      },
                                      child: Container(
                                        height: 100,
                                        alignment: Alignment.bottomCenter,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                    topRight:
                                                        Radius.circular(8)),
                                            image: DecorationImage(
                                              image: NetworkImage(temp.image!),
                                              fit: BoxFit.cover,
                                              opacity: 0.8,
                                            )),
                                        child: Text(temp.title!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14)),
                                      ));
                                },
                              ),
                            )
                          ],
                        )
                      : const Center()
                ])),
      ),
    );
  }
}

List<Widget> overview(Movie info, int activeSeason) {
  return info.seasons![activeSeason].overview.isNotEmpty
      ? [
          const SizedBox(height: 10),
          const Text(
            "Season Overview",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(info.seasons![activeSeason].overview,
              style:
                  TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)))
        ]
      : [];
}

// epsCard(String txt, String img) {
//   return Container(
//     alignment: Alignment.center,
//     margin: const EdgeInsets.only(bottom: 10),
//     decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//         color: Colors.white.withOpacity(0.1)),
//     padding: const EdgeInsets.symmetric(horizontal: 10),
//     child: Container(
//       width: 150,
//       height: 80,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           image: DecorationImage(
//             image: NetworkImage(img),
//             fit: BoxFit.cover,
//             opacity: 0.8,
//           )),
//       child: Text(txt,
//           maxLines: 3,
//           overflow: TextOverflow.ellipsis,
//           textAlign: TextAlign.center,
//           style: const TextStyle(color: Colors.white70, fontSize: 12)),
//     ),
//   );
// }
