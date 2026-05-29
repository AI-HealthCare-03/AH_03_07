from uuid import UUID

from app.models.pill_recognitions import PillRecognition


class PillRecognitionRepository:
    """약품 인식 DB 쿼리"""

    @staticmethod
    async def create(user_id: UUID, image_url: str) -> PillRecognition:
        return await PillRecognition.create(user_id=user_id, image_url=image_url)

    @staticmethod
    async def get_by_id(recognition_id: UUID) -> PillRecognition | None:
        return await PillRecognition.filter(id=recognition_id).first()

    @staticmethod
    async def get_user_recognitions(user_id: UUID) -> list[PillRecognition]:
        return await PillRecognition.filter(user_id=user_id).order_by("-created_at").all()
