import json
from uuid import UUID
from openai import OpenAI
from app.core import config
from app.dtos.pill_recognitions import (
    PillRecognitionListResponse,
    PillRecognitionResponse,
    PillSelectRequest,
)
from app.models.pill_recognitions import RecognitionStatus
from app.repositories.pill_recognition_repository import PillRecognitionRepository


class PillRecognitionService:
    """약품 인식 비즈니스 로직 (PILL-002 MVP - OpenAI Vision 사용)"""

    def __init__(self):
        self.repo = PillRecognitionRepository()
        self.openai_client = OpenAI(api_key=config.OPENAI_API_KEY)

    async def recognize_pill(self, user_id: UUID, image_url: str) -> PillRecognitionResponse:
        """약품 이미지 인식 (Top 3 후보!)"""
        # 1. 레코드 생성
        recognition = await self.repo.create(user_id=user_id, image_url=image_url)

        try:
            # 2. 상태 업데이트
            recognition.status = RecognitionStatus.PROCESSING
            await recognition.save()

            # 3. OpenAI Vision으로 인식!
            response = self.openai_client.chat.completions.create(
                model=config.OPENAI_MODEL,
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": """이 이미지에서 약품을 인식해주세요.
가능성이 높은 약품 Top 3 후보를 신뢰도와 함께 JSON으로 반환해주세요.

JSON 형식:
[
    {"drug_name": "약품명1", "confidence": 0.95},
    {"drug_name": "약품명2", "confidence": 0.75},
    {"drug_name": "약품명3", "confidence": 0.50}
]

JSON만 반환하세요 (다른 설명 없이!)."""
                            },
                            {"type": "image_url", "image_url": {"url": image_url}}
                        ]
                    }
                ],
                max_tokens=500,
            )

            content = response.choices[0].message.content.strip()
            if content.startswith("```"):
                content = content.split("```")[1]
                if content.startswith("json"):
                    content = content[4:]
                content = content.strip()

            candidates = json.loads(content)

            # 4. Top 3 저장
            if len(candidates) >= 1:
                recognition.top1_drug_name = candidates[0]["drug_name"]
                recognition.top1_confidence = candidates[0]["confidence"]
            if len(candidates) >= 2:
                recognition.top2_drug_name = candidates[1]["drug_name"]
                recognition.top2_confidence = candidates[1]["confidence"]
            if len(candidates) >= 3:
                recognition.top3_drug_name = candidates[2]["drug_name"]
                recognition.top3_confidence = candidates[2]["confidence"]

            # 5. 신뢰도 0.7 미만이면 LOW_CONFIDENCE!
            if recognition.top1_confidence and recognition.top1_confidence < 0.7:
                recognition.status = RecognitionStatus.LOW_CONFIDENCE
            else:
                recognition.status = RecognitionStatus.COMPLETED

            await recognition.save()

        except Exception as e:
            recognition.status = RecognitionStatus.FAILED
            recognition.error_message = str(e)
            await recognition.save()

        return PillRecognitionResponse.model_validate(recognition)

    async def select_drug(self, recognition_id: UUID, data: PillSelectRequest) -> PillRecognitionResponse:
        """사용자가 Top 후보 중 선택!"""
        recognition = await self.repo.get_by_id(recognition_id)
        if not recognition:
            raise Exception("인식 결과를 찾을 수 없습니다")

        recognition.selected_drug_name = data.selected_drug_name
        await recognition.save()

        return PillRecognitionResponse.model_validate(recognition)

    async def get_my_recognitions(self, user_id: UUID) -> PillRecognitionListResponse:
        """내 약품 인식 이력"""
        recognitions = await self.repo.get_user_recognitions(user_id)
        return PillRecognitionListResponse(
            recognitions=[PillRecognitionResponse.model_validate(r) for r in recognitions],
            total=len(recognitions),
        )