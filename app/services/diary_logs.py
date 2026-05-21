from datetime import date

from app.dtos.diary_logs import (
    MedicationLogCreateRequest,
    MedicationLogListResponse,
    MedicationLogResponse,
    SymptomLogCreateRequest,
    SymptomLogListResponse,
    SymptomLogResponse,
)
from app.repositories.diary_log_repository import DiaryLogRepository


class DiaryLogService:
    """일기 (증상 + 복약) 비즈니스 로직"""

    def __init__(self):
        self.repo = DiaryLogRepository()

    # ========== 증상 기록 ==========

    async def get_symptom_logs(self, user_id: int) -> SymptomLogListResponse:
        """증상 기록 이력 조회"""
        logs = await self.repo.get_symptom_logs(user_id)
        return SymptomLogListResponse(
            logs=[SymptomLogResponse.model_validate(log) for log in logs],
            total=len(logs),
        )

    async def create_symptom_log(self, user_id: int, data: SymptomLogCreateRequest) -> SymptomLogResponse:
        """증상 기록 생성"""
        new_log = await self.repo.create_symptom_log(
            user_id=user_id,
            log_date=data.log_date,
            overall_condition=data.overall_condition,
            body_parts=data.body_parts,
            feeling=data.feeling,
            memo=data.memo,
        )
        return SymptomLogResponse.model_validate(new_log)

    # ========== 복약 기록 ==========

    async def get_medication_logs(self, user_id: int) -> MedicationLogListResponse:
        """복약 기록 이력 조회"""
        logs = await self.repo.get_medication_logs(user_id)
        return MedicationLogListResponse(
            logs=[MedicationLogResponse.model_validate(log) for log in logs],
            total=len(logs),
        )

    async def create_medication_log(self, user_id: int, data: MedicationLogCreateRequest) -> MedicationLogResponse:
        """복약 기록 생성"""
        new_log = await self.repo.create_medication_log(
            user_id=user_id,
            log_date=data.log_date,
            time_slot=data.time_slot,
            medication_name=data.medication_name,
            taken=data.taken,
        )
        return MedicationLogResponse.model_validate(new_log)
