import 'package:flutter/material.dart';
import 'package:posts/screens/homescreen.dart';
import 'package:provider/provider.dart';
import 'provider/post_provider.dart';
import 'services/api_service.dart';
import 'services/local_storage.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PostProvider(apiService:
        apiService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Offline Posts',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const HomeScreen(),
      ),
    );
  }
}