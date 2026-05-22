import uuid
from enum import StrEnum
from tortoise import fields, models

class RecognitionStatus(StrEnum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
    LOW_CONFIDENCE = "LOW_CONFIDENCE"

class PillRecognition(models.Model):
    id = fields.UUIDField(primary_key=True, default=uuid.uuid4)
    user = fields.ForeignKeyField("models.User", related_name="pill_recognitions", on_delete=fields.CASCADE)
    image_url = fields.CharField(max_length=500)
    status = fields.CharEnumField(enum_type=RecognitionStatus, max_length=30, default=RecognitionStatus.PENDING)

    # Top 3 후보!
    top1_drug_name = fields.CharField(max_length=200, null=True)
    top1_confidence = fields.FloatField(null=True)
    top2_drug_name = fields.CharField(max_length=200, null=True)
    top2_confidence = fields.FloatField(null=True)
    top3_drug_name = fields.CharField(max_length=200, null=True)
    top3_confidence = fields.FloatField(null=True)

    # 사용자 선택!
    selected_drug_name = fields.CharField(max_length=200, null=True)

    error_message = fields.TextField(null=True)
    created_at = fields.DatetimeField(auto_now_add=True)

    class Meta:
        table = "pill_recognitions"