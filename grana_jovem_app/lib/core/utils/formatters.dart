import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
final _date = DateFormat('dd/MM/yyyy', 'pt_BR');

String currency(num value) => _currency.format(value);
String dateLabel(DateTime value) => _date.format(value);

/// Os dígitos digitados representam centavos: 123456 -> 1.234,56.
class BrazilianMoneyInputFormatter extends TextInputFormatter {
  static final _number = NumberFormat('#,##0.00', 'pt_BR');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final formatted = _number.format(int.parse(digits) / 100);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

double? parseBrazilianMoney(String value) {
  return double.tryParse(value.trim().replaceAll('.', '').replaceAll(',', '.'));
}
