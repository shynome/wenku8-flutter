class Book {
  static const TableName = "books";

  /// 如 `https://www.wenku8.net/novel/1/1861/index.htm` 中的 `1861`
  int bid;

  /// 书名
  String name;

  List<ChaptersVol> chaptersVols;

  Book({
    this.bid,
    this.name,
    this.chaptersVols,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "bid": bid,
      "name": name,
    };
    return map;
  }

  Book.fromMap(Map<String, dynamic> map) {
    bid = map["bid"];
    name = map["name"];
  }
}

class ChaptersVol {
  static const TableName = "chapters_vols";
  int vid;
  int bid;

  /// 如: 第四卷, 外传 xxx
  String name;

  /// 排序
  int order;

  /// 章节
  List<Chapter> chapters;

  ChaptersVol({
    this.vid,
    this.bid,
    this.name,
    this.chapters,
    this.order,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "bid": bid,
      "order": order,
      "name": name,
    };
    if (vid != null) {
      map["vid"] = vid;
    }
    return map;
  }

  ChaptersVol.fromMap(Map<String, dynamic> map) {
    vid = map["vid"];
    bid = map["bid"];
    order = map["order"];
    name = map["name"];
  }
}

class Chapter {
  static const TableName = "chapters";

  int cid;
  int bid;
  int vid;

  /// 小章节名, 如: 序章 『开始的余温』
  String name;
  String content;
  int order;
  Chapter({
    this.cid,
    this.bid,
    this.vid,
    this.name,
    this.content,
    this.order,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "bid": bid,
      "vid": vid,
      "order": order,
      "name": name,
      "content": content,
    };
    if (cid != null) {
      map["cid"] = cid;
    }
    return map;
  }

  Chapter.fromMap(Map<String, dynamic> map) {
    cid = map["cid"];
    bid = map["bid"];
    vid = map["vid"];
    order = map["order"];
    name = map["name"];
    content = map["content"];
  }
}

class Record {
  static const TableName = "records";

  int rid;
  int bid;
  int vid;
  int cid;
  int offset;
  DateTime updatedAt;
  DateTime createdAt;

  Record({
    this.rid,
    this.cid,
    this.bid,
    this.vid,
    this.updatedAt,
    this.createdAt,
    this.offset,
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      "rid": rid,
      "bid": bid,
      "vid": vid,
      "cid": cid,
      "offset": offset ?? 0,
      "updated_at": updatedAt.toUtc().millisecondsSinceEpoch,
      "created_at": createdAt.toUtc().millisecondsSinceEpoch,
    };
    if (rid != null) {
      map["rid"] = rid;
    }
    return map;
  }

  Record.fromMap(Map<String, dynamic> map) {
    rid = map["rid"];
    bid = map["bid"];
    cid = map["cid"];
    vid = map["vid"];
    offset = map["offset"] ?? 0;
    updatedAt = DateTime.fromMillisecondsSinceEpoch(map["updated_at"]);
    createdAt = DateTime.fromMillisecondsSinceEpoch(map["created_at"]);
  }
}
