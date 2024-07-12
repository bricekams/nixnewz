import 'package:flutter/material.dart';
import 'package:newsapp/configs/extensions.dart';

class UpgradeWidget extends StatelessWidget {
  const UpgradeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_outlined),
            const SizedBox(height: 15),
            Text(
              context.localize("@upgradeRequired"),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: (){},
              child: Text(
                context.localize("@upgradePlan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
