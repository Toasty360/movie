import 'package:flutter/material.dart';
import 'package:movie/components/logoSection.dart';
import 'package:movie/model/model.dart';

class BigGuy extends StatelessWidget {
  final HomeData focusedItem;
  final String logo;
  const BigGuy({
    Key? key,
    required this.focusedItem,
    required this.logo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    return SizedBox(
      height: screen.height * 0.7,
      width: screen.width,
      child: Stack(
        children: [
          Container(
            height: screen.height * 0.69,
            width: screen.width,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(focusedItem.cover), fit: BoxFit.cover)),
          ),
          Container(
            height: screen.height * 0.70,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          ),
          if (focusedItem.runtimeType != Null)
            LogoSection(
              logo: logo,
              id: focusedItem.id,
              type: focusedItem.type,
              popularity: focusedItem.popularity,
              title: focusedItem.title,
            ),
        ],
      ),
    );
  }
}
