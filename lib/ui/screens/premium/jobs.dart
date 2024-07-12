import 'package:flutter/material.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/ui/widgets/screens/upgrade.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.localize("@jobs"),
        ),
      ),
      body: const UpgradeWidget(),
    );
  }
}
