import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../shared/widgets/empty_state.dart';

class BillsPage extends StatelessWidget {
  const BillsPage({super.key});

  Future<void> _openForm(BuildContext context) async {
    final title = TextEditingController(); final amount = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 3));
    String recurrence = 'monthly';
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheet) => Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        Text('Nova conta', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 18),
        TextField(controller: title, decoration: const InputDecoration(labelText: 'Nome da conta')),
        const SizedBox(height: 12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor (ex.: 120,50)')),
        const SizedBox(height: 12), ListTile(contentPadding: EdgeInsets.zero, title: const Text('Data de vencimento'), subtitle: Text(dateLabel(dueDate)), trailing: const Icon(Icons.calendar_month), onTap: () async { final picked = await showDatePicker(context: context, initialDate: dueDate, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) setSheet(() => dueDate = picked); }),
        DropdownButtonFormField<String>(initialValue: recurrence, decoration: const InputDecoration(labelText: 'Recorrência'), items: const [DropdownMenuItem(value: 'none', child: Text('Não se repete')), DropdownMenuItem(value: 'monthly', child: Text('Mensal')), DropdownMenuItem(value: 'yearly', child: Text('Anual'))], onChanged: (v) => setSheet(() => recurrence = v ?? 'monthly')),
        const SizedBox(height: 18), ElevatedButton(onPressed: () async { final parsed = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.')); if (title.text.trim().isEmpty || parsed == null || parsed <= 0) return; await context.read<FinanceProvider>().addBill(title: title.text.trim(), amount: parsed, dueDate: dueDate, recurrence: recurrence); if (context.mounted) Navigator.pop(context); }, child: const Text('Salvar conta')),
      ])),
    )));
    title.dispose(); amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Contas a vencer'), actions: [IconButton(onPressed: () => _openForm(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.orange))]), floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Nova conta')), body: finance.isLoading ? const Center(child: CircularProgressIndicator()) : finance.bills.isEmpty ? const EmptyState(icon: Icons.receipt_long_outlined, title: 'Nenhuma conta cadastrada', description: 'Adicione aluguel, assinaturas ou outras contas para não perder os vencimentos.') : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), itemCount: finance.bills.length, separatorBuilder: (_, __) => const SizedBox(height: 10), itemBuilder: (context, index) { final bill = finance.bills[index]; return Card(child: ListTile(leading: CircleAvatar(backgroundColor: bill.isPaid ? AppColors.green.withValues(alpha: .12) : AppColors.orange.withValues(alpha: .12), child: Icon(bill.isPaid ? Icons.check : Icons.calendar_month, color: bill.isPaid ? AppColors.green : AppColors.orange)), title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('Vencimento: ${dateLabel(bill.dueDate)} • ${_recurrenceLabel(bill.recurrence)}'), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text(currency(bill.amount), style: const TextStyle(fontWeight: FontWeight.w800)), TextButton(onPressed: () => context.read<FinanceProvider>().toggleBill(bill), child: Text(bill.isPaid ? 'Reabrir' : 'Pagar'))]))); }));
  }

  String _recurrenceLabel(String value) => switch (value) { 'monthly' => 'Mensal', 'yearly' => 'Anual', _ => 'Única' };
}
