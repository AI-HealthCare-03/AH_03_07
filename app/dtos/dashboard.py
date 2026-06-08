from pydantic import BaseModel

from app.dtos.medications import MedicationResponse


class DashboardResponse(BaseModel):
    today_medications: list[MedicationResponse]
    recent_activity: list[dict] = []
    pending_schedules: list[dict] = []
    active_risk_flags: list[dict] = []
