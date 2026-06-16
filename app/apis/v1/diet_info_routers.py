from typing import Annotated

from fastapi import APIRouter, Depends, Query
from fastapi.responses import ORJSONResponse as Response

from app.dependencies.security import get_request_user
from app.dtos.diet_info import DietInfoResponse, DrugLinkResponse
from app.models.user_disease import DiseaseCode
from app.models.users import User
from app.services.diet_info import DietInfoService
from app.services.diet_info_service import DietInfoQueryService

diet_info_router = APIRouter(prefix="/diet-info", tags=["diet-info"])
diet_router = APIRouter(prefix="/diet", tags=["diet"])


@diet_info_router.get("", response_model=DrugLinkResponse)
async def get_drug_links(
    drug_name: Annotated[str, Query(min_length=1, description="약품명 (예: 타크로리무스)")],
    user: Annotated[User, Depends(get_request_user)],
) -> DrugLinkResponse:
    """약품명으로 공식 외부 링크 진입점 4개를 반환한다 (REQ-DIET-001).

    앱은 콘텐츠를 생성·수집·재가공하지 않으며, 공식 기관 검색 URL만 제공한다.
    """
    service = DietInfoService()
    return service.get_external_links(drug_name)


@diet_router.get("/info", response_model=list[DietInfoResponse])
async def get_diet_info(
    disease_code: Annotated[DiseaseCode | None, Query(description="질환 코드 (예: RA, SLE)")] = None,
    user: Annotated[User, Depends(get_request_user)] = None,
) -> Response:
    """질환별 식이 정보 조회.

    disease_code 미전달 시 전체 식이 정보를 반환한다.
    """
    service = DietInfoQueryService()
    if disease_code:
        result = await service.get_diet_info_by_disease(disease_code)
    else:
        result = await service.get_all_diet_info()
    return Response([item.model_dump(mode="json") for item in result])
