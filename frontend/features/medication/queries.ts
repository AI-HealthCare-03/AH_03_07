// 약물 목록/등록 서버 상태 (TanStack Query)
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getUserMedications, createMedication, deleteMedication, type MedicationDetail, type MedicationCreate } from "./api";
import { getLocalMeds, addLocalMed, markLocalMedDeleted, getDeletedMeds } from "./local";
import { withTimeout } from "@/lib/query/util";

export const medicationKeys = { all: ["medications"] as const };

async function fetchMedications(): Promise<MedicationDetail[]> {
  try {
    const server = await withTimeout(getUserMedications());
    if (server.length > 0) return server;
  } catch {
    // 백엔드 미가동 시 로컬 폴백
  }
  const deletedIds = new Set(getDeletedMeds().map((d) => d.id));
  return (getLocalMeds() as MedicationDetail[]).filter((m) => !deletedIds.has(m.id));
}

export function useMedications() {
  return useQuery({ queryKey: medicationKeys.all, queryFn: fetchMedications, refetchOnMount: "always" });
}

export function useCreateMedication() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (data: MedicationCreate) => {
      try {
        await withTimeout(createMedication(data));
      } catch {
        // 백엔드 미가동 시 로컬에만 저장
        addLocalMed(data);
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: medicationKeys.all }),
  });
}

export function useDeleteMedication() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, name }: { id: number; name: string }) => {
      markLocalMedDeleted(id, name);
      try { await withTimeout(deleteMedication(id)); } catch { /* 백엔드 미가동 */ }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: medicationKeys.all }),
  });
}
