import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movie/pages/media.dart';
import 'package:movie/services/tmdb.dart';
import 'model/model.dart';

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
  // String hdrezkaId = "";
  // String hdrezkaURL = "";
  late Movie info;

  @override
  void initState() {
    super.initState();
    // getIds(widget.data.title, widget.data.releaseDate, widget.data.type)
    //     .then((value) {
    //   hdrezkaId = value["id"];
    //   hdrezkaURL = value["url"];
    //   print(hdrezkaId);
    //   setState(() {});
    // });
    data = widget.data;
    try {
      TMDB
          .fetchMovieDetails(data.id, data.type.toLowerCase() == "tv")
          .then((value) {
        if (value != "") {
          info = value;
          isFetched = true;
        } else {
          gotError = true;
        }
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
    return Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox(
          height: screen.height,
          child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              children: [
                //Top container
                SizedBox(
                  height: 300,
                  child: Stack(
                    children: [
                      //cover
                      Container(
                        width: screen.width,
                        height: 250,
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
                        height: 250,
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                              Color.fromARGB(89, 0, 0, 0),
                              Colors.black
                            ])),
                      ),

                      //image
                      Positioned(
                          bottom: 0,
                          left: screen.width * 0.3,
                          child: Hero(
                            tag: data.id,
                            child: Container(
                              height: 200,
                              width: 130,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                      image: NetworkImage(data.image),
                                      fit: BoxFit.cover)),
                            ),
                          )),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       vertical: 4, horizontal: 6),
                      //   decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(4),
                      //       color: const Color.fromARGB(255, 12, 14, 17)),
                      //   child: Text(
                      //     hdrezkaId,
                      //     style: const TextStyle(color: Colors.purple),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color.fromARGB(255, 12, 14, 17)),
                        child: Text(
                          data.type.toUpperCase(),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: const Color.fromARGB(255, 12, 14, 17)),
                        child: Text(
                          data.popularity,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      ),
                    ],
                  ),
                ),

                isFetched
                    ? Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Text(
                          info.releaseDate ?? "No ETA",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                      )
                    : const Center(),
                isFetched
                    ? Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Text(
                          info.geners.runtimeType != Null
                              ? info.geners!.join(", ")
                              : "Nil",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white54),
                        ),
                      )
                    : const Center(),
                //desc
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: const Text(
                    "Description",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                      data.description != ""
                          ? data.description
                          : isFetched
                              ? info.description!
                              : "",
                      softWrap: true,
                      textAlign: TextAlign.justify),
                ),
                //eps
                data.type != "movie"
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

                isFetched
                    ? data.type.toLowerCase() != "movie"
                        ? ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            children: [
                              info.seasons!.length > 1
                                  ? SizedBox(
                                      height: 100,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        physics: const ClampingScrollPhysics(),
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
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
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
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 25,
                                                        color: Color.fromARGB(
                                                            142, 0, 0, 0)),
                                                  )),
                                            ),
                                          );
                                        },
                                      ),
                                    )
                                  : const Center(),
                              Container(
                                margin: const EdgeInsets.only(top: 10),
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
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  scrollDirection: Axis.vertical,
                                  physics: const ClampingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: info
                                      .seasons![activeSeason].episodes?.length,
                                  itemBuilder: (context, index) {
                                    Episode temp = info.seasons![activeSeason]
                                        .episodes![index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MediaPlayer(
                                                        episode: temp
                                                          ..id = data.id)));
                                      },
                                      child: epsCard(temp.title!, temp.image!),
                                    );
                                  },
                                ),
                              )
                            ],
                          )
                        : InkWell(
                            onTap: () {
                              // fetchByBruteForce(hdrezkaURL).then((value) {
                              //   print(value);
                              // });
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MediaPlayer(
                                          episode: Episode(
                                              type: "movie",
                                              id: widget.data.id,
                                              title: data.title))));
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 20),
                              alignment: Alignment.center,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromARGB(255, 12, 14, 17),
                              ),
                              child: const Text(
                                "Watch now!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey),
                              ),
                            ),
                          )
                    : Container(
                        margin: const EdgeInsets.only(top: 30),
                        alignment: Alignment.center,
                        child: gotError
                            ? const Center(
                                child: Text("No Data yet"),
                              )
                            : const CircularProgressIndicator(),
                      )
              ]),
        ));
  }
}

epsCard(String txt, String img) {
  return Container(
    alignment: Alignment.center,
    height: 100,
    width: 300,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    margin: const EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(31, 27, 36, 0),
              Color.fromRGBO(31, 27, 36, 1),
            ]),
        image: img != ""
            ? DecorationImage(
                image: NetworkImage(img),
                fit: BoxFit.cover,
                opacity: 0.8,
              )
            : null),
    child: Text(txt,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.white70)),
  );
}
