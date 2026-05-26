import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();

  void _doLogin() {
    if (_nameCtrl.text.trim().isEmpty) return;
    context.read<AppProvider>().login(_nameCtrl.text.trim(), "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.shield, size: 100, color: AppTheme.primary),
              const SizedBox(height: 16),
              Text('FieldKit AI', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 32)),
              const SizedBox(height: 8),
              const Text('Portale Operativo - Web App', textAlign: TextAlign.center),
              const SizedBox(height: 48),
              TextField(
                controller: _nameCtrl, 
                decoration: const InputDecoration(labelText: 'Inserisci il tuo Nome e Cognome', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person))
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _doLogin, child: const Text('ENTRA NEL SISTEMA', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }
}