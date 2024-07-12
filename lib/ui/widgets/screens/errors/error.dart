import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class CommonErrorWidget extends StatelessWidget {
  final Widget icon;
  final String message;
  final void Function() onRetry;
  const CommonErrorWidget({super.key,required this.onRetry, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 15),
            Text(
              message,
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
