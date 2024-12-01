import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../components/labeled_text_field.dart';
import '../../pages/auth/email_signup.dart';

class EmailLoginPage extends StatefulWidget {
  const EmailLoginPage({super.key});

  @override
  State<EmailLoginPage> createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loginButtonActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerText(context),
            const SizedBox(height: 40.0),
            LabeledTextField(
              label: "Email",
              inputType: TextInputType.emailAddress,
              controller: _emailController,
              onChanged: _validateLogin,
            ),
            const SizedBox(height: 14.0),
            LabeledTextField(
              label: "Password",
              inputType: TextInputType.text,
              obscureText: true,
              controller: _passwordController,
              onChanged: _validateLogin,
            ),
            const SizedBox(height: 14.0),
            _forgotPasswordButton(context),
            const SizedBox(height: 40.0),
            _bottomButtons(context),
            const SizedBox(height: 32.0),
            _createAccountText(context),
          ],
        ),
      ),
    );
  }

  Widget _headerText(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 256.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ready to scout?",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6.0),
          Text(
            "Enter your information to access your account",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }

  Widget _forgotPasswordButton(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: const Text("Forgot password?"),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const FaIcon(FontAwesomeIcons.arrowLeft),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ElevatedButton(
            // TODO: style button when inactive using MaterialState.disabled
            onPressed: _loginButtonActive ? _loginWithEmail : null,
            child: const Text("Sign In"),
          ),
        )
      ],
    );
  }

  Widget _createAccountText(BuildContext context) {
    return Row(
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 6.0),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EmailSignUpPage()),
            );
          },
          child: const Text("Create one"),
        )
      ],
    );
  }

  void _validateLogin([String? _]) {
    setState(() {
      _loginButtonActive = EmailValidator.validate(_emailController.text) &&
          _passwordController.text.isNotEmpty;
    });
  }

  void _loginWithEmail() async {
    final supabase = Supabase.instance.client;

    final AuthResponse authResponse;
    try {
      authResponse = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (e) {
      // TODO: notify user of the error in the UI
      // https://supabase.com/docs/guides/auth/debugging/error-codes#auth-error-codes-table
      print('email login failed');
      print(e.code);
      print(e.message);
      return;
    }

    if (authResponse.session != null) {
      // TODO: clear nav stack and push home page
      print('email login succeeded');
    }
  }
}
