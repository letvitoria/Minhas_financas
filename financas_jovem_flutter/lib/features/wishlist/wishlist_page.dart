import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/finance_models.dart';
import '../../providers/finance_provider.dart';
import '../../shared/widgets/empty_state.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  Future<void> _openForm(BuildContext context) async {
    final title = TextEditingController(); final amount = TextEditingController(); DateTime? targetDate;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, showDragHandle: true, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheet) => Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      Text('Novo desejo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)), const SizedBox(height: 18),
      TextField(controller: title, decoration: const InputDecoration(labelText: 'O que você quer conquistar?')),
      const SizedBox(height: 12), TextField(controller: amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quanto precisa juntar?')),
      ListTile(contentPadding: EdgeInsets.zero, title: const Text('Prazo (opcional)'), subtitle: Text(targetDate == null ? 'Sem prazo definido' : dateLabel(targetDate!)), trailing: const Icon(Icons.event), onTap: () async { final picked = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 90)), firstDate: DateTime.now(), lastDate: DateTime(2100)); if (picked != null) setSheet(() => targetDate = picked); }),
      const SizedBox(height: 12), ElevatedButton(onPressed: () async { final parsed = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.')); if (title.text.trim().isEmpty || parsed == null || parsed <= 0) return; await context.read<FinanceProvider>().addGoal(title: title.text.trim(), targetAmount: parsed, targetDate: targetDate); if (context.mounted) Navigator.pop(context); }, child: const Text('Criar meta')),
    ]))));
    title.dispose(); amount.dispose();
  }

  Future<void> _addSaved(BuildContext context, WishlistGoal goal) async {
    final amount = TextEditingController();
    await showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: Text('Guardar para ${goal.title}'), content: TextField(controller: amount, autofocus: true, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Quanto você guardou?')), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')), FilledButton(onPressed: () async { final parsed = double.tryParse(amount.text.replaceAll('.', '').replaceAll(',', '.')); if (parsed == null || parsed <= 0) return; try { await context.read<FinanceProvider>().addToGoal(goal, parsed); } catch (error) { if (dialogContext.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString()))); } if (dialogContext.mounted) Navigator.pop(dialogContext); }, child: const Text('Adicionar'))]));
    amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return SafeArea(child: Scaffold(backgroundColor: Colors.transparent, appBar: AppBar(title: const Text('Lista de desejos')), floatingActionButton: FloatingActionButton.extended(onPressed: () => _openForm(context), icon: const Icon(Icons.add), label: const Text('Novo desejo')), body: finance.isLoading ? const Center(child: CircularProgressIndicator()) : finance.goals.isEmpty ? const EmptyState(icon: Icons.favorite_border_rounded, title: 'Qual é seu próximo sonho?', description: 'Crie uma meta para acompanhar quanto falta para comprar algo especial.') : ListView.separated(padding: const EdgeInsets.fromLTRB(20, 8, 20, 100), itemCount: finance.goals.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (context, index) { final goal = finance.goals[index]; return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: .12), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.favorite_rounded, color: AppColors.orange)), const SizedBox(width: 12), Expanded(child: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))), Text('${(goal.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900))]), const SizedBox(height: 18), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: goal.progress, minHeight: 9, color: AppColors.orange, backgroundColor: AppColors.orange.withValues(alpha: .12))), const SizedBox(height: 10), Row(children: [Expanded(child: Text('${currency(goal.savedAmount)} guardados', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700))), Text('Meta ${currency(goal.targetAmount)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))]), if (goal.targetDate != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Prazo: ${dateLabel(goal.targetDate!)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))), const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: goal.progress >= 1 ? null : () => _addSaved(context, goal), icon: const Icon(Icons.add), label: const Text('Guardar valor')))]))); })));
  }
}
