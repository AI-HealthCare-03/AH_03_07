"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { User, FileText, Pill, FolderOpen, ScanLine, ShieldCheck, Settings, ChevronRight } from "lucide-react";
import { Card } from "@/components/ui/card";
import { getMe } from "@/features/auth/api";
import type { UserProfile } from "@/features/auth/types";

const menus = [
  { href: "/records", label: "진료 기록", icon: FileText },
  { href: "/medication", label: "약물 목록", icon: Pill },
  { href: "/documents", label: "문서 보관함", icon: FolderOpen },
  { href: "/pills", label: "약품 인식", icon: ScanLine },
  { href: "/consent", label: "동의 관리", icon: ShieldCheck },
  { href: "/settings", label: "설정", icon: Settings },
];

export default function MyPage() {
  const [user, setUser] = useState<UserProfile | null>(null);

  useEffect(() => {
    getMe().then(setUser).catch(() => {});
  }, []);

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-10">
      <h1 className="text-2xl font-bold">마이페이지</h1>

      {/* 프로필 */}
      <Card className="mt-5 p-5">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 items-center justify-center rounded-full bg-secondary">
            <User className="h-7 w-7 text-primary" />
          </div>
          <div>
            <p className="text-lg font-bold">{user?.name ?? "-"}</p>
            <p className="text-sm text-muted-foreground">{user?.email ?? "-"}</p>
          </div>
        </div>
      </Card>

      {/* 메뉴 */}
      <div className="mt-5 overflow-hidden rounded-2xl border border-border">
        {menus.map(({ href, label, icon: Icon }, i) => (
          <Link
            key={href}
            href={href}
            className={
              "flex items-center gap-3 bg-card px-4 py-3.5 hover:bg-accent " +
              (i > 0 ? "border-t border-border" : "")
            }
          >
            <Icon className="h-5 w-5 text-muted-foreground" />
            <span className="flex-1 text-sm font-medium">{label}</span>
            <ChevronRight className="h-4 w-4 text-muted-foreground" />
          </Link>
        ))}
      </div>
    </main>
  );
}
