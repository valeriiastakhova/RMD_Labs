import 'dart:async';

import 'package:flutter/material.dart';

import 'package:lab1/data/repositories/shared_prefs_plant_repository.dart';
import 'package:lab1/data/services/mqtt_service.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:lab1/domain/repositories/i_plant_repository.dart';
import 'package:lab1/ui/widgets/plant_card.dart';
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

class DashboardScreen extends StatefulWidget {
  final bool startedOffline;

  const DashboardScreen({super.key, this.startedOffline = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final IPlantRepository _plantRepository = SharedPrefsPlantRepository();
  List<Plant> _plants = [];
  bool _isLoading = true;

  final NetworkService _networkService = NetworkService();
  final MqttService _mqttService = MqttService();

  StreamSubscription<bool>? _networkSub;
  StreamSubscription<String>? _mqttDataSub;
  StreamSubscription<bool>? _mqttStatusSub;

  late bool _isOnline;
  bool _isMqttConnected = false;

  static const List<PlantTheme> _plantThemes = [
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

  @override
  void initState() {
    super.initState();
    _isOnline = !widget.startedOffline;
    _loadPlants();
    _initNetworkAndMqtt();
  }

  Future<void> _initNetworkAndMqtt() async {
    final connected = await _networkService.hasConnection();
    if (mounted) {
      setState(() => _isOnline = connected);
    }

    _networkSub = _networkService.onConnectionChange.listen((isConnected) {
      if (!mounted) return;
      setState(() => _isOnline = isConnected);
      if (isConnected && !_isMqttConnected) {
        _mqttService.connect();
      }
    });

    _mqttStatusSub = _mqttService.connectionStatusStream.listen((status) {
      if (!mounted) return;
      setState(() => _isMqttConnected = status);
    });

    _mqttDataSub = _mqttService.sensorDataStream.listen((payload) {
      if (!mounted) return;
      _processMqttPayload(payload);
    });

    if (connected) {
      await _mqttService.connect();
    }
  }

  Future<void> _processMqttPayload(String payload) async {
    final updated = MqttService.applyTelemetryToPlants(_plants, payload);
    if (updated != null) {
      await _plantRepository.updatePlant(updated);
      await _loadPlants();
    }
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    _mqttDataSub?.cancel();
    _mqttStatusSub?.cancel();
    _mqttService.dispose();
    super.dispose();
  }

  Future<void> _loadPlants() async {
    setState(() => _isLoading = true);
    final plants = await _plantRepository.getPlants();
    if (!mounted) return;
    setState(() {
      _plants = plants;
      _isLoading = false;
    });
  }

  Future<void> _showPlantDialog([Plant? plant]) async {
    final nameController = TextEditingController(text: plant?.name ?? '');
    final moistureController = TextEditingController(
      text: plant != null ? plant.moisture.toString() : '50',
    );
    final tempController = TextEditingController(
      text: plant != null ? plant.temperature.toString() : '22',
    );
    int selectedIconIndex = plant?.iconIndex ?? 0;
    String? nameError;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(plant == null ? 'Додати рослину' : 'Редагувати рослину'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Назва рослини',
                    errorText: nameError,
                  ),
                  onChanged: (val) {
                    if (nameError != null) {
                      setDialogState(() => nameError = null);
                    }
                  },
                ),
                TextField(
                  controller: moistureController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Вологість (%)',
                  ),
                ),
                TextField(
                  controller: tempController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Температура (°C)',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Оберіть іконку:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_plantThemes.length, (index) {
                    final theme = _plantThemes[index];
                    final isSelected = selectedIconIndex == index;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          selectedIconIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.bgColor,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: theme.iconColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          theme.icon,
                          color: theme.iconColor,
                          size: 24,
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
              onPressed: () async {
                final name = nameController.text.trim();
                final moisture = int.tryParse(moistureController.text) ?? 50;
                final temp = int.tryParse(tempController.text) ?? 22;

                if (name.isEmpty) {
                  setDialogState(() {
                    nameError = 'Введіть назву рослини!';
                  });
                  return;
                }

                if (plant == null) {
                  final newPlant = Plant(
                    id: const Uuid().v4(),
                    name: name,
                    moisture: moisture,
                    temperature: temp,
                    iconIndex: selectedIconIndex,
                  );
                  await _plantRepository.addPlant(newPlant);
                } else {
                  final updatedPlant = Plant(
                    id: plant.id,
                    name: name,
                    moisture: moisture,
                    temperature: temp,
                    iconIndex: selectedIconIndex,
                  );
                  await _plantRepository.updatePlant(updatedPlant);
                }

                if (ctx.mounted) Navigator.pop(ctx);
                _loadPlants();
              },
              child: const Text('Зберегти'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePlant(String id) async {
    await _plantRepository.deletePlant(id);
    _loadPlants();
  }

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
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isMqttConnected
                    ? Colors.green.shade100
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sensors,
                    size: 16,
                    color: _isMqttConnected
                        ? Colors.green.shade800
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isMqttConnected ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: _isMqttConnected
                          ? Colors.green.shade800
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.white,
                child: Icon(Icons.person_outline, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _showPlantDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isOnline)
              Container(
                width: double.infinity,
                color: Colors.red.shade700,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Відсутнє інтернет-з\'єднання. '
                        'Режим обмеженої функціональності.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _plants.isEmpty
                        ? const Center(
                            child: Text(
                              'Список рослин порожній.\n'
                              'Натисніть "+", щоб додати!',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final int crossAxisCount =
                                  constraints.maxWidth > 600 ? 3 : 2;

                              return GridView.builder(
                                itemCount: _plants.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.9,
                                ),
                                itemBuilder: (context, index) {
                                  final plant = _plants[index];
                                  final theme = _plantThemes[
                                      plant.iconIndex % _plantThemes.length];

                                  return PlantCard(
                                    name: plant.name,
                                    moisture: plant.moisture,
                                    temperature: plant.temperature,
                                    icon: theme.icon,
                                    iconColor: theme.iconColor,
                                    iconBgColor: theme.bgColor,
                                    onTap: () => _showPlantDialog(plant),
                                    onDelete: () => _deletePlant(plant.id),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
