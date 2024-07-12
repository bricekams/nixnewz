import 'package:flutter/material.dart';
import 'package:newsapp/core/models/article.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/ui/widgets/components/tile.dart';

class FeedsWidgets extends StatelessWidget {
  final FeedsProvider feedsProviderRead;
  final FeedsProvider feedsProviderWatch;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  const FeedsWidgets({super.key, required this.feedsProviderRead, required this.feedsProviderWatch, required this.scrollController, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: Theme.of(context).colorScheme.secondary,
      child: ListView.builder(
        controller: scrollController,
        itemCount: feedsProviderWatch.articles.length + 1,
        itemBuilder: (context, index) {
          if (index < feedsProviderWatch.articles.length) {
            final Article article =
            feedsProviderWatch.articles[index];
            return ArticleTile(article: article);
          } else {
            if (feedsProviderWatch.loadingMore) {
              return Container(
                margin: const EdgeInsets.only(top: 10,bottom: 10),
                child: const Center(
                  child: SizedBox(
                    width: 60,
                    child: LinearProgressIndicator(minHeight: 3),
                  ),
                ),
              );
            }
          }
          return const SizedBox();
        },
      ),
    );
  }
}
