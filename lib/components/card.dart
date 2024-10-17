import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:movie/model/model.dart';
import 'package:movie/pages/details.dart';

cards(BuildContext context, Movie item) {
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
                image: ExtendedNetworkImageProvider(item.image!, cache: true),
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
            item.title!,
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
