import 'package:lab1/domain/models/plant.dart';

abstract class IPlantRepository {
  Future<List<Plant>> getPlants();
  Future<void> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String id);
}
