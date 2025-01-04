import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import '../../components/labeled_text_field.dart';
import '../../supabase/email_auth.dart';

class EmailSignUpPage extends StatefulWidget {
  const EmailSignUpPage({super.key});

  @override
  State<EmailSignUpPage> createState() => _EmailSignUpPageState();
}

class _EmailSignUpPageState extends State<EmailSignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _verifyController = TextEditingController();

  bool _signupButtonActive = false;

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
                  onChanged: _validateForm,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Email",
                  inputType: TextInputType.emailAddress,
                  controller: _emailController,
                  onChanged: _validateForm,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                  controller: _passwordController,
                  onChanged: _validateForm,
                ),
                const SizedBox(height: 14.0),
                LabeledTextField(
                  label: "Verify Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                  controller: _verifyController,
                  onChanged: _validateForm,
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
          onPressed: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: _signupButtonActive ? _createUser : null,
            child: const Text("Sign Up"),
          ),
        )
      ],
    );
  }

  void _createUser() async {
    await supabaseCreateEmailUser(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _validateForm([String? _]) {
    setState(() {
      _signupButtonActive = _nameController.text.isNotEmpty &&
          EmailValidator.validate(_emailController.text) &&
          _passwordController.text.isNotEmpty &&
          _passwordController.text == _verifyController.text;
    });
    print(_signupButtonActive);
  }
}
