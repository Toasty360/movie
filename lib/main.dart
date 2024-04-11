import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:movie/model/model.dart';
import 'package:movie/services/tmdb.dart';
import 'package:toast/toast.dart';

import 'details.dart';

void main() {
  Future<List<HomeData>> trending = TMDB.fetchTopRated();
  MediaKit.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Moviemate',
    darkTheme: ThemeData.dark(useMaterial3: true),
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: Home(data: trending),
  ));
}

class Home extends StatefulWidget {
  final Future<List<HomeData>> data;
  const Home({super.key, required this.data});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<HomeData> trending = [];
  @override
  void initState() {
    ToastContext().init(context);
    super.initState();
    widget.data.then((value) {
      setState(() => trending = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Container(
              alignment: Alignment.center,
              width: screen.width,
              height: screen.height,
              child: ListView(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  physics: const ClampingScrollPhysics(),
                  children: trending.isNotEmpty
                      ? [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 25),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
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
                          ),
                          myGrid(trending, screen, context)
                        ]
                      : [const Center(child: CircularProgressIndicator())]))),
    );
  }
}

mysnack(Future<List<HomeData>> fuData, BuildContext context) {
  Size screen = MediaQuery.of(context).size;
  return showModalBottomSheet(
    elevation: 0,
    isScrollControlled: true,
    backgroundColor: Colors.black,
    enableDrag: true,
    isDismissible: true,
    useSafeArea: true,
    barrierColor: Colors.transparent,
    showDragHandle: true,
    shape: const BeveledRectangleBorder(),
    context: context,
    builder: (context) => FutureBuilder(
      future: fuData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<HomeData> data = snapshot.data!;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) => InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(data: data[index]),
                        )),
                    child: Container(
                      width: screen.width,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 5),
                      height: 180,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromARGB(225, 31, 33, 35)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            height: 150,
                            width: 120,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: ExtendedNetworkImageProvider(
                                        data[index].image))),
                          ),
                          Container(
                            width: screen.width * 0.5,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    data[index].title,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    data[index].type,
                                    textAlign: TextAlign.center,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 212, 212, 216),
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: Text(
                                      data[index].releaseDate,
                                      textAlign: TextAlign.center,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  )
                                ]),
                          )
                        ],
                      ),
                    ),
                  ));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}

myGrid(
  List<HomeData> data,
  Size screen,
  BuildContext context,
) {
  return GridView(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    shrinkWrap: true,
    physics: const ClampingScrollPhysics(),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: max(2, screen.width ~/ 200),
        mainAxisSpacing: 15,
        mainAxisExtent: 250,
        crossAxisSpacing: 10),
    children: data.map((e) => cards(context, e)).toList().cast<Widget>(),
  );
}

cards(BuildContext context, HomeData item) {
  return InkWell(
    onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (ctx) => DetailsPage(data: item))),
    child: Container(
      width: 175,
      padding: const EdgeInsets.only(left: 10),
      child: Stack(children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: ExtendedNetworkImageProvider(item.image,
                    cache: true, cacheKey: item.title),
                fit: BoxFit.cover,
              )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          alignment: Alignment.bottomCenter,
          height: double.maxFinite,
          width: double.maxFinite,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(16, 0, 0, 0),
                    Color.fromARGB(189, 0, 0, 0),
                  ])),
          child: Text(
            item.title,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
      ]),
    ),
  );
}
