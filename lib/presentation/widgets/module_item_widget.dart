import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';

class ModuleItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String? subTitle;
  final VoidCallback onTap;

  const ModuleItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.onTap,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outline = scheme.outline.withValues(alpha: 0.5);

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: outline),
          ),
          child: Row(
            children: [
              Icon(icon, size: 40, color: scheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      title,
                      textColor: scheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    if (subTitle != null && subTitle!.isNotEmpty)
                      Text(
                        subTitle!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
