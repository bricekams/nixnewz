import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/api/articles.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/configs/enums.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:provider/provider.dart';

class FeedsProvider with ChangeNotifier {
  String endpoint = "top-headlines";

  int _selectedCategory = 0;

  int get selectedCategory => _selectedCategory;
  final List<Article> _articles = [];

  List<Article> get articles => _articles;
  int _page = 1;
  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;
  ErrorType? _loadingMoreError;
  ErrorType? get loadingMoreError => _loadingMoreError;
  void resetPage() {
    _page = 1;
  }

  bool _loading = false;
  ErrorType? _error;

  bool get loading => _loading;

  ErrorType? get error => _error;

  set selectedCategory(int value) {
    _selectedCategory = value;
    notifyListeners();
  }

  set articles(List<Article> value) {
    _articles.addAll(value);
  }

  Future<void> fetchArticles(BuildContext context,
      {Map<String, dynamic>? params, String? path, bool clean = false}) async {
    if (clean) {
      resetPage();
      _articles.clear();
    }
    if (_articles.isNotEmpty) {
      return;
    }
    _error = null;
    _loading = true;
    notifyListeners();
    try {
      final List<Article> articles = await ArticlesApi.getArticles(context,
          endpoint: endpoint,
          path: path,
          params: {"page": _page, "pageSize": 20, ...?params});
      _articles.addAll(articles);
      _loading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = handleError(e);
      _loading = false;
      notifyListeners();
    }
  }

  void fetchMoreArticles(BuildContext context,
      {Map<String, dynamic>? params, String? path}) {
    if (_loadingMore) return;
    _loadingMore = true;
    _loadingMoreError = null;
    notifyListeners();
    _page++;
    ArticlesApi.getArticles(context,
        endpoint: endpoint,
        path: path,
        params: {"page": _page, "pageSize": 20, ...?params}).then((value) {
      _articles.addAll(value);
      _loadingMore = false;
      _loadingMoreError = null;
      notifyListeners();
    }).catchError((e) {
      _page--;
      _loadingMore = false;
      _loadingMoreError = handleError(e);
      notifyListeners();

      CustomSnackBar.error(
        context,
        errorMessages[_loadingMoreError!]?["message"]
                [context.read<SettingsProvider>().language] ??
            "Something went wrong!",
      );
    });
  }
}

class HomeFeedsProvider extends FeedsProvider {}

class FromSourceFeedsProvider extends FeedsProvider {}
