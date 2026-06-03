"use client";

import { useEffect, useState } from "react";
import { Bell } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getNotifications, markRead } from "@/features/notifications/api";
import type { AppNotification } from "@/features/notifications/api";

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

export default function NotificationsPage() {
  const [items, setItems] = useState<AppNotification[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getNotifications()
      .then(setItems)
      .catch(() => setError("알림을 불러오지 못했습니다."))
      .finally(() => setLoading(false));
  }, []);

  async function handleClick(n: AppNotification) {
    if (n.is_read) return;
    try {
      await markRead(n.id);
      setItems((prev) =>
        prev.map((x) => (x.id === n.id ? { ...x, is_read: true } : x))
      );
    } catch {
      /* no-op */
    }
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-10">
      <h1 className="text-3xl font-bold">알림</h1>

      {loading ? (
        <p className="mt-8 text-sm text-muted-foreground">불러오는 중...</p>
      ) : error ? (
        <p className="mt-8 text-sm text-destructive">{error}</p>
      ) : items.length === 0 ? (
        <div className="mt-16 flex flex-col items-center text-muted-foreground">
          <Bell className="h-12 w-12 opacity-30" />
          <p className="mt-3 text-sm">알림이 없습니다.</p>
        </div>
      ) : (
        <div className="mt-6 space-y-3">
          {items.map((n) => (
            <Card
              key={n.id}
              onClick={() => handleClick(n)}
              className={
                "cursor-pointer p-4 " +
                (n.notification_type === "risk" ? "border-amber-400" : "")
              }
            >
              <div className="flex items-start gap-3">
                <span className="text-2xl">{emoji(n.notification_type)}</span>
                <div className="flex-1">
                  <p className={"text-sm " + (n.is_read ? "font-normal" : "font-bold")}>
                    {n.title}
                  </p>
                  {n.body && (
                    <p className="mt-0.5 text-sm text-muted-foreground">{n.body}</p>
                  )}
                </div>
                {!n.is_read && <span className="mt-1 h-2.5 w-2.5 rounded-full bg-destructive" />}
              </div>
            </Card>
          ))}
        </div>
      )}
    </main>
  );
}
