from pydantic import BaseModel

from app.models.diet_info import DietCategory
from app.models.user_disease import DiseaseCode


class DietLink(BaseModel):
    source: str
    url: str
    description: str


class DrugLinkResponse(BaseModel):
    drug_name: str
    external_links: list[DietLink]
    disclaimer: str


class DietInfoResponse(BaseModel):
    id: int
    disease_code: DiseaseCode
    category: DietCategory
    food_name: str
    reason: str

    class Config:
        from_attributes = True
