import uuid
from enum import StrEnum
from tortoise import fields, models

class TimeSlot(StrEnum):
    MORNING = "MORNING"
    LUNCH = "LUNCH"
    DINNER = "DINNER"
    BEDTIME = "BEDTIME"

class DiaryMedicationLog(models.Model):
    id = fields.UUIDField(primary_key=True, default=uuid.uuid4)
    user = fields.ForeignKeyField("models.User", related_name="medication_logs", on_delete=fields.CASCADE)
    log_date = fields.DateField()
    drug_name = fields.CharField(max_length=200)
    time_slot = fields.CharEnumField(enum_type=TimeSlot, max_length=20, null=True)
    taken = fields.BooleanField(default=True)
    taken_time = fields.DatetimeField(null=True)
    notes = fields.TextField(null=True)
    # NOTI-008: 위치 태깅 (옵셔널, 100m 정확도)
    latitude = fields.DecimalField(max_digits=10, decimal_places=4, null=True)
    longitude = fields.DecimalField(max_digits=10, decimal_places=4, null=True)
    location_recorded_at = fields.DatetimeField(null=True)

    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)

    class Meta:
        table = "diary_medication_logs"
