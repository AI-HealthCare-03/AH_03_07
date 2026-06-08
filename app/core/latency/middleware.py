from __future__ import annotations

import time

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

from app.core.latency.metrics import REQUEST_COUNT, REQUEST_LATENCY
from app.core.logger import default_logger as logger

# LLM/OCR 등 외부 API를 호출하는 경로 — Histogram 측정 제외
_EXTERNAL_PREFIXES: tuple[str, ...] = (
    "/api/v1/chat",
    "/api/v1/knowledge",
    "/api/v1/pill",
)

# P95 임계값 (초)
_SLOW_THRESHOLD = 3.0


class LatencyMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        path = request.url.path
        method = request.method

        if path.startswith(_EXTERNAL_PREFIXES):
            return await call_next(request)

        start = time.perf_counter()
        response = await call_next(request)
        elapsed = time.perf_counter() - start

        status = str(response.status_code)
        REQUEST_LATENCY.labels(method=method, path=path, status_code=status).observe(elapsed)
        REQUEST_COUNT.labels(method=method, path=path, status_code=status).inc()

        if elapsed > _SLOW_THRESHOLD:
            logger.warning("SLOW API | %s %s → %.3fs (P95 임계 초과)", method, path, elapsed)

        return response
