import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../shared/widgets/empty_state.dart';

class IncomePage extends StatelessWidget {
  const IncomePage({super.key});

  Future<void> _openForm(BuildContext context) async {
    final title = TextEditingController(); final amount = TextEditingController();
    String frequency = 'monthly'; DateTime receivedOn = DateTime.now();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheet) => Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text('Adicionar renda', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 18),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'Fonte (salário, bolsa, freelance...)')),
      const SizedBox(height: 12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor (ex.: 1800,00)')),
      const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: frequency, decoration: const InputDecoration(labelText: 'Tipo de renda'), items: const [DropdownMenuItem(value: 'monthly', child: Text('Mensal')), DropdownMenuItem(value: 'extra', child: Text('Extra / eventual'))], onChanged: (v) => setSheet(() => frequency = v ?? 'monthly')),
      ListTile(contentPadding: EdgeInsets.zero, title: const Text('Data de recebimento'), subtitle: Text(dateLabel(receivedOn)), trailing: const Icon(Icons.calendar_month), onTap: () async { final picked = await showDatePicker(context: context, initialDate: receivedOn, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) setSheet(() => receivedOn = picked); }),
      const SizedBox(height: 12), ElevatedButton(onPressed: () async { final parsed = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.')); if (title.text.trim().isEmpty || parsed == null || parsed <= 0) return; await context.read<FinanceProvider>().addIncome(title: title.text.trim(), amount: parsed, frequency: frequency, receivedOn: receivedOn); if (context.mounted) Navigator.pop(context); }, child: const Text('Salvar renda')),
    ]))));
    title.dispose(); amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Minhas rendas')), floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Adicionar renda')), body: finance.isLoading ? const Center(child: CircularProgressIndicator()) : finance.incomes.isEmpty ? const EmptyState(icon: Icons.payments_outlined, title: 'Cadastre sua primeira renda', description: 'Salário, estágio, mesada, bolsa ou trabalhos extras: registre tudo em um só lugar.') : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), itemCount: finance.incomes.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) { final income = finance.incomes[index]; return Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0x1A16A36A), child: Icon(Icons.south_west_rounded, color: AppColors.green)), title: Text(income.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${income.frequency == 'monthly' ? 'Mensal' : 'Extra'} • ${dateLabel(income.receivedOn)}'), trailing: Text(currency(income.amount), style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800)))); })));
  }
}
