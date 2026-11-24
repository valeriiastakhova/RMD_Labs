import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab1/data/network/api_client.dart';
import 'package:lab1/data/network/plant_dto.dart';
import 'package:lab1/data/repositories/remote_plant_repository.dart';
import 'package:lab1/data/repositories/shared_prefs_auth_repository.dart';
import 'package:lab1/data/repositories/shared_prefs_plant_repository.dart';
import 'package:lab1/data/services/mqtt_service.dart';
import 'package:lab1/domain/models/plant.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // 1. Тестування моделі Plant
  group('1. Plant Model Unit Tests', () {
    test('Коректна серіалізація toJson() та десеріалізація fromJson()', () {
      const plant = Plant(
        id: 'p1',
        name: 'Фікус',
        moisture: 65,
        temperature: 22,
        iconIndex: 3,
      );

      final map = plant.toJson();
      final decoded = Plant.fromJson(map);

      expect(decoded.id, 'p1');
      expect(decoded.name, 'Фікус');
      expect(decoded.moisture, 65);
      expect(decoded.temperature, 22);
      expect(decoded.iconIndex, 3);
    });

    test('Значення iconIndex за замовчуванням дорівнює 0', () {
      final decoded = Plant.fromJson({
        'id': 'p2',
        'name': 'Кактус',
        'moisture': 15,
        'temperature': 26,
      });

      expect(decoded.iconIndex, 0);
    });
  });

  // 2. Тестування автентифікації та сесій (автологін / вихід)
  group('2. Auth & Session Repository Unit Tests', () {
    late SharedPrefsAuthRepository authRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      authRepo = SharedPrefsAuthRepository();
    });

    test('Успішна реєстрація та вхід зберігають активну сесію', () async {
      await authRepo.signUp('Валерія', 'valeri@gmail.com', 'pass123');
      await authRepo.logOut();

      final isSuccess = await authRepo.signIn('valeri@gmail.com', 'pass123');
      expect(isSuccess, isTrue);

      // Перевіряємо дані для автологіну
      expect(await authRepo.getCurrentEmail(), 'valeri@gmail.com');
      expect(await authRepo.getCurrentUser(), 'Валерія');
    });

    test('Вхід з невірним паролем повертає false і не створює сесію', () async {
      await authRepo.signUp('Валерія', 'valeri@gmail.com', 'pass123');
      await authRepo.logOut(); // Скидаємо авто-сесію після реєстрації

      final isSuccess = await authRepo.signIn('valeri@gmail.com', 'wrong_pass');
      expect(isSuccess, isFalse);
      expect(await authRepo.getCurrentEmail(), isNull);
    });

    test('Вихід з акаунту (logOut) очищає збережену сесію', () async {
      await authRepo.signUp('Валерія', 'valeri@gmail.com', 'pass123');
      await authRepo.signIn('valeri@gmail.com', 'pass123');

      await authRepo.logOut();

      expect(await authRepo.getCurrentEmail(), isNull);
    });
  });

  // 3. Тестування CRUD-операцій з рослинами
  group('3. Plant Repository CRUD Unit Tests', () {
    late SharedPrefsPlantRepository plantRepo;
    late SharedPrefsAuthRepository authRepo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      authRepo = SharedPrefsAuthRepository();
      plantRepo = SharedPrefsPlantRepository();
      // Створюємо активну сесію користувача, до якого прив'язуються рослини
      await authRepo.signUp('Валерія', 'valeri@gmail.com', 'pass123');
    });

    test('Додавання, оновлення та видалення рослини в сховищі', () async {
      const plant = Plant(
        id: '1',
        name: 'Монстера',
        moisture: 45,
        temperature: 21,
      );

      // Create
      await plantRepo.addPlant(plant);
      var list = await plantRepo.getPlants();
      expect(list.length, 1);
      expect(list.first.name, 'Монстера');

      // Update
      const updated = Plant(
        id: '1',
        name: 'Монстера',
        moisture: 80,
        temperature: 24,
      );
      await plantRepo.updatePlant(updated);
      list = await plantRepo.getPlants();
      expect(list.first.moisture, 80);
      expect(list.first.temperature, 24);

      // Delete
      await plantRepo.deletePlant('1');
      list = await plantRepo.getPlants();
      expect(list, isEmpty);
    });
  });

  // 4. Тестування обробки вхідної телеметрії MQTT
  group('4. MQTT Telemetry Parser Unit Tests', () {
    final plants = [
      const Plant(id: '1', name: 'Фікус', moisture: 40, temperature: 20),
      const Plant(id: '2', name: 'Орхідея', moisture: 50, temperature: 22),
    ];

    test('Оновлює конкретну рослину за назвою з JSON-повідомлення', () {
      const payload =
          '{"plant": "Орхідея", "moisture": 30, "temperature": 25.4}';

      final result = MqttService.applyTelemetryToPlants(plants, payload);

      expect(result, isNotNull);
      expect(result!.id, '2');
      expect(result.name, 'Орхідея');
      expect(result.moisture, 30);
      expect(result.temperature, 25); // округлено з 25.4
    });

    test('Оновлює першу рослину, якщо поле plant не вказане в JSON', () {
      const payload = '{"moisture": 72}';

      final result = MqttService.applyTelemetryToPlants(plants, payload);

      expect(result, isNotNull);
      expect(result!.id, '1');
      expect(result.moisture, 72);
      expect(result.temperature, 20); // залишилась попередня
    });

    test('Не падає і повертає null при некоректному тексті замість JSON', () {
      const invalidPayload = 'Просто текстове повідомлення без JSON';

      final result = MqttService.applyTelemetryToPlants(plants, invalidPayload);
      expect(result, isNull);
    });
  });

  // 5. Тестування логіки перевірки статусу мережі
  group('5. Network Status Logic Unit Tests', () {
    bool checkConnectivity(List<ConnectivityResult> results) {
      return results.any(
        (r) =>
            r == ConnectivityResult.wifi ||
            r == ConnectivityResult.mobile ||
            r == ConnectivityResult.ethernet,
      );
    }

    test('Повертає true при наявності Wi-Fi або мобільного інтернету', () {
      expect(checkConnectivity([ConnectivityResult.wifi]), isTrue);
      expect(checkConnectivity([ConnectivityResult.mobile]), isTrue);
    });

    test('Повертає false при відсутності інтернету '
        '(ConnectivityResult.none)', () {
      expect(checkConnectivity([ConnectivityResult.none]), isFalse);
      expect(checkConnectivity([]), isFalse);
    });
  });

  group('6. REST API DTO & Offline-First Repository Unit Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPrefsAuthRepository().signUp(
        'Валерія',
        'valeri@gmail.com',
        'pass123',
      );
    });

    test('PlantDto коректно мапить JSON із зовнішнього REST API', () {
      final plant = PlantDto.fromRemoteJson({
        'id': 2,
        'title': 'delectus aut autem',
      });
      expect(plant.id, '2');
      expect(plant.name, 'Монстера Деліціоза');
      expect(plant.moisture, greaterThan(0));
      expect(plant.temperature, greaterThan(0));
    });

    test(
      'RemotePlantRepository повертає кеш при помилці мережі (Offline-First)',
      () async {
        final localCache = SharedPrefsPlantRepository();
        await localCache.addPlant(
          const Plant(
            id: 'cached_1',
            name: 'Кешований Фікус',
            moisture: 55,
            temperature: 23,
          ),
        );

        final failingClient = ApiClient(
          client: MockClient((_) async => http.Response('Server Error', 500)),
        );
        final remoteRepo = RemotePlantRepository(
          api: failingClient,
          cache: localCache,
        );

        final result = await remoteRepo.getPlants();
        expect(remoteRepo.isFromCache, isTrue);
        expect(result.length, 1);
        expect(result.first.name, 'Кешований Фікус');
      },
    );
  });
}
