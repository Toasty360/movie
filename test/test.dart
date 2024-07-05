import 'package:html/parser.dart';
import 'package:movie/services/extractor.dart';
import 'package:test/test.dart';

void main() {
  test("info test", () async {
    await dio
        .get("https://hdrezka.me/search/?do=search&subaction=search&q=boys")
        .then((value) async {
      print("hello");
      final doc = parse(await value.data);
      doc.querySelectorAll(".b-content__inline_item").map((e) {
        print(e.text);
      });
    });
  });
}
