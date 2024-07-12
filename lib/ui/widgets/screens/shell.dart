import 'package:flutter/material.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/navigation.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';

class Shell extends StatelessWidget {
  final Widget body;
  const Shell({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShellRoutes.toList()[context.watch<ShellProvider>().current].widget,
      bottomNavigationBar: NavigationBar(
        selectedIndex: context.watch<ShellProvider>().current,
        onDestinationSelected: (index) {
          context.read<ShellProvider>().setCurrent = index;
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: context.localize("@home"),
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark),
            label: context.localize("@bookmarks"),
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: context.localize("@settings"),
          ),
        ],
      ),
    );
  }
}