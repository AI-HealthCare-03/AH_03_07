import { apiFetch } from "@/lib/api/client";

// GET /v1/lab-references — 검사 항목 일반 참고 정보 (자동 판정 X, REQ-LAB-001)
export interface LabReferenceResponse {
  code: string;
  name_ko: string;
  abbr: string | null;
  category: string | null;
  description: string | null;
  unit: string | null;
  reference_range_general: string | null;
  reference_note: string | null;
  source: string | null;
}

export async function listLabReferences(
  query?: string,
  category?: string,
): Promise<LabReferenceResponse[]> {
  const p = new URLSearchParams();
  if (query) p.set("query", query);
  if (category) p.set("category", category);
  const qs = p.toString();
  return apiFetch<LabReferenceResponse[]>(`/v1/lab-references${qs ? `?${qs}` : ""}`);
}

export interface LabResultResponse {
  id: number;
  test_date: string; // "YYYY-MM-DD"
  test_type: string;
  user_recorded_value: string;
  reference_range: string | null;
  note: string | null;
  created_at: string;
  updated_at: string;
}

export interface LabResultCreateRequest {
  test_date: string; // "YYYY-MM-DD"
  test_type: string; // max 128
  user_recorded_value: string; // max 64
  reference_range?: string | null;
  note?: string | null;
}

export type LabResultUpdateRequest = Partial<LabResultCreateRequest>;

export async function listLabResults(
  from?: string,
  to?: string
): Promise<LabResultResponse[]> {
  const p = new URLSearchParams();
  if (from) p.set("from", from);
  if (to) p.set("to", to);
  const qs = p.toString();
  return apiFetch<LabResultResponse[]>(`/v1/lab-results${qs ? `?${qs}` : ""}`);
}

export async function createLabResult(
  body: LabResultCreateRequest
): Promise<LabResultResponse> {
  return apiFetch<LabResultResponse>("/v1/lab-results", {
    method: "POST",
    body,
  });
}

export async function updateLabResult(
  id: number,
  body: LabResultUpdateRequest
): Promise<LabResultResponse> {
  return apiFetch<LabResultResponse>(`/v1/lab-results/${id}`, {
    method: "PATCH",
    body,
  });
}

export async function deleteLabResult(id: number): Promise<void> {
  return apiFetch<void>(`/v1/lab-results/${id}`, { method: "DELETE" });
}
