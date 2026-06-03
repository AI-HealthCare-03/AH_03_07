"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { logout, withdraw } from "@/features/auth/api";
import { ApiError } from "@/lib/api/client";

export default function SettingsPage() {
  const router = useRouter();
  const [confirming, setConfirming] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleLogout() {
    await logout();
    router.replace("/login");
  }

  async function handleWithdraw() {
    setLoading(true);
    setError(null);
    try {
      await withdraw();
      router.replace("/login");
    } catch (err) {
      setError(err instanceof ApiError ? err.message : "탈퇴에 실패했습니다.");
    } finally {
      setLoading(false);
    }
  }

  return (
    <main className="mx-auto w-full max-w-md px-6 py-8">
      <h1 className="text-2xl font-bold">설정</h1>

      <div className="mt-6 space-y-3">
        <Link href="/consent">
          <Card className="flex items-center justify-between p-4 hover:bg-accent">
            <span className="text-sm font-medium">동의 관리</span>
            <span className="text-muted-foreground">›</span>
          </Card>
        </Link>

        <Card className="p-4">
          <button
            onClick={handleLogout}
            className="w-full text-left text-sm font-medium"
          >
            로그아웃
          </button>
        </Card>

        {/* 회원탈퇴 (REQ-USER-008) */}
        <Card className="p-4">
          {!confirming ? (
            <button
              onClick={() => setConfirming(true)}
              className="w-full text-left text-sm font-medium text-destructive"
            >
              회원탈퇴
            </button>
          ) : (
            <div className="space-y-3">
              <p className="text-sm text-foreground">
                탈퇴 시 모든 의료 기록·가이드·OCR 데이터가 즉시 삭제되며 복구할 수
                없습니다.
              </p>
              {error && <p className="text-sm text-destructive">{error}</p>}
              <div className="flex gap-2">
                <Button
                  variant="outline"
                  className="flex-1"
                  onClick={() => setConfirming(false)}
                  disabled={loading}
                >
                  취소
                </Button>
                <Button
                  variant="destructive"
                  className="flex-1"
                  onClick={handleWithdraw}
                  disabled={loading}
                >
                  {loading ? "처리 중..." : "탈퇴"}
                </Button>
              </div>
            </div>
          )}
        </Card>
      </div>
    </main>
  );
}
