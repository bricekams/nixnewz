import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = "settings";
  static const String darkModeKey = "darkMode";
  static const String langKey = "lang";
  static const String jsModeKey = "jsMode";
  static const String jsWarningDisplayKey = "doNotShowJsWarning";
  static String? countryKey = "country";

  late Box _box;

  Future<void> openBox() async {
    _box = await Hive.openBox(_boxName);
    await initBox();
  }

  Future<void> initBox() async {
    await _box.put(darkModeKey, _box.get(darkModeKey, defaultValue: false) as bool);
    await _box.put(langKey, _box.get(langKey, defaultValue: "en") as String);
    await _box.put(jsModeKey, _box.get(jsModeKey, defaultValue: true) as bool);
    await _box.put(jsWarningDisplayKey, _box.get(jsWarningDisplayKey, defaultValue: false) as bool);
    await _box.put(countryKey, _box.get(countryKey, defaultValue: null) as String?);
  }

  bool get darkMode => _box.get(darkModeKey) as bool;
  String get language => _box.get(langKey) as String;
  bool get jsActive => _box.get(jsModeKey) as bool;
  bool get jsWarningDisplay => _box.get(jsWarningDisplayKey) as bool;
  String? get country => _box.get("country") as String?;

  Future<void> setDarkMode(bool value) async => await _box.put(darkModeKey, value);
  Future<void> setLang(String value) async => await _box.put(langKey, value);
  Future<void> setJsMode(bool value) async => await _box.put(jsModeKey, value);

  Future<void> setJsWarningDisplay(bool value) async => await _box.put(jsWarningDisplayKey, value);
  Future<void> setCountry(String? value) async => await _box.put("country", value);
}


class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;

  SettingsProvider(this._settingsService);

  bool get darkMode => _settingsService.darkMode;
  String get language => _settingsService.language;
  bool get jsActive => _settingsService.jsActive;
  bool get jsWarningDisplay => _settingsService.jsWarningDisplay;
  String? get country => _settingsService.country;

  Future<void> toggleDarkMode() async {
    await _settingsService.setDarkMode(!darkMode);
    notifyListeners();
  }

  Future<void> toggleLang() async {
    await _settingsService.setLang(language == "en" ? "fr" : "en");
    notifyListeners();
    return;
  }

  Future<void> toggleJsMode() async {
    await _settingsService.setJsMode(!jsActive);
    notifyListeners();
    return;
  }

  Future<void> setJsWarningDisplay(bool value) async {
    await _settingsService.setJsWarningDisplay(value);
    notifyListeners();
    return;
  }

  Future<void> setCountry(String? value) async {
    await _settingsService.setCountry(value);
    notifyListeners();
    return;
  }
}

