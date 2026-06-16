from app.dtos.diet_info import DietInfoResponse
from app.models.user_disease import DiseaseCode
from app.repositories.diet_info_repository import DietInfoRepository


class DietInfoQueryService:
    def __init__(self):
        self.repo = DietInfoRepository()

    async def get_diet_info_by_disease(self, disease_code: DiseaseCode) -> list[DietInfoResponse]:
        items = await self.repo.get_by_disease_code(disease_code)
        return [DietInfoResponse.model_validate(item) for item in items]

    async def get_all_diet_info(self) -> list[DietInfoResponse]:
        items = await self.repo.get_all()
        return [DietInfoResponse.model_validate(item) for item in items]
