from __future__ import annotations

from enum import StrEnum

from tortoise import fields, models


class DiseaseCode(StrEnum):
    # 자가면역
    RA = "RA"
    SLE = "SLE"
    # 대사/순환
    DM1 = "DM1"
    DM2 = "DM2"
    HTN = "HTN"
    HYPERLIPIDEMIA = "HYPERLIPIDEMIA"
    # 호흡기
    ASTHMA = "ASTHMA"
    COPD = "COPD"
    # 신경계
    PARKINSON = "PARKINSON"
    MS = "MS"
    # 암
    BREAST_CANCER = "BREAST_CANCER"
    COLON_CANCER = "COLON_CANCER"
    LUNG_CANCER = "LUNG_CANCER"


class UserDisease(models.Model):
    """REQ-DISE-001/002 — 자가면역 모드 사용자의 등록 질환."""

    id = fields.BigIntField(primary_key=True)
    user = fields.ForeignKeyField("models.User", related_name="diseases", on_delete=fields.CASCADE)
    disease_code = fields.CharEnumField(enum_type=DiseaseCode, max_length=20)
    diagnosed_date = fields.DateField(null=True)
    note = fields.TextField(null=True)
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)
    deleted_at = fields.DatetimeField(null=True)

    class Meta:
        table = "user_diseases"
