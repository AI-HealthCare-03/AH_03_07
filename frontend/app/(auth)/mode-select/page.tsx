"use client";

import { useRouter } from "next/navigation";
import { setMode } from "@/features/auth/mode";

const GREEN = "#22C55E";
const PURPLE = "#7C5CCF";

type Mode = "general" | "autoimmune";

function PersonPlusIcon({ color, id }: { color: string; id: string }) {
  return (
    <svg width="64" height="64" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <radialGradient id={`bg-${id}`} cx="38%" cy="28%" r="65%">
          <stop offset="0%" stopColor="#ffffff" stopOpacity="0.55" />
          <stop offset="100%" stopColor={color} stopOpacity="1" />
        </radialGradient>
        <radialGradient id={`shine-${id}`} cx="40%" cy="25%" r="55%">
          <stop offset="0%" stopColor="#ffffff" stopOpacity="0.7" />
          <stop offset="100%" stopColor="#ffffff" stopOpacity="0" />
        </radialGradient>
        <filter id={`shadow-${id}`} x="-20%" y="-20%" width="140%" height="140%">
          <feDropShadow dx="0" dy="3" stdDeviation="4" floodColor="#00000033" />
        </filter>
      </defs>
      <circle cx="32" cy="32" r="30" fill={`url(#bg-${id})`} filter={`url(#shadow-${id})`} />
      <ellipse cx="26" cy="20" rx="13" ry="8" fill={`url(#shine-${id})`} />
      <circle cx="28" cy="22" r="8" fill="white" fillOpacity="0.92" />
      <path d="M12 46c0-8.8 7.2-16 16-16h0c8.8 0 16 7.2 16 16" fill="white" fillOpacity="0.92" />
      <circle cx="46" cy="44" r="10" fill="white" />
      <rect x="44.5" y="38" width="3" height="12" rx="1.5" fill={color} />
      <rect x="40" y="42.5" width="12" height="3" rx="1.5" fill={color} />
    </svg>
  );
}

export default function ModeSelectPage() {
  const router = useRouter();

  function select(mode: Mode) {
    setMode(mode);
    router.replace(mode === "autoimmune" ? "/mode-consent" : "/home");
  }

  const cards: { key: Mode; title: string; lines: string[]; color: string; id: string }[] = [
    { key: "autoimmune", title: "자가면역환자", lines: ["활성도 추적", "면역약물 특화 정보"], color: PURPLE, id: "auto" },
    { key: "general", title: "일반 환자", lines: ["복약 관리", "일반 의료 정보"], color: GREEN, id: "gen" },
  ];

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-md flex-col px-6 pb-10 pt-12">
      <h1 className="mt-6 text-3xl font-extrabold leading-tight">
        어떤 도움이<br />필요하신가요?
      </h1>
      <p className="mt-2 text-sm text-muted-foreground">맞춤 가이드를 제공해드릴게요</p>

      <div className="mt-12 space-y-4">
        {cards.map((c) => (
          <button
            key={c.key}
            onClick={() => select(c.key)}
            className="flex w-full items-center gap-4 rounded-2xl border-2 bg-card p-5 text-left transition-all hover:scale-[1.02] active:scale-[0.98]"
            style={{ borderColor: c.color, boxShadow: `inset 0 0 0 1px ${c.color}40` }}
          >
            <PersonPlusIcon color={c.color} id={c.id} />
            <div className="flex-1">
              <p className="text-lg font-bold" style={{ color: c.color }}>{c.title}</p>
              {c.lines.map((l) => (
                <p key={l} className="text-sm text-muted-foreground">{l}</p>
              ))}
            </div>
            <span style={{ color: c.color }}>›</span>
          </button>
        ))}
      </div>

      <div className="mt-auto flex justify-center pt-8">
        <button onClick={() => select("general")} className="text-sm text-muted-foreground">
          나중에 선택할게요
        </button>
      </div>
    </main>
  );
}
