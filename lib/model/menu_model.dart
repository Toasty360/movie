import 'package:flutter/material.dart';

class Menu {
  String name;
  IconData icon;
  Menu({required this.name, required this.icon});
}

List<Menu> menuData = [
  Menu(name: 'Home', icon: Icons.home),
  Menu(name: 'Profile', icon: Icons.person),
  Menu(name: "Trending", icon: Icons.local_fire_department_sharp),
  Menu(name: "WatchList", icon: Icons.bookmark),
  Menu(name: 'Settings', icon: Icons.settings),
  Menu(name: 'Logout', icon: Icons.exit_to_app)
];
