from typing import Annotated

from fastapi import APIRouter, Depends
from tortoise.expressions import Q

from app.dependencies.security import get_request_user
from app.dtos.lab_reference import LabReferenceResponse
from app.models.lab_reference import LabReference
from app.models.users import User

lab_reference_router = APIRouter(prefix="/lab-references", tags=["lab-reference"])


@lab_reference_router.get("", response_model=list[LabReferenceResponse])
async def list_lab_references(
    user: Annotated[User, Depends(get_request_user)],
    query: str | None = None,
    category: str | None = None,
) -> list[LabReference]:
    """검사 항목 일반 참고 정보(조회용). 자동 판정·추천 아님. 참고범위는 일반 참고치이며 검사실별 상이."""
    qs = LabReference.all()
    if category:
        qs = qs.filter(category=category)
    if query:
        qs = qs.filter(
            Q(code__icontains=query)
            | Q(name_ko__icontains=query)
            | Q(abbr__icontains=query)
            | Q(description__icontains=query)
        )
    return await qs.order_by("category", "name_ko")
