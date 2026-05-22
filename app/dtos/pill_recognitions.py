from datetime import datetime
from uuid import UUID
from pydantic import BaseModel
from app.models.pill_recognitions import RecognitionStatus

class PillRecognitionCreateRequest(BaseModel):
    image_url: str

class PillSelectRequest(BaseModel):
    selected_drug_name: str

class PillRecognitionResponse(BaseModel):
    id: UUID
    image_url: str
    status: RecognitionStatus
    top1_drug_name: str | None
    top1_confidence: float | None
    top2_drug_name: str | None
    top2_confidence: float | None
    top3_drug_name: str | None
    top3_confidence: float | None
    selected_drug_name: str | None
    error_message: str | None
    created_at: datetime

    class Config:
        from_attributes = True

class PillRecognitionListResponse(BaseModel):
    recognitions: list[PillRecognitionResponse]
    total: int