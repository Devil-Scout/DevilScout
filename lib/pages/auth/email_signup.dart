import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../components/labeled_text_field.dart';
import '../../router.dart';
import '../../supabase/database.dart';

class EmailSignUpPage extends StatelessWidget {
  EmailSignUpPage({super.key});

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _headerText(context),
                const SizedBox(height: 40.0),
                LabeledTextField(
                  label: "Full Name",
                  inputType: TextInputType.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Email",
                  inputType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Verify Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                  controller: _verifyController,
                ),
                const SizedBox(height: 40.0),
                _bottomButtons(context),
              ],
            ),
          ),
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
            "Welcome!",
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 6.0),
          Text(
            "Level up your scouting with the DevilScout platform",
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
      ),
    );
  }

  Widget _bottomButtons(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: router.pop,
          child: Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([
              _nameController,
              _emailController,
              _passwordController,
              _verifyController,
            ]),
            builder: (context, _) {
              return ElevatedButton(
                onPressed: _isFormValid() ? () => _createUser(context) : null,
                child: const Text('Sign Up'),
              );
            },
          ),
        ),
      ],
    );
  }

  void _createUser(BuildContext context) async {
    try {
      await Database.of(context).auth.signUpWithEmail(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          );
    } catch (e) {
      // TODO: notify user of error
    }
  }

  bool _isFormValid() =>
      _nameController.text.isNotEmpty &&
      EmailValidator.validate(_emailController.text) &&
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _verifyController.text;
}
