import 'package:flutter/material.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/ui/widgets/screens/upgrade.dart';

class EntrancesScreen extends StatelessWidget {
  const EntrancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localize("@entrances"),
        ),
      ),
      body: const UpgradeWidget(),
    );
  }
}
