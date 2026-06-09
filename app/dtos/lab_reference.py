from pydantic import BaseModel, ConfigDict


class LabReferenceResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    code: str
    name_ko: str
    abbr: str | None = None
    category: str | None = None
    description: str | None = None
    unit: str | None = None
    reference_range_general: str | None = None
    reference_note: str | None = None
    source: str | None = None
