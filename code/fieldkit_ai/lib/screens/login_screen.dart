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
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 48.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Image.asset('lib/assets/icons/logo.png', width: 100, height: 100, errorBuilder: (context, error, stackTrace) => const Icon(Icons.shield, size: 80, color: AppTheme.primary)),
                    ),
                    const SizedBox(height: 24),
                    Text('FieldKit AI', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primary, fontSize: 28)),
                    const SizedBox(height: 8),
                    Text('Portale operativo', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textLight, fontSize: AppTheme.bodySize(context))),
                    const SizedBox(height: 48),
                    TextField(
                      controller: _nameCtrl, 
                      decoration: const InputDecoration(labelText: 'Utente', prefixIcon: Icon(Icons.person))
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _doLogin, 
                      child: const Text('Entra', style: TextStyle(fontWeight: FontWeight.bold))
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}