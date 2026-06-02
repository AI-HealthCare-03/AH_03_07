// REQ-AUTO-002: 약물 등록 카드 — 와이어프레임 기반 UI
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../services/ocr_service.dart';
import '../../../main.dart';
import '../../../login_page.dart';
import '../../../home_page.dart';

class MedicationAddPage extends StatefulWidget {
  const MedicationAddPage({super.key});

  @override
  State<MedicationAddPage> createState() => _MedicationAddPageState();
}

class _MedicationAddPageState extends State<MedicationAddPage> {
  static const _green = Color(0xFF22C55E);

  final _client = http.Client();
  final _formKey = GlobalKey<FormState>();

  // 약품 정보
  final _nameCtrl = TextEditingController();
  String _category = '면역억제제';

  // 복용 정보
  final _doseCtrl = TextEditingController(text: '1');
  String _doseUnit = '정';
  int _frequency = 2; // 1일 복용 횟수
  final Set<String> _timings = {'아침', '저녁'}; // 복용 시점
  DateTime? _startDate;
  DateTime? _endDate;

  // 추가 정보
  final _memoCtrl = TextEditingController();

  bool _isLoading = false;

  static const _categories = ['면역억제제', '항염증제', '스테로이드', '항류마티스', '기타'];
  static const _units = ['정', '캡슐', 'ml', 'mg', '포'];
  static const _timingList = ['아침', '점심', '저녁', '취침 전'];

  @override
  void dispose() {
    _client.close();
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<String?> _getToken() => SecureTokenStorage().getAccessToken();

  void _handleUnauthorized() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginPage(
          onLoginSuccess: () => Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomePage(),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
              transitionDuration: const Duration(milliseconds: 400),
            ),
            (r) => false,
          ),
        ),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (r) => false,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_nameCtrl.text.trim().isEmpty) {
      _showSnack('약품명을 입력해주세요.');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final token = await _getToken();
      if (token == null) throw Exception('토큰 없음');

      final body = jsonEncode({
        'name': _nameCtrl.text.trim(),
        'category': _category,
        'dose_amount': int.tryParse(_doseCtrl.text) ?? 1,
        'dose_unit': _doseUnit,
        'frequency': _frequency,
        'timings': _timings.toList(),
        'start_date': _startDate?.toIso8601String().substring(0, 10),
        'end_date': _endDate?.toIso8601String().substring(0, 10),
        'memo': _memoCtrl.text.trim(),
      });

      final response = await _client
          .post(
            Uri.parse('${OcrConfig.baseUrl}/v1/medications'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;
      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnack('약이 등록됐습니다! 🎉');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context, true);
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        _showSnack('등록에 실패했습니다. 다시 시도해주세요.');
      }
    } catch (_) {
      if (mounted) _showSnack('오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 90)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '약 등록',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _sectionCard('약품 정보', [
              _fieldLabel('약품명', required: true),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  hintText: '약품명 검색',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: const Icon(Icons.search,
                      color: Colors.grey, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _green, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '약품명을 입력해주세요' : null,
              ),
              const SizedBox(height: 16),
              _fieldLabel('약물 분류'),
              const SizedBox(height: 6),
              _dropdownField<String>(
                value: _category,
                items: _categories,
                onChanged: (v) => setState(() => _category = v ?? _category),
              ),
            ]),
            const SizedBox(height: 12),
            _sectionCard('복용 정보', [
              _fieldLabel('1회 복용량', required: true),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _doseCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: _green, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _dropdownField<String>(
                    value: _doseUnit,
                    items: _units,
                    onChanged: (v) =>
                        setState(() => _doseUnit = v ?? _doseUnit),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _fieldLabel('1일 복용 횟수', required: true),
              const SizedBox(height: 8),
              Row(
                children: [1, 2, 3, 4].map((n) {
                  final label = n == 4 ? '4회 +' : '$n회';
                  final selected = _frequency == n;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: GestureDetector(
                        onTap: () => setState(() => _frequency = n),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected ? _green : Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: selected
                                  ? _green
                                  : const Color(0xFFD0D0D0),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _fieldLabel('복용 시점'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _timingList.map((t) {
                  final selected = _timings.contains(t);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected) {
                        _timings.remove(t);
                      } else {
                        _timings.add(t);
                      }
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? _green : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selected
                              ? _green
                              : const Color(0xFFD0D0D0),
                        ),
                      ),
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color:
                              selected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              _fieldLabel('복용 기간'),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: _datePicker(
                    hint: '시작일',
                    date: _startDate,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('~',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ),
                Expanded(
                  child: _datePicker(
                    hint: '종료일',
                    date: _endDate,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ]),
            ]),
            const SizedBox(height: 12),
            _sectionCard('추가 정보', [
              _fieldLabel('메모 (선택)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _memoCtrl,
                maxLines: 3,
                maxLength: 200,
                decoration: InputDecoration(
                  hintText: '예: 식후 30분에 복용',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: _green, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _green.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        '등록하기',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _sectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool required = false}) {
    return Row(children: [
      Text(label,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      if (required)
        const Text(' *',
            style: TextStyle(color: Colors.red, fontSize: 14)),
    ]);
  }

  Widget _dropdownField<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey, size: 20),
          items: items
              .map((i) => DropdownMenuItem<T>(
                    value: i,
                    child: Text(i.toString(),
                        style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _datePicker({
    required String hint,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final text = date != null
        ? '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}'
        : hint;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: date != null ? Colors.black87 : Colors.grey,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 4,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF22C55E),
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      elevation: 8,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      onTap: (_) {},
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined), label: '기록'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline), label: '챗봇'),
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: '홈'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined), label: '알림'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: '마이'),
      ],
    );
  }
}
