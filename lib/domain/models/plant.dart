class Plant {
  final String id;
  final String name;
  final int moisture;
  final int temperature;
  final int iconIndex;

  const Plant({
    required this.id,
    required this.name,
    required this.moisture,
    required this.temperature,
    this.iconIndex = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'moisture': moisture,
    'temperature': temperature,
    'iconIndex': iconIndex,
  };

  factory Plant.fromJson(Map<String, dynamic> json) => Plant(
    id: json['id'] as String,
    name: json['name'] as String,
    moisture: json['moisture'] as int,
    temperature: json['temperature'] as int,
    iconIndex: (json['iconIndex'] as int?) ?? 0,
  );
}
