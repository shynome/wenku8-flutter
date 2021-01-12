import 'package:wenku8/wenku8/utils.dart';
import 'package:test/test.dart';

void main() {
  group("wenku8 utils", () {
    test("getLink", () async {
      var a = await getLink("1861");
      expect(a, "https://www.wenku8.net/novel/1/1861/index.htm");
    });
    test("getChaptersVol", () async {
      var book = await getChaptersVol(
          "https://www.wenku8.net/novel/1/1861/index.htm", "1861");
      // expect(book, null);
      return;
    });
    test("getChapterContent", () async {
      var content = await getChapterContent("1861", "65288");
      return;
    });
    test("getChapterContent delimiter", () async {
      var content = await getChapterContent("1861", "65288");
      var s = content.split(delimiter);
      return;
    });
  });
}
