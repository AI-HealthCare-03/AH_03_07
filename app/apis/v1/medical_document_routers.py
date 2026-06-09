from datetime import datetime
from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Response, status
from fastapi.responses import ORJSONResponse
from pydantic import BaseModel

from app.dependencies.consent import require_consent
from app.dependencies.security import get_request_user
from app.models.medical_documents import DocumentType, MedicalDocument, OcrJob, OcrJobStatus, UploadStatus
from app.models.user_consents import ConsentType
from app.models.users import User

medical_document_router = APIRouter(
    prefix="/medical-documents",
    tags=["medical-documents"],
    dependencies=[Depends(require_consent(ConsentType.MEDICAL_DATA))],
)


# ─── DTOs ─────────────────────────────────────────────────────────────────────


class MedicalDocumentCreateRequest(BaseModel):
    document_type: DocumentType
    original_filename: str
    file_path: str
    stored_filename: str
    file_size: int | None = None
    mime_type: str | None = None


class MedicalDocumentResponse(BaseModel):
    id: int
    document_type: DocumentType
    original_filename: str
    mime_type: str | None
    upload_status: UploadStatus
    is_user_confirmed: bool
    created_at: datetime

    class Config:
        from_attributes = True


class OcrJobResponse(BaseModel):
    id: int
    document_id: int
    status: OcrJobStatus
    raw_text: str | None
    structured_data: str | None
    confidence_score: float | None
    error_message: str | None
    started_at: datetime | None
    completed_at: datetime | None
    created_at: datetime

    class Config:
        from_attributes = True


# ─── Endpoints ────────────────────────────────────────────────────────────────


@medical_document_router.get("", status_code=status.HTTP_200_OK)
async def list_documents(
    user: Annotated[User, Depends(get_request_user)],
) -> ORJSONResponse:
    docs = await MedicalDocument.filter(user_id=user.id, deleted_at=None).order_by("-created_at").all()
    return ORJSONResponse([MedicalDocumentResponse.model_validate(d).model_dump(mode="json") for d in docs])


@medical_document_router.get("/{document_id}", status_code=status.HTTP_200_OK)
async def get_document(
    document_id: int,
    user: Annotated[User, Depends(get_request_user)],
) -> ORJSONResponse:
    doc = await MedicalDocument.filter(id=document_id, user_id=user.id, deleted_at=None).first()
    if doc is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="문서를 찾을 수 없습니다.")
    return ORJSONResponse(MedicalDocumentResponse.model_validate(doc).model_dump(mode="json"))


@medical_document_router.post("", status_code=status.HTTP_201_CREATED)
async def create_document(
    body: MedicalDocumentCreateRequest,
    user: Annotated[User, Depends(get_request_user)],
) -> ORJSONResponse:
    doc = await MedicalDocument.create(
        user_id=user.id,
        document_type=body.document_type,
        file_path=body.file_path,
        original_filename=body.original_filename,
        stored_filename=body.stored_filename,
        file_size=body.file_size,
        mime_type=body.mime_type,
    )
    return ORJSONResponse(
        MedicalDocumentResponse.model_validate(doc).model_dump(mode="json"),
        status_code=status.HTTP_201_CREATED,
    )


@medical_document_router.delete("/{document_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_document(
    document_id: int,
    user: Annotated[User, Depends(get_request_user)],
) -> Response:
    doc = await MedicalDocument.filter(id=document_id, user_id=user.id, deleted_at=None).first()
    if doc is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="문서를 찾을 수 없습니다.")
    doc.deleted_at = datetime.now()
    doc.upload_status = UploadStatus.deleted
    await doc.save()
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@medical_document_router.get("/{document_id}/ocr-jobs", status_code=status.HTTP_200_OK)
async def list_ocr_jobs(
    document_id: int,
    user: Annotated[User, Depends(get_request_user)],
) -> ORJSONResponse:
    doc = await MedicalDocument.filter(id=document_id, user_id=user.id, deleted_at=None).first()
    if doc is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="문서를 찾을 수 없습니다.")
    jobs = await OcrJob.filter(document_id=document_id).order_by("-created_at").all()
    return ORJSONResponse([OcrJobResponse.model_validate(j).model_dump(mode="json") for j in jobs])


@medical_document_router.put("/{document_id}/confirm", status_code=status.HTTP_200_OK)
async def confirm_document(
    document_id: int,
    user: Annotated[User, Depends(get_request_user)],
) -> ORJSONResponse:
    doc = await MedicalDocument.filter(id=document_id, user_id=user.id, deleted_at=None).first()
    if doc is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="문서를 찾을 수 없습니다.")
    doc.is_user_confirmed = True
    doc.upload_status = UploadStatus.confirmed
    await doc.save()
    return ORJSONResponse(MedicalDocumentResponse.model_validate(doc).model_dump(mode="json"))
