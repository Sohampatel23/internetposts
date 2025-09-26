import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/post.dart';


class ApiService {
  final Dio _dio;
  final String baseUrl = 'https://jsonplaceholder.typicode.com';


  ApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }


  Future<List<Post>> fetchPosts({int retries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await _dio.get('$baseUrl/posts');
        final data = response.data as List<dynamic>;
        return data.map((e) => Post.fromJson(e)).toList();
      } catch (e) {
        if (attempt >= retries) rethrow;
        attempt++;
        await Future.delayed(Duration(seconds: 1 << attempt)); // exponential backoff
      }
    }
  }


  Future<Post> createPost(Post post, {int retries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        final response = await _dio.post('$baseUrl/posts', data: post.toJson());
// JSONPlaceholder returns the created object with an id
        final data = response.data as Map<String, dynamic>;
        return Post.fromJson(data);
      } catch (e) {
        if (attempt >= retries) rethrow;
        attempt++;
        await Future.delayed(Duration(seconds: 1 << attempt));
      }
    }
  }
}