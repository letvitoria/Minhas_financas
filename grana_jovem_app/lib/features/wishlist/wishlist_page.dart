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
    final title = TextEditingController();
    final amount = TextEditingController();
    DateTime? targetDate;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Text('Nova meta', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'O que você quer conquistar?')),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [BrazilianMoneyInputFormatter()],
                decoration: const InputDecoration(labelText: 'Valor que deseja alcançar'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Prazo da meta (opcional)'),
                subtitle: Text(targetDate == null ? 'Sem prazo definido' : dateLabel(targetDate!)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 90)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setSheet(() => targetDate = picked);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final parsed = parseBrazilianMoney(amount.text);
                  if (title.text.trim().isEmpty || parsed == null || parsed <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe uma descrição e um valor válido maior que zero.')));
                    return;
                  }
                  try {
                    await context.read<FinanceProvider>().addGoal(title: title.text.trim(), targetAmount: parsed, targetDate: targetDate);
                    if (context.mounted) Navigator.pop(context);
                  } catch (error) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível criar a meta. $error')));
                  }
                },
                child: const Text('Criar meta'),
              ),
            ]),
          ),
        ),
      ),
    );
    title.dispose();
    amount.dispose();
  }

  Future<void> _addSaved(BuildContext context, WishlistGoal goal) async {
    final amount = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Guardar para ${goal.title}'),
        content: TextField(
          controller: amount,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [BrazilianMoneyInputFormatter()],
          decoration: const InputDecoration(labelText: 'Quanto você guardou?'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              final parsed = parseBrazilianMoney(amount.text);
              if (parsed == null || parsed <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor maior que zero.')));
                return;
              }
              try {
                await context.read<FinanceProvider>().addToGoal(goal, parsed);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (dialogContext.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível registrar o valor. $error')));
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
    amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Metas de economia'),
          actions: [
            IconButton(tooltip: 'Criar meta', onPressed: () => _openForm(context), icon: const Icon(Icons.add_circle_outline, color: AppColors.orange)),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openForm(context),
          icon: const Icon(Icons.add),
          label: const Text('Nova meta'),
        ),
        body: finance.isLoading
            ? const Center(child: CircularProgressIndicator())
            : finance.goals.isEmpty
                ? const EmptyState(
                    icon: Icons.track_changes_rounded,
                    title: 'Escolha sua próxima conquista',
                    description: 'Crie uma meta, defina quanto deseja juntar e acompanhe seu progresso a cada novo aporte.',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    children: [
                      Text('Seus objetivos', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      ...finance.goals.map((goal) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _SavingsGoalCard(goal: goal, onAdd: () => _addSaved(context, goal)),
                      )),
                    ],
                  ),
      ),
    );
  }
}

class _SavingsGoalCard extends StatelessWidget {
  const _SavingsGoalCard({required this.goal, required this.onAdd});
  final WishlistGoal goal;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final remaining = (goal.targetAmount - goal.savedAmount).clamp(0, double.infinity).toDouble();
    final isComplete = goal.progress >= 1;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppColors.orange, AppColors.orangeLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Meta de economia', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              Icon(isComplete ? Icons.check_circle_rounded : Icons.track_changes_rounded, color: Colors.white, size: 28),
            ]),
            const SizedBox(height: 8),
            Text(goal.title, style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
            const SizedBox(height: 5),
            Text(currency(goal.targetAmount), style: const TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: -.5)),
            if (goal.targetDate != null) ...[
              const SizedBox(height: 4),
              Text('Prazo: ${dateLabel(goal.targetDate!)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: _GoalMetric(label: 'Já guardado', value: currency(goal.savedAmount))),
              const SizedBox(width: 12),
              Expanded(child: _GoalMetric(label: 'Falta juntar', value: currency(remaining))),
            ]),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(child: Text('Progresso', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700))),
              Text('${(goal.progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 11,
                color: AppColors.orange,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isComplete ? null : onAdd,
                icon: Icon(isComplete ? Icons.check_rounded : Icons.add),
                label: Text(isComplete ? 'Meta alcançada' : 'Guardar valor'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      const SizedBox(height: 5),
      Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
    ]),
  );
}
