"use client";

import { useRouter } from "next/navigation";
import Link from "next/link";
import { ChevronLeft, BookOpen, CheckCircle, Clock } from "lucide-react";
import { Card } from "@/components/ui/card";
import { useGuides } from "@/features/guides/queries";

function StatusBadge({ status }: { status?: string }) {
  const isComplete = status === "완료";
  return (
    <span
      className={`flex items-center gap-1 rounded-full px-2.5 py-0.5 text-[11px] font-semibold ${
        isComplete ? "bg-[#EDE9FF] text-[#7C5CCF]" : "bg-secondary text-muted-foreground"
      }`}
    >
      {isComplete ? <CheckCircle className="h-3 w-3" /> : <Clock className="h-3 w-3" />}
      {status ?? "처리 중"}
    </span>
  );
}

function toDisplayDate(dateStr?: string): string {
  if (!dateStr) return "";
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  return `${d.getFullYear()}.${String(d.getMonth() + 1).padStart(2, "0")}.${String(d.getDate()).padStart(2, "0")}`;
}

export default function GuidesPage() {
  const router = useRouter();
  const { data: guides = [], isLoading } = useGuides();

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-5 pb-8">
      <div className="flex items-center gap-2 mb-6">
        <button
          onClick={() => router.push("/home")}
          className="p-1 -ml-1 text-muted-foreground"
          aria-label="홈으로 이동"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="text-lg font-bold">진료 전 요약</h1>
      </div>

      {isLoading ? (
        <p className="mt-8 text-sm text-muted-foreground text-center">불러오는 중...</p>
      ) : guides.length === 0 ? (
        <div className="mt-16 flex flex-col items-center text-muted-foreground">
          <BookOpen className="h-12 w-12 opacity-30" />
          <p className="mt-3 text-sm">생성된 요약이 없습니다.</p>
          <p className="mt-1 text-xs">진료기록에서 안내문을 생성해보세요.</p>
        </div>
      ) : (
        <div className="space-y-3">
          {guides.map((g) => (
            <Link key={g.id} href={`/guides/${g.id}`}>
              <Card className="p-4 hover:bg-accent border-l-4 border-l-[#7C5CCF]">
                <div className="flex items-start justify-between gap-2">
                  <div className="flex-1 min-w-0">
                    <p className="font-semibold text-sm">진료 전 요약</p>
                    {g.symptom_summary && (
                      <p className="mt-1.5 line-clamp-2 text-sm text-muted-foreground leading-5">
                        {g.symptom_summary}
                      </p>
                    )}
                    {g.created_at && (
                      <p className="mt-2 text-xs text-muted-foreground">
                        {toDisplayDate(g.created_at)}
                      </p>
                    )}
                  </div>
                  <StatusBadge status={g.status} />
                </div>
              </Card>
            </Link>
          ))}
        </div>
      )}
    </main>
  );
}
