import 'package:flutter/material.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:uuid/uuid.dart';

class PlantTheme {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  const PlantTheme({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });
}

const List<PlantTheme> kPlantThemes = [
  PlantTheme(
    icon: Icons.eco,
    iconColor: Colors.green,
    bgColor: Color(0xFFE8F5E9),
  ),
  PlantTheme(
    icon: Icons.local_florist,
    iconColor: Colors.pink,
    bgColor: Color(0xFFFCE4EC),
  ),
  PlantTheme(
    icon: Icons.grass,
    iconColor: Colors.amber,
    bgColor: Color(0xFFFFF8E1),
  ),
  PlantTheme(
    icon: Icons.park,
    iconColor: Colors.teal,
    bgColor: Color(0xFFE0F2F1),
  ),
  PlantTheme(
    icon: Icons.spa,
    iconColor: Colors.purple,
    bgColor: Color(0xFFF3E5F5),
  ),
];

Future<Plant?> showPlantFormDialog(BuildContext context, [Plant? plant]) {
  final nameCtrl = TextEditingController(text: plant?.name ?? '');
  final moistCtrl = TextEditingController(text: '${plant?.moisture ?? 50}');
  final tempCtrl = TextEditingController(text: '${plant?.temperature ?? 22}');
  int iconIdx = plant?.iconIndex ?? 0;
  String? nameError;

  return showDialog<Plant>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(plant == null ? 'Додати рослину' : 'Редагувати рослину'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Назва рослини',
                  errorText: nameError,
                ),
                onChanged: (_) =>
                    nameError != null ? setState(() => nameError = null) : null,
              ),
              TextField(
                controller: moistCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Вологість (%)'),
              ),
              TextField(
                controller: tempCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Температура (°C)',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(kPlantThemes.length, (i) {
                  final t = kPlantThemes[i];
                  return GestureDetector(
                    onTap: () => setState(() => iconIdx = i),
                    child: CircleAvatar(
                      backgroundColor: t.bgColor,
                      child: Icon(
                        t.icon,
                        color: t.iconColor,
                        size: iconIdx == i ? 28 : 20,
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) {
                setState(() => nameError = 'Введіть назву рослини!');
                return;
              }
              Navigator.pop(
                ctx,
                Plant(
                  id: plant?.id ?? const Uuid().v4(),
                  name: nameCtrl.text.trim(),
                  moisture: int.tryParse(moistCtrl.text) ?? 50,
                  temperature: int.tryParse(tempCtrl.text) ?? 22,
                  iconIndex: iconIdx,
                ),
              );
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    ),
  );
}
