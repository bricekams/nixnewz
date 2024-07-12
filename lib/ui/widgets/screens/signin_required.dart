import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';

class SigninRequiredWidget extends StatelessWidget {
  const SigninRequiredWidget({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsProvider sp = context.read<SettingsProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.localize('@signinRequired'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            FilledButton(
              onPressed: () {
                context.pushNamed(OtherRoutes.signin);
              },
              child: Text(context.localize('@signin')),
            ),
          ],
        ),
      ),
    );
  }
}
