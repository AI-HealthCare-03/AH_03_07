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
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddDialog,
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
                                content: Text('${_results[i].testType} 결과를 삭제할까요?'),
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
          if (mounted) { Navigator.pop(context); _load(); }
        },
      ),
    );
  }

  void _showEditDialog(LabResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddLabResultSheet(
        initial: result,
        onSave: (input) async {
          await _service.updateResult(result.id, input);
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
                    result.testType,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.displayValue,
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
            Text(
              '${result.testDate.year}.${result.testDate.month.toString().padLeft(2, '0')}.${result.testDate.day.toString().padLeft(2, '0')}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
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
  final LabResult? initial; // 수정 모드일 때 기존 값
  const _AddLabResultSheet({required this.onSave, this.initial});

  @override
  State<_AddLabResultSheet> createState() => _AddLabResultSheetState();
}

class _AddLabResultSheetState extends State<_AddLabResultSheet> {
  static const _unitOptions = [
    '없음', 'mg/L', 'mg/dL', 'g/dL', 'μg/mL', 'μg/dL',
    'mm/h', 'IU/L', 'U/L', 'mIU/mL', 'ng/mL', 'pg/mL',
    'mmHg', 'mmol/L', '%', 'cells/μL', 'x10³/μL', 'x10⁶/μL',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _typeCtrl;
  late final TextEditingController _valueCtrl;
  late String _selectedUnit;
  late final TextEditingController _rangeCtrl;
  late final TextEditingController _memoCtrl;
  late DateTime _testDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _typeCtrl = TextEditingController(text: init?.testType ?? '');
    _valueCtrl = TextEditingController(text: init?.userRecordedValue ?? '');
    _rangeCtrl = TextEditingController(text: init?.referenceRange ?? '');
    _memoCtrl = TextEditingController(text: init?.memo ?? '');
    _testDate = init?.testDate ?? DateTime.now();
    final unit = init?.unit;
    _selectedUnit = (unit != null && _unitOptions.contains(unit)) ? unit : '없음';
  }

  @override
  void dispose() {
    _typeCtrl.dispose();
    _valueCtrl.dispose();
    _rangeCtrl.dispose();
    _memoCtrl.dispose();
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
                controller: _typeCtrl,
                decoration: const InputDecoration(labelText: '검사 유형 * (예: ESR, CRP, 혈당)'),
                validator: (v) => (v?.isEmpty ?? true) ? '검사 유형을 입력하세요' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _valueCtrl,
                      decoration: const InputDecoration(labelText: '검사값 *'),
                      validator: (v) => (v?.isEmpty ?? true) ? '검사값을 입력하세요' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(labelText: '단위'),
                      isExpanded: true,
                      items: _unitOptions
                          .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v ?? '없음'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _rangeCtrl,
                decoration: const InputDecoration(labelText: '참고범위 (예: 0~5 mg/L)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoCtrl,
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
                    : const Text('저장'),
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
        testType: _typeCtrl.text.trim(),
        userRecordedValue: _valueCtrl.text.trim(),
        unit: _selectedUnit == '없음' ? null : _selectedUnit,
        referenceRange: _rangeCtrl.text.trim().isNotEmpty ? _rangeCtrl.text.trim() : null,
        memo: _memoCtrl.text.trim().isNotEmpty ? _memoCtrl.text.trim() : null,
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
