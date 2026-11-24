import 'package:lab1/domain/models/plant.dart';

class PlantDto {
  static const List<String> _names = [
    'Фікус Бенджаміна',
    'Монстера Деліціоза',
    'Орхідея Фаленопсис',
    'Сансевієрія',
    'Спатифілум',
    'Заміокулькас',
  ];

  static Plant fromRemoteJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? 1;
    final numId = rawId is int ? rawId : int.tryParse('$rawId') ?? 1;
    return Plant(
      id: rawId.toString(),
      name: json['name'] as String? ?? _names[(numId - 1) % _names.length],
      moisture: (json['moisture'] as int?) ?? (35 + (numId * 7) % 50),
      temperature: (json['temperature'] as int?) ?? (20 + (numId % 6)),
      iconIndex: (json['iconIndex'] as int?) ?? (numId % 5),
    );
  }

  static Map<String, dynamic> toRemoteJson(Plant p) => {
    'id': p.id,
    'name': p.name,
    'moisture': p.moisture,
    'temperature': p.temperature,
    'iconIndex': p.iconIndex,
  };
}
