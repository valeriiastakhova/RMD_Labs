import 'dart:convert';

import 'package:lab1/domain/models/plant.dart';
import 'package:lab1/domain/repositories/i_plant_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsPlantRepository implements IPlantRepository {
  static const _currentEmailKey = 'current_user_email';

  String? _getPlantsKey(SharedPreferences prefs) {
    final currentEmail = prefs.getString(_currentEmailKey);
    if (currentEmail == null || currentEmail.isEmpty) return null;
    return 'plants_list_${currentEmail.toLowerCase()}';
  }

  @override
  Future<List<Plant>> getPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPlantsKey(prefs);
    if (key == null) return [];

    final String? plantsJson = prefs.getString(key);
    if (plantsJson == null) return [];

    final List<dynamic> decodedList = jsonDecode(plantsJson) as List<dynamic>;
    return decodedList
        .map((item) => Plant.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addPlant(Plant plant) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPlantsKey(prefs);
    if (key == null) return;

    final plants = await getPlants();
    plants.add(plant);
    await _savePlants(prefs, key, plants);
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPlantsKey(prefs);
    if (key == null) return;

    final plants = await getPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);
    if (index != -1) {
      plants[index] = plant;
      await _savePlants(prefs, key, plants);
    }
  }

  @override
  Future<void> deletePlant(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getPlantsKey(prefs);
    if (key == null) return;

    final plants = await getPlants();
    plants.removeWhere((p) => p.id == id);
    await _savePlants(prefs, key, plants);
  }

  Future<void> _savePlants(
    SharedPreferences prefs,
    String key,
    List<Plant> plants,
  ) async {
    final String encodedList = jsonEncode(
      plants.map((p) => p.toJson()).toList(),
    );
    await prefs.setString(key, encodedList);
  }
}
