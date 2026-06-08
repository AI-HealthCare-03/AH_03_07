"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Bell, ChevronLeft } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getNotifications, type AppNotification } from "@/features/notifications/api";
import { markRead } from "@/features/notifications/api";

function makeIso(daysAgo: number, hours: number, minutes: number): string {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  d.setHours(hours, minutes, 0, 0);
  return d.toISOString();
}

const FALLBACK_ITEMS: AppNotification[] = [
  { id: 1, title: "복약 시간이에요", body: "아침약 복용해주세요", notification_type: "medication", is_read: false, created_at: makeIso(0, 9, 0) },
  { id: 2, title: "의료진 확인 신호", body: "통증 점수 7점 이상", notification_type: "risk", is_read: false, created_at: makeIso(0, 7, 0) },
  { id: 3, title: "활성도 기록 알림", body: "오늘 컨디션을 기록해주세요", notification_type: "activity", is_read: true, created_at: makeIso(1, 21, 0) },
  { id: 4, title: "약 복용 완료", body: "저녁약 복용 완료", notification_type: "done", is_read: true, created_at: makeIso(1, 19, 30) },
];

function emoji(type?: string) {
  switch (type) {
    case "medication": return "💊";
    case "risk": return "⚠️";
    case "activity": return "📊";
    case "done": return "✅";
    case "guide": return "📋";
    default: return "🔔";
  }
}

function dateGroup(isoStr?: string): string {
  if (!isoStr) return "이전";
  const d = new Date(isoStr);
  const now = new Date();
  const yesterday = new Date();
  yesterday.setDate(now.getDate() - 1);
  if (d.toDateString() === now.toDateString()) return "오늘";
  if (d.toDateString() === yesterday.toDateString()) return "어제";
  return d.toLocaleDateString("ko-KR", { month: "long", day: "numeric" });
}

function timeStr(isoStr?: string): string {
  if (!isoStr) return "";
  const d = new Date(isoStr);
  return d.toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit", hour12: true });
}

export default function NotificationsPage() {
  const router = useRouter();
  const [items, setItems] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    getNotifications()
      .then((data) => setItems(data.length ? data : FALLBACK_ITEMS))
      .catch(() => setItems(FALLBACK_ITEMS))
      .finally(() => setLoading(false));
  }, []);

  function handleClick(n: AppNotification) {
    if (!n.is_read) {
      markRead(n.id).catch(() => {});
      setItems((prev) => prev.map((x) => (x.id === n.id ? { ...x, is_read: true } : x)));
    }
    if (n.notification_type === "risk") router.push("/symptom-check");
  }

  const groups = items.reduce((acc, n) => {
    const key = dateGroup(n.created_at);
    if (!acc[key]) acc[key] = [];
    acc[key].push(n);
    return acc;
  }, {} as Record<string, AppNotification[]>);

  const groupKeys = ["오늘", "어제", ...Object.keys(groups).filter((k) => k !== "오늘" && k !== "어제")].filter((k) => groups[k]);

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-6">
      <div className="flex items-center gap-2">
        <button onClick={() => router.back()} className="p-1 text-foreground">
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="text-3xl font-extrabold">알림</h1>
      </div>

      {loading ? (
        <p className="mt-8 text-sm text-muted-foreground">불러오는 중...</p>
      ) : items.length === 0 ? (
        <div className="mt-16 flex flex-col items-center text-muted-foreground">
          <Bell className="h-12 w-12 opacity-30" />
          <p className="mt-3 text-sm">알림이 없습니다.</p>
        </div>
      ) : (
        <div className="mt-6 space-y-6">
          {groupKeys.map((group) => (
            <div key={group}>
              <h2 className="mb-3 text-sm font-semibold text-muted-foreground">{group}</h2>
              <div className="space-y-3">
                {groups[group].map((n) => (
                  <Card
                    key={n.id}
                    onClick={() => handleClick(n)}
                    className={"cursor-pointer p-4 " + (n.notification_type === "risk" ? "border-amber-400" : "")}
                  >
                    <div className="flex items-start gap-3">
                      <span className="text-2xl">{emoji(n.notification_type)}</span>
                      <div className="flex-1">
                        <div className="flex items-center justify-between">
                          <p className={"text-base " + (n.is_read ? "font-medium" : "font-bold")}>{n.title}</p>
                          {!n.is_read && <span className="ml-2 h-2.5 w-2.5 shrink-0 rounded-full bg-destructive" />}
                        </div>
                        {n.body && <p className="mt-0.5 text-sm text-muted-foreground">{n.body}</p>}
                        {n.created_at && (
                          <p className="mt-2 text-right text-xs text-muted-foreground">{timeStr(n.created_at)}</p>
                        )}
                      </div>
                    </div>
                  </Card>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}
    </main>
  );
}
