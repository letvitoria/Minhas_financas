import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../providers/finance_provider.dart';

class RecordCrudActions extends StatelessWidget {
  const RecordCrudActions({super.key, required this.table, required this.id, required this.values, required this.label});
  final String table;
  final String id;
  final Map<String, dynamic> values;
  final String label;
  static const _hiddenFields = {'id', 'user_id', 'created_at', 'metadata'};

  String _fieldLabel(String field) => switch (field) {
    'title' => 'Descrição', 'type' => 'Tipo', 'category' => 'Categoria',
    'amount' => 'Valor', 'occurred_on' => 'Data', 'due_date' => 'Vencimento',
    'recurrence' => 'Recorrência', 'is_paid' => 'Conta paga',
    'frequency' => 'Frequência', 'received_on' => 'Data de recebimento',
    'target_amount' => 'Valor da meta', 'saved_amount' => 'Valor guardado',
    'target_date' => 'Prazo da meta', _ => field,
  };

  Future<void> _edit(BuildContext context) async {
    final controllers = <String, TextEditingController>{};
    final boolValues = <String, bool>{};
    for (final entry in values.entries) {
      if (_hiddenFields.contains(entry.key)) continue;
      final value = entry.value;
      if (value is bool) {
        boolValues[entry.key] = value;
      } else if (value == null || value is String || value is num) {
        final text = value == null ? '' : (value is num &&
          {'amount', 'target_amount', 'saved_amount'}.contains(entry.key)
          ? value.toStringAsFixed(2).replaceAll('.', ',') : value.toString());
        controllers[entry.key] = TextEditingController(text: text);
      }
    }

    final updated = await showModalBottomSheet<Map<String, dynamic>>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Editar ' + label, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ...controllers.entries.map((entry) {
                final field = entry.key;
                final isMoney = {'amount', 'target_amount', 'saved_amount'}.contains(field);
                final isDate = {'occurred_on', 'due_date', 'received_on', 'target_date'}.contains(field);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: entry.value,
                    keyboardType: isMoney ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                    inputFormatters: isMoney ? [BrazilianMoneyInputFormatter()] :
                      (isDate ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9/\-]'))] : null),
                    decoration: InputDecoration(labelText: _fieldLabel(field), hintText: isDate ? 'AAAA-MM-DD' : null),
                  ),
                );
              }),
              ...boolValues.entries.map((entry) => SwitchListTile(
                contentPadding: EdgeInsets.zero, title: Text(_fieldLabel(entry.key)), value: entry.value,
                onChanged: (value) => setSheet(() => boolValues[entry.key] = value),
              )),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () {
                  final result = <String, dynamic>{...boolValues};
                  for (final entry in controllers.entries) {
                    final field = entry.key;
                    final raw = entry.value.text.trim();
                    if ({'amount', 'target_amount', 'saved_amount'}.contains(field)) {
                      final parsed = parseBrazilianMoney(raw);
                      if (parsed == null || (field != 'saved_amount' && parsed <= 0) || (field == 'saved_amount' && parsed < 0)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Informe um ' + _fieldLabel(field).toLowerCase() + ' válido.')));
                        return;
                      }
                      result[field] = parsed;
                    } else if ({'occurred_on', 'due_date', 'received_on', 'target_date'}.contains(field)) {
                      if (raw.isEmpty && field == 'target_date') {
                        result[field] = null;
                      } else {
                        final normalized = raw.contains('/') ? raw.split('/').reversed.join('-') : raw;
                        if (DateTime.tryParse(normalized) == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Use uma data válida no formato AAAA-MM-DD.')));
                          return;
                        }
                        result[field] = normalized;
                      }
                    } else {
                      if (raw.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preencha todos os campos de texto.')));
                        return;
                      }
                      result[field] = raw;
                    }
                  }
                  Navigator.pop(sheetContext, result);
                },
                child: const Text('Salvar alterações'),
              ),
            ]),
          ),
        ),
      ),
    );

    for (final controller in controllers.values) { controller.dispose(); }
    if (updated == null || !context.mounted) return;
    try {
      await context.read<FinanceProvider>().updateRecord(table, id, updated);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label + ' atualizado com sucesso.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível atualizar ' + label + ': ' + error.toString())));
    }
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Excluir ' + label + '?'),
        content: const Text('Essa ação remove o registro do banco de dados e não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await context.read<FinanceProvider>().deleteRecord(table, id);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label + ' excluído com sucesso.')));
    } catch (error) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível excluir ' + label + ': ' + error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    tooltip: 'Ações de ' + label,
    onSelected: (action) { if (action == 'edit') _edit(context); if (action == 'delete') _delete(context); },
    itemBuilder: (_) => const [
      PopupMenuItem(value: 'edit', child: ListTile(dense: true, leading: Icon(Icons.edit_outlined), title: Text('Editar'))),
      PopupMenuItem(value: 'delete', child: ListTile(dense: true, leading: Icon(Icons.delete_outline), title: Text('Excluir'))),
    ],
  );
}
