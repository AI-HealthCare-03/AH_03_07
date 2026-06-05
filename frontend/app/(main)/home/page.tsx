"use client";

import { useEffect, useState } from "react";
import { getDashboard } from "@/features/dashboard/api";
import { getMe } from "@/features/auth/api";
import { getMode } from "@/features/auth/mode";
import type { DashboardData } from "@/features/dashboard/api";
import GeneralHome from "@/features/home/GeneralHome";
import AutoimmuneHome from "@/features/home/AutoimmuneHome";

export default function HomePage() {
  const [data, setData] = useState<DashboardData | null>(null);
  const [name, setName] = useState<string>("");
  const [userType, setUserType] = useState<"general" | "autoimmune">("general");

  useEffect(() => {
    setUserType(getMode());
    getMe()
      .then((u) => {
        setName(u.name);
        if (u.user_type) setUserType(u.user_type);
      })
      .catch(() => {});
    getDashboard()
      .then((d) => {
        setData(d);
        if (d.user_type) setUserType(d.user_type);
      })
      .catch(() => setData(fallback));
  }, []);

  const meds = data?.medications ?? fallback.medications!;
  const displayName = name || data?.user_name || "OOO";

  if (userType === "autoimmune") {
    return <AutoimmuneHome name={displayName} medications={meds} />;
  }
  return <GeneralHome name={displayName} medications={meds} />;
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