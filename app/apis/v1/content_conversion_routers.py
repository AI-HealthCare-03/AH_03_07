from typing import Annotated

from fastapi import APIRouter, Depends, status

from app.dependencies.security import get_request_user
from app.dtos.content_conversions import (
    CardNewsCreateRequest,
    ContentConversionResponse,
    HealthSummaryTTSResponse,
)
from app.models.users import User
from app.services.content_conversions import ContentConversionService

content_router = APIRouter(prefix="/contents", tags=["content"])


@content_router.post("/card-news", response_model=ContentConversionResponse, status_code=status.HTTP_201_CREATED)
async def create_card_news(
    data: CardNewsCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
):
    """카드뉴스 생성 (CONT-001)"""
    service = ContentConversionService()
    return await service.create_card_news(user.id, data.guide_id)


@content_router.post("/tts", response_model=ContentConversionResponse, status_code=status.HTTP_201_CREATED)
async def create_tts(
    data: CardNewsCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
):
    """가이드 → 음성 변환 (CONT-002)"""
    service = ContentConversionService()
    return await service.create_tts(user.id, data.guide_id)


@content_router.post("/health-summary-tts", response_model=HealthSummaryTTSResponse, status_code=status.HTTP_200_OK)
async def create_health_summary_tts(
    user: Annotated[User, Depends(get_request_user)],
):
    """오늘 컨디션·건강수치·복약 요약 음성 생성"""
    service = ContentConversionService()
    return await service.create_health_summary_tts(user.id)
