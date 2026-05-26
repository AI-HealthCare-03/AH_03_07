from typing import Annotated
from fastapi import APIRouter, Depends
from app.dependencies.security import get_request_user
from app.dtos.vaccinations import VaccinationInfoResponse
from app.models.users import User
from app.services.vaccinations import VaccinationService

vaccination_router = APIRouter(prefix="/vaccinations", tags=["vaccinations"])

@vaccination_router.get("/info", response_model=VaccinationInfoResponse)
async def get_vaccination_info(
    user: Annotated[User, Depends(get_request_user)],
):
    """백신·감염 예방 정보 안내 (REQ-AUTO-PREV-001)"""
    service = VaccinationService()
    return service.get_vaccination_info()