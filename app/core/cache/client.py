from __future__ import annotations

import json

from redis.asyncio import Redis

from app.core import config as app_config

_cache_client: Redis | None = None

# TTL 상수 (초)
TTL_DRUG_SEARCH = 3600  # 1시간
TTL_USER_PROFILE = 600  # 10분
TTL_GUIDE_DETAIL = 1800  # 30분


def get_cache() -> Redis:
    global _cache_client
    if _cache_client is None:
        _cache_client = Redis.from_url(app_config.REDIS_URL, decode_responses=True)
    return _cache_client


async def cache_get_json(key: str) -> dict | None:
    redis = get_cache()
    raw = await redis.get(key)
    if raw is None:
        return None
    return json.loads(raw)


async def cache_set_json(key: str, value: dict, ttl: int) -> None:
    redis = get_cache()
    await redis.setex(key, ttl, json.dumps(value))


async def cache_delete(key: str) -> None:
    redis = get_cache()
    await redis.delete(key)
