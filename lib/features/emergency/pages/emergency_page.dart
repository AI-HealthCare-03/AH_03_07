// REQ-EMRG-001: 응급 SOS 페이지
// 119 직접 발신 원칙 — 앱은 보조 도구 역할만 수행
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/emergency_service.dart';
import '../../../core/api/api_client.dart';

class EmergencyPage extends StatefulWidget {
  final ApiClient apiClient;
  const EmergencyPage({super.key, required this.apiClient});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  late final EmergencyService _service;
  List<GuardianContact> _contacts = [];
  bool _loadingContacts = true;

  @override
  void initState() {
    super.initState();
    _service = EmergencyService(client: widget.apiClient);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final data = await _service.getContacts();
      if (mounted) setState(() => _contacts = data.where((c) => c.isActive).toList());
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingContacts = false);
    }
  }

  Future<void> _call119() async {
    final uri = Uri.parse('tel:119');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _callContact(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('응급 SOS'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PrimaryEmergencyButton(onPressed: _call119),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보호자 목록',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _contacts.length >= 3 ? null : _showAddDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('추가'),
                ),
              ],
            ),
            Text(
              '보호자 전화번호로 직접 연락할 수 있습니다. (최대 3명)',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            const SizedBox(height: 12),
            if (_loadingContacts)
              const Center(child: CircularProgressIndicator())
            else if (_contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '등록된 보호자가 없습니다.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              )
            else
              ...(_contacts.map((c) => _ContactTile(
                    contact: c,
                    onCall: () => _callContact(c.phone),
                    onDelete: () async {
                      await _service.deleteContact(c.id);
                      _loadContacts();
                    },
                  ))),
          ],
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
      builder: (_) => _AddContactSheet(
        onSave: (name, phone) async {
          await _service.addContact(name: name, phone: phone);
          if (mounted) {
            Navigator.pop(context);
            _loadContacts();
          }
        },
      ),
    );
  }
}

class _PrimaryEmergencyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _PrimaryEmergencyButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call, color: Colors.white, size: 36),
            SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '119 신고',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '즉시 전화 연결',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final GuardianContact contact;
  final VoidCallback onCall;
  final VoidCallback onDelete;
  const _ContactTile({
    required this.contact,
    required this.onCall,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            contact.name.isNotEmpty ? contact.name[0] : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(contact.name),
        subtitle: Text(contact.phone),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: onCall,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddContactSheet extends StatefulWidget {
  final Future<void> Function(String name, String phone) onSave;
  const _AddContactSheet({required this.onSave});

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
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
              '보호자 추가',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: '이름 *'),
              validator: (v) => (v?.isEmpty ?? true) ? '이름을 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: '전화번호 *',
                hintText: '010-1234-5678',
              ),
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return '전화번호를 입력하세요';
                final clean = v.replaceAll('-', '');
                if (!RegExp(r'^01[0-9]\d{7,8}$').hasMatch(clean)) {
                  return '010-XXXX-XXXX 형식으로 입력하세요';
                }
                return null;
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
      await widget.onSave(_nameCtrl.text.trim(), _phoneCtrl.text.trim());
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
