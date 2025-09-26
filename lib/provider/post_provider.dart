import 'dart:async';


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';


import '../models/post.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

class PostProvider extends ChangeNotifier {
  final ApiService apiService;
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;
  List<Post> _posts = [];
  List<Post> get posts => List.unmodifiable(_posts);
  late StreamSubscription<ConnectivityResult> _connectivitySub;
  PostProvider({required this.apiService}) {
    _init();
  }
  Future<void> _init() async {
// initialize connectivity
    final connectivity = Connectivity();
    _connectivitySub = connectivity.onConnectivityChanged.listen((event) async {
      final wasOnline = _isOnline;
      _isOnline = event != ConnectivityResult.none;
      notifyListeners();
      if (!wasOnline && _isOnline) {
        await syncLocalPosts();
        await fetchAndCachePosts();
      }
    });
// load cached posts
    _posts = LocalStorage.getAllPosts();
    notifyListeners();

    try {
      _isOnline = (await connectivity.checkConnectivity()) !=
          ConnectivityResult.none;
      if (_isOnline) {
        await fetchAndCachePosts();
        await syncLocalPosts();
      }
    } catch (e) {
// keep offline state
      _isOnline = false;
    }
  }
  Future<void> fetchAndCachePosts() async {
    try {
      final remote = await apiService.fetchPosts();
// mark remote posts as synced and give them localId
      final mapped = remote
          .map((r) => Post(id: r.id, title: r.title, body: r.body, localId:
      'server-${r.id}', isSynced: true))
          .toList();
      _posts = mapped;
      await LocalStorage.savePosts(_posts);
      notifyListeners();
    } catch (e) {
// ignore - keep cache
    }
  }
  Future<void> addPost({required String title, required String body}) async {
    final String localId = const Uuid().v4();
    final newPost = Post(id: null, title: title, body: body, localId: localId,
        isSynced: false);
    _posts.insert(0, newPost);
    await LocalStorage.addLocalPost(newPost);
    notifyListeners();
    if (_isOnline) {
// attempt immediate sync
      await _trySyncPost(newPost);
    }
  }
  Future<void> _trySyncPost(Post post) async {
    try {
      final serverPost = await apiService.createPost(post);
// update local post with server id and mark synced
      post.id = serverPost.id;
      post.isSynced = true;
// change localId to server-x to avoid collision with fetched ones
      post.localId = 'server-${serverPost.id}';
      await LocalStorage.updatePost(post);
// replace _posts entry
      final index = _posts.indexWhere((p) => p.localId == post.localId ||
          p.localId == post.localId);
      if (index >= 0) _posts[index] = post;
      notifyListeners();
    } catch (e) {
// leave unsynced; will retry later when connectivity returns
    }
  }
  Future<void> syncLocalPosts() async {
    if (_isSyncing) return;
    _isSyncing = true;
    notifyListeners();
    final unsynced = LocalStorage.getUnsyncedPosts();
    for (var p in unsynced) {
      try {
        final serverPost = await apiService.createPost(p);
// update p
        p.id = serverPost.id;
        p.isSynced = true;
        p.localId = 'server-${serverPost.id}';
        await LocalStorage.updatePost(p);
      } catch (e) {
// if any single post fails, keep it unsynced; continue others
      }
    }


    try {
      final remote = await apiService.fetchPosts();
      final mapped = remote
          .map((r) => Post(id: r.id, title: r.title, body: r.body, localId:
      'server-${r.id}', isSynced: true))
          .toList();
// Merge: keep any server-synced local posts that might not be present in
//       fresh fetch (rare for placeholder but safe)
      final all = <String, Post>{};
      for (var r in mapped) {
        all[r.localId] = r;
      }
      final current = LocalStorage.getAllPosts();
      for (var c in current.where((x) => x.isSynced)) {
        all[c.localId] = c;
      }
      final merged = all.values.toList()..sort((a, b) => (b.id ??
          0).compareTo(a.id ?? 0));
      _posts = merged;
      await LocalStorage.savePosts(_posts);
    } catch (e) {
// ignore: keep old cache
    }
    _isSyncing = false;
    notifyListeners();
  }
  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }
}