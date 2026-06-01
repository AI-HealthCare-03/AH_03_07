from __future__ import annotations

from datetime import UTC, datetime
from unittest.mock import AsyncMock, patch

from httpx import ASGITransport, AsyncClient
from tortoise.contrib.test import TestCase

from app.auto_guide.schema import OrchestratorResult, OrchestratorStatus
from app.guide_generator.schema import GuideStatus, HealthGuideOutput, SourceItem
from app.main import app
from app.models.auto_guide import AutoGuide
from app.models.users import User

BASE_URL = "http://test"
GENERATE_EP = "/api/v1/guides/generate"

_FAKE_SOURCE = SourceItem(
    title="류마티스관절염 진료지침",
    section="약물 치료",
    page=42,
    organization="대한류마티스학회",
    published_year=2023,
    score=0.91,
)


async def _signup_and_login(client: AsyncClient, email: str, phone: str) -> str:
    await client.post(
        "/api/v1/auth/signup",
        json={
            "email": email,
            "password": "Password123!",
            "name": "가이드테스터",
            "gender": "FEMALE",
            "birth_date": "1990-01-01",
            "phone_number": phone,
        },
    )
    resp = await client.post(
        "/api/v1/auth/login",
        json={"email": email, "password": "Password123!"},
    )
    return resp.json()["access_token"]


def _make_guide_output(user_id: int, status: GuideStatus = GuideStatus.GENERATED) -> HealthGuideOutput:
    return HealthGuideOutput(
        user_id=user_id,
        status=status,
        medication_general="약물 복용 시 의료진 지시를 따르세요.",
        side_effect_monitoring=["두통", "구역"],
        lifestyle_info="규칙적인 생활을 유지하세요.",
        symptom_summary="증상 변화를 다음 진료 시 공유하세요.",
        sources=[_FAKE_SOURCE],
        disclaimer="※ 이 안내문은 의료 진단·처방·치료를 대체하지 않습니다.",
        created_at=datetime.now(UTC),
    )


def _make_result(user_id: int, status: OrchestratorStatus) -> OrchestratorResult:
    guide = None
    if status in (OrchestratorStatus.GENERATED, OrchestratorStatus.BLOCKED_HIGH_RISK):
        guide_status = (
            GuideStatus.GENERATED if status == OrchestratorStatus.GENERATED else GuideStatus.BLOCKED_HIGH_RISK
        )
        guide = _make_guide_output(user_id, guide_status)
    return OrchestratorResult(
        user_id=user_id,
        orchestrator_status=status,
        guide=guide,
        evaluated_at=datetime.now(UTC),
    )


class TestAutoGuidePersistence(TestCase):
    async def test_generated_saves_one_record_and_returns_guide_id(self):
        """GENERATED → auto_guides 1건 저장, 응답 guide_id == 저장된 id."""
        async with AsyncClient(transport=ASGITransport(app=app), base_url=BASE_URL) as client:
            token = await _signup_and_login(client, "persist_gen@example.com", "01095000001")
            user = await User.get(email="persist_gen@example.com")
            mock_result = _make_result(user.id, OrchestratorStatus.GENERATED)

            with patch("app.apis.v1.auto_guide_router.orchestrate", AsyncMock(return_value=mock_result)):
                resp = await client.post(GENERATE_EP, headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200
        data = resp.json()
        assert data["guide_id"] is not None

        saved = await AutoGuide.filter(user_id=user.id).all()
        assert len(saved) == 1
        assert saved[0].id == data["guide_id"]

    async def test_trigger_not_met_saves_nothing_and_guide_id_is_none(self):
        """TRIGGER_NOT_MET → 저장 0건, guide_id None."""
        async with AsyncClient(transport=ASGITransport(app=app), base_url=BASE_URL) as client:
            token = await _signup_and_login(client, "persist_notmet@example.com", "01095000002")
            user = await User.get(email="persist_notmet@example.com")
            mock_result = _make_result(user.id, OrchestratorStatus.TRIGGER_NOT_MET)

            with patch("app.apis.v1.auto_guide_router.orchestrate", AsyncMock(return_value=mock_result)):
                resp = await client.post(GENERATE_EP, headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200
        assert resp.json()["guide_id"] is None
        assert await AutoGuide.filter(user_id=user.id).count() == 0

    async def test_blocked_high_risk_saves_nothing_and_guide_id_is_none(self):
        """BLOCKED_HIGH_RISK → 저장 0건, guide_id None."""
        async with AsyncClient(transport=ASGITransport(app=app), base_url=BASE_URL) as client:
            token = await _signup_and_login(client, "persist_blocked@example.com", "01095000003")
            user = await User.get(email="persist_blocked@example.com")
            mock_result = _make_result(user.id, OrchestratorStatus.BLOCKED_HIGH_RISK)

            with patch("app.apis.v1.auto_guide_router.orchestrate", AsyncMock(return_value=mock_result)):
                resp = await client.post(GENERATE_EP, headers={"Authorization": f"Bearer {token}"})

        assert resp.status_code == 200
        assert resp.json()["guide_id"] is None
        assert await AutoGuide.filter(user_id=user.id).count() == 0

    async def test_saved_sources_are_deserializable_as_source_items(self):
        """저장된 sources(JSON)를 SourceItem으로 역직렬화 가능."""
        async with AsyncClient(transport=ASGITransport(app=app), base_url=BASE_URL) as client:
            token = await _signup_and_login(client, "persist_sources@example.com", "01095000004")
            user = await User.get(email="persist_sources@example.com")
            mock_result = _make_result(user.id, OrchestratorStatus.GENERATED)

            with patch("app.apis.v1.auto_guide_router.orchestrate", AsyncMock(return_value=mock_result)):
                await client.post(GENERATE_EP, headers={"Authorization": f"Bearer {token}"})

        saved = await AutoGuide.filter(user_id=user.id).first()
        assert saved is not None

        deserialized = [SourceItem(**s) for s in saved.sources]
        assert len(deserialized) == 1
        assert deserialized[0].title == _FAKE_SOURCE.title
        assert deserialized[0].organization == _FAKE_SOURCE.organization
        assert deserialized[0].published_year == _FAKE_SOURCE.published_year
