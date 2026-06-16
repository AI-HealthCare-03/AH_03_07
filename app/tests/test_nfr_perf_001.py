"""NFR-PERF-001 — LatencyMiddleware + /metrics 엔드포인트 단위 테스트."""

from __future__ import annotations

from unittest.mock import MagicMock, patch

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient
from starlette.requests import Request
from starlette.responses import JSONResponse, Response

from app.core.latency.middleware import _EXTERNAL_PREFIXES, _SLOW_THRESHOLD, LatencyMiddleware


def _make_request(path: str, method: str = "GET") -> Request:
    """테스트용 Request 객체를 생성한다."""
    scope = {
        "type": "http",
        "method": method,
        "path": path,
        "query_string": b"",
        "headers": [],
    }
    return Request(scope)


async def _simple_call_next(_request: Request) -> JSONResponse:
    return JSONResponse({"ok": True})


# ── 정상 경로 측정 ─────────────────────────────────────────────


@pytest.mark.asyncio
async def test_normal_path_records_metrics() -> None:
    """일반 경로는 Histogram·Counter의 observe/inc가 호출된다."""
    middleware = LatencyMiddleware(app=MagicMock())
    request = _make_request("/api/v1/users")

    with (
        patch("app.core.latency.middleware.REQUEST_COUNT") as mock_count,
        patch("app.core.latency.middleware.REQUEST_LATENCY") as mock_hist,
    ):
        response = await middleware.dispatch(request, _simple_call_next)

    assert response.status_code == 200
    mock_hist.labels.assert_called_once_with(method="GET", path="/api/v1/users", status_code="200")
    mock_hist.labels().observe.assert_called_once()
    mock_count.labels.assert_called_once_with(method="GET", path="/api/v1/users", status_code="200")
    mock_count.labels().inc.assert_called_once()


# ── 외부 API 경로 제외 ─────────────────────────────────────────


@pytest.mark.asyncio
@pytest.mark.parametrize("excluded_prefix", list(_EXTERNAL_PREFIXES))
async def test_external_prefix_skips_metrics(excluded_prefix: str) -> None:
    """외부 API 경로(chat/knowledge/pill)는 observe/inc가 호출되지 않는다."""
    middleware = LatencyMiddleware(app=MagicMock())
    request = _make_request(f"{excluded_prefix}/some-endpoint")

    with (
        patch("app.core.latency.middleware.REQUEST_COUNT") as mock_count,
        patch("app.core.latency.middleware.REQUEST_LATENCY") as mock_hist,
    ):
        await middleware.dispatch(request, _simple_call_next)

    mock_hist.labels.assert_not_called()
    mock_count.labels.assert_not_called()


# ── 느린 응답 경고 로그 ────────────────────────────────────────


@pytest.mark.asyncio
async def test_slow_response_emits_warning() -> None:
    """응답 시간이 _SLOW_THRESHOLD 초과 시 경고 로그가 출력된다."""
    middleware = LatencyMiddleware(app=MagicMock())
    request = _make_request("/api/v1/slow")

    with (
        patch("app.core.latency.middleware.time.perf_counter", side_effect=[0.0, _SLOW_THRESHOLD + 0.1]),
        patch("app.core.latency.middleware.logger") as mock_logger,
        patch("app.core.latency.middleware.REQUEST_COUNT"),
        patch("app.core.latency.middleware.REQUEST_LATENCY"),
    ):
        await middleware.dispatch(request, _simple_call_next)

    mock_logger.warning.assert_called_once()
    assert "SLOW API" in mock_logger.warning.call_args[0][0]


@pytest.mark.asyncio
async def test_fast_response_no_warning() -> None:
    """응답 시간이 _SLOW_THRESHOLD 이내이면 경고 로그가 없다."""
    middleware = LatencyMiddleware(app=MagicMock())
    request = _make_request("/api/v1/fast")

    with (
        patch("app.core.latency.middleware.time.perf_counter", side_effect=[0.0, _SLOW_THRESHOLD - 0.1]),
        patch("app.core.latency.middleware.logger") as mock_logger,
        patch("app.core.latency.middleware.REQUEST_COUNT"),
        patch("app.core.latency.middleware.REQUEST_LATENCY"),
    ):
        await middleware.dispatch(request, _simple_call_next)

    mock_logger.warning.assert_not_called()


# ── /metrics 엔드포인트 ────────────────────────────────────────


def test_metrics_endpoint_returns_prometheus_format() -> None:
    """/metrics 가 200 응답과 text/plain 본문을 반환한다."""
    from prometheus_client import CONTENT_TYPE_LATEST, generate_latest

    mini = FastAPI()

    @mini.get("/metrics", include_in_schema=False)
    def metrics_handler() -> Response:
        return Response(content=generate_latest(), media_type=CONTENT_TYPE_LATEST)

    client = TestClient(mini)
    response = client.get("/metrics")

    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]
    assert b"# HELP" in response.content
