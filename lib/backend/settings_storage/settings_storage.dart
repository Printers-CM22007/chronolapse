
import 'package:shared_preferences/shared_preferences.dart';

class SharedStorage {
  static SharedStorage? _instance;

  final SharedPreferences _sp;
  SharedStorage._(this._sp);

  static Future<void> initialise() async {
    _instance = SharedStorage._(await SharedPreferences.getInstance());
  }

  static SharedPreferences sp() {
    if (_instance == null) {
      throw Exception("SharedStorage.initialise() has not been called (must be awaited)");
    }
    return _instance!._sp;
  }
}