import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../shared/widgets/brand_mark.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _name.dispose(); _email.dispose(); _password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signUp(_name.text, _email.text, _password.text);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Cadastro enviado. Confira seu e-mail caso a confirmação esteja habilitada.' : auth.errorMessage ?? 'Não foi possível cadastrar.')));
    if (ok && Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 440), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const BrandMark(), const SizedBox(height: 28),
        Text('Crie sua conta', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8), Text('Um passo de cada vez. Comece por aqui.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor)),
        const SizedBox(height: 26),
        TextFormField(controller: _name, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Como quer ser chamado?', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().length < 2 ? 'Informe seu nome.' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'E-mail', prefixIcon: Icon(Icons.mail_outline)), validator: (v) => v == null || !v.contains('@') ? 'Informe um e-mail válido.' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _password, obscureText: _obscure, decoration: InputDecoration(labelText: 'Senha (mínimo 6 caracteres)', prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined))), validator: (v) => v == null || v.length < 6 ? 'A senha precisa ter pelo menos 6 caracteres.' : null),
        const SizedBox(height: 22),
        ElevatedButton(onPressed: auth.isLoading ? null : _submit, child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Criar conta')),
      ]))))),
    );
  }
}
