// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:movie/components/task.dart';

import 'package:movie/model/menu_model.dart';
import 'package:movie/model/model.dart';

class MenuButton extends StatelessWidget {
  const MenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
        icon: const Icon(Icons.menu));
  }
}

class ShowDrawer extends StatefulWidget {
  const ShowDrawer({super.key});

  @override
  State<ShowDrawer> createState() => ShowDrawerState();
}

class ShowDrawerState extends State<ShowDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.7),
      width: 200,
      child: Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ...menuData.map((e) => MenuItem(item: e)).toList().cast<Widget>(),
          TextButton(
              onPressed: () {
                showTaskDialog(Episode(id: 1724, type: "movie"), context);
              },
              child: const Text("test")),
        ]),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  final Menu item;
  const MenuItem({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        mouseCursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(item.icon),
              const SizedBox(
                width: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(item.name),
              ),
            ],
          ),
        ));
  }
}
