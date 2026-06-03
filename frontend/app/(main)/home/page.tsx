"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowRight, Check, Circle } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getDashboard } from "@/features/dashboard/api";
import { getMe } from "@/features/auth/api";
import type { DashboardData } from "@/features/dashboard/api";

export default function HomePage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [name, setName] = useState<string>("");

  useEffect(() => {
    getMe()
      .then((u) => setName(u.name))
      .catch(() => {});
    getDashboard()
      .then(setData)
      .catch(() => setData(fallback));
  }, []);

  const meds = data?.medications ?? fallback.medications!;
  const tips = data?.health_tips ?? fallback.health_tips!;
  const typeLabel =
    data?.user_type === "autoimmune" ? "자가면역 환자" : "일반 환자";

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-10">
      {/* 인사말 */}
      <h1 className="text-3xl font-bold leading-tight">
        안녕하세요!
        <br />
        {name || data?.user_name || "OOO"}님{" "}
        <span className="text-base font-semibold text-primary">{typeLabel}</span>
      </h1>

      {/* 오늘 복약 */}
      <Card className="mt-6 p-5">
        <h2 className="text-base font-bold">오늘 복약</h2>
        <ul className="mt-3 space-y-2">
          {meds.map((m, i) => (
            <li key={i} className="flex items-center gap-2.5 text-sm">
              {m.done ? (
                <Check className="h-4 w-4 text-primary" />
              ) : (
                <Circle className="h-4 w-4 text-muted-foreground/40" />
              )}
              <span className={m.done ? "text-foreground" : "text-muted-foreground"}>
                {m.label}
              </span>
            </li>
          ))}
        </ul>
        <Link
          href="/medication/checklist"
          className="mt-3 flex items-center justify-end gap-1 text-sm text-primary"
        >
          전체 보기 <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </Card>

      {/* 오늘의 건강 팁 */}
      <Card className="mt-4 p-5">
        <h2 className="text-base font-bold">오늘의 건강 팁</h2>
        <ul className="mt-3 space-y-2 text-sm">
          {tips.map((t, i) => (
            <li key={i}>{t}</li>
          ))}
        </ul>
        <Link
          href="/guides"
          className="mt-3 flex items-center justify-end gap-1 text-sm text-primary"
        >
          전체 보기 <ArrowRight className="h-3.5 w-3.5" />
        </Link>
      </Card>
    </main>
  );
}

const fallback: DashboardData = {
  user_type: "general",
  medications: [
    { label: "아침약 (오전 9시)", done: true },
    { label: "점심약 (오후 1시)", done: false },
    { label: "저녁약 (오후 7시)", done: false },
  ],
  health_tips: ["💧 수분 충분히 섭취하기", "🚶 30분 가벼운 산책", "😴 7시간 이상 수면"],
};
