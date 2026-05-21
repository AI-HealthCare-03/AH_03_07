from typing import Annotated
from fastapi import APIRouter, Depends, status
from fastapi.responses import ORJSONResponse as Response
from app.dependencies.consent import require_consent
from app.dependencies.security import get_request_user
from app.dtos.medications import (
    MedicationCreateRequest,
    MedicationListResponse,
    MedicationResponse,
    MedicationStructureRequest,
)
from app.models.user_consents import ConsentType
from app.models.users import User
from app.services.medications import MedicationService

medication_router = APIRouter(prefix="/medications", tags=["medications"])


@medication_router.get(
    "",
    response_model=MedicationListResponse,
    status_code=status.HTTP_200_OK,
    dependencies=[Depends(require_consent(ConsentType.MEDICAL_DATA))],
)
async def get_my_medications(
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    """내 약품 목록 조회"""
    result = await service.get_my_medications(user_id=user.id)
    return Response(result.model_dump(mode="json"), status_code=status.HTTP_200_OK)


@medication_router.post(
    "/structure",
    response_model=MedicationListResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_consent(ConsentType.MEDICAL_DATA))],
)
async def structure_from_ocr(
    request: MedicationStructureRequest,
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    """OCR 텍스트를 LLM으로 구조화 (REQ-OCR-003)"""
    result = await service.structure_from_ocr(user_id=user.id, data=request)
    return Response(result.model_dump(mode="json"), status_code=status.HTTP_201_CREATED)


@medication_router.post(
    "",
    response_model=MedicationResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_consent(ConsentType.MEDICAL_DATA))],
)
async def create_medication(
    request: MedicationCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    """약품 수동 등록"""
    result = await service.create_medication(user_id=user.id, data=request)
    return Response(result.model_dump(mode="json"), status_code=status.HTTP_201_CREATED)

@medication_router.get("/official-info/{drug_name}")
async def get_official_info(
    drug_name: str,
    user: Annotated[User, Depends(get_request_user)],
):
    """약품 공식 정보 외부 링크 (콘텐츠 생성 X)"""
    service = MedicationService()
    return service.get_official_info_urls(drug_name)
