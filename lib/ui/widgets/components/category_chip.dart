import 'package:flutter/material.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class CategoryChip extends StatelessWidget {
  final int index;
  final FeedsProvider feedsProviderRead;
  final FeedsProvider feedsProviderWatch;

  const CategoryChip({super.key, required this.index, required this.feedsProviderRead, required this.feedsProviderWatch});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: index == feedsProviderWatch.selectedCategory,
      selectedColor: Theme.of(context).colorScheme.surfaceContainerLow,
      onSelected: (value) {
        if (index == feedsProviderRead.selectedCategory) return;
        feedsProviderRead.selectedCategory = index;
        feedsProviderRead.fetchArticles(
          context,
          params: {
            "category":
                categories["en"]![index]
          },
          clean: true,
        );
      },
      label:
          Text(categories[context.read<SettingsProvider>().language]![index]),
    );
  }
}
