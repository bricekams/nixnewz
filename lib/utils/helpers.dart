import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/enums.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

handleError(e) {
  log(e?.toString() ?? "An error occured");
  if (e is DioException) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ErrorType.NETWORK;
    }
    if (e.type == DioExceptionType.badResponse) {
      return ErrorType.SERVER;
    }
    return ErrorType.UNKNOWN;
  } else {
    return ErrorType.UNKNOWN;
  }
}

class AuthHelper {

  static Future<void> signInWithOtp(BuildContext context,
      {required String email,
      required void Function() onCodeSent,
      required void Function() onError}) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
      );
      onCodeSent();
    } catch (error) {
      onError();
      if (context.mounted) {
        if (error is AuthApiException) {
          log(error.message);
          CustomSnackBar.error(
            context,
            error.message,
          );
          return;
        }
        CustomSnackBar.error(
          context,
          dictionary["@error"][context.read<SettingsProvider>().language],
        );
        return;
      }
    }
  }

  static Future<AuthResponse?> verifyOtp(BuildContext context,
      {required String email, required String token}) async {
    try {
      final response = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: token,
        email: email,
      );
      return response;
    } catch (error) {
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
      return null;
    }
  }
}

class CustomSnackBar {
  static void error(BuildContext context, String message, {bool long = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: long ? const Duration(seconds: 4) : const Duration(milliseconds: 700),
      ),
    );
  }

  static void success(BuildContext context, String message, {bool long = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.green,
        duration: long ? const Duration(seconds: 4) : const Duration(milliseconds: 700),
      ),
    );
  }

  static void info(BuildContext context, String message, {bool long = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: long ? const Duration(seconds: 4) : const Duration(milliseconds: 700),
      ),
    );
  }
}
