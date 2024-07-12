import 'package:flutter/material.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:newsapp/configs/enums.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const String appName = "NiixNews";

class ExternalLinks {
  static String get copyrights => "https://roaxer.com";
  static String get terms => "https://roaxer.com";
}

SupabaseClient supabase = Supabase.instance.client;

Map<ErrorType, Map<String, dynamic>> errorMessages = {
  ErrorType.NETWORK: {
    "message": dictionary["@networkError"],
    "icon": const Icon(Icons.network_check_rounded, size: 60),
  },
  ErrorType.SERVER: {
    "message": dictionary["@serverError"],
    "icon": const Icon(Icons.error, size: 60),
  },
  ErrorType.UNKNOWN: {
    "message": dictionary["@unknownError"],
    "icon": const Icon(Icons.error, size: 60),
  },
};

Map<String, String> bookmarksErrorMessages = {
  "23505": "@bookmarksDuplicateError",
};

List<String> sortOptions = ["@relevancy", "@popularity", "@publishedAt"];
List<Map<String, String>> languages = [
  {
    "name": "English",
    "code": "en",
  },
  {
    // name in arabic
    "name": "العربية",
    "code": "ar",
  },
  {
    "name": "Deutsch",
    "code": "de",
  },
  {
    "name": "Español",
    "code": "es",
  },
  {
    "name": "Français",
    "code": "fr",
  },
  {
    "name": "עברית",
    "code": "he",
  },
  {
    "name": "Italiano",
    "code": "it",
  },
  {
    "name": "Nederlands",
    "code": "nl",
  },
  {
    "name": "Norsk",
    "code": "no",
  },
  {
    "name": "Português",
    "code": "pt",
  },
  {
    "name": "Русский",
    "code": "ru",
  },
  {
    "name": "Svenska",
    "code": "sv",
  },
  {
    "name": "Українська",
    "code": "ud",
  },
  {
    "name": "中文",
    "code": "zh",
  },
];
