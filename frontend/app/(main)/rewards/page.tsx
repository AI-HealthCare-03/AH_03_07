"use client";

import { useState } from "react";
import { Card } from "@/components/ui/card";
import {
  levelOf, levelName, progressRatio, nextLevelPoints,
} from "@/features/gamification/types";
import { DUMMY_POINTS, BADGES, REWARDS } from "@/features/gamification/data";

type Tab = "badge" | "reward";

export default function RewardsPage() {
  const [tab, setTab] = useState<Tab>("badge");
  const [points, setPoints] = useState(DUMMY_POINTS.totalPoints);
  const [checkedIn, setCheckedIn] = useState(DUMMY_POINTS.todayCheckedIn);

  const lv = levelOf(points);
  const ratio = progressRatio(points);
  const earnedCount = BADGES.filter((b) => b.earned).length;

  function checkIn() {
    if (checkedIn) return;
    setPoints((p) => p + 10);
    setCheckedIn(true);
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-8">
      <h1 className="text-2xl font-bold">포인트 · 보상</h1>

      {/* 포인트 카드 */}
      <Card className="mt-5 bg-primary p-5 text-primary-foreground">
        <div className="flex items-center justify-between">
          <span className="text-sm opacity-90">Lv.{lv} {levelName(points)}</span>
          <span className="text-2xl font-extrabold">{points}P</span>
        </div>
        <div className="mt-3 h-2 w-full overflow-hidden rounded-full bg-white/30">
          <div className="h-full rounded-full bg-white" style={{ width: `${ratio * 100}%` }} />
        </div>
        <p className="mt-1.5 text-xs opacity-90">
          다음 레벨까지 {Math.max(0, nextLevelPoints(points) - points)}P
        </p>
        <button
          onClick={checkIn}
          disabled={checkedIn}
          className="mt-4 w-full rounded-xl bg-white py-2.5 font-bold text-primary disabled:opacity-60"
        >
          {checkedIn ? "오늘 출석 완료 ✓" : "출석체크 +10P"}
        </button>
      </Card>

      {/* 탭 */}
      <div className="mt-5 flex gap-2">
        <button onClick={() => setTab("badge")} className={"flex-1 rounded-full py-2.5 text-sm font-bold " + (tab === "badge" ? "bg-primary text-primary-foreground" : "border border-border")}>
          뱃지 {earnedCount}/{BADGES.length}
        </button>
        <button onClick={() => setTab("reward")} className={"flex-1 rounded-full py-2.5 text-sm font-bold " + (tab === "reward" ? "bg-primary text-primary-foreground" : "border border-border")}>
          보상 상점
        </button>
      </div>

      {/* 뱃지 그리드 */}
      {tab === "badge" && (
        <div className="mt-5 grid grid-cols-4 gap-3 pb-6">
          {BADGES.map((b) => (
            <div key={b.id} className="flex flex-col items-center text-center">
              <div className={"flex h-14 w-14 items-center justify-center rounded-2xl text-2xl " + (b.earned ? "bg-secondary" : "bg-muted opacity-40 grayscale")}>
                {b.icon}
              </div>
              <span className="mt-1 line-clamp-1 text-[11px] text-muted-foreground">{b.name}</span>
            </div>
          ))}
        </div>
      )}

      {/* 보상 상점 */}
      {tab === "reward" && (
        <div className="mt-5 space-y-3 pb-6">
          {REWARDS.map((r) => {
            const canAfford = points >= r.requiredPoints;
            return (
              <Card key={r.id} className="flex items-center justify-between p-4">
                <div>
                  <p className="font-semibold">{r.name}</p>
                  <p className="text-xs text-muted-foreground">{r.type === "title" ? "칭호" : "테마"} · {r.requiredPoints}P</p>
                </div>
                {r.owned ? (
                  <span className="rounded-md bg-secondary px-3 py-1.5 text-xs font-bold text-primary">보유</span>
                ) : (
                  <button
                    disabled={!canAfford}
                    className="rounded-md bg-primary px-3 py-1.5 text-xs font-bold text-primary-foreground disabled:opacity-40"
                  >
                    {canAfford ? "교환" : "포인트 부족"}
                  </button>
                )}
              </Card>
            );
          })}
        </div>
      )}
    </main>
  );
}
