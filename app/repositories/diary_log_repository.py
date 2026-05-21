from uuid import UUID
from datetime import date
from app.models.diary_medication_logs import DiaryMedicationLog, TimeSlot
from app.models.diary_symptom_logs import DiarySymptomLog, OverallCondition

class DiaryLogRepository:
    """일기 (증상 + 복약) DB 쿼리 담당"""

    # ========== 증상 기록 ==========

    @staticmethod
    async def get_symptom_logs(user_id: UUID) -> list[DiarySymptomLog]:
        """사용자의 증상 기록 전체 조회"""
        return await DiarySymptomLog.filter(user_id=user_id).order_by("-log_date").all()

    @staticmethod
    async def get_symptom_log_by_date(user_id: UUID, log_date: date) -> DiarySymptomLog | None:
        """특정 날짜 증상 기록 조회"""
        return await DiarySymptomLog.filter(user_id=user_id, log_date=log_date).first()

    @staticmethod
    async def create_symptom_log(
        user_id: UUID,
        log_date: date,
        overall_condition: OverallCondition,
        body_parts: list[str] | None,
        feeling: dict | None,
        memo: str | None,
    ) -> DiarySymptomLog:
        """증상 기록 생성"""
        return await DiarySymptomLog.create(
            user_id=user_id,
            log_date=log_date,
            overall_condition=overall_condition,
            body_parts=body_parts,
            feeling=feeling,
            memo=memo,
        )

    # ========== 복약 기록 ==========

    @staticmethod
    async def get_medication_logs(user_id: UUID) -> list[DiaryMedicationLog]:
        """사용자의 복약 기록 전체 조회"""
        return await DiaryMedicationLog.filter(user_id=user_id).order_by("-log_date").all()

    @staticmethod
    async def get_medication_logs_by_date(user_id: UUID, log_date: date) -> list[DiaryMedicationLog]:
        """특정 날짜 복약 기록 목록"""
        return await DiaryMedicationLog.filter(user_id=user_id, log_date=log_date).all()

    @staticmethod
    async def create_medication_log(
        user_id: UUID,
        log_date: date,
        time_slot: TimeSlot,
        medication_name: str,
        taken: bool,
    ) -> DiaryMedicationLog:
        """복약 기록 생성"""
        return await DiaryMedicationLog.create(
            user_id=user_id,
            log_date=log_date,
            time_slot=time_slot,
            medication_name=medication_name,
            taken=taken,
        )
