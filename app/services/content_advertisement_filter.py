"""NFR-COMPLI-003 의료광고법 준수 콘텐츠 출력 게이트.

의료법 제56조(의료광고 금지) 준수:
HealthGuide guide_content 저장 전 의료광고성 금지 표현을 탐지하고 차단한다.
차단 이력은 NFR-COMPLI-004 감사 로그로 기록한다.
"""

import json
from dataclasses import dataclass, field

from tortoise.signals import pre_save

from app.core.logger import default_logger as logger

# 의료광고법 금지 표현 (의료법 제56조 기준)
_FORBIDDEN_AD: dict[str, list[str]] = {
    "superiority": [
        "최고의",
        "1위",
        "유일한",
        "특허받은",
        "독보적인",
        "국내 최초",
        "세계 최고",
        "검증된 유일",
    ],
    "effect_guarantee": [
        "완치",
        "100% 효과",
        "기적의",
        "반드시 낫",
        "효과를 보장",
        "치료를 보장",
        "완전히 나을",
    ],
    "testimonial": [
        "환자 후기",
        "체험담",
        "경험담",
        "실제 후기",
        "환자 사례",
        "치료 후기",
    ],
    "solicitation": [
        "추천 병원",
        "병원 소개",
        "전문 의료진 연결",
        "예약 안내",
        "진료 예약",
        "의료기관 알선",
    ],
}


@dataclass
class AdvertisementFilterResult:
    is_blocked: bool
    matched_patterns: list[str] = field(default_factory=list)


def apply_advertisement_filter(text: str) -> AdvertisementFilterResult:
    """의료광고 금지 표현을 스캔하여 탐지 결과를 반환한다."""
    matched: list[str] = []
    for category, patterns in _FORBIDDEN_AD.items():
        for pattern in patterns:
            if pattern in text:
                matched.append(f"{category}:{pattern}")

    return AdvertisementFilterResult(is_blocked=bool(matched), matched_patterns=matched)


def log_advertisement_block(guide_id: object, matched_patterns: list[str]) -> None:
    """의료광고 표현 차단 감사 로그 기록 (NFR-COMPLI-004)."""
    logger.warning(
        json.dumps(
            {
                "event": "nfr_compli_003_blocked",
                "guide_id": str(guide_id),
                "matched_patterns": matched_patterns,
            },
            ensure_ascii=False,
        )
    )


async def handle_pre_save(sender, instance, using_db, update_fields) -> None:  # type: ignore[no-untyped-def]
    """HealthGuide pre_save 핸들러. 테스트에서 직접 호출 가능."""
    if not instance.guide_content:
        return

    result = apply_advertisement_filter(instance.guide_content)
    if result.is_blocked:
        log_advertisement_block(instance.id, result.matched_patterns)
        raise ValueError(f"의료광고 금지 표현이 포함된 콘텐츠입니다 (의료법 제56조): {result.matched_patterns}")


def _register_signals() -> None:
    """HealthGuideContent pre_save signal 등록. main.py import 시 자동 호출된다."""
    from app.models.health_guides import HealthGuideContent

    pre_save(HealthGuideContent)(handle_pre_save)


_register_signals()
