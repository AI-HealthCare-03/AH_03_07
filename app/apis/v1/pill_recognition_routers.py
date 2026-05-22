from typing import Annotated
from uuid import UUID
from fastapi import APIRouter, Depends, status
from app.dependencies.security import get_request_user
from app.dtos.pill_recognitions import (
    PillRecognitionCreateRequest,
    PillRecognitionListResponse,
    PillRecognitionResponse,
    PillSelectRequest,
)
from app.models.users import User
from app.services.pill_recognitions import PillRecognitionService


pill_router = APIRouter(prefix="/pills", tags=["pills"])


@pill_router.post("/recognize", response_model=PillRecognitionResponse, status_code=status.HTTP_201_CREATED)
async def recognize_pill(
    data: PillRecognitionCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
):
    """약품 이미지 인식 (PILL-002)"""
    service = PillRecognitionService()
    return await service.recognize_pill(user.id, data.image_url)


@pill_router.put("/{recognition_id}/select", response_model=PillRecognitionResponse)
async def select_drug(
    recognition_id: UUID,
    data: PillSelectRequest,
    user: Annotated[User, Depends(get_request_user)],
):
    """Top 후보 중 약품 선택"""
    service = PillRecognitionService()
    return await service.select_drug(recognition_id, data)


@pill_router.get("", response_model=PillRecognitionListResponse)
async def get_my_recognitions(
    user: Annotated[User, Depends(get_request_user)],
):
    """내 약품 인식 이력"""
    service = PillRecognitionService()
    return await service.get_my_recognitions(user.id)