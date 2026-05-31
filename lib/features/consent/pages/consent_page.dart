// NFR-COMPLI-001 + NFR-COMPLI-004: 동의 관리·이력 조회·접근 통제
import 'package:flutter/material.dart';
import '../services/consent_service.dart';
import '../../../core/api/api_client.dart';
import '../../../core/logging/app_logger.dart';

class ConsentPage extends StatefulWidget {
  final ApiClient apiClient;
  const ConsentPage({super.key, required this.apiClient});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final ConsentService _service;
  List<ConsentItem> _history = [];
  bool _loading = true;
  String? _error;

  // 현재 동의 상태 (NFR-COMPLI-001)
  final _consents = {
    'terms':             (label: '서비스 이용약관', required: true,  agreed: false),
    'privacy':           (label: '개인정보 처리방침', required: true, agreed: false),
    'sensitive_medical': (label: '민감 의료정보 처리 동의', required: true, agreed: false),
    'marketing':         (label: '마케팅 정보 수신 (선택)', required: false, agreed: false),
  };

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _service = ConsentService(client: widget.apiClient);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final history = await _service.getConsentHistory();
      if (!mounted) return;
      setState(() => _history = history);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleConsent(String type, bool current) async {
    final consent = _consents[type];
    if (consent == null) return;
    if (consent.required && current) {
      // 필수 동의는 철회 불가
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('필수 동의 항목은 철회할 수 없습니다.')),
      );
      return;
    }
    try {
      await _service.updateConsent(type, !current);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(!current ? '✅ 동의 완료' : '동의가 철회됐습니다.')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('변경 실패: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('동의 관리'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFFFF8C00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF8C00),
          tabs: const [Tab(text: '📋 동의 현황'), Tab(text: '🕒 동의 이력')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tab,
              children: [_buildConsentStatus(), _buildConsentHistory()],
            ),
    );
  }

  Widget _buildConsentStatus() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 민감정보 처리 안내 (NFR-COMPLI-001)
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFCC80)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(Icons.shield_outlined, color: Color(0xFFFF8C00), size: 18),
                SizedBox(width: 8),
                Text('민감정보 처리 안내', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF8C00))),
              ]),
              SizedBox(height: 8),
              Text(
                '• 의료·건강 정보는 암호화되어 안전하게 저장됩니다\n'
                '• 수집된 정보는 서비스 제공 목적으로만 사용됩니다\n'
                '• 회원탈퇴 시 의료 데이터는 즉시 삭제됩니다\n'
                '• 법령에 따라 일부 정보는 일정 기간 보관될 수 있습니다',
                style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.6),
              ),
            ],
          ),
        ),
        // 동의 항목 목록
        ..._consents.entries.map((entry) => _ConsentTile(
          type: entry.key,
          label: entry.value.label,
          isRequired: entry.value.required,
          agreed: _history.any((h) => h.consentType == entry.key && h.agreed),
          onToggle: (current) => _toggleConsent(entry.key, current),
        )),
      ],
    );
  }

  Widget _buildConsentHistory() {
    if (_error != null) {
      return Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error!, textAlign: TextAlign.center),
          TextButton(onPressed: _load, child: const Text('다시 시도')),
        ],
      ));
    }
    if (_history.isEmpty) {
      return const Center(
        child: Text('동의 이력이 없습니다.', style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _history.length,
      itemBuilder: (_, i) {
        final item = _history[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: item.agreed ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                item.agreed ? Icons.check : Icons.close,
                color: item.agreed ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(item.typeLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(
              '${item.agreed ? '동의' : '철회'} · '
              '${item.agreedAt.year}.${item.agreedAt.month.toString().padLeft(2,'0')}.${item.agreedAt.day.toString().padLeft(2,'0')} '
              '${item.agreedAt.hour.toString().padLeft(2,'0')}:${item.agreedAt.minute.toString().padLeft(2,'0')}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: item.agreed ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.agreed ? '동의' : '철회',
                style: TextStyle(
                  fontSize: 12,
                  color: item.agreed ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConsentTile extends StatelessWidget {
  final String type;
  final String label;
  final bool isRequired;
  final bool agreed;
  final void Function(bool current) onToggle;

  const _ConsentTile({
    required this.type,
    required this.label,
    required this.isRequired,
    required this.agreed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isRequired ? Colors.red.shade50 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isRequired ? '필수' : '선택',
                        style: TextStyle(
                          fontSize: 10,
                          color: isRequired ? Colors.red : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    agreed ? '✅ 동의 완료' : '❌ 미동의',
                    style: TextStyle(
                      fontSize: 12,
                      color: agreed ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: agreed,
              onChanged: isRequired && agreed ? null : (_) => onToggle(agreed),
              activeColor: const Color(0xFFFF8C00),
            ),
          ],
        ),
      ),
    );
  }
}

// NFR-COMPLI-004: 접근 통제 — 동의 필요 기능 접근 시 확인
class ConsentGate extends StatelessWidget {
  final String requiredConsent;
  final Widget child;
  final ApiClient apiClient;

  const ConsentGate({
    super.key,
    required this.requiredConsent,
    required this.child,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        logger.logAccessDenied(requiredConsent, '동의 미완료');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('동의 필요'),
            content: const Text('이 기능을 사용하려면 관련 정보 처리에 동의해야 합니다.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ConsentPage(apiClient: apiClient),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                child: const Text('동의 관리', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: child,
    );
  }
}
