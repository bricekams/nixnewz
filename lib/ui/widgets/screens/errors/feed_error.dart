import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class FeedErrorWidget extends StatelessWidget {
  final FeedsProvider feedsProviderRead;
  final void Function() onRetry;
  const FeedErrorWidget({super.key, required this.feedsProviderRead,required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            errorMessages[feedsProviderRead.error!]?["icon"],
            const SizedBox(height: 15),
            Text(
              errorMessages[feedsProviderRead.error!]?["message"][context.read<SettingsProvider>().language] ?? "Something went wrong but it's not your fault!",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: onRetry,
              child: Text(dictionary["@tryAgain"]?[context.read<SettingsProvider>().language]! ?? "Try again"),
            ),
          ],
        ),
      ),
    );
  }
}
