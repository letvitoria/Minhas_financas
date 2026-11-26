import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../shared/widgets/section_title.dart';
import '../../shared/widgets/record_crud_actions.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _hideValues = false;
  String _money(double value) => _hideValues ? '••••••' : currency(value);

  Future<void> _openExpenseForm() async {
    final title = TextEditingController();
    final amount = TextEditingController();
    String category = 'Dia a dia';
    DateTime date = DateTime.now();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
              Text('Novo gasto', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 18),
              TextField(controller: title, decoration: const InputDecoration(labelText: 'No que você gastou?')),
              const SizedBox(height: 12),
              TextField(
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [BrazilianMoneyInputFormatter()],
                decoration: const InputDecoration(labelText: 'Valor (ex.: 45,90)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'Dia a dia', child: Text('Dia a dia')),
                  DropdownMenuItem(value: 'Moradia', child: Text('Moradia')),
                  DropdownMenuItem(value: 'Transporte', child: Text('Transporte')),
                  DropdownMenuItem(value: 'Alimentação', child: Text('Alimentação')),
                  DropdownMenuItem(value: 'Lazer', child: Text('Lazer')),
                  DropdownMenuItem(value: 'Estudos', child: Text('Estudos')),
                ],
                onChanged: (v) => setSheet(() => category = v ?? 'Dia a dia'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Data do gasto'),
                subtitle: Text(dateLabel(date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(context: context, initialDate: date, firstDate: DateTime(2020), lastDate: DateTime(2100));
                  if (picked != null) setSheet(() => date = picked);
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
                    await context.read<FinanceProvider>().addExpense(title: title.text.trim(), amount: parsed, category: category, date: date);
                    if (context.mounted) Navigator.pop(context);
                  } catch (error) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Não foi possível salvar. $error')));
                  }
                },
                child: const Text('Salvar gasto'),
              ),
            ]),
          ),
        ),
      ),
    );
    title.dispose();
    amount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final user = context.watch<AuthProvider>();
    final total = finance.incomeTotal + finance.expenseTotal + finance.investmentTotal;
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: finance.refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Olá, ${user.displayName}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                Text('Bora cuidar do seu dinheiro?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
              ])),
              IconButton(tooltip: 'Alternar tema', onPressed: () => context.read<ThemeProvider>().toggle(Theme.of(context).brightness), icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined)),
              IconButton(tooltip: 'Sair', onPressed: () => context.read<AuthProvider>().signOut(), icon: const Icon(Icons.logout_rounded)),
            ]),
            const SizedBox(height: 20),
            _BalanceCard(
              balance: _money(finance.availableBalance),
              income: _money(finance.incomeTotal),
              expenses: _money(finance.expenseTotal + finance.investmentTotal),
              hidden: _hideValues,
              onToggle: () => setState(() => _hideValues = !_hideValues),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text('Acompanhamento', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
              TextButton.icon(onPressed: _openExpenseForm, icon: const Icon(Icons.add, size: 18), label: const Text('Novo gasto')),
            ]),
            const SizedBox(height: 4),
            _MonthlySpendingCard(transactions: finance.transactions, hideValues: _hideValues),
            const SizedBox(height: 18),
            const SectionTitle('Últimos lançamentos'),
            const SizedBox(height: 8),
            if (finance.transactions.isEmpty)
              const Card(child: Padding(padding: EdgeInsets.all(16), child: Text('Nenhum gasto registrado ainda.')))
            else
              ...finance.transactions.take(8).map((item) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
                  title: Text(item.title),
                  subtitle: Text(item.category + ' • ' + dateLabel(item.occurredOn)),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(_money(item.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                    RecordCrudActions(table: 'transactions', id: item.id, label: 'lançamento', values: {
                      'title': item.title, 'type': item.type, 'category': item.category,
                      'amount': item.amount, 'occurred_on': item.occurredOn.toIso8601String().split('T').first,
                    }),
                  ]),
                ),
              )),
            const SizedBox(height: 20),
            const SectionTitle('Sua saúde financeira'),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(children: [
                  if (finance.isLoading)
                    const SizedBox(height: 160, child: Center(child: CircularProgressIndicator()))
                  else if (total == 0)
                    SizedBox(height: 150, child: Center(child: Text('Adicione rendas, despesas e investimentos para visualizar sua distribuição.', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor))))
                  else
                    SizedBox(
                      height: 170,
                      child: Row(children: [
                        Expanded(child: PieChart(PieChartData(
                          centerSpaceRadius: 42,
                          sectionsSpace: 3,
                          sections: [
                            if (finance.expenseTotal > 0) PieChartSectionData(value: finance.expenseTotal, color: AppColors.red, radius: 22, showTitle: false),
                            if (finance.incomeTotal > 0) PieChartSectionData(value: finance.incomeTotal, color: AppColors.green, radius: 22, showTitle: false),
                            if (finance.investmentTotal > 0) PieChartSectionData(value: finance.investmentTotal, color: AppColors.orange, radius: 22, showTitle: false),
                          ],
                        ))),
                        const SizedBox(width: 12),
                        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          _Legend(color: AppColors.green, label: 'Receitas', value: _money(finance.incomeTotal)),
                          const SizedBox(height: 12),
                          _Legend(color: AppColors.red, label: 'Gastos', value: _money(finance.expenseTotal)),
                          const SizedBox(height: 12),
                          _Legend(color: AppColors.orange, label: 'Investido', value: _money(finance.investmentTotal)),
                        ])),
                      ]),
                    ),
                  Align(alignment: Alignment.centerLeft, child: Text('Visão baseada nos lançamentos cadastrados', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))),
                ]),
              ),
            ),
            const SizedBox(height: 22),
            const SectionTitle('Próximos vencimentos'),
            const SizedBox(height: 10),
            if (finance.bills.where((b) => !b.isPaid).isEmpty)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('Tudo em dia por aqui. Cadastre uma conta para acompanhar os vencimentos.', style: TextStyle(color: Theme.of(context).hintColor))))
            else
              ...finance.bills.where((b) => !b.isPaid).take(3).map((bill) => Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Card(child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0x1AFF6B00), child: Icon(Icons.calendar_month, color: AppColors.orange)),
                  title: Text(bill.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Vence em ${dateLabel(bill.dueDate)}'),
                  trailing: Text(_money(bill.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                )),
              )),
          ],
        ),
      ),
    );
  }
}

class _MonthlySpendingCard extends StatelessWidget {
  const _MonthlySpendingCard({required this.transactions, required this.hideValues});
  final List<dynamic> transactions;
  final bool hideValues;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = List.generate(5, (index) => DateTime(now.year, now.month - (4 - index)));
    final totals = months.map((month) {
      return transactions.where((item) =>
        item.type == 'expense' &&
        item.occurredOn.year == month.year &&
        item.occurredOn.month == month.month
      ).fold<double>(0, (sum, item) => sum + item.amount);
    }).toList();
    final maxValue = totals.fold<double>(0, (max, value) => value > max ? value : max);
    final chartMax = maxValue == 0 ? 100.0 : maxValue * 1.2;
    const labels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('Gastos mensais', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))),
            Icon(Icons.info_outline, size: 19, color: Theme.of(context).colorScheme.primary),
          ]),
          const SizedBox(height: 8),
          SizedBox(
            height: 190,
            child: BarChart(BarChartData(
              maxY: chartMax,
              minY: 0,
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: chartMax / 4),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 42, getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('R\$ 0', style: TextStyle(fontSize: 9));
                  return Text(value >= 1000 ? 'R\$ ${(value / 1000).toStringAsFixed(1)}k' : value.toStringAsFixed(0), style: const TextStyle(fontSize: 9));
                })),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= months.length) return const SizedBox.shrink();
                  return Padding(padding: const EdgeInsets.only(top: 7), child: Text(labels[months[index].month - 1], style: const TextStyle(fontSize: 10)));
                })),
              ),
              barGroups: List.generate(months.length, (index) => BarChartGroupData(
                x: index,
                barRods: [BarChartRodData(
                  toY: totals[index],
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
                  color: index == months.length - 1 ? AppColors.orange : Theme.of(context).colorScheme.outlineVariant,
                )],
              )),
            )),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _MetricTile(label: 'Este mês', value: hideValues ? '••••' : currency(totals.last))),
            const SizedBox(width: 10),
            Expanded(child: _MetricTile(label: 'Média do período', value: hideValues ? '••••' : currency(totals.fold<double>(0, (a, b) => a + b) / totals.length))),
          ]),
        ]),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: .55), borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor)),
      const SizedBox(height: 4),
      Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
    ]),
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.balance, required this.income, required this.expenses, required this.hidden, required this.onToggle});
  final String balance, income, expenses;
  final bool hidden;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppColors.orange, AppColors.orangeLight], begin: Alignment.topLeft, end: Alignment.bottomRight),
      borderRadius: BorderRadius.circular(26),
      boxShadow: [BoxShadow(color: AppColors.orange.withValues(alpha: .20), blurRadius: 24, offset: const Offset(0, 10))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Expanded(child: Text('Saldo disponível', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))), IconButton(onPressed: onToggle, color: Colors.white, icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined))]),
      Text(balance, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
      const SizedBox(height: 18),
      Row(children: [
        Expanded(child: _MiniAmount(icon: Icons.south_west_rounded, title: 'Entradas', value: income)),
        const SizedBox(width: 12),
        Expanded(child: _MiniAmount(icon: Icons.north_east_rounded, title: 'Saídas', value: expenses)),
      ]),
    ]),
  );
}

class _MiniAmount extends StatelessWidget {
  const _MiniAmount({required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .18), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 17)),
    const SizedBox(width: 8),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13), overflow: TextOverflow.ellipsis),
    ])),
  ]);
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label, required this.value});
  final Color color;
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 7),
    Expanded(child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
    Text(value, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800)),
  ]);
}
