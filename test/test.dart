import 'package:movie/services/vidlink.dart';
import 'package:movie/services/vidsrcNet.dart';
import 'package:test/test.dart';

void main() {
  test("vidlink testing", () async {
    var data = await VidsrcNet().getSource(141723, true);
    print(data.src);
  });
}
