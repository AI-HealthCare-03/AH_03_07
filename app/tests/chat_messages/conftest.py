from __future__ import annotations
from unittest.mock import AsyncMock, MagicMock, patch
import pytest


@pytest.fixture(autouse=True)
def mock_openai_moderation():
    mock_result = MagicMock()
    mock_result.status = "SAFE"
    mock_result.category = None
    mock_result.matched_keywords = []
    with patch(
        "app.services.chat_guardrail_enhanced.apply_enhanced_guardrail",
        new_callable=AsyncMock,
        return_value=mock_result,
    ):
        yield
