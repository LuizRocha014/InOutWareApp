import 'package:componentes_lr/componentes_lr.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_out_ware_app/core/auth/app_auth.dart';
import 'package:stock_module/modules/domain/repositories/stock_inventory_repository.dart';
import 'package:stock_module/modules/domain/usecases/stock_inventory_usecases.dart';

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
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Filial de trabalho'),
      content: SizedBox(
        width: 400,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            : _error != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Não foi possível carregar as filiais.',
                        style: TextStyle(color: scheme.error),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  )
                : (_branches == null || _branches!.isEmpty)
                    ? Text(
                        'Nenhuma filial cadastrada na API.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      )
                    : InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Filial',
                          border: OutlineInputBorder(),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedId,
                            hint: const Text('Selecione'),
                            items: _branches!
                                .map(
                                  (b) => DropdownMenuItem(
                                    value: b.id,
                                    child: Text(b.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _selectedId = v),
                          ),
                        ),
                      ),
      ),
      actions: [
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
        if (!_loading && _error == null && (_branches?.isNotEmpty ?? false))
          FilledButton(
            onPressed: _selectedId == null ? null : _confirm,
            child: const Text('Continuar'),
          ),
      ],
    );
  }
}
