import 'package:flutter/material.dart';
import 'package:movie/components/big_guy.dart';
import 'package:movie/components/heading.dart';
import 'package:movie/components/grid.dart';
import 'package:movie/components/menu.dart';
import 'package:movie/model/model.dart';
import 'package:movie/services/tmdb.dart';
import 'package:toast/toast.dart';

class Home extends StatefulWidget {
  final Future<List<HomeData>> data;
  const Home({super.key, required this.data});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<HomeData> trending = [];
  late HomeData focusedItem;
  String logo = "";
  @override
  void initState() {
    ToastContext().init(context);
    super.initState();
    widget.data.then((value) async {
      setState(() {
        trending = value;
        focusedItem = trending.first;
      });

      for (var item in value) {
        logo = await TMDB.getLogo(item.id, item.type.toLowerCase() == "tv");
        if (logo.isNotEmpty) {
          setState(() => focusedItem = item);
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.black,
        drawer: const ShowDrawer(),
        floatingActionButton: const MenuButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
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
                        BigGuy(focusedItem: focusedItem, logo: logo),
                        const Heading("Trending"),
                        MyGrid(trending)
                      ]
                    : [const Center(child: CircularProgressIndicator())])));
  }
}

// Container(
//   padding: const EdgeInsets.only(left: 10, top: 30),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.end,
//     children: [
//       IconButton(
//         icon: const Icon(Icons.person),
//         onPressed: () {
//           Navigator.push(
//               context,
//               MaterialPageRoute(
//                   builder: (context) =>
//                       const Profile()));
//         },
//       )
//     ],
//   ),
// ),
