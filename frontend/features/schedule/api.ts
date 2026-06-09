import { apiFetch } from "@/lib/api/client";

export interface CareSchedule {
  id: number;
  title: string;
  scheduled_at: string;
  type: "exam" | "injection" | "visit" | string;
  location?: string;
  detail?: string;
  repeat_type?: string;
  reminder_enabled?: boolean;
}

export interface CreateScheduleData {
  title: string;
  scheduled_at: string;
  type: string;
  location?: string;
  detail?: string;
  repeat_type?: string;
  reminder_enabled?: boolean;
}

export async function getSchedules(): Promise<CareSchedule[]> {
  const res = await apiFetch<{ items?: CareSchedule[] } | CareSchedule[]>("/v1/care-schedules");
  return Array.isArray(res) ? res : (res.items ?? []);
}

export async function createSchedule(data: CreateScheduleData): Promise<CareSchedule> {
  return apiFetch<CareSchedule>("/v1/care-schedules", {
    method: "POST",
    body: data,
  });
}

export async function updateSchedule(id: number, data: Partial<CreateScheduleData>): Promise<CareSchedule> {
  return apiFetch<CareSchedule>(`/v1/care-schedules/${id}`, {
    method: "PUT",
    body: data,
  });
}

export async function deleteSchedule(id: number): Promise<void> {
  await apiFetch<void>(`/v1/care-schedules/${id}`, { method: "DELETE" });
}
