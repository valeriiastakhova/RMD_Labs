import 'package:lab1/data/network/api_client.dart';
import 'package:lab1/data/network/plant_dto.dart';
import 'package:lab1/data/repositories/shared_prefs_plant_repository.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:lab1/domain/repositories/i_plant_repository.dart';

class RemotePlantRepository implements IPlantRepository {
  final ApiClient _api;
  final SharedPrefsPlantRepository _cache;
  bool isFromCache = false;

  RemotePlantRepository({ApiClient? api, SharedPrefsPlantRepository? cache})
    : _api = api ?? ApiClient(),
      _cache = cache ?? SharedPrefsPlantRepository();

  @override
  Future<List<Plant>> getPlants() async {
    try {
      final data = await _api.get('/todos?_limit=6');
      if (data is List) {
        final remote = data
            .map(
              (dynamic e) => PlantDto.fromRemoteJson(e as Map<String, dynamic>),
            )
            .toList();
        await _seedCacheIfEmpty(remote);
        isFromCache = false;
        return await _cache.getPlants();
      }
      isFromCache = true;
      return await _cache.getPlants();
    } catch (_) {
      isFromCache = true;
      return await _cache.getPlants();
    }
  }

  Future<void> _seedCacheIfEmpty(List<Plant> remote) async {
    if ((await _cache.getPlants()).isEmpty) {
      for (final p in remote) {
        await _cache.addPlant(p);
      }
    }
  }

  @override
  Future<void> addPlant(Plant plant) async {
    try {
      await _api.post('/posts', PlantDto.toRemoteJson(plant));
    } catch (_) {}
    await _cache.addPlant(plant);
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    try {
      await _api.post('/posts', PlantDto.toRemoteJson(plant));
    } catch (_) {}
    await _cache.updatePlant(plant);
  }

  @override
  Future<void> deletePlant(String id) => _cache.deletePlant(id);
}
