"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { getMe, logout } from "@/features/auth/api";
import type { UserProfile } from "@/features/auth/types";

// Phase 1 임시 홈 (Phase 3에서 대시보드로 확장)
export default function HomePage() {
  const router = useRouter();
  const [user, setUser] = useState<UserProfile | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getMe()
      .then(setUser)
      .catch(() => setError("로그인이 필요합니다."));
  }, []);

  async function handleLogout() {
    await logout();
    router.replace("/login");
  }

  return (
    <main className="mx-auto w-full max-w-md px-6 py-10">
      <h1 className="text-2xl font-bold">
        안녕하세요!{user ? ` ${user.name}님` : ""}
      </h1>
      {error ? (
        <p className="mt-4 text-sm text-destructive">{error}</p>
      ) : user ? (
        <p className="mt-2 text-sm text-muted-foreground">{user.email}</p>
      ) : (
        <p className="mt-2 text-sm text-muted-foreground">불러오는 중...</p>
      )}

      <div className="mt-10">
        <Button variant="outline" onClick={handleLogout}>
          로그아웃
        </Button>
      </div>
    </main>
  );
}
