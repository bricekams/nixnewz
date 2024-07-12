import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:provider/provider.dart';

class JsWarningDialog extends StatefulWidget {
  final void Function() onConfirm;

  const JsWarningDialog({super.key, required this.onConfirm});

  @override
  State<JsWarningDialog> createState() => _JsWarningDialogState();
}

class _JsWarningDialogState extends State<JsWarningDialog> {
  bool doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        context.localize("@warning"),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.localize("@enableJsProposal"),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                context.localize("@doNotShowAgain"),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Checkbox(
                value: doNotShowAgain,
                onChanged: (value) {
                  setState(() {
                    doNotShowAgain = !doNotShowAgain;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  context.pop();
                  context
                      .read<SettingsProvider>()
                      .setJsWarningDisplay(!doNotShowAgain);
                },
                child: Text(
                  context.localize("@no"),
                ),
              ),
              const SizedBox(width: 20),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SettingsProvider>().setJsWarningDisplay(false);
                  context.read<SettingsProvider>().toggleJsMode();
                  widget.onConfirm();
                },
                child: Text(
                  context.localize("@yes"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
