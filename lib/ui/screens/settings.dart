import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/providers/feeds.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/components/settings_section_title.dart';
import 'package:newsapp/ui/widgets/screens/webview/webview.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.localize("@settings")),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 17.0),
        child: Column(
          children: [
            const SettingsSectionTitle(title: "@preferences"),
            _buildDarkModeTile(context, settingsProvider),
            _buildLanguageTile(context, settingsProvider),
            const SizedBox(height: 25),
            const SettingsSectionTitle(title: "@browserSettings"),
            _buildJsModeTile(context, settingsProvider),
            _buildCacheSettingTile(context, settingsProvider),
            const SizedBox(height: 25),
            const SettingsSectionTitle(title: "@generalSettings"),
            _buildAccountTile(context),
            _buildGeneralRulesTile(context),
            _buildCopyrightsTile(context),
            if (context.watch<AuthProvider>().authenticated)
              _buildSignOutTile(context),
          ],
        ),
      ),
    );
  }

  ListTile _buildDarkModeTile(BuildContext context, SettingsProvider sp) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        context.localize("@darkMode"),
        style: const TextStyle(overflow: TextOverflow.ellipsis),
      ),
      leading: sp.darkMode
          ? const Icon(Icons.dark_mode_outlined)
          : const Icon(Icons.light_mode_outlined),
      trailing: Switch(
        value: sp.darkMode,
        onChanged: (value) {
          sp.toggleDarkMode();
        },
      ),
    );
  }

  ListTile _buildLanguageTile(BuildContext context, SettingsProvider sp) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        context.localize("@language"),
        style: const TextStyle(overflow: TextOverflow.ellipsis),
      ),
      leading: const Icon(Icons.language_outlined),
      trailing: ChoiceChip(
        selected: true,
        showCheckmark: false,
        onSelected: (value) {
          sp.toggleLang().then((result) {
            context.read<HomeFeedsProvider>().fetchArticles(
                  context,
                  params: {
                    "category": categories["en"]![
                            context.read<HomeFeedsProvider>().selectedCategory]
                        .toLowerCase(),
                  },
                  clean: true,
                );
          });
        },
        label: Text(context.localize("@currentLang")),
      ),
    );
  }

  ListTile _buildJsModeTile(BuildContext context, SettingsProvider sp) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(
        context.localize("@jsMode"),
        style: const TextStyle(overflow: TextOverflow.ellipsis),
      ),
      leading: const Icon(Icons.javascript_outlined),
      trailing: Switch(
        value: sp.jsActive,
        onChanged: (value) {
          if (sp.jsActive) {
            _showJsModeDialog(context, sp);
          } else {
            sp.toggleJsMode();
          }
        },
      ),
    );
  }

  void _showJsModeDialog(BuildContext context, SettingsProvider sp) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.localize("@disableJs"),
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          content: Text(context.localize("@disableJsConfirm")),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(context.localize("@no")),
            ),
            FilledButton(
              onPressed: () {
                context.pop();
                sp.toggleJsMode();
                sp.setJsWarningDisplay(true);
              },
              child: Text(context.localize("@yes")),
            ),
          ],
        );
      },
    );
  }

  ListTile _buildCacheSettingTile(BuildContext context, SettingsProvider sp) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(context.localize("@cacheSetting")),
      leading: const Icon(Icons.cached),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _showCacheSettingDialog(context, sp);
        },
      ),
    );
  }

  void _showCacheSettingDialog(BuildContext context, SettingsProvider sp) {
    showAdaptiveDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            context.localize("@cacheSetting"),
            style: const TextStyle(overflow: TextOverflow.ellipsis),
          ),
          content: Text(context.localize("@emptyCache")),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(context.localize("@no")),
            ),
            FilledButton(
              onPressed: () {
                context.pop();
                // Add logic to empty cache
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text(context.localize("@done")),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Text(context.localize("@yes")),
            ),
          ],
        );
      },
    );
  }

  InkWell _buildAccountTile(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(OtherRoutes.account),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          context.localize("@account"),
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        leading: const Icon(Icons.person_outline),
      ),
    );
  }

  InkWell _buildGeneralRulesTile(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewCustomWidget(url: ExternalLinks.terms),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          context.localize("@generalRules"),
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        leading: const Icon(Icons.text_snippet_outlined),
      ),
    );
  }

  InkWell _buildCopyrightsTile(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WebViewCustomWidget(url: ExternalLinks.copyrights),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          context.localize("@legalMentions"),
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        leading: const Icon(Icons.copyright),
      ),
    );
  }

  InkWell _buildSignOutTile(BuildContext context) {
    return InkWell(
      onTap: () {
        showAdaptiveDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text(context.localize("@signOut")),
            content: Text(context.localize("@confirmSignOut")),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: Text(context.localize("@no")),
              ),
              FilledButton(
                onPressed: () {
                  supabase.auth.signOut().then((value) {
                    CustomSnackBar.info(context, context.localize("@signOutSuccess"), long: true);
                    context.pop();
                  });
                },
                child: Text(context.localize("@yes")),
              ),
            ],
          );
        });
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        title: Text(
          context.localize("@signOut"),
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        leading: const Icon(Icons.logout),
      ),
    );
  }
}
