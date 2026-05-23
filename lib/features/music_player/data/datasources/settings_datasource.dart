import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/features/music_player/data/models/app_settings_model.dart';

abstract class SettingsDataSource {
  Future<AppSettingsModel> getSettings();
  Future<void> saveSettings(AppSettingsModel settings);
}

class SettingsDataSourceImpl implements SettingsDataSource {
  static const String _settingsKey = 'app_settings';
  final SharedPreferences _sharedPreferences;

  SettingsDataSourceImpl(this._sharedPreferences);

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      final jsonString = _sharedPreferences.getString(_settingsKey);
      if (jsonString == null) {
        final defaults = AppSettingsModel.defaults();
        await saveSettings(defaults);
        return defaults;
      }
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return AppSettingsModel.fromMap(jsonMap);
    } catch (e) {
      throw SettingsException('Failed to get settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      final jsonMap = settings.toMap();
      final jsonString = json.encode(jsonMap);
      await _sharedPreferences.setString(_settingsKey, jsonString);
    } catch (e) {
      throw SettingsException('Failed to save settings: $e');
    }
  }
}
