from uuid import UUID

from app.models.medications import Medication


class MedicationRepository:
    """약품 정보 DB 쿼리"""

    @staticmethod
    async def get_user_medications(user_id: UUID) -> list[Medication]:
        return await Medication.filter(user_id=user_id).order_by("-created_at").all()

    @staticmethod
    async def get_by_prescription(prescription_id: UUID) -> list[Medication]:
        return await Medication.filter(prescription_id=prescription_id).all()

    @staticmethod
    async def create(user_id: UUID, **kwargs) -> Medication:
        return await Medication.create(user_id=user_id, **kwargs)

    @staticmethod
    async def bulk_create(user_id: UUID, medications_data: list[dict]) -> list[Medication]:
        created = []
        for data in medications_data:
            med = await Medication.create(user_id=user_id, **data)
            created.append(med)
        return created
