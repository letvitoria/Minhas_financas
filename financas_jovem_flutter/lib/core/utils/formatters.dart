import 'package:intl/intl.dart';

final _currency = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
final _date = DateFormat('dd/MM/yyyy', 'pt_BR');

String currency(num value) => _currency.format(value);
String dateLabel(DateTime value) => _date.format(value);
