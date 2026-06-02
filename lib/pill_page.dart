import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'services/ocr_service.dart';
import 'main.dart';
import 'login_page.dart';
import 'home_page.dart';

// ── 약품 이미지 업로드 (REQ-PILL-001) ────────────────────
class PillRecognizePage extends StatefulWidget {
  const PillRecognizePage({super.key});

  @override
  State<PillRecognizePage> createState() => _PillRecognizePageState();
}

class _PillRecognizePageState extends State<PillRecognizePage> {
  final _client = http.Client();
  bool _isUploading = false;
  XFile? _selectedImage;
  List<Map<String, dynamic>> _candidates = [];
  bool _showResult = false;

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<String?> _getToken() async {
    return SecureTokenStorage().getAccessToken();
  }

  void _handleUnauthorized() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginPage(
          onLoginSuccess: () {
            Navigator.of(context).pushAndRemoveUntil(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const HomePage(),
                transitionsBuilder: (_, anim, __, child) =>
                    FadeTransition(opacity: anim, child: child),
                transitionDuration: const Duration(milliseconds: 400),
              ),
              (route) => false,
            );
          },
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (route) => false,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _showResult = false;
          _candidates = [];
        });
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 불러오지 못했습니다.')),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('이미지 선택',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: Color(0xFF22C55E)),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: Color(0xFF22C55E)),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _recognizePill() async {
    if (_selectedImage == null) return;
    setState(() => _isUploading = true);

    try {
      final token = await _getToken();
      if (token == null) throw Exception('토큰 없음');

      final bytes = await _selectedImage!.readAsBytes();
      final filename = _selectedImage!.name;
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${OcrConfig.baseUrl}/v1/pills/recognize'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ));

      final streamedResponse = await request.send()
          .timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _candidates = List<Map<String, dynamic>>.from(
              data['candidates'] ?? []);
          _showResult = true;
          _isUploading = false;
        });
      } else if (response.statusCode == 401) {
        _handleUnauthorized();
      } else {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('약품 인식에 실패했습니다.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '약품 카메라 인식',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const PillHistoryPage()),
            ),
            child: const Text('인식 내역',
                style: TextStyle(color: Color(0xFF22C55E))),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 안내 배너 (초록)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF22C55E), size: 26),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('약품을 촬영해주세요',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                        SizedBox(height: 2),
                        Text('인식 후보 중 직접 선택하세요',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 카메라 프레임 영역 (어두운 배경 + 점선 가이드)
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D34),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(180, 110),
                            painter: _DashedGuidePainter(),
                            child: const SizedBox(
                              width: 180,
                              height: 110,
                              child: Icon(Icons.medication_outlined,
                                  size: 48, color: Color(0xFFAAAAAA)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text('알약을 가이드 안에 맞춰주세요',
                              style: TextStyle(
                                  color: Color(0xFFBBBBBB),
                                  fontSize: 14)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: FutureBuilder<Uint8List>(
                          future: _selectedImage!.readAsBytes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 280,
                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF22C55E)),
                            );
                          },
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // 둥근 카메라 버튼 (중앙)
            Center(
              child: GestureDetector(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF22C55E).withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.camera_alt,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 인식 버튼 (이미지 선택 후에만 표시)
            if (_selectedImage != null)
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _recognizePill,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(Icons.search, color: Colors.white),
                  label: Text(
                    _isUploading ? '인식 중...' : '약품 인식 시작',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),

            // 인식 결과
            if (_showResult) ...[
              const SizedBox(height: 24),
              const Text(
                '인식 결과(후보)',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 12),
              if (_candidates.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('인식된 약품이 없습니다.',
                      style: TextStyle(color: Colors.grey)),
                )
              else
                ...(_candidates.map((c) => _buildCandidateCard(c))),
              const SizedBox(height: 12),

              // 찾는 약품이 없어요 · 직접 검색
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const PillHistoryPage()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search,
                          color: Colors.grey.shade500, size: 18),
                      const SizedBox(width: 8),
                      Text('찾는 약품이 없어요 · 직접 검색',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 하단 안내 문구
              Center(
                child: Text(
                  'AI 인식 결과는 참고용입니다\n정확한 약품은 직접 확인 후 선택하세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final drugName = candidate['drug_name'] as String? ?? '';
    final confidence = (candidate['confidence'] as num?)?.toDouble() ?? 0.0;
    final confidencePercent = (confidence * 100).toStringAsFixed(1);

    final isHigh = confidence >= 0.9;
    // 성분·분류 정보 (있으면 표시)
    final ingredient = candidate['ingredient'] as String? ??
        candidate['component'] as String? ?? '';
    final category = candidate['category'] as String? ??
        candidate['drug_class'] as String? ?? '';
    final sub = [ingredient, category].where((s) => s.isNotEmpty).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 알약 아이콘 (높은 신뢰도는 초록 배경)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xFFDCFCE7)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.medication_outlined,
                color: isHigh
                    ? const Color(0xFF22C55E)
                    : Colors.grey.shade500,
                size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(drugName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // 신뢰도 % 배지
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHigh
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFDEBD0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${confidencePercent.replaceAll('.0', '')}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isHigh
                    ? const Color(0xFF16A34A)
                    : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 점선 가이드 박스 페인터 ──────────────────────────────
class _DashedGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const radius = 16.0;
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    // 점선으로 path 그리기
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final len = dashWidth;
        canvas.drawPath(
          metric.extractPath(dist, dist + len),
          paint,
        );
        dist += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedGuidePainter oldDelegate) => false;
}

// ── 약품 인식 내역 (REQ-PILL-004) ─────────────────────────
class PillHistoryPage extends StatefulWidget {
  const PillHistoryPage({super.key});

  @override
  State<PillHistoryPage> createState() => _PillHistoryPageState();
}

class _PillHistoryPageState extends State<PillHistoryPage> {
  final _client = http.Client();
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _recognitions = [];

  @override
  void initState() {
    super.initState();
    _loadRecognitions();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _loadRecognitions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final token = await SecureTokenStorage().getAccessToken();
      if (token == null) throw Exception('토큰 없음');

      final response = await _client.get(
        Uri.parse('${OcrConfig.baseUrl}/v1/pills/recognitions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(OcrConfig.timeoutDuration);

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recognitions = List<Map<String, dynamic>>.from(
              data is List ? data : data['items'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '약품 인식 내역',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF22C55E)))
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('데이터를 불러오지 못했습니다.',
                          style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadRecognitions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('다시 시도',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFF22C55E),
                  onRefresh: _loadRecognitions,
                  child: _recognitions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.medication_outlined,
                                  size: 64,
                                  color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              const Text('약품 인식 내역이 없습니다.',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _recognitions.length,
                          itemBuilder: (_, i) =>
                              _buildRecognitionCard(_recognitions[i]),
                        ),
                ),
    );
  }

  Widget _buildRecognitionCard(Map<String, dynamic> recognition) {
    final candidates = (recognition['candidates'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final createdAt = recognition['created_at'] as String? ?? '';
    final topCandidate = candidates.isNotEmpty ? candidates.first : null;

    String formattedDate = createdAt;
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      formattedDate =
          '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined,
                    color: Color(0xFF22C55E), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topCandidate != null
                          ? topCandidate['drug_name'] as String? ?? '약품명 없음'
                          : '인식 결과 없음',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87),
                    ),
                    Text(formattedDate,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                '후보 ${candidates.length}개',
                style: const TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
