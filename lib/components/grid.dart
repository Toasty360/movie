import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movie/components/card.dart';
import 'package:movie/model/model.dart';

class MyGrid extends StatelessWidget {
  final List<HomeData> data;
  const MyGrid(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: max(2, MediaQuery.of(context).size.width ~/ 200),
          mainAxisSpacing: 15,
          mainAxisExtent: 250,
          crossAxisSpacing: 10),
      children: data.map((e) => cards(context, e)).toList().cast<Widget>(),
    );
  }
}
