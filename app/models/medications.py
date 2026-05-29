import uuid

from tortoise import fields, models


class Medication(models.Model):
    id = fields.UUIDField(primary_key=True, default=uuid.uuid4)
    user = fields.ForeignKeyField("models.User", related_name="medications", on_delete=fields.CASCADE)
    prescription = fields.ForeignKeyField(
        "models.Prescription", related_name="medications", null=True, on_delete=fields.SET_NULL
    )
    drug_name_user_input = fields.CharField(max_length=200)
    dosage = fields.CharField(max_length=50, null=True)
    frequency = fields.CharField(max_length=50, null=True)
    duration_days = fields.IntField(null=True)
    start_date = fields.DateField(null=True)
    end_date = fields.DateField(null=True)
    is_autoimmune_drug = fields.BooleanField(default=False)
    drug_category = fields.CharField(max_length=50, null=True)
    notes = fields.TextField(null=True)
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)

    class Meta:
        table = "medications"
