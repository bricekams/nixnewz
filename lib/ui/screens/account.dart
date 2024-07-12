import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/providers/auth.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/screens/errors/error.dart';
import 'package:newsapp/ui/widgets/screens/signin_required.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool authenticated = context.watch<AuthProvider>().authenticated == true;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            dictionary["@account"][context.read<SettingsProvider>().language]),
      ),
      body: authenticated
          ? Center(
              child: TextButton(
                onPressed: () {
                  supabase.auth.signOut();
                },
                child: Text(dictionary["@signOut"]
                    [context.read<SettingsProvider>().language]),
              ),
            )
          : const SigninRequiredWidget(),
    );
  }
}
