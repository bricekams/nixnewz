import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/configs/extensions.dart';
import 'package:newsapp/core/providers/timer.dart';
import 'package:newsapp/core/storage/settings.dart';
import 'package:newsapp/ui/widgets/components/fields/text_field.dart';
import 'package:newsapp/utils/helpers.dart';
import 'package:newsapp/utils/localization.dart';
import 'package:newsapp/utils/routes.dart';
import 'package:provider/provider.dart';

class EmailAuthScreen extends StatelessWidget {
  const EmailAuthScreen({super.key});

  static final TextEditingController emailController = TextEditingController();
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
              _EmailForm(),
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
    SettingsProvider sp = context.read<SettingsProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dictionary["@signin"][sp.language],
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
              ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                style: Theme.of(context).textTheme.titleSmall,
                text: "${context.localize('@emailExplain')}. ",
              ),
              TextSpan(
                text: context.localize('@learnMore'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      decoration: TextDecoration.underline,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmailForm extends StatefulWidget {
  const _EmailForm();

  @override
  State<_EmailForm> createState() => _EmailFormState();
}

class _EmailFormState extends State<_EmailForm> {
  bool processing = false;
  bool onceSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: EmailAuthScreen.formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: EmailAuthScreen.emailController,
            keyboardType: TextInputType.emailAddress,
            autoValidateMode: !onceSubmitted
                ? AutovalidateMode.disabled
                : AutovalidateMode.onUserInteraction,
            suffixIcon: const Icon(Icons.email),
            label: const Text("Email"),
            hintText: 'example@email.com',
            validator: (value) {
              RegExp regex = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
              if (value == null || !regex.hasMatch(value)) {
                return context.localize('@invalidEmail');
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  if (!EmailAuthScreen.formKey.currentState!.validate()) return;
                  if (!onceSubmitted) {
                    setState(() {
                      onceSubmitted = true;
                    });
                  }
                  setState(() {
                    processing = true;
                  });

                  await AuthHelper.signInWithOtp(
                    context,
                    email: EmailAuthScreen.emailController.text,
                    onCodeSent: () {
                      setState(() {
                        processing = false;
                      });
                      context.read<TimerProvider>().startEmailTimer();
                      context.pushNamed(OtherRoutes.otp);
                    },
                    onError: () {
                      setState(() {
                        processing = false;
                      });
                    },
                  );
                },
                label: Text(context.localize('@sendCode')),
                icon: processing
                    ? SizedBox(
                        width: 11,
                        height: 11,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
