import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;
  bool isLoading = false;
  String? errorMessage;
  String get displayName => _client.auth.currentUser?.userMetadata?['display_name'] as String? ?? 'por aqui';

  Future<bool> signIn(String email, String password) async {
    return _run(() async {
      await _client.auth.signInWithPassword(email: email.trim(), password: password);
    });
  }

  Future<bool> signUp(String name, String email, String password) async {
    return _run(() async {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'display_name': name.trim()},
      );
    });
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Não foi possível concluir. Tente novamente.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
