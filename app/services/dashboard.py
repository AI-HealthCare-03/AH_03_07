from uuid import UUID

from app.dtos.dashboard import DashboardResponse
from app.services.medications import MedicationService


class DashboardService:
    async def get_dashboard(self, user_id: UUID) -> DashboardResponse:
        medications = await MedicationService().get_my_medications(user_id=user_id)
        return DashboardResponse(
            today_medications=medications.medications,
            recent_activity=[],
            pending_schedules=[],
            active_risk_flags=[],
        )
