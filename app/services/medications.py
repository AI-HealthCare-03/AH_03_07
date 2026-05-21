import json
from urllib.parse import quote
from uuid import UUID
from openai import OpenAI
from app.core import config
from app.dtos.medications import (
    MedicationCreateRequest,
    MedicationListResponse,
    MedicationResponse,
    MedicationStructureRequest,
)
from app.repositories.medication_repository import MedicationRepository


class MedicationService:
    """약품 정보 비즈니스 로직"""

    def __init__(self):
        self.repo = MedicationRepository()
        self.openai_client = OpenAI(api_key=config.OPENAI_API_KEY)

    async def get_my_medications(self, user_id: UUID) -> MedicationListResponse:
        """내 약품 목록"""
        medications = await self.repo.get_user_medications(user_id)
        return MedicationListResponse(
            medications=[MedicationResponse.model_validate(m) for m in medications],
            total=len(medications),
        )

    async def structure_from_ocr(self, user_id: UUID, data: MedicationStructureRequest) -> MedicationListResponse:
        """OCR 텍스트를 LLM으로 구조화!"""
        prompt = f"""다음 처방전 텍스트에서 약품 정보를 추출해서 JSON 배열로 반환해주세요.

처방전 텍스트: {data.ocr_text}

JSON 형식:
[
  {{
    "drug_name_user_input": "약 이름",
    "dosage": "용량 (예: 500mg)",
    "frequency": "복용 횟수 (예: 1일 3회)",
    "duration_days": 기간_일수_정수,
    "is_autoimmune_drug": false,
    "drug_category": "분류"
  }}
]

JSON만 반환하세요 (다른 설명 없이!)."""

        response = self.openai_client.chat.completions.create(
            model=config.OPENAI_MODEL,
            messages=[
                {"role": "user", "content": prompt}
            ],
            max_tokens=1500,
        )

        try:
            content = response.choices[0].message.content.strip()
            if content.startswith("```"):
                content = content.split("```")[1]
                if content.startswith("json"):
                    content = content[4:]
                content = content.strip()

            medications_data = json.loads(content)

            for med in medications_data:
                med["prescription_id"] = data.prescription_id

            created = await self.repo.bulk_create(user_id=user_id, medications_data=medications_data)

            return MedicationListResponse(
                medications=[MedicationResponse.model_validate(m) for m in created],
                total=len(created),
            )
        except Exception as e:
            return MedicationListResponse(medications=[], total=0)

    async def create_medication(self, user_id: UUID, data: MedicationCreateRequest) -> MedicationResponse:
        """약품 수동 등록"""
        medication = await self.repo.create(
            user_id=user_id,
            prescription_id=data.prescription_id,
            drug_name_user_input=data.drug_name_user_input,
            dosage=data.dosage,
            frequency=data.frequency,
            duration_days=data.duration_days,
            start_date=data.start_date,
            end_date=data.end_date,
            is_autoimmune_drug=data.is_autoimmune_drug,
            drug_category=data.drug_category,
            notes=data.notes,
        )
        return MedicationResponse.model_validate(medication)

    @staticmethod
    def get_official_info_urls(drug_name: str) -> dict:
        """약품 공식 정보 외부 링크 (콘텐츠 생성 X, 외부 링크만!)"""
        encoded = quote(drug_name)

        return {
            "drug_name": drug_name,
            "external_sources": [
                {
                    "name": "식약처 의약품안전나라",
                    "description": "의약품 허가사항 및 복약정보 (정부 공식)",
                    "url": f"https://nedrug.mfds.go.kr/searchDrug?searchYn=true&itemName={encoded}",
                },
                {
                    "name": "약학정보원",
                    "description": "일반인 대상 의약품 정보",
                    "url": f"https://www.health.kr/search/search.asp?txtKeyword={encoded}",
                },
            ],
            "notice": "외부 사이트로 이동합니다. 콘텐츠는 해당 기관 책임입니다.",
        }