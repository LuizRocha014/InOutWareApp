import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:in_out_ware_app/presentation/theme/iw_design.dart';
import 'package:stock_module/modules/domain/repositories/stock_inventory_repository.dart';
import 'package:stock_module/modules/domain/usecases/stock_inventory_usecases.dart';
import 'package:componentes_lr/componentes_lr.dart' show instanceManager;

/// Diálogo modal para escolher a filial de trabalho (após login ou se ainda não houver filial).
Future<void> showBranchSelectionDialog(
  BuildContext context, {
  String? preselectedBranchId,
}) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _BranchSelectionDialog(
      preselectedBranchId: preselectedBranchId,
    ),
  );
}

class _BranchSelectionDialog extends StatefulWidget {
  const _BranchSelectionDialog({this.preselectedBranchId});

  final String? preselectedBranchId;

  @override
  State<_BranchSelectionDialog> createState() => _BranchSelectionDialogState();
}

class _BranchSelectionDialogState extends State<_BranchSelectionDialog> {
  List<BranchRef>? _branches;
  String? _error;
  String? _selectedId;
  bool _loading = true;

  ListStockFormOptionsUseCase get _options =>
      instanceManager.get<ListStockFormOptionsUseCase>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await _options();
      if (!mounted) return;
      final list = r.branches;
      String? id = widget.preselectedBranchId;
      if ((id == null || id.isEmpty) && list.isNotEmpty) {
        id = list.first.id;
      }
      if (id != null && list.every((b) => b.id != id)) {
        id = list.isNotEmpty ? list.first.id : null;
      }
      setState(() {
        _branches = list;
        _selectedId = id;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _confirm() async {
    final branches = _branches;
    final id = _selectedId;
    if (branches == null || id == null || id.isEmpty) return;
    BranchRef? chosen;
    for (final b in branches) {
      if (b.id == id) {
        chosen = b;
        break;
      }
    }
    if (chosen == null) return;
    await AppAuth.I.setSelectedBranch(id: chosen.id, name: chosen.name);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IwRadius.xl),
      ),
      backgroundColor: IwColors.surfaceContainerLow,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: IwColors.primaryContainer,
                      borderRadius: BorderRadius.circular(IwRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.store_outlined,
                        color: IwColors.onPrimaryContainer, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Filial de trabalho',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: IwColors.onSurface,
                        letterSpacing: -0.10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Selecione a filial em que você quer operar.',
                style: TextStyle(
                  fontSize: 13,
                  color: IwColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              _body(),
              const SizedBox(height: 20),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.cloud_off_outlined, color: IwColors.error, size: 20),
              SizedBox(width: 8),
              Text(
                'Não foi possível carregar as filiais.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: IwColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: const TextStyle(
              fontSize: 12,
              color: IwColors.onSurfaceVariant,
            ),
          ),
        ],
      );
    }
    final list = _branches;
    if (list == null || list.isEmpty) {
      return const Text(
        'Nenhuma filial cadastrada na API.',
        style: TextStyle(color: IwColors.onSurfaceVariant),
      );
    }
    return DropdownButtonFormField<String>(
      initialValue: _selectedId,
      decoration: const InputDecoration(
        labelText: 'Filial',
        prefixIcon: Icon(Icons.store_outlined),
      ),
      hint: const Text('Selecione'),
      items: list
          .map((b) => DropdownMenuItem(value: b.id, child: Text(b.name)))
          .toList(),
      onChanged: (v) => setState(() => _selectedId = v),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_loading && (_error != null || (_branches?.isEmpty ?? false)))
          TextButton(
            onPressed: () async {
              await AppAuth.I.clearSessionToken();
              if (context.mounted) {
                Navigator.of(context).pop();
                Get.offAllNamed('/login');
              }
            },
            child: const Text('Sair'),
          ),
        if (!_loading && _error != null) ...[
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _load,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Tentar novamente'),
          ),
        ],
        if (!_loading && _error == null && (_branches?.isNotEmpty ?? false)) ...[
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _selectedId == null ? null : _confirm,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Continuar'),
          ),
        ],
      ],
    );
  }
}
