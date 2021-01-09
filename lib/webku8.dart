class Book {
  /// 如 `https://www.wenku8.net/novel/1/1861/index.htm` 中的 `1861`
  String bid;

  /// 书名
  String name;

  List<ChaptersVol> chaptersVols;
}

class ChaptersVol {
  /// 如: 第四卷, 外传 xxx
  String name;

  /// 排序
  int order;

  /// 章节
  List<Chapter> chapters;

  ChaptersVol(this.name, this.chapters);
}

class Chapter {
  /// 小章节名, 如: 序章 『开始的余温』
  String name;

  /// 章节 id 用以获取内容
  String cid;

  int order;

  Chapter(this.name, this.cid, this.order);
}
