import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie/components/season_builder.dart';
import 'package:movie/components/watch_btn.dart';
import 'package:movie/main.dart';
import 'package:movie/services/tmdb.dart';
import 'package:toast/toast.dart';
import '../model/model.dart';

class DetailsPage extends StatefulWidget {
  final Movie data;

  const DetailsPage({
    super.key,
    required this.data,
  });

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool gotError = false;
  bool isFetched = false;
  bool isTv = false;
  late Movie info;
  late Future<String> futureLogo;
  var watchlist = WatchList.box;
  bool isSaved = false;

  randomShitInit() async {
    futureLogo = TMDB.getLogo(int.parse(info.id), isTv);
    try {
      await TMDB
          .fetchMovieDetails(int.parse(info.id), isTv)
          .then((value) async {
        info = Movie.mergeMovie(info, value);
        isFetched = true;
        info.logo = (await futureLogo).trim();
        setState(() {});
      });
    } catch (e) {
      setState(() {});
      gotError = true;
    }
  }

  randomShitInit2() {
    setState(() {
      isSaved = watchlist.containsKey(widget.data.id);
    });
  }

  @override
  void initState() {
    super.initState();
    info = widget.data;
    isTv = info.type?.toLowerCase() == "tv";
    randomShitInit();
    randomShitInit2();
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
      child: SafeArea(
        bottom: true,
        top: false,
        child: Focus(
          autofocus: true,
          child: Scaffold(
              floatingActionButton: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: () {
                        if (isFetched) {
                          if (isSaved) {
                            watchlist.delete(info.id);
                            setState(() {});
                            isSaved = false;
                          } else {
                            watchlist.put(info.id, info);
                            setState(() {});
                            isSaved = true;
                          }
                          Toast.show(isSaved ? "Item added" : "Item deleted");
                        }
                      },
                      icon: Icon(
                        Icons.book,
                        color: isSaved
                            ? Colors.purple.withOpacity(0.8)
                            : Colors.white.withOpacity(0.8),
                      )),
                  const SizedBox(
                    width: 20,
                  ),
                ],
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.startTop,
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
                                          ? info.image!
                                          : info.cover!
                                      : info.image!),
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
                                  if (isFetched)
                                    ...showLogoOrTitle(info.logo, info.title!,
                                        info.image!, screen),
                                  Container(
                                    margin: const EdgeInsets.only(top: 20),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4, horizontal: 6),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              color: Colors.white
                                                  .withOpacity(0.1)),
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
                                              color: Colors.white
                                                  .withOpacity(0.1)),
                                          child: Text(
                                            isFetched
                                                ? info.type?.toUpperCase() ?? ""
                                                : widget.data.type
                                                        ?.toLowerCase() ??
                                                    "",
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
                                                  "${info.rating}K",
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
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          child: Text(
                                            info.geners?.join(", ") ??
                                                "Unknown",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white54),
                                          ),
                                        )
                                      : const Center(),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Text(info.description ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: screen.width > 400
                                            ? null
                                            : TextAlign.justify,
                                        softWrap: true,
                                        maxLines: 10),
                                  ),
                                  WatchBtn(
                                    isMovie: !isTv,
                                    id: int.parse(widget.data.id),
                                    title: widget.data.title!,
                                  )
                                ],
                              ),
                            )),
                      ],
                    ),
                    //bottom section
                    if (isFetched & isTv)
                      SeasonViewer(
                        id: int.parse(info.id),
                        seasons: info.seasons ?? [],
                      )
                  ])),
        ),
      ),
    );
  }
}

List<Widget> showLogoOrTitle(
    String? logo, String title, String poster, Size screen) {
  if (logo!.isNotEmpty) {
    return [
      ConstrainedBox(
        constraints: screen.width > 400
            ? const BoxConstraints(maxWidth: 300, maxHeight: 200)
            : const BoxConstraints(maxWidth: 200, maxHeight: 100),
        child: logo.isNotEmpty
            ? Image.network(logo)
            : Text(
                title,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.yellow.shade600),
              ),
      )
    ];
  } else {
    return [
      Container(
        width: 150,
        height: 200,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            image: DecorationImage(
                image: NetworkImage(poster), fit: BoxFit.cover)),
      ),
      Text(
        title,
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.yellow.shade600),
      ),
    ];
  }
}
