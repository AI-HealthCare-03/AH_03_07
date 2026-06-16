from tortoise import fields, models


class LabReference(models.Model):
    id = fields.BigIntField(primary_key=True)
    code = fields.CharField(max_length=64, unique=True)
    name_ko = fields.CharField(max_length=128)
    abbr = fields.CharField(max_length=64, null=True)
    category = fields.CharField(max_length=64, null=True)
    description = fields.CharField(max_length=255, null=True)
    unit = fields.CharField(max_length=32, null=True)
    reference_range_general = fields.CharField(max_length=255, null=True)
    reference_note = fields.CharField(max_length=255, null=True)
    source = fields.CharField(max_length=255, null=True)
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)

    class Meta:
        table = "lab_references"
