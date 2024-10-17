import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:movie/components/grid.dart';
import 'package:movie/components/heading.dart';
import 'package:movie/main.dart';

class Later extends StatelessWidget {
  Later({super.key});
  final watchlist = WatchList.box;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent));
    return Scaffold(
      floatingActionButton: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      backgroundColor: Colors.black,
      body: ListView(
        padding: const EdgeInsets.only(top: 100, left: 10),
        children: [
          const Heading("Watch List"),
          ValueListenableBuilder(
            valueListenable: watchlist.listenable(),
            builder: (context, value, child) {
              var items = value.values.toList();
              return MyGrid(items);
            },
          )
        ],
      ),
    );
  }
}
