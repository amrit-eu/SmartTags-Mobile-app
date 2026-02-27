// Widget that shows when the device is offline.
import 'package:flutter/material.dart';

/// A widget that displays an offline status message to the user.
class OfflineStatus extends StatelessWidget {
  /// Creates an [OfflineStatus] widget to indicate offline status.
  const OfflineStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.signal_wifi_off, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(
            'You are offline. Changes will be saved locally and synced when you are back online.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            softWrap: true,
            textAlign: TextAlign.center,
          ),)
        ],
      ),
    );
  }
}
