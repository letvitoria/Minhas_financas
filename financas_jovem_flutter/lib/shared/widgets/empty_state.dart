import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 18), child: Column(children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppColors.orange.withValues(alpha: .12), shape: BoxShape.circle), child: Icon(icon, color: AppColors.orange, size: 30)),
    const SizedBox(height: 14), Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    const SizedBox(height: 6), Text(description, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor)),
  ]));
}
