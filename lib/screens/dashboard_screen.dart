import 'package:flutter/material.dart';
import 'package:lab1/widgets/plant_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            SizedBox(height: 4),
            Text(
              'Мої рослини',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3142),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  PlantCard(
                    name: 'Фікус Анатолій',
                    moisture: 45,
                    temperature: 22,
                    icon: Icons.energy_savings_leaf,
                    iconColor: Colors.green.shade700,
                    iconBgColor: Colors.green.shade100,
                  ),
                  PlantCard(
                    name: 'Сукулента',
                    moisture: 60,
                    temperature: 24,
                    icon: Icons.grass,
                    iconColor: Colors.teal.shade700,
                    iconBgColor: Colors.teal.shade100,
                  ),
                  PlantCard(
                    name: 'Кактус',
                    moisture: 15,
                    temperature: 28,
                    icon: Icons.nature,
                    iconColor: Colors.orange.shade700,
                    iconBgColor: Colors.orange.shade100,
                  ),
                  PlantCard(
                    name: 'Орхідея',
                    moisture: 70,
                    temperature: 21,
                    icon: Icons.local_florist,
                    iconColor: Colors.purple.shade700,
                    iconBgColor: Colors.purple.shade100,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
