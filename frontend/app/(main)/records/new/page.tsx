"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { createRecord } from "@/features/medical-records/api";
import { ApiError } from "@/lib/api/client";

export default function NewRecordPage() {
  const router = useRouter();
  const [hospital, setHospital] = useState("");
  const [department, setDepartment] = useState("");
  const [visitDate, setVisitDate] = useState("");
  const [diagnosis, setDiagnosis] = useState("");
  const [memo, setMemo] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      await createRecord({
        hospital_name: hospital,
        department,
        visit_date: visitDate,
        diagnosis,
        memo,
      });
      router.replace("/records");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "저장에 실패했습니다.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 py-8">
      <h1 className="text-2xl font-bold">진료기록 입력</h1>

      <form onSubmit={handleSubmit} className="mt-6 space-y-4">
        <div className="space-y-2">
          <Label htmlFor="hospital">병원명 *</Label>
          <Input id="hospital" required value={hospital} onChange={(e) => setHospital(e.target.value)} />
        </div>
        <div className="space-y-2">
          <Label htmlFor="dept">진료과</Label>
          <Input id="dept" value={department} onChange={(e) => setDepartment(e.target.value)} placeholder="예: 류마티스내과" />
        </div>
        <div className="space-y-2">
          <Label htmlFor="date">방문일 *</Label>
          <Input id="date" type="date" required value={visitDate} onChange={(e) => setVisitDate(e.target.value)} />
        </div>
        <div className="space-y-2">
          <Label htmlFor="diag">진단</Label>
          <Input id="diag" value={diagnosis} onChange={(e) => setDiagnosis(e.target.value)} />
        </div>
        <div className="space-y-2">
          <Label htmlFor="memo">메모</Label>
          <textarea
            id="memo"
            value={memo}
            onChange={(e) => setMemo(e.target.value)}
            rows={3}
            className="flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
          />
        </div>

        {error && <p className="text-sm text-destructive">{error}</p>}

        <div className="flex gap-2 pt-2">
          <Button type="button" variant="outline" className="flex-1" onClick={() => router.back()}>
            취소
          </Button>
          <Button type="submit" className="flex-1" disabled={loading}>
            {loading ? "저장 중..." : "저장"}
          </Button>
        </div>
      </form>
    </main>
  );
}
