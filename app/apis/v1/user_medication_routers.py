from typing import Annotated

from fastapi import APIRouter, Depends, status
from fastapi.responses import ORJSONResponse as Response

from app.dependencies.security import get_request_user
from app.dtos.autoimmune_profile import (
    MedicationBulkCreateRequest,
    MedicationResponse,
    MedicationUpdateRequest,
)
from app.models.users import User
from app.services.autoimmune_profile_service import MedicationService

user_medication_router = APIRouter(prefix="/user-medications", tags=["user-medications"])


@user_medication_router.post(
    "",
    status_code=status.HTTP_201_CREATED,
)
async def create_medications(
    request: MedicationBulkCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    result = await service.create_medications(user=user, data=request)
    return Response(
        [MedicationResponse.model_validate(m).model_dump(mode="json") for m in result],
        status_code=status.HTTP_201_CREATED,
    )


@user_medication_router.get(
    "",
    status_code=status.HTTP_200_OK,
)
async def list_medications(
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    result = await service.list_medications(user=user)
    return Response(
        [MedicationResponse.model_validate(m).model_dump(mode="json") for m in result], status_code=status.HTTP_200_OK
    )


@user_medication_router.patch(
    "/{medication_id}",
    status_code=status.HTTP_200_OK,
)
async def update_medication(
    medication_id: int,
    request: MedicationUpdateRequest,
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    result = await service.update_medication(user=user, medication_id=medication_id, data=request)
    return Response(MedicationResponse.model_validate(result).model_dump(mode="json"), status_code=status.HTTP_200_OK)


@user_medication_router.delete(
    "/{medication_id}",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def delete_medication(
    medication_id: int,
    user: Annotated[User, Depends(get_request_user)],
    service: Annotated[MedicationService, Depends(MedicationService)],
) -> Response:
    await service.delete_medication(user=user, medication_id=medication_id)
    return Response(None, status_code=status.HTTP_204_NO_CONTENT)
