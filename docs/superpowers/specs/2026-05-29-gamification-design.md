# REQ-GAME-002 포인트·뱃지·보상 시스템 설계

## 개요
마이페이지에 포인트·레벨·뱃지·보상 시스템을 추가한다.
백엔드 API가 없으므로 더미 데이터로 먼저 구현하고, 나중에 API 교체가 쉬운 구조로 만든다.

## 화면 구조

마이페이지 상단에 포인트·레벨 카드를 추가하고, 뱃지/보상 탭을 그 아래에 배치한다.

```
마이페이지
├── 포인트·레벨 카드
│   └── 레벨명, 현재 포인트, 다음 레벨까지 진행바
├── [뱃지] [보상] 탭
│   ├── 뱃지 탭: 그리드 (획득=컬러, 미획득=흐릿+자물쇠)
│   └── 보상 탭: 칭호 목록 + 테마 목록 (포인트 차감 교환)
```

## 포인트 적립 조건

| 행동 | 포인트 |
|---|---|
| 출석체크 (일 1회) | +10 |
| 검사결과 기록 | +20 |
| 챗봇 이용 | +5 |
| 가이드 읽기 | +5 |
| 복약 체크 완료 | +10 |

## 레벨 구조

| 레벨 | 이름 | 필요 포인트 |
|---|---|---|
| 1 | 건강 새싹 | 0 |
| 2 | 건강 관리자 | 100 |
| 3 | 건강 지킴이 | 300 |
| 4 | 건강 전문가 | 600 |
| 5 | 건강 마스터 | 1000 |

## 뱃지 목록

| ID | 이름 | 조건 |
|---|---|---|
| first_record | 첫 기록 | 검사결과 첫 등록 |
| streak_7 | 7일 연속 | 7일 연속 출석 |
| streak_30 | 한 달 개근 | 30일 연속 출석 |
| med_10 | 복약 습관 | 복약 체크 10회 |
| med_30 | 복약 마스터 | 복약 체크 30회 |
| chat_10 | 챗봇 친구 | 챗봇 10회 이용 |
| guide_reader | 가이드 탐험가 | 가이드 5개 읽기 |
| lab_5 | 검사 기록왕 | 검사결과 5개 등록 |

## 보상 목록

### 칭호
| ID | 이름 | 필요 포인트 |
|---|---|---|
| title_guardian | 건강 지킴이 | 200 |
| title_master | 복약 마스터 | 300 |
| title_explorer | 가이드 탐험가 | 150 |

### 테마
| ID | 이름 | 필요 포인트 |
|---|---|---|
| theme_green | 그린 테마 | 500 |
| theme_blue | 블루 테마 | 500 |
| theme_purple | 퍼플 테마 | 800 |

## 파일 구조

```
lib/features/gamification/
  models/gamification_models.dart     — 데이터 모델
  services/gamification_service.dart  — 더미 데이터 (API 교체 포인트)
  pages/gamification_page.dart        — 뱃지/보상 탭 페이지
  widgets/point_card_widget.dart      — 포인트·레벨 카드
  widgets/badge_grid_widget.dart      — 뱃지 그리드
  widgets/reward_shop_widget.dart     — 보상 상점
```

## API 연동 전략

`GamificationService`에 더미 데이터를 반환하는 메서드를 만들고,
나중에 `ApiClient`를 주입해 실제 API로 교체하는 구조.

```dart
class GamificationService {
  // 나중에 ApiClient 주입으로 교체
  Future<UserPoints> getPoints() async => UserPoints.dummy();
  Future<List<Badge>> getBadges() async => Badge.dummyList();
}
```

## 마이페이지 연동

`my_page.dart` 상단에 `PointCardWidget` 추가,
"뱃지·보상" 버튼 탭 시 `GamificationPage`로 이동.
