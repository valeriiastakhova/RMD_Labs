import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  static const String broker = 'broker.hivemq.com';
  static const String topic = 'plant_app_valeriia/sensors';

  MqttServerClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _subscription;

  final _dataController = StreamController<String>.broadcast();
  final _statusController = StreamController<bool>.broadcast();
  bool _isConnecting = false;
  bool _isDisposed = false;

  Stream<String> get sensorDataStream => _dataController.stream;
  Stream<bool> get connectionStatusStream => _statusController.stream;

  Future<void> connect() async {
    if (_isDisposed || _isConnecting) return;

    final clientId = 'flutter_plant_${const Uuid().v4().substring(0, 8)}';
    _client = MqttServerClient(broker, clientId);
    _client!.port = 1883;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.autoReconnect = false;
    _client!.onConnected = () => _statusController.add(true);
    _client!.onDisconnected = () => _statusController.add(false);

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;

    _isConnecting = true;
    try {
      await _client!.connect().timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('MQTT Connection failed: $e');
      _statusController.add(false);
      _client!.disconnect();
      return;
    } finally {
      _isConnecting = false;
    }

    if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
      _statusController.add(true);
      _client!.subscribe(topic, MqttQos.atMostOnce);

      _subscription = _client!.updates?.listen(
        (messages) {
          if (messages.isEmpty) return;
          final recMess = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );
          _dataController.add(payload);
        },
        onError: (_) {
          if (!_statusController.isClosed) {
            _statusController.add(false);
          }
        },
      );
    }
  }

  static Plant? applyTelemetryToPlants(List<Plant> plants, String payload) {
    if (plants.isEmpty) return null;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return null;

      final String? targetName = decoded['plant']?.toString().toLowerCase();
      final index = targetName != null
          ? plants.indexWhere((p) => p.name.toLowerCase().contains(targetName))
          : 0;

      if (index == -1) return null;

      final oldPlant = plants[index];
      final newMoisture = decoded['moisture'] != null
          ? int.tryParse(decoded['moisture'].toString()) ?? oldPlant.moisture
          : oldPlant.moisture;

      final newTemp = decoded['temperature'] != null
          ? double.tryParse(decoded['temperature'].toString())?.round() ??
                oldPlant.temperature
          : oldPlant.temperature;

      return Plant(
        id: oldPlant.id,
        name: oldPlant.name,
        moisture: newMoisture,
        temperature: newTemp,
        iconIndex: oldPlant.iconIndex,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _client?.disconnect();
    _dataController.close();
    _statusController.close();
  }
}
