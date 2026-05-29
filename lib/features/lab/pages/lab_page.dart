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
    setState(() { _loading = true; _error = null; });
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
          IconButton(icon: const Icon(Icons.add), onPressed: _showAddDialog),
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
                        itemBuilder: (_, i) => Dismissible(
                          key: ValueKey(_results[i].id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (_) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('삭제'),
                                content: Text('${_results[i].testItem} 결과를 삭제할까요?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('삭제',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) async {
                            await _service.deleteResult(_results[i].id);
                            _load();
                          },
                          child: GestureDetector(
                            onTap: () => _showEditDialog(_results[i]),
                            child: _LabResultCard(result: _results[i]),
                          ),
                        ),
                      ),
                    ),
    );
  }

  void _showAddDialog() => _showSheet(null);
  void _showEditDialog(LabResult result) => _showSheet(result);

  void _showSheet(LabResult? initial) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LabResultSheet(
        initial: initial,
        onSave: (input) async {
          if (initial == null) {
            await _service.addResult(input);
          } else {
            await _service.updateResult(initial.id, input);
          }
          if (mounted) { Navigator.pop(context); _load(); }
        },
      ),
    );
  }
}

class _LabResultCard extends StatelessWidget {
  final LabResult result;
  const _LabResultCard({required this.result});

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
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.testItem,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.value,
                    style: const TextStyle(
                      color: Color(0xFFFF8C00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (result.referenceRange != null)
                    Text(
                      '참고범위: ${result.referenceRange}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${result.testDate.year}.${result.testDate.month.toString().padLeft(2, '0')}.${result.testDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Icon(Icons.edit_outlined, size: 14, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
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

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
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

class _LabResultSheet extends StatefulWidget {
  final LabResult? initial;
  final Future<void> Function(LabResultInput) onSave;
  const _LabResultSheet({this.initial, required this.onSave});

  @override
  State<_LabResultSheet> createState() => _LabResultSheetState();
}

class _LabResultSheetState extends State<_LabResultSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _rangeCtrl;
  late final TextEditingController _noteCtrl;
  late DateTime _testDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _itemCtrl = TextEditingController(text: init?.testItem ?? '');
    _valueCtrl = TextEditingController(text: init?.value ?? '');
    _rangeCtrl = TextEditingController(text: init?.referenceRange ?? '');
    _noteCtrl = TextEditingController(text: init?.note ?? '');
    _testDate = init?.testDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _itemCtrl.dispose();
    _valueCtrl.dispose();
    _rangeCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.initial != null ? '검사 결과 수정' : '검사 결과 추가',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _itemCtrl,
                decoration: const InputDecoration(
                  labelText: '검사 항목 *',
                  hintText: '예: ESR, CRP, 혈당, 혈압',
                ),
                validator: (v) => (v?.isEmpty ?? true) ? '검사 항목을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _valueCtrl,
                decoration: const InputDecoration(
                  labelText: '검사값 *',
                  hintText: '예: 5.2 mg/L, 120/80 mmHg',
                ),
                validator: (v) => (v?.isEmpty ?? true) ? '검사값을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rangeCtrl,
                decoration: const InputDecoration(
                  labelText: '참고범위',
                  hintText: '예: 0~5 mg/L',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: '메모'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('검사일'),
                subtitle: Text(
                  '${_testDate.year}.${_testDate.month.toString().padLeft(2, '0')}.${_testDate.day.toString().padLeft(2, '0')}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _testDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _testDate = picked);
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
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.initial != null ? '수정' : '저장'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(LabResultInput(
        testDate: _testDate,
        testItem: _itemCtrl.text.trim(),
        value: _valueCtrl.text.trim(),
        referenceRange: _rangeCtrl.text.trim().isNotEmpty ? _rangeCtrl.text.trim() : null,
        note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : null,
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
