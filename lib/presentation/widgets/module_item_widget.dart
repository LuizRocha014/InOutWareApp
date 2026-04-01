import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';

class ModuleItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  final String? subTitle;
  final VoidCallback onTap;
  /// Layout desktop (grade): padding e ícone menores.
  final bool compact;

  const ModuleItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.onTap,
    this.subTitle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final outline = scheme.outline.withValues(alpha: 0.5);
    final vPad = compact ? 14.0 : 22.0;
    final hPad = compact ? 16.0 : 20.0;
    final iconSize = compact ? 32.0 : 40.0;
    final gap = compact ? 12.0 : 16.0;

    return Material(
      color: scheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: hPad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: outline),
          ),
          child: Row(
            children: [
              Icon(icon, size: iconSize, color: scheme.primary),
              SizedBox(width: gap),
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
