import '../../../core/database/app_database.dart' hide Thing;
import '../../things/data/things_repository.dart';
import '../../things/domain/thing.dart';

class HomeRepository {
  final AppDatabase database;
  HomeRepository(this.database);
  Future<List<MoneyEntry>> loadMoney() async =>
      (await database.allMoney()).reversed.toList();
  Future<List<Thing>> loadThings() => ThingsRepository(database).all();
  Future<String?> loadCurrency() => database.setting('currency');
  Future<void> saveCurrency(String currency) =>
      database.saveSetting('currency', currency);
}
