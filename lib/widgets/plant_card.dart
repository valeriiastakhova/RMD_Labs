import 'package:flutter/material.dart';

class PlantCard extends StatelessWidget {
  final String name;
  final int moisture;
  final int temperature;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const PlantCard({
    required this.name,
    required this.moisture,
    required this.temperature,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              // Збільшений контейнер з іконкою
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 36),
              ),
              Icon(Icons.more_vert, color: Colors.grey.shade400, size: 28),
            ],
          ),
          const Spacer(),
          // Збільшений текст із підтримкою 2 рядків
          Text(
            name,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
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
    );
  }

  // Збільшені показники датчиків
  Widget _buildSensorInfo(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
