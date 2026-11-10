import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final String name;
  final int moisture;
  final int temperature;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const PlantCard({
    required this.name,
    required this.moisture,
    required this.temperature,
    this.icon = Icons.energy_savings_leaf,
    this.iconColor = Colors.green,
    this.iconBgColor = const Color(0xFFE8F5E9),
    this.onDelete,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3142),
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSensorInfo(
                  Icons.water_drop,
                  '$moisture%',
                  Colors.blueAccent,
                ),
                _buildSensorInfo(
                  Icons.thermostat,
                  '$temperature°C',
                  Colors.deepOrangeAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorInfo(IconData iconData, String value, Color color) {
    return Row(
      children: [
        Icon(iconData, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
