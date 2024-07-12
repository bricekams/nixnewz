import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/search.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/screens/search_criteria.dart';
import 'package:newsapp/ui/widgets/components/tile.dart';
import 'package:newsapp/ui/widgets/screens/shimmer.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:provider/provider.dart';

class CustomSearchDelegate extends SearchDelegate {
  @override
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const SearchCriteriaScreen(),
            ),
          );
        },
        icon: const Icon(Icons.tune),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.read<SearchProvider>().reset(context);
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: context.read<SearchProvider>().search(context, query: query),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (context.read<SearchProvider>().articles.isEmpty) {
            return Center(
              child: Text(
                context.localize("@noResults"),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          return ListView.builder(
            itemCount: context.read<SearchProvider>().articles.length,
            itemBuilder: (context, index) {
              final article = context.read<SearchProvider>().articles[index];
              // todo: add bottom loading indicator
              return ArticleTile(article: article);
            },
          );
        }
        if (snapshot.hasError) {
          final error = handleError(snapshot.error);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  errorMessages[error!]?["icon"],
                  const SizedBox(height: 15),
                  Text(
                    errorMessages[error!]?["message"]
                        [context.read<SettingsProvider>().language],
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  FilledButton(
                    onPressed: () {
                      buildResults(context);
                    },
                    child: Text(context.localize("@tryAgain")),
                  ),
                ],
              ),
            ),
          );
        }
        return const LoadingShimmer();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
