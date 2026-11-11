import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  SupabaseConfig._();

  static String get url => _required('SUPABASE_URL');
  static String get publishableKey => _required('SUPABASE_PUBLISHABLE_KEY');

  static String _required(String key) {
    final value = dotenv.env[key]?.trim();
    if (value == null || value.isEmpty || value.startsWith('SEU_')) {
      throw StateError('Configure $key no arquivo .env antes de executar o app.');
    }
    return value;
  }
}
