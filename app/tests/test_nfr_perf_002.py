"""NFR-PERF-002 — Celery 큐 분리 정책 단위 테스트."""

from kombu import Queue

# ── queue_config ──────────────────────────────────────────────


def test_queue_names_contains_all_five() -> None:
    from ai_worker.core.queue_config import QUEUE_NAMES

    assert set(QUEUE_NAMES) == {
        "ocr_queue",
        "llm_queue",
        "ml_queue",
        "notification_queue",
        "content_queue",
    }


def test_task_queues_count() -> None:
    from ai_worker.core.queue_config import TASK_QUEUES

    assert len(TASK_QUEUES) == 5


def test_task_queues_are_kombu_queue_instances() -> None:
    from ai_worker.core.queue_config import TASK_QUEUES

    for q in TASK_QUEUES:
        assert isinstance(q, Queue)


def test_task_queues_names_match_queue_names() -> None:
    from ai_worker.core.queue_config import QUEUE_NAMES, TASK_QUEUES

    assert {q.name for q in TASK_QUEUES} == set(QUEUE_NAMES)


def test_task_routes_covers_all_five_queues() -> None:
    from ai_worker.core.queue_config import QUEUE_NAMES, TASK_ROUTES

    routed_queues = {v["queue"] for v in TASK_ROUTES.values()}
    assert routed_queues == set(QUEUE_NAMES)


def test_task_routes_embedding_to_ml_queue() -> None:
    from ai_worker.core.queue_config import TASK_ROUTES

    assert TASK_ROUTES.get("ai_worker.tasks.embedding.*") == {"queue": "ml_queue"}