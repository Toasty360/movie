import 'package:flutter/material.dart';
import 'package:movie/components/watch_btn.dart';

class LogoSection extends StatelessWidget {
  final String logo;
  final int id;
  final String type;
  final String popularity;
  final String title;

  const LogoSection(
      {super.key,
      required this.logo,
      required this.id,
      required this.type,
      required this.popularity,
      required this.title});

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Positioned(
        bottom: 100,
        left: screen.width > 700 ? 20 : screen.width * 0.2,
        child: Column(
          children: [
            logo.isNotEmpty
                ? ConstrainedBox(
                    constraints: MediaQuery.of(context).size.width > 400
                        ? const BoxConstraints(maxWidth: 300, maxHeight: 200)
                        : const BoxConstraints(maxWidth: 200, maxHeight: 100),
                    child: Image.network(logo),
                  )
                : const Center(),
            Container(
              margin: const EdgeInsets.only(top: 20),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.1)),
                    child: Text(
                      id.toString(),
                      style: const TextStyle(color: Colors.purple),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: Colors.white.withOpacity(0.1)),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.white.withOpacity(0.1)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.local_fire_department_outlined,
                            color: Colors.red,
                          ),
                          Text(
                            "${popularity.split(".").first}K",
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            WatchBtn(id: id, title: title, isMovie: type.toLowerCase() != "tv")
          ],
        ));
  }
}
