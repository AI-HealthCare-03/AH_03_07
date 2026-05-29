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
  List<EmergencyContact> _contacts = [];
  bool _loadingContacts = true;
  bool _sendingSos = false;

  @override
  void initState() {
    super.initState();
    _service = EmergencyService(client: widget.apiClient);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    try {
      final data = await _service.getContacts();
      if (mounted) setState(() => _contacts = data);
    } catch (_) {} finally {
      if (mounted) setState(() => _loadingContacts = false);
    }
  }

  Future<void> _call119() async {
    final uri = Uri.parse('tel:119');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendSos() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SOS 전송'),
        content: const Text(
          '등록된 보호자에게 위치 정보가 포함된 SOS 링크를 전송합니다.\n'
          '119 신고는 직접 전화하셔야 합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('전송'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _sendingSos = true);
    try {
      final result = await _service.sendSos(message: '도움이 필요합니다');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.notifiedCount}명에게 SOS가 전송됐습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('전송 실패: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _sendingSos = false);
    }
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
            // 119 직접 발신 버튼 (최우선)
            _PrimaryEmergencyButton(onPressed: _call119),
            const SizedBox(height: 16),

            // 보호자 SOS 전송
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '보호자 알림',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '등록된 보호자(${_contacts.length}명)에게 위치 정보를 전송합니다.',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (_sendingSos || _contacts.isEmpty) ? null : _sendSos,
                        icon: _sendingSos
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.notifications_active),
                        label: const Text('보호자에게 SOS 전송'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    if (_contacts.isEmpty && !_loadingContacts)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '보호자를 먼저 등록해주세요.',
                          style: TextStyle(color: Colors.orange[700], fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 보호자 목록
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '보호자 목록',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _showAddContactDialog,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('추가'),
                ),
              ],
            ),
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

  void _showAddContactDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddContactSheet(
        onSave: (name, phone, relation) async {
          await _service.addContact(name: name, phone: phone, relation: relation);
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
  final EmergencyContact contact;
  final VoidCallback onDelete;
  const _ContactTile({required this.contact, required this.onDelete});

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
            if (contact.relation != null)
              Chip(
                label: Text(contact.relation!, style: const TextStyle(fontSize: 11)),
                padding: EdgeInsets.zero,
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
  final Future<void> Function(String name, String phone, String? relation) onSave;
  const _AddContactSheet({required this.onSave});

  @override
  State<_AddContactSheet> createState() => _AddContactSheetState();
}

class _AddContactSheetState extends State<_AddContactSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _relationCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
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
              decoration: const InputDecoration(labelText: '전화번호 *'),
              keyboardType: TextInputType.phone,
              validator: (v) => (v?.isEmpty ?? true) ? '전화번호를 입력하세요' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _relationCtrl,
              decoration: const InputDecoration(labelText: '관계 (예: 부모, 배우자)'),
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
      await widget.onSave(
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim(),
        _relationCtrl.text.trim().isNotEmpty ? _relationCtrl.text.trim() : null,
      );
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
