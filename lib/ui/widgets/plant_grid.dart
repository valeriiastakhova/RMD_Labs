import 'package:flutter/material.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:lab1/ui/widgets/plant_card.dart';
import 'package:lab1/ui/widgets/plant_form_dialog.dart';

class PlantGrid extends StatelessWidget {
  final List<Plant> plants;
  final ValueChanged<Plant> onEdit;
  final ValueChanged<String> onDelete;

  const PlantGrid({
    required this.plants,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (plants.isEmpty) {
      return const Center(child: Text('Список порожній. Натисніть "+"'));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: plants.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (ctx, i) {
            final p = plants[i];
            final t = kPlantThemes[p.iconIndex % kPlantThemes.length];
            return PlantCard(
              name: p.name,
              moisture: p.moisture,
              temperature: p.temperature,
              icon: t.icon,
              iconColor: t.iconColor,
              iconBgColor: t.bgColor,
              onTap: () => onEdit(p),
              onDelete: () => onDelete(p.id),
            );
          },
        );
      },
    );
  }
}
