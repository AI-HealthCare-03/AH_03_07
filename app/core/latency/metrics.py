from prometheus_client import Counter, Histogram

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP 요청 처리 시간 (초)",
    ["method", "path", "status_code"],
    buckets=[0.1, 0.25, 0.5, 1.0, 2.0, 3.0, 5.0, 10.0],
)

REQUEST_COUNT = Counter(
    "http_requests_total",
    "HTTP 요청 총 횟수",
    ["method", "path", "status_code"],
)
