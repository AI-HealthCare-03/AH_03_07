"""NFR-COMPLI-003 의료광고 필터 단위 테스트."""

from unittest.mock import MagicMock, patch

import pytest

from app.services.content_advertisement_filter import (
    apply_advertisement_filter,
    handle_pre_save,
)

# ── 순수 함수 테스트 ──────────────────────────────────────────


def test_clean_content_passes() -> None:
    result = apply_advertisement_filter("루푸스 환자는 자외선 차단이 중요합니다.")
    assert result.is_blocked is False
    assert result.matched_patterns == []


def test_superiority_expression_blocked() -> None:
    result = apply_advertisement_filter("국내 최초로 개발된 치료법입니다.")
    assert result.is_blocked is True
    assert any("superiority" in p for p in result.matched_patterns)


def test_effect_guarantee_blocked() -> None:
    result = apply_advertisement_filter("이 방법으로 완치된 사례가 많습니다.")
    assert result.is_blocked is True
    assert any("effect_guarantee" in p for p in result.matched_patterns)


def test_testimonial_blocked() -> None:
    result = apply_advertisement_filter("환자 후기를 통해 효과를 확인하세요.")
    assert result.is_blocked is True
    assert any("testimonial" in p for p in result.matched_patterns)


def test_solicitation_blocked() -> None:
    result = apply_advertisement_filter("추천 병원 안내를 받아보세요.")
    assert result.is_blocked is True
    assert any("solicitation" in p for p in result.matched_patterns)


def test_multiple_categories_returns_all_matched() -> None:
    result = apply_advertisement_filter("최고의 치료로 완치 보장! 환자 후기 확인하세요.")
    assert result.is_blocked is True
    categories = {p.split(":")[0] for p in result.matched_patterns}
    assert len(categories) >= 2


def test_partial_match_within_sentence_blocked() -> None:
    """패턴이 문장 중간에 포함돼도 탐지한다."""
    result = apply_advertisement_filter("이 약은 100% 효과가 입증되었습니다.")
    assert result.is_blocked is True


def test_medical_guideline_content_passes() -> None:
    """공신력 있는 출처 기반 정상 의료 정보는 통과한다."""
    text = (
        "EULAR 권고안에 따르면 루푸스 환자는 하이드록시클로로퀸을 "
        "지속 복용하는 것이 권장됩니다. 담당 의료진과 상담하시기 바랍니다."
    )
    result = apply_advertisement_filter(text)
    assert result.is_blocked is False


# ── pre_save signal 핸들러 테스트 ────────────────────────────


@pytest.mark.asyncio
async def test_handle_pre_save_skips_when_no_guide_content() -> None:
    """guide_content가 None이면 필터를 실행하지 않는다."""
    from app.models.health_guides import HealthGuideContent

    instance = MagicMock(spec=HealthGuideContent)
    instance.guide_content = None

    with patch("app.services.content_advertisement_filter.apply_advertisement_filter") as mock_filter:
        await handle_pre_save(HealthGuideContent, instance, None, None)
        mock_filter.assert_not_called()


@pytest.mark.asyncio
async def test_handle_pre_save_blocks_ad_content() -> None:
    """의료광고 표현이 포함된 guide_content 저장을 차단한다."""
    from app.models.health_guides import HealthGuideContent

    instance = MagicMock(spec=HealthGuideContent)
    instance.guide_content = "국내 최초 특허받은 치료법으로 완치 보장합니다."
    instance.id = "test-uuid"

    with patch("app.services.content_advertisement_filter.log_advertisement_block") as mock_log:
        with pytest.raises(ValueError, match="의료광고 금지 표현"):
            await handle_pre_save(HealthGuideContent, instance, None, None)
        mock_log.assert_called_once()


@pytest.mark.asyncio
async def test_handle_pre_save_passes_clean_content() -> None:
    """정상 콘텐츠는 ValueError 없이 통과한다."""
    from app.models.health_guides import HealthGuideContent

    instance = MagicMock(spec=HealthGuideContent)
    instance.guide_content = "자외선 차단제를 매일 사용하고 정기적으로 혈액검사를 받으세요."

    await handle_pre_save(HealthGuideContent, instance, None, None)
