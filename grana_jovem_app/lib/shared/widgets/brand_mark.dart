import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key});
  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(width: 42, height: 42, decoration: BoxDecoration(color: AppColors.orange, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 27)),
    const SizedBox(width: 10),
    Text('grana', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.8)),
    Text('jovem', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500, color: AppColors.orange, letterSpacing: -0.8)),
  ]);
}
