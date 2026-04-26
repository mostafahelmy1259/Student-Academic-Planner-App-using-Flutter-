import 'package:flutter/material.dart';

class ConfigMissingScreen extends StatelessWidget {
  final String? errorMessage;

  const ConfigMissingScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase Setup Required')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: ListView(
              children: [
                const Icon(Icons.cloud_off, size: 72, color: Colors.indigo),
                const SizedBox(height: 16),
                Text(
                  'Connect this app to Firebase',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'This project is complete, but Firebase needs your own project keys. '
                  'Run these commands in the project folder:',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                _CodeBox(
                  text:
                      'dart pub global activate flutterfire_cli\nflutterfire configure\nflutter pub get\nflutter run',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Also enable Email/Password sign-in in Firebase Authentication and create a Cloud Firestore database.',
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 18),
                  Text(
                    'Startup message:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(errorMessage!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  final String text;

  const _CodeBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
