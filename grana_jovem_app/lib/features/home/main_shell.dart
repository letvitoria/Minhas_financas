import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/finance_provider.dart';
import '../../providers/theme_provider.dart';
import '../bills/bills_page.dart';
import '../home/home_page.dart';
import '../income/income_page.dart';
import '../investments/investments_page.dart';
import '../wishlist/wishlist_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final _pages = const [HomePage(), BillsPage(), IncomePage(), InvestmentsPage(), WishlistPage()];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<FinanceProvider>().refresh());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Contas'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Renda'),
          NavigationDestination(icon: Icon(Icons.trending_up_rounded), label: 'Investir'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), label: 'Desejos'),
        ],
      ),
    );
  }
}
