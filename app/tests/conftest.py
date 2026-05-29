import asyncio
from collections.abc import Generator

import pytest
import pytest_asyncio
from _pytest.fixtures import FixtureRequest
from tortoise.contrib.test import finalizer, initializer

from app.core import config
from app.core.db.databases import TORTOISE_APP_MODELS

TEST_BASE_URL = "http://test"
TEST_DB_LABEL = "models"
TEST_DB_TZ = "Asia/Seoul"


@pytest.fixture(scope="session", autouse=True)
def initialize(request: FixtureRequest) -> Generator[None, None]:
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    db_available = True
    _app_models = [m for m in TORTOISE_APP_MODELS if m != "aerich.models"]
    try:
        initializer(
            modules=_app_models,
            db_url=f"mysql://{config.DB_USER}:{config.DB_PASSWORD}@{config.DB_HOST}:{config.DB_PORT}/test",
            app_label=TEST_DB_LABEL,
        )
    except Exception:
        try:
            initializer(modules=_app_models, db_url="sqlite://:memory:")
        except Exception:
            db_available = False
    yield
    if db_available:
        finalizer()
    loop.close()


@pytest_asyncio.fixture(autouse=True, scope="session")  # type: ignore[type-var]
def event_loop() -> None:
    pass
