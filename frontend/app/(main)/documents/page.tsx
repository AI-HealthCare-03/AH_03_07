"use client";

import { useEffect, useState } from "react";
import { FolderOpen } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getDocuments } from "@/features/documents/api";
import type { MedicalDocument } from "@/features/documents/api";

const typeLabel: Record<string, string> = {
  prescription: "처방전",
  medical_record: "진료기록",
  pill_bag: "약봉투",
  lab_result: "검사결과지",
  health_checkup: "건강검진",
  other: "기타",
};

export default function DocumentsPage() {
  const [docs, setDocs] = useState<MedicalDocument[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getDocuments()
      .then(setDocs)
      .catch(() => setError("문서를 불러오지 못했습니다."))
      .finally(() => setLoading(false));
  }, []);

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-10">
      <h1 className="text-2xl font-bold">문서 보관함</h1>

      {loading ? (
        <p className="mt-8 text-sm text-muted-foreground">불러오는 중...</p>
      ) : error ? (
        <p className="mt-8 text-sm text-destructive">{error}</p>
      ) : docs.length === 0 ? (
        <div className="mt-16 flex flex-col items-center text-muted-foreground">
          <FolderOpen className="h-12 w-12 opacity-30" />
          <p className="mt-3 text-sm">보관된 문서가 없습니다.</p>
        </div>
      ) : (
        <div className="mt-6 space-y-3">
          {docs.map((d) => (
            <Card key={d.id} className="flex items-center justify-between p-4">
              <div>
                <p className="font-semibold">
                  {typeLabel[d.document_type ?? "other"] ?? "기타"}
                </p>
                {d.created_at && (
                  <p className="text-xs text-muted-foreground">
                    {d.created_at.slice(0, 10)}
                  </p>
                )}
              </div>
              {d.status && (
                <span className="rounded bg-secondary px-2 py-0.5 text-[11px] text-secondary-foreground">
                  {d.status}
                </span>
              )}
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
