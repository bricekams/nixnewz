import 'package:flutter/cupertino.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/enums.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/api/articles.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:provider/provider.dart';

class SearchProvider with ChangeNotifier {
  late String _language;
  String _sortBy = "publishedAt";

  String get sortBy => _sortBy;

  String get language => _language;

  SearchProvider(BuildContext context) {
    _language = context.read<SettingsProvider>().language;
  }

  set sortBy(String value) {
    _sortBy = value;
    notifyListeners();
  }

  set language(String value) {
    _language = value;
    notifyListeners();
  }

  reset(BuildContext context) {
    sortBy = "publishedAt";
    language = context.read<SettingsProvider>().language;
  }

  List<Article> _results = [];

  List<Article> get articles => _results;
  int _page = 1;
  bool _loadingMore = false;

  bool get loadingMore => _loadingMore;
  ErrorType? _loadingMoreError;

  ErrorType? get loadingMoreError => _loadingMoreError;

  void resetPage() {
    _page = 1;
  }

  void clear() {
    _results.clear();
    notifyListeners();
  }

  Future<List<Article>> search(BuildContext context,
      {required String query, Map<String, dynamic>? params}) async {
    final List<Article> articles = await ArticlesApi.getArticles(
      context,
      endpoint: "everything",
      overrideLanguage: true,
      params: {"q": query, "sortBy": _sortBy, "language": language, ...?params},
    );
    _results = articles;
    notifyListeners();
    return articles;
  }

  void fetchMoreResults(BuildContext context, {required String query}) async {
    try {
      if (_loadingMore) return;
      _loadingMore = true;
      _loadingMoreError = null;
      notifyListeners();
      _page++;
      List<Article> articles = await search(context,
          query: query, params: {"page": _page, "pageSize": 20});
      _results.addAll(articles);
      _loadingMore = false;
      _loadingMoreError = null;
      notifyListeners();
    } catch (e) {
      _page--;
      _loadingMore = false;
      _loadingMoreError = handleError(e);
      notifyListeners();
      if (context.mounted) {
        CustomSnackBar.error(
          context,
          errorMessages[_loadingMoreError!]?["message"]
                  [context.read<SettingsProvider>().language] ??
              context.localize("@error"),
        );
      }
    }
  }
}
