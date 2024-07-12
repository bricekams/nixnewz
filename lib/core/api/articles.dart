import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:newsapp/configs/dio.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:provider/provider.dart';

class ArticlesApi {
  static getArticles(BuildContext context,
      {Map<String, dynamic>? params,required String endpoint, String? path, bool overrideLanguage = false}) async {
    Response response;
    List<dynamic> body;
    List<Article> articles;
    try {
      response = await DioConfig.dio.get(
        "/$endpoint${path != null ? "/$path" : ""}",
        queryParameters: {
          ...( !overrideLanguage ? {"language": context.read<SettingsProvider>().language} : {}),
          ...?params
        },
      );
      body = response.data["articles"];
      articles = body.map((item) => Article.fromJson(item)).toList();
      return articles;
    } catch (e) {
      if (e is DioException) {
        if (e.type == DioExceptionType.badResponse) {
          log("${e.response!.requestOptions.baseUrl}${e.response!.requestOptions.path}");
          log(e.response!.requestOptions.headers.toString());
          log(e.response!.requestOptions.queryParameters.toString());
        }
      }
      rethrow;
    }
  }

}
