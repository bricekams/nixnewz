import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/constants.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/bookmarks.dart';
import 'package:newsapp/core/providers/navigation.dart';
import 'package:newsapp/core/providers/timer.dart';
import 'package:newsapp/ui/screens/auth/email.dart';
import 'package:newsapp/ui/widgets/components/fields/code.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key});

  static final List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 13.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              SizedBox(height: 20),
              _OTPForm(),
              SizedBox(height: 10),
              _ResendOTP(),
              SizedBox(height: 20),
              _VerifyButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.localize('@emailVerification'),
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        Text(
          context.localize('@otpSent'),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _OTPForm extends StatelessWidget {
  const _OTPForm();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: OTPScreen.formKey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: OTPScreen.otpControllers
            .indexedMap(
              (controller, index) => Padding(
                padding: index == 0
                    ? const EdgeInsets.only(left: 0)
                    : const EdgeInsets.only(left: 5),
                child: OTPField(
                  controller: controller,
                  textInputAction: index == OTPScreen.otpControllers.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onChanged: (value) {
                    if (index != OTPScreen.otpControllers.length - 1 &&
                        controller.text.isNotEmpty) {
                      FocusScope.of(context).nextFocus();
                      if (OTPScreen.otpControllers[index + 1].text.isNotEmpty) {
                        OTPScreen.otpControllers[index + 1].text = '';
                      }
                    }
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ResendOTP extends StatefulWidget {
  const _ResendOTP();

  @override
  State<_ResendOTP> createState() => _ResendOTPState();
}

class _ResendOTPState extends State<_ResendOTP> {
  bool resending = false;

  @override
  Widget build(BuildContext context) {
    TimerProvider timerProvider = context.read<TimerProvider>();
    TimerProvider timerProviderWatch = context.watch<TimerProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (resending)
          SizedBox(
            width: 9,
            height: 9,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        if (resending) const SizedBox(width: 5),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor:
                (resending || !timerProviderWatch.canRequestEmailCode)
                    ? Theme.of(context).colorScheme.secondary
                    : null,
          ),
          onPressed: () async {
            if (resending || !timerProviderWatch.canRequestEmailCode) {
              return;
            }
            setState(() {
              resending = true;
            });
            try {
              await supabase.auth.resend(
                type: OtpType.signup,
                email: EmailAuthScreen.emailController.text,
              );
              timerProvider.startEmailTimer();
            } catch (error) {
              log(error.toString());
              if (context.mounted) {
                if (error is DioException) {
                  final err = handleError(error);
                  CustomSnackBar.error(
                    context,
                    context.localize(errorMessages[err]!["message"]),
                  );
                } else if (error is AuthApiException) {
                  CustomSnackBar.error(context, error.message);
                } else {
                  CustomSnackBar.error(context, context.localize('@error'));
                }
              }
            } finally {
              setState(() {
                resending = false;
              });
            }
          },
          child: Text(
            "${context.localize('@resendOTP')}"
            "${timerProviderWatch.canRequestEmailCode ? "" : "? ${timerProviderWatch.emailCodeTimer}"}",
          ),
        ),
      ],
    );
  }
}

class _VerifyButton extends StatefulWidget {
  const _VerifyButton();

  @override
  State<_VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<_VerifyButton> {
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FilledButton.icon(
          onPressed: () async {
            if (processing) return;
            setState(() {
              processing = true;
            });

            String otp = OTPScreen.otpControllers
                .map((controller) => controller.text)
                .join();
            bool isDigitsOnly = otp.contains(RegExp(r'^[0-9]+$'));
            if (otp.length != 6 || !isDigitsOnly) {
              CustomSnackBar.error(
                context,
                context.localize('@invalidOTP'),
              );
              setState(() {
                processing = false;
              });
              return;
            }

            try {
              AuthResponse? response = await AuthHelper.verifyOtp(
                context,
                token: otp,
                email: EmailAuthScreen.emailController.text,
              );
              if (response != null && response.user != null) {
                if (context.mounted) {
                  switch (context.read<ShellProvider>().current) {
                    case 0:
                      context.goNamed(ShellRoutes.home.name);
                      break;
                    case 1:
                      context.read<BookmarksProvider>().init();
                      context.goNamed(ShellRoutes.bookmarks.name);
                      break;
                    case 2:
                      context.goNamed(ShellRoutes.settings.name);
                      break;
                  }
                }
              } else {
                log(response.toString());
              }
            } catch (error) {
              log(error.toString());
              if (context.mounted) {
                CustomSnackBar.error(context, context.localize('@error'));
              }
            } finally {
              setState(() {
                processing = false;
              });
            }
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          icon: processing
              ? SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                )
              : null,
          label: Text(context.localize('@verify')),
        ),
      ],
    );
  }
}
