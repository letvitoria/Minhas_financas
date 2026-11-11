import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';
import '../../shared/widgets/empty_state.dart';

class InvestmentsPage extends StatelessWidget {
  const InvestmentsPage({super.key});
  static const categories = ['Renda Fixa', 'Global', 'Fundos', 'Ações', 'Cripto', 'Outros'];
  static const categoryColors = [AppColors.orange, AppColors.green, Color(0xFF6A70D8), Color(0xFF21A6B5), Color(0xFFB46ADB), Color(0xFF889099)];

  Future<void> _openForm(BuildContext context) async {
    final title = TextEditingController(); final amount = TextEditingController(); String category = categories.first;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheet) => Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text('Novo investimento', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 18),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'Nome do investimento')),
      const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Categoria'), items: categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setSheet(() => category = v ?? categories.first)),
      const SizedBox(height: 12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor investido')),
      const SizedBox(height: 18), ElevatedButton(onPressed: () async { final parsed = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.')); if (title.text.trim().isEmpty || parsed == null || parsed <= 0) return; await context.read<FinanceProvider>().addInvestment(title: title.text.trim(), category: category, amount: parsed); if (context.mounted) Navigator.pop(context); }, child: const Text('Salvar investimento')),
    ]))));
    title.dispose(); amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final total = finance.investmentTotal;
    final grouped = <String, double>{};
    for (final item in finance.investments) { grouped.update(item.category, (value) => value + item.amount, ifAbsent: () => item.amount); }
    return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Investimentos')), floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Investir')), body: finance.isLoading ? const Center(child: CircularProgressIndicator()) : finance.investments.isEmpty ? const EmptyState(icon: Icons.trending_up_rounded, title: 'Sua carteira começa aqui', description: 'Registre seus investimentos para acompanhar a distribuição por categoria.') : ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), children: [
      Container(padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Total investido', style: TextStyle(color: Colors.white70)), const SizedBox(height: 8), Text(currency(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)), const SizedBox(height: 8), const Text('Valores informados por você', style: TextStyle(color: Colors.white54, fontSize: 12))]),
      const SizedBox(height: 22), Text('Sua carteira', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 12),
      ...grouped.entries.toList().asMap().entries.map((entry) { final index = entry.key; final item = entry.value; final fraction = total == 0 ? 0.0 : item.value / total; final color = categoryColors[categories.indexOf(item.key).clamp(0, categoryColors.length - 1).toInt()]; return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 9), Expanded(child: Text(item.key, style: const TextStyle(fontWeight: FontWeight.w800))), Text(currency(item.value), style: const TextStyle(fontWeight: FontWeight.w800))]), const SizedBox(height: 12), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: fraction, minHeight: 8, color: color, backgroundColor: color.withValues(alpha: .12))), const SizedBox(height: 6), Align(alignment: Alignment.centerRight, child: Text('${(fraction * 100).toStringAsFixed(1)}% da carteira', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)))]))); }),
      const SizedBox(height: 12), ...finance.investments.map((item) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 4), title: Text(item.title), subtitle: Text(item.category), trailing: Text(currency(item.amount), style: const TextStyle(fontWeight: FontWeight.w700)))),
    ])));
  }
}
