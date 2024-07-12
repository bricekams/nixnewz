import 'package:flutter/cupertino.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider with ChangeNotifier {
  bool _authenticated = false;

  bool get authenticated => _authenticated;

  init(BuildContext context) {
    supabase.auth.onAuthStateChange.listen(
      (data) {
        _authenticated = data.session?.user != null;
        if (!_authenticated) {
          if (context.mounted) {
            context.read<BookmarksProvider>().clear();
          }
        }
        notifyListeners();
      },
      onError: (error) {
        if (error is AuthException) {
          if (context.mounted) {
            if (error is AuthApiException) {
              CustomSnackBar.error(
                context,
                error.message,
              );
              return null;
            }
            CustomSnackBar.error(
              context,
              dictionary["@error"][context.read<SettingsProvider>().language],
            );
          }
        }
      },
    );
  }

  retryInit(BuildContext context) {
    supabase.auth.onAuthStateChange.listen(
      (data) {
        _authenticated = data.session?.user != null;
        notifyListeners();
      },
      onError: (error) {
        if (error is AuthException) {
          if (context.mounted) {
            if (error is AuthApiException) {
              CustomSnackBar.error(
                context,
                error.message,
              );
              return null;
            }
            CustomSnackBar.error(
              context,
              dictionary["@error"][context.read<SettingsProvider>().language],
            );
          }
        }
      },
    );
  }
}
