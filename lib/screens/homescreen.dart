import 'package:flutter/material.dart';
import 'package:posts/provider/post_provider.dart';
import 'package:posts/screens/add_post_screen.dart';
import 'package:provider/provider.dart';
import '../widgets/offline_banner.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<PostProvider>(builder: (context, provider, _) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Posts'),
            centerTitle: true,
          ),
          body: Column(
              children: [
              OfflineBanner(isOnline: provider.isOnline, isSyncing:
          provider.isSyncing),
          Expanded(
              child: provider.posts.isEmpty
                  ? const Center(child: Text('No posts available'))
                  : RefreshIndicator(
                  onRefresh: () async {
                    if (provider.isOnline) await
                    provider.fetchAndCachePosts();
                  },
                  child: ListView.builder(
                      itemCount: provider.posts.length,
                      itemBuilder: (context, index) {
                        final p = provider.posts[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6,
                              horizontal: 12),
                          child: ListTile(
                            title: Text(p.title, style: const
                            TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p.body, maxLines: 2, overflow:
                            TextOverflow.ellipsis),
                            trailing: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                            Container(
                            padding: const
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.isSynced ?
                              Colors.green.shade100 : Colors.red.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.isSynced ? 'Synced' : 'Not Synced',
                              style: TextStyle(color: p.isSynced ?
                              Colors.green.shade800 : Colors.red.shade800),
                            ),
                          ),
                            const SizedBox(height: 6),
                            if (!p.isSynced) Text('localId: ${p.localId}', style: const TextStyle(fontSize: 10))
                          ],
                        ),
                        ),
                        );
                      },
                  ),
              ),
          )
              ],
          ),
          floatingActionButton: FloatingActionButton(
          onPressed: () =>
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const
          AddPostScreen())),
      child: const Icon(Icons.add),
      ),
      );
    });
  }
}