import 'package:flutter/material.dart';

class ShowDrawer extends StatefulWidget {
  const ShowDrawer({super.key});

  @override
  State<ShowDrawer> createState() => ShowDrawerState();
}

class ShowDrawerState extends State<ShowDrawer> {
  @override
  Widget build(BuildContext context) {
    return const Drawer(
      child: Text("f"),
    );
  }
}
