import { apiFetch } from "@/lib/api/client";

export type MetricType = "bp" | "glucose" | "weight";

export interface HealthMetric {
  id?: number;
  metric_type: MetricType;
  value: string;
  measured_at: string;
  status?: string;
}

export interface HealthMetricCreate {
  metric_type: MetricType;
  value: string;
  measured_at?: string;
}

export async function getHealthMetrics(): Promise<HealthMetric[]> {
  const res = await apiFetch<{ items?: HealthMetric[] } | HealthMetric[]>("/v1/health-metrics");
  return Array.isArray(res) ? res : (res.items ?? []);
}

export async function createHealthMetric(data: HealthMetricCreate): Promise<void> {
  await apiFetch("/v1/health-metrics", { method: "POST", body: data });
}
