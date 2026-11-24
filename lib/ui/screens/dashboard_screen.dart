import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lab1/data/repositories/remote_plant_repository.dart';
import 'package:lab1/data/services/mqtt_service.dart';
import 'package:lab1/data/services/network_service.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:lab1/domain/repositories/i_plant_repository.dart';
import 'package:lab1/ui/widgets/plant_form_dialog.dart';
import 'package:lab1/ui/widgets/plant_grid.dart';
import 'package:lab1/ui/widgets/status_banners.dart';

class DashboardScreen extends StatefulWidget {
  final IPlantRepository plantRepository;
  final bool startedOffline;

  const DashboardScreen({
    required this.plantRepository,
    this.startedOffline = false,
    super.key,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<List<Plant>> _plantsFuture;
  List<Plant> _latestPlants = [];
  final _network = NetworkService();
  final _mqtt = MqttService();
  StreamSubscription<bool>? _netSub;
  StreamSubscription<String>? _mqttDataSub;
  StreamSubscription<bool>? _mqttStatusSub;
  late bool _isOnline;
  bool _isMqttConnected = false;

  @override
  void initState() {
    super.initState();
    _isOnline = !widget.startedOffline;
    _reloadPlants();
    _initStreams();
  }

  void _reloadPlants() => setState(() {
        _plantsFuture = widget.plantRepository.getPlants().then((list) {
          _latestPlants = list;
          return list;
        });
      });

  Future<void> _initStreams() async {
    final connected = await _network.hasConnection();
    if (mounted) setState(() => _isOnline = connected);
    _netSub = _network.onConnectionChange.listen((online) {
      if (!mounted) return;
      setState(() => _isOnline = online);
      if (online && !_isMqttConnected) _mqtt.connect();
      if (online) _reloadPlants();
    });
    _mqttStatusSub = _mqtt.connectionStatusStream.listen((s) {
      if (mounted) setState(() => _isMqttConnected = s);
    });
    _mqttDataSub = _mqtt.sensorDataStream.listen((payload) async {
      final updated =
          MqttService.applyTelemetryToPlants(_latestPlants, payload);
      if (updated != null && mounted) {
        await widget.plantRepository.updatePlant(updated);
        _reloadPlants();
      }
    });
    if (connected) await _mqtt.connect();
  }

  @override
  void dispose() {
    _netSub?.cancel();
    _mqttDataSub?.cancel();
    _mqttStatusSub?.cancel();
    _mqtt.dispose();
    super.dispose();
  }

  Future<void> _savePlant([Plant? existing]) async {
    final res = await showPlantFormDialog(context, existing);
    if (res == null) return;
    existing == null
        ? await widget.plantRepository.addPlant(res)
        : await widget.plantRepository.updatePlant(res);
    _reloadPlants();
  }

  Future<void> _deletePlant(String id) async {
    await widget.plantRepository.deletePlant(id);
    _reloadPlants();
  }

  @override
  Widget build(BuildContext context) {
    final repo = widget.plantRepository;
    final fromCache = repo is RemotePlantRepository && repo.isFromCache;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: DashboardAppBar(
        isMqttConnected: _isMqttConnected,
        onRefresh: () {
          _reloadPlants();
          if (!_isMqttConnected) _mqtt.connect();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: _savePlant,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting &&
              _latestPlants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('${snap.error}'));
          return Column(
            children: [
              OfflineCacheBanner(
                isOffline: !_isOnline,
                isFromCache: fromCache,
              ),
              Expanded(
                child: PlantGrid(
                  plants: snap.data ?? _latestPlants,
                  onEdit: _savePlant,
                  onDelete: _deletePlant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
