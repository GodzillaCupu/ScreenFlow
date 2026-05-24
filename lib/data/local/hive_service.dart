import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class HiveService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _initialized = true;
  }
}
