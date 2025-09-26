import 'package:hive/hive.dart';


part 'post.g.dart';


@HiveType(typeId: 0)
class Post extends HiveObject {
  @HiveField(0)
  int? id; // server id (nullable for local-only posts)


  @HiveField(1)
  String title;


  @HiveField(2)
  String body;


  @HiveField(3)
  String localId; // UUID for local identification


  @HiveField(4)
  bool isSynced; // synced with server?


  Post({this.id, required this.title, required this.body, required this.localId, this.isSynced = false});


  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    localId: json['id'] != null ? 'server-${json['id']}' : DateTime.now().microsecondsSinceEpoch.toString(),
    isSynced: true,
  );


  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
  };
}