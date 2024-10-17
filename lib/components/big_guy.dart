import 'package:flutter/material.dart';
import 'package:movie/components/logoSection.dart';
import 'package:movie/model/model.dart';
import 'package:movie/pages/details.dart';

class BigGuy extends StatelessWidget {
  final Movie focusedItem;
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
                    image: NetworkImage(focusedItem.cover!),
                    fit: BoxFit.cover)),
          ),
          Container(
            height: screen.height * 0.70,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black],
                    stops: [0.4, 0.9],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)),
          ),
          if (focusedItem.runtimeType != Null)
            LogoSection(
              logo: logo,
              id: int.parse(focusedItem.id),
              description: focusedItem.description!,
              maxLines: 2,
              type: focusedItem.type!,
              popularity: focusedItem.rating!,
              title: focusedItem.title!,
              addOn: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsPage(data: focusedItem),
                    )),
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  height: 28,
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withOpacity(0.1)),
                  child: const Text("Show Details", style: TextStyle()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
