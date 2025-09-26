import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/post.dart';


class LocalStorage {
  static const String postsBox = 'posts_box';


  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PostAdapter());
    await Hive.openBox<Post>(postsBox);
  }


  static Box<Post> _box() => Hive.box<Post>(postsBox);


  static List<Post> getAllPosts() => _box().values.toList();


  static Future<void> savePosts(List<Post> posts) async {
    final box = _box();
    await box.clear();
    for (var p in posts) {
      await box.put(p.localId, p);
    }
  }


  static Future<void> addLocalPost(Post p) async {
    final box = _box();
    await box.put(p.localId, p);
  }


  static Future<void> updatePost(Post p) async {
    final box = _box();
    await box.put(p.localId, p);
  }


  static List<Post> getUnsyncedPosts() => _box().values.where((p) => !p.isSynced).toList();


  static Future<void> clear() async => await _box().clear();
}