from tortoise import fields, models


class EmailVerifyCode(models.Model):
    """인증코드 DB 저장 — 멀티워커/재시작 환경에서 인메모리 _store 대체"""

    id = fields.BigIntField(primary_key=True)
    email = fields.CharField(max_length=255, unique=True)
    code = fields.CharField(max_length=6)
    expires_at = fields.FloatField()  # Unix timestamp (time.time() + TTL)

    class Meta:
        table = "email_verify_codes"
