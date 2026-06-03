"use client";

import { useEffect, useState } from "react";
import { Pill } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getMedications } from "@/features/medication/api";
import type { Medication } from "@/features/medication/api";

export default function MedicationPage() {
  const [meds, setMeds] = useState<Medication[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getMedications()
      .then(setMeds)
      .catch(() => setError("약물 목록을 불러오지 못했습니다."))
      .finally(() => setLoading(false));
  }, []);

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-10">
      <h1 className="text-2xl font-bold">내 약물 목록</h1>
      <p className="mt-1 text-sm text-muted-foreground">복용 중인 약 {meds.length}개</p>

      {loading ? (
        <p className="mt-8 text-sm text-muted-foreground">불러오는 중...</p>
      ) : error ? (
        <p className="mt-8 text-sm text-destructive">{error}</p>
      ) : meds.length === 0 ? (
        <div className="mt-16 flex flex-col items-center text-muted-foreground">
          <Pill className="h-12 w-12 opacity-30" />
          <p className="mt-3 text-sm">등록된 약물이 없습니다.</p>
        </div>
      ) : (
        <div className="mt-6 space-y-3">
          {meds.map((m) => (
            <Card key={m.id} className="flex items-center gap-3 p-4">
              <Pill className="h-7 w-7 text-primary" />
              <div className="flex-1">
                <p className="font-semibold">{m.name}</p>
                {m.frequency && (
                  <p className="text-xs text-muted-foreground">{m.frequency}</p>
                )}
                {m.next_dose && (
                  <p className="text-xs text-muted-foreground">다음 복용: {m.next_dose}</p>
                )}
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
