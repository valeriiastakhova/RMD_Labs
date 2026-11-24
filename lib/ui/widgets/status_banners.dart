import 'package:flutter/material.dart';

class MqttStatusBadge extends StatelessWidget {
  final bool isConnected;
  const MqttStatusBadge({required this.isConnected, super.key});

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? Colors.green.shade800 : Colors.grey.shade700;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            isConnected ? 'Online' : 'Offline',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class OfflineCacheBanner extends StatelessWidget {
  final bool isOffline;
  final bool isFromCache;

  const OfflineCacheBanner({
    required this.isOffline,
    required this.isFromCache,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline && !isFromCache) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: isOffline ? Colors.red.shade700 : Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Row(
        children: [
          Icon(
            isOffline ? Icons.wifi_off : Icons.cached,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOffline
                  ? 'Офлайн-режим: відображаються збережені кешовані дані.'
                  : 'Дані завантажено з локального кешу.',
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMqttConnected;
  final VoidCallback onRefresh;

  const DashboardAppBar({
    required this.isMqttConnected,
    required this.onRefresh,
    super.key,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Мої рослини',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      actions: [
        Center(child: MqttStatusBadge(isConnected: isMqttConnected)),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.green),
          onPressed: onRefresh,
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => Navigator.pushNamed(context, '/profile'),
        ),
      ],
    );
  }
}
