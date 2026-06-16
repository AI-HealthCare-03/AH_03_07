from typing import Annotated

from fastapi import APIRouter, Depends, status
from fastapi.responses import ORJSONResponse as Response

from app.dependencies.security import get_request_user
from app.dtos.dashboard import DashboardResponse
from app.models.users import User
from app.services.dashboard import DashboardService

dashboard_router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@dashboard_router.get(
    "",
    response_model=DashboardResponse,
    status_code=status.HTTP_200_OK,
)
async def get_dashboard(
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[DashboardService, Depends(DashboardService)],
) -> Response:
    """홈 대시보드 메인 (REQ-MYPG-001)"""
    result = await service.get_dashboard(user_id=user.id)
    return Response(result.model_dump(mode="json"), status_code=status.HTTP_200_OK)
