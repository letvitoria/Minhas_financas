import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/brand_mark.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (!ok) _message(auth.errorMessage ?? 'Falha no login.');
  }

  void _message(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const BrandMark(),
                  const SizedBox(height: 34),
                  Text('Seu dinheiro,\nno seu ritmo.', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800, height: 1.05)),
                  const SizedBox(height: 10),
                  Text('Organize sua vida financeira sem complicação.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 30),
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)), validator: (v) => v == null || !v.contains('@') ? 'Informe um e-mail válido.' : null),
                  const SizedBox(height: 14),
                  TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Senha', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => v == null || v.length < 6 ? 'Use pelo menos 6 caracteres.' : null),
                  const SizedBox(height: 22),
                  ElevatedButton(onPressed: auth.isLoading ? null : _submit, child: auth.isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Entrar')),
                  const SizedBox(height: 18),
                  TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())), child: const Text('Ainda não tem conta? Criar cadastro')),
                  const SizedBox(height: 22),
                  Text('Seus dados ficam protegidos por autenticação e políticas de acesso.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
