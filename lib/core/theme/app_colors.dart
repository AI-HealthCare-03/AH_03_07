// 앱 전역 색상 상수
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // 브랜드
  static const primary   = Color(0xFF22C55E); // 주 그린 (와이어프레임 통일)
  static const green     = Color(0xFF22C55E); // 초록
  static const greenDark = Color(0xFF16A34A);

  // 텍스트
  static const textPrimary   = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF888888);

  // 배경
  static const bg     = Color(0xFFF8F8F8);
  static const bgCard = Colors.white;

  // 구분선
  static const divider = Color(0xFFF0F0F0);

  // 상태
  static const error   = Colors.red;
  static const warning = Color(0xFFFFCA28);
  static const success = Color(0xFF66BB6A);

  // 게이미피케이션
  static const gold   = Color(0xFFFFD700);
  static const purple = Color(0xFF7C5CCF);
  static const purpleLight = Color(0xFFF0E8FF);
}
