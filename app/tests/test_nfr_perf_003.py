"""NFR-PERF-003 — Redis 캐시 단위 테스트."""

from __future__ import annotations

import json
from unittest.mock import AsyncMock, patch

import pytest

# ── cache client 헬퍼 ─────────────────────────────────────────


@pytest.mark.asyncio
async def test_cache_set_and_get_json() -> None:
    """set 후 get이 동일한 딕셔너리를 반환한다."""
    mock_redis = AsyncMock()
    mock_redis.get = AsyncMock(return_value=json.dumps({"foo": "bar"}))
    mock_redis.setex = AsyncMock()

    with patch("app.core.cache.client.get_cache", return_value=mock_redis):
        from app.core.cache.client import cache_get_json, cache_set_json

        await cache_set_json("test:key", {"foo": "bar"}, ttl=60)
        result = await cache_get_json("test:key")

    assert result == {"foo": "bar"}
    mock_redis.setex.assert_awaited_once_with("test:key", 60, json.dumps({"foo": "bar"}))


@pytest.mark.asyncio
async def test_cache_get_json_miss_returns_none() -> None:
    """캐시 미스(None) 시 None을 반환한다."""
    mock_redis = AsyncMock()
    mock_redis.get = AsyncMock(return_value=None)

    with patch("app.core.cache.client.get_cache", return_value=mock_redis):
        from app.core.cache.client import cache_get_json

        result = await cache_get_json("test:missing")

    assert result is None


@pytest.mark.asyncio
async def test_cache_delete_calls_redis_delete() -> None:
    """cache_delete가 Redis delete를 호출한다."""
    mock_redis = AsyncMock()
    mock_redis.delete = AsyncMock()

    with patch("app.core.cache.client.get_cache", return_value=mock_redis):
        from app.core.cache.client import cache_delete

        await cache_delete("test:key")

    mock_redis.delete.assert_awaited_once_with("test:key")
