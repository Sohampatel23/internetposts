import 'package:flutter/material.dart';
class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  final bool isSyncing;
  const OfflineBanner({super.key, required this.isOnline, required
  this.isSyncing});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: isOnline ? Colors.green.shade600 : Colors.red.shade600,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(isOnline ? 'Online' : 'Offline', style: const TextStyle(color:
          Colors.white, fontWeight: FontWeight.bold)),
          if (isSyncing) ...[
            const SizedBox(width: 12),
            const SizedBox(width: 16, height: 16, child:
            CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 8),
            const Text('Syncing...', style: TextStyle(color: Colors.white)),
          ]
        ],
      ),
    );
  }
}