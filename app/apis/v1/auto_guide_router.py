"""REQ-AUTO-005 맞춤 안내문 수동 생성 엔드포인트."""

from fastapi import APIRouter, Depends

from app.auto_guide.schema import OrchestratorResult, OrchestratorStatus
from app.auto_guide.service import orchestrate
from app.core.logger import default_logger as logger
from app.dependencies.security import get_request_user
from app.models.auto_guide import AutoGuide, AutoGuideStatus
from app.models.users import User

auto_guide_router = APIRouter(prefix="/guide", tags=["guide"])


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
