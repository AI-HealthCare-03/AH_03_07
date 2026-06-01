"""REQ-AUTO-005/006 맞춤 안내문 엔드포인트."""

from fastapi import APIRouter, Depends, HTTPException

from app.auto_guide.schema import (
    GuideSectionItem,
    GuideSectionType,
    GuideSourceItem,
    OrchestratorResult,
    OrchestratorStatus,
)
from app.auto_guide.service import orchestrate
from app.core.logger import default_logger as logger
from app.dependencies.security import get_request_user
from app.models.auto_guide import AutoGuide, AutoGuideStatus
from app.models.users import User

auto_guide_router = APIRouter(prefix="/guides", tags=["guides"])


@auto_guide_router.post("/generate", response_model=OrchestratorResult)
async def generate_guide_endpoint(
    current_user: User = Depends(get_request_user),
) -> OrchestratorResult:
    """맞춤 안내문 수동 생성 (REQ-AUTO-005).

    자가면역 모드 + 질환 등록 + 입력 소스 조건이 충족되어야 안내문이 생성된다.
    조건 미충족 시 TRIGGER_NOT_MET 상태를 반환한다.
    GENERATED 상태일 때만 auto_guides 테이블에 영속화한다.
    """
    result = await orchestrate(user_id=current_user.id)

    if result.orchestrator_status == OrchestratorStatus.GENERATED and result.guide is not None:
        try:
            guide = result.guide
            saved = await AutoGuide.create(
                user_id=current_user.id,
                status=AutoGuideStatus.GENERATED,
                medication_general=guide.medication_general,
                side_effect_monitoring=guide.side_effect_monitoring,
                lifestyle_info=guide.lifestyle_info,
                symptom_summary=guide.symptom_summary,
                sources=[s.model_dump() for s in guide.sources],
                disclaimer=guide.disclaimer,
            )
            result.guide_id = saved.id
        except Exception as exc:
            logger.error(f'{{"event": "auto_guide_persist_failed", "user_id": {current_user.id}, "error": "{exc}"}}')

    return result


@auto_guide_router.get("/{guide_id}/sources", response_model=list[GuideSourceItem])
async def get_guide_sources(
    guide_id: int,
    current_user: User = Depends(get_request_user),
) -> list[GuideSourceItem]:
    """안내문 출처 목록 조회 (REQ-AUTO-005)."""
    guide = await AutoGuide.get_or_none(id=guide_id, user_id=current_user.id)
    if guide is None:
        raise HTTPException(status_code=404, detail="Guide not found")
    return [
        GuideSourceItem(
            citation_order=i + 1,
            source_title=s["title"],
            source_org=s["organization"],
            source_page=s.get("page"),
            used_for_section=s.get("section"),
        )
        for i, s in enumerate(guide.sources)
    ]


@auto_guide_router.get("/{guide_id}/sections", response_model=list[GuideSectionItem])
async def get_guide_sections(
    guide_id: int,
    current_user: User = Depends(get_request_user),
) -> list[GuideSectionItem]:
    """안내문 섹션 목록 조회 (REQ-AUTO-006)."""
    guide = await AutoGuide.get_or_none(id=guide_id, user_id=current_user.id)
    if guide is None:
        raise HTTPException(status_code=404, detail="Guide not found")

    monitoring = guide.side_effect_monitoring
    side_effect_content = "\n".join(monitoring) if isinstance(monitoring, list) else monitoring

    return [
        GuideSectionItem(
            section_type=GuideSectionType.MEDICATION_GENERAL,
            section_title="복약 일반 정보",
            section_content=guide.medication_general,
            display_order=1,
        ),
        GuideSectionItem(
            section_type=GuideSectionType.SIDE_EFFECT,
            section_title="부작용 모니터링",
            section_content=side_effect_content,
            display_order=2,
        ),
        GuideSectionItem(
            section_type=GuideSectionType.LIFESTYLE,
            section_title="생활 정보",
            section_content=guide.lifestyle_info,
            display_order=3,
        ),
        GuideSectionItem(
            section_type=GuideSectionType.SYMPTOM_SUMMARY,
            section_title="증상 요약",
            section_content=guide.symptom_summary,
            display_order=4,
        ),
    ]
