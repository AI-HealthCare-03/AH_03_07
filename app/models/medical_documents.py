import uuid
from enum import StrEnum
from tortoise import fields, models

class DocumentType(StrEnum):
    PRESCRIPTION = "PRESCRIPTION"
    LAB_RESULT = "LAB_RESULT"
    MEDICAL_RECORD = "MEDICAL_RECORD"

class UploadStatus(StrEnum):
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"

class MedicalDocument(models.Model):
    id = fields.UUIDField(primary_key=True, default=uuid.uuid4)
    user = fields.ForeignKeyField("models.User", related_name="medical_documents", on_delete=fields.CASCADE)
    document_type = fields.CharEnumField(enum_type=DocumentType, max_length=50)
    file_s3_url = fields.TextField()
    original_filename = fields.CharField(max_length=255)
    mime_type = fields.CharField(max_length=100, null=True)
    upload_status = fields.CharEnumField(enum_type=UploadStatus, max_length=30, default=UploadStatus.PENDING)
    uploaded_at = fields.DatetimeField(auto_now_add=True)
    deleted_at = fields.DatetimeField(null=True)

    class Meta:
        table = "medical_documents"
