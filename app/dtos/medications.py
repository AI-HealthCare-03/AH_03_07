from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel


class MedicationStructureRequest(BaseModel):
    prescription_id: UUID
    ocr_text: str


class MedicationCreateRequest(BaseModel):
    prescription_id: UUID | None = None
    drug_name_user_input: str
    dosage: str | None = None
    frequency: str | None = None
    duration_days: int | None = None
    start_date: date | None = None
    end_date: date | None = None
    is_autoimmune_drug: bool = False
    drug_category: str | None = None
    notes: str | None = None


class MedicationResponse(BaseModel):
    id: UUID
    drug_name_user_input: str
    dosage: str | None
    frequency: str | None
    duration_days: int | None
    start_date: date | None
    end_date: date | None
    is_autoimmune_drug: bool
    drug_category: str | None
    notes: str | None
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MedicationListResponse(BaseModel):
    medications: list[MedicationResponse]
    total: int
