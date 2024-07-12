import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/models/bookmark.dart';


class BookmarksProvider with ChangeNotifier {
  List<Bookmark>? _bookmarks;

  List<Bookmark>? get bookmarks {
    if (_bookmarks == null) return null;
    _bookmarks!.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return _bookmarks;
  }

  bool _error = false;

  bool get error => _error;
  bool _loading = false;

  bool get loading => _loading;

  /// [cold] is set to false just after user logs in and he is in the bookmarks screen
  Future<void> init({cold = true}) async {
    _error = false;
    _loading = true;
    if (cold) notifyListeners();
    try {
      final response = (await supabase.from("bookmarks").select("*").eq("owner", supabase.auth.currentUser!.id))
          .map((e) => Bookmark.fromJson(e))
          .toList();
      _bookmarks ??= response;
      _loading = false;
      _error = false;
      notifyListeners();
      return;
    } catch (e) {
      log(e.toString());
      _error = true;
      _loading = false;
      notifyListeners();
      return;
    }
  }

  Future<void> addBookmark(BuildContext context,
      {required Bookmark bookmark}) async {
    try {
      final response = await supabase
          .from("bookmarks")
          .insert(bookmark.toJson())
          .select("*");
      bookmark = Bookmark.fromJson(response.first);
      _bookmarks ??= [];
      _bookmarks!.add(bookmark);
      notifyListeners();
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  Future<void> removeBookmark(Bookmark bookmark) async {
    try {
      _bookmarks ??= [];
      _bookmarks!.removeWhere((element) => element.id == bookmark.id);
      notifyListeners();
      await supabase.from("bookmarks").delete().eq("id", bookmark.id);
      notifyListeners();
    } catch (e) {
      _bookmarks ??= [];
      _bookmarks!.add(bookmark);
      notifyListeners();
      log(e.toString());
      rethrow;
    }
  }

  isBookmarked(String id) {
    return _bookmarks?.any((element) => element.id == id) ?? false;
  }

  clear() {
    _bookmarks = null;
    _error = false;
    _loading = false;
    notifyListeners();
  }
}
