import 'package:flutter/material.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    SettingsProvider settingsProvider = context.watch<SettingsProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          dictionary[title][settingsProvider.language],
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 15),
        const Expanded(
          child: Divider(),
        )
      ],
    );
  }
}
