import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class DioConfig {
  static final String baseUrl = dotenv.env["NEWSAPI_BASE_URL"]!;
  static final String apiKey = dotenv.env["NEWSAPI_API_KEY"]!;

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      headers: {
        "X-Api-Key": apiKey,
        HttpHeaders.connectionHeader: "keep-alive",
      },
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );
}
