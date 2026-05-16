import 'package:flutter/material.dart';
import 'package:in_out_ware_app/presentation/theme/iw_design.dart';

enum IwModulePalette { sales, stock, transfer }

class _PalettePair {
  const _PalettePair(this.accent, this.ring, this.onRing);
  final Color accent;
  final Color ring;
  final Color onRing;
}

const Map<IwModulePalette, _PalettePair> _palettes = {
  IwModulePalette.sales: _PalettePair(
    IwColors.primary,
    IwColors.primaryContainer,
    IwColors.onPrimaryContainer,
  ),
  IwModulePalette.stock: _PalettePair(
    IwColors.secondary,
    IwColors.secondaryContainer,
    IwColors.onSecondaryContainer,
  ),
  IwModulePalette.transfer: _PalettePair(
    IwColors.tertiary,
    IwColors.tertiaryContainer,
    IwColors.onTertiaryContainer,
  ),
};

class IwKpi {
  const IwKpi({required this.label, required this.value});
  final String label;
  final String value;
}

class IwModuleStatus {
  const IwModuleStatus({required this.label, this.warn = false});
  final String label;
  final bool warn;
}

/// Tile rico do dashboard — ícone hero, faixa de cor, subtítulo, KPIs e seta.
class ModuleItemWidget extends StatefulWidget {
  const ModuleItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.route,
    required this.onTap,
    this.subTitle,
    this.kpis = const [],
    this.status,
    this.palette = IwModulePalette.sales,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String route;
  final String? subTitle;
  final List<IwKpi> kpis;
  final IwModuleStatus? status;
  final IwModulePalette palette;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<ModuleItemWidget> createState() => _ModuleItemWidgetState();
}

class _ModuleItemWidgetState extends State<ModuleItemWidget> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = _palettes[widget.palette]!;
    final iconBoxSize = widget.compact ? 52.0 : 64.0;
    final iconSize = widget.compact ? 28.0 : 34.0;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        transform: _hover
            ? (Matrix4.identity()..translateByDouble(0, -1, 0, 1))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: IwColors.surface,
          borderRadius: BorderRadius.circular(IwRadius.lg),
          border: Border.all(
            color: IwColors.outline.withValues(alpha: 0.30),
          ),
          boxShadow: _hover
              ? const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(IwRadius.lg),
          child: InkWell(
            borderRadius: BorderRadius.circular(IwRadius.lg),
            onTap: widget.onTap,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: p.accent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(IwRadius.lg),
                        bottomLeft: Radius.circular(IwRadius.lg),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.compact ? 16 : 20,
                    16,
                    8,
                    16,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: iconBoxSize,
                        height: iconBoxSize,
                        decoration: BoxDecoration(
                          color: p.ring,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Icon(widget.icon, color: p.onRing, size: iconSize),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: IwColors.onSurface,
                                letterSpacing: -0.085,
                              ),
                            ),
                            if (widget.subTitle != null &&
                                widget.subTitle!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                widget.subTitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: IwColors.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            if (widget.status != null) ...[
                              const SizedBox(height: 10),
                              _StatusDot(status: widget.status!),
                            ],
                            if (widget.kpis.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _Kpis(kpis: widget.kpis),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.arrow_forward,
                            size: 22, color: IwColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final IwModuleStatus status;

  @override
  Widget build(BuildContext context) {
    final base = status.warn ? IwColors.warning : IwColors.success;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: base,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: base.withValues(alpha: 0.22),
                blurRadius: 0,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          status.label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: status.warn ? IwColors.warning : IwColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _Kpis extends StatelessWidget {
  const _Kpis({required this.kpis});
  final List<IwKpi> kpis;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (var i = 0; i < kpis.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 28,
              color: IwColors.outlineVariant,
              margin: const EdgeInsets.symmetric(horizontal: 18),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kpis[i].value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: IwColors.onSurface,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kpis[i].label.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'RobotoMono',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: IwColors.onSurfaceVariant,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
