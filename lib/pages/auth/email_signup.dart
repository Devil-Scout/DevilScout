import 'package:devil_scout/components/data_collection_field.dart';
import 'package:devil_scout/pages/auth/login_select.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmailSignUpPage extends StatelessWidget {
  const EmailSignUpPage({super.key});

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
                _InfoText(),
                const SizedBox(height: 40.0),
                const DataCollectionField(
                  label: "Full Name",
                  inputType: TextInputType.name,
                ),
                const SizedBox(height: 14.0),
                const DataCollectionField(
                  label: "Email",
                  inputType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14.0),
                const DataCollectionField(
                  label: "Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 14.0),
                const DataCollectionField(
                  label: "Verify Password",
                  inputType: TextInputType.text,
                  obscureText: true,
                ),
                const SizedBox(height: 40.0),
                _EmailSignUpFunctions(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _EmailSignUpFunctions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
            onPressed: () {},
            child: const Text("Sign Up"),
          ),
        )
      ],
    );
  }
}
