import 'package:flutter/material.dart';
import '../models/lab_models.dart';
import '../services/lab_service.dart';
import '../../../core/api/api_client.dart';

class LabPage extends StatefulWidget {
  final ApiClient apiClient;
  const LabPage({super.key, required this.apiClient});

  @override
  State<LabPage> createState() => _LabPageState();
}

class _LabPageState extends State<LabPage> {
  late final LabService _service;
  List<LabResult> _results = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _service = LabService(client: widget.apiClient);
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getResults();
      if (!mounted) return;
      setState(() => _results = data);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('검사 결과'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : _results.isEmpty
                  ? _EmptyView(onAdd: _showAddDialog)
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        itemBuilder: (_, i) => _LabResultCard(result: _results[i]),
                      ),
                    ),
    );
  }

  void _showAddDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddLabResultSheet(
        onSave: (input) async {
          await _service.addResult(input);
          if (mounted) {
            Navigator.pop(context);
            _load();
          }
        },
      ),
    );
  }
}

class _LabResultCard extends StatelessWidget {
  final LabResult result;
  const _LabResultCard({required this.result});

  Color get _statusColor {
    return switch (result.status) {
      'critical' => Colors.red,
      'high' || 'low' => Colors.orange,
      _ => Colors.green,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.testName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.value} ${result.unit}',
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (result.referenceMin != null && result.referenceMax != null)
                    Text(
                      '참고범위: ${result.referenceMin} ~ ${result.referenceMax} ${result.unit}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _statusLabel(result.status),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${result.testedAt.year}.${result.testedAt.month.toString().padLeft(2, '0')}.${result.testedAt.day.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    return switch (status) {
      'high' => '높음',
      'low' => '낮음',
      'critical' => '위험',
      _ => '정상',
    };
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('검사 결과가 없습니다', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('검사 결과 추가'),
          ),
        ],
      ),
    );
  }
}

class _AddLabResultSheet extends StatefulWidget {
  final Future<void> Function(LabResultInput) onSave;
  const _AddLabResultSheet({required this.onSave});

  @override
  State<_AddLabResultSheet> createState() => _AddLabResultSheetState();
}

class _AddLabResultSheetState extends State<_AddLabResultSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  DateTime _testedAt = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '검사 결과 추가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '검사명 *'),
              validator: (v) => (v?.isEmpty ?? true) ? '검사명을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _codeCtrl,
              decoration: const InputDecoration(labelText: '검사 코드 (예: ESR, CRP)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _valueCtrl,
                    decoration: const InputDecoration(labelText: '수치 *'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return '수치를 입력하세요';
                      if (double.tryParse(v) == null) return '숫자만 입력하세요';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitCtrl,
                    decoration: const InputDecoration(labelText: '단위 *'),
                    validator: (v) => (v?.isEmpty ?? true) ? '단위를 입력하세요' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('검사일'),
              subtitle: Text(
                '${_testedAt.year}.${_testedAt.month.toString().padLeft(2, '0')}.${_testedAt.day.toString().padLeft(2, '0')}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _testedAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _testedAt = picked);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('저장'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(LabResultInput(
        testName: _nameCtrl.text.trim(),
        testCode: _codeCtrl.text.trim().isNotEmpty
            ? _codeCtrl.text.trim()
            : _nameCtrl.text.trim().toUpperCase(),
        value: double.parse(_valueCtrl.text),
        unit: _unitCtrl.text.trim(),
        testedAt: _testedAt,
      ));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
