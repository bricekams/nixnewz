import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/ui/widgets/components/tile.dart';
import 'package:newsapp/ui/widgets/screens/errors/error.dart';
import 'package:newsapp/ui/widgets/screens/shimmer.dart';
import 'package:newsapp/ui/widgets/screens/signin_required.dart';
import 'package:provider/provider.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeBookmarks());
  }

  void _initializeBookmarks() {
    if (context.read<BookmarksProvider>().bookmarks == null &&
        context.read<AuthProvider>().authenticated) {
      context.read<BookmarksProvider>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.localize('@bookmarks')),
      ),
      body: Builder(
        builder: (context) {
          switch (context.watch<AuthProvider>().authenticated) {
            case true:
              if (context.read<BookmarksProvider>().error) {
                return CommonErrorWidget(
                  onRetry: context.read<BookmarksProvider>().init,
                  icon: const Icon(Icons.error, size: 60),
                  message: context.localize('@failedToFetchBookmarks'),
                );
              }
              if (context.watch<BookmarksProvider>().bookmarks == null) {
                context.read<BookmarksProvider>().init(cold: false);
              }
              switch (context.watch<BookmarksProvider>().bookmarks == null) {
                case true:
                  return const LoadingShimmer();
                case false:
                  switch (context.watch<BookmarksProvider>().loading) {
                    case false:
                      switch (context
                          .watch<BookmarksProvider>()
                          .bookmarks!
                          .isEmpty) {
                        case true:
                          return _buildEmptyBookmarksMessage(context);
                        case false:
                          return _buildBookmarksList(
                              context.watch<BookmarksProvider>());
                      }
                    case true:
                      return const LoadingShimmer();
                  }
              }
            case false:
              return const SigninRequiredWidget();
          }
        },
      ),
    );
  }

  Widget _buildEmptyBookmarksMessage(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book_outlined, size: 60),
          const SizedBox(height: 15),
          Text(
            context.localize('@bookmarksEmpty'),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(BookmarksProvider bookmarksProvider) {
    return RefreshIndicator(
      onRefresh: () async {
        return await bookmarksProvider.init();
      },
      child: ListView.builder(
        itemCount: bookmarksProvider.bookmarks!.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarksProvider.bookmarks![index];
          return ArticleTile(article: bookmark.article, canSlide: true);
        },
      ),
    );
  }
}
