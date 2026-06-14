"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { getMe, updateMe, withdraw } from "@/features/auth/api";

const CHRONIC_OPTIONS = ["당뇨", "고혈압", "고지혈증", "심혈관 질환", "갑상선 질환", "기타"];

export default function ProfileEditPage() {
  const router = useRouter();
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [birthDate, setBirthDate] = useState("");
  const [height, setHeight] = useState("");
  const [weight, setWeight] = useState("");
  const [chronicList, setChronicList] = useState<string[]>([]);
  const [allergy, setAllergy] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saved, setSaved] = useState(false);
  const [showWithdraw, setShowWithdraw] = useState(false);
  const [withdrawing, setWithdrawing] = useState(false);

  useEffect(() => {
    getMe().then((u) => {
      setName(u.name ?? "");
      setPhone(u.phone_number ?? "");
      setBirthDate(u.birthday ?? "");
      setHeight(u.height != null ? String(u.height) : "");
      setWeight(u.weight != null ? String(u.weight) : "");
      setAllergy(u.allergy_info ?? "");
      if (u.chronic_diseases) {
        setChronicList(u.chronic_diseases.split(",").map((s) => s.trim()).filter(Boolean));
      }
    }).catch(() => {});
  }, []);

  function toggleChronic(item: string) {
    setChronicList((prev) =>
      prev.includes(item) ? prev.filter((c) => c !== item) : [...prev, item]
    );
  }

  async function handleSave() {
    setSaving(true);
    setError(null);
    try {
      await updateMe({
        name: name.trim() || undefined,
        phone_number: phone.trim() || undefined,
        birthday: birthDate.trim() || undefined,
        height: height.trim() ? Number(height) : undefined,
        weight: weight.trim() ? Number(weight) : undefined,
        chronic_diseases: chronicList.join(",") || undefined,
        allergy_info: allergy.trim() || undefined,
      });
      setSaved(true);
      setTimeout(() => router.back(), 800);
    } catch (err) {
      setError(err instanceof Error ? err.message : "저장에 실패했습니다.");
    } finally {
      setSaving(false);
    }
  }

  async function handleWithdraw() {
    setWithdrawing(true);
    try {
      await withdraw();
      router.replace("/auth/login");
    } catch (err) {
      setError(err instanceof Error ? err.message : "탈퇴에 실패했습니다.");
      setShowWithdraw(false);
    } finally {
      setWithdrawing(false);
    }
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 py-6 pb-36">
      <div className="flex items-center gap-2">
        <button onClick={() => router.back()} className="rounded-full p-1 hover:bg-accent" aria-label="뒤로가기">
          <ChevronLeft className="h-5 w-5" />
        </button>
        <h1 className="text-2xl font-bold">회원 정보 수정</h1>
      </div>

      <div className="mt-6 space-y-5">
        {/* 이름 */}
        <div>
          <label className="text-sm font-medium">이름</label>
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="이름 입력"
            className="mt-2 h-11 w-full rounded-xl border border-input bg-background px-4 text-sm outline-none focus:border-primary"
          />
        </div>

        {/* 생년월일 */}
        <div>
          <label className="text-sm font-medium">생년월일</label>
          <input
            type="date"
            value={birthDate}
            onChange={(e) => setBirthDate(e.target.value)}
            className="mt-2 h-11 w-full rounded-xl border border-input bg-background px-4 text-sm outline-none focus:border-primary"
          />
        </div>

        {/* 키 / 몸무게 */}
        <div className="flex gap-3">
          <div className="flex-1">
            <label className="text-sm font-medium">키</label>
            <div className="relative mt-2">
              <input
                type="number"
                value={height}
                onChange={(e) => setHeight(e.target.value)}
                placeholder="170"
                min={0}
                max={300}
                className="h-11 w-full rounded-xl border border-input bg-background px-4 pr-10 text-sm outline-none focus:border-primary"
              />
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">cm</span>
            </div>
          </div>
          <div className="flex-1">
            <label className="text-sm font-medium">몸무게</label>
            <div className="relative mt-2">
              <input
                type="number"
                value={weight}
                onChange={(e) => setWeight(e.target.value)}
                placeholder="65"
                min={0}
                max={500}
                className="h-11 w-full rounded-xl border border-input bg-background px-4 pr-10 text-sm outline-none focus:border-primary"
              />
              <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">kg</span>
            </div>
          </div>
        </div>

        {/* 휴대폰 */}
        <div>
          <label className="text-sm font-medium">휴대폰 번호</label>
          <input
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            placeholder="010-0000-0000"
            className="mt-2 h-11 w-full rounded-xl border border-input bg-background px-4 text-sm outline-none focus:border-primary"
          />
        </div>

        {/* 만성질환 */}
        <div>
          <label className="text-sm font-medium">만성질환 정보</label>
          <div className="mt-2 flex flex-wrap gap-2">
            {CHRONIC_OPTIONS.map((item) => (
              <button
                key={item}
                type="button"
                onClick={() => toggleChronic(item)}
                className="rounded-full px-4 py-1.5 text-sm font-medium transition-colors"
                style={
                  chronicList.includes(item)
                    ? { background: "hsl(var(--primary))", color: "#fff" }
                    : { border: "1px solid hsl(var(--border))", background: "hsl(var(--background))" }
                }
              >
                {item}
              </button>
            ))}
          </div>
        </div>

        {/* 알레르기 */}
        <div>
          <label className="text-sm font-medium">알레르기 정보</label>
          <textarea
            value={allergy}
            onChange={(e) => setAllergy(e.target.value)}
            rows={3}
            placeholder="예: 페니실린, 땅콩"
            className="mt-2 w-full rounded-xl border border-input bg-background px-4 py-3 text-sm outline-none focus:border-primary"
          />
        </div>
      </div>

      {error && <p className="mt-4 text-sm text-destructive">{error}</p>}

      {/* 회원탈퇴 버튼 */}
      <div className="mt-8 border-t border-border pt-6">
        <button
          type="button"
          onClick={() => setShowWithdraw(true)}
          className="text-sm text-destructive underline underline-offset-2"
        >
          회원 탈퇴
        </button>
      </div>

      {/* 저장 버튼 */}
      <div className="fixed inset-x-0 bottom-6 mx-auto max-w-md px-5">
        <Button className="w-full" size="lg" onClick={handleSave} disabled={saving || saved}>
          {saved ? "저장됨 ✓" : saving ? "저장 중..." : "저장하기"}
        </Button>
      </div>

      {/* 탈퇴 확인 모달 */}
      {showWithdraw && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 px-5">
          <div className="w-full max-w-sm rounded-2xl bg-card p-6 shadow-lg">
            <h2 className="text-lg font-bold">정말 탈퇴하시겠어요?</h2>
            <p className="mt-2 text-sm text-muted-foreground">
              탈퇴하면 모든 의료 데이터가 즉시 삭제되며 복구할 수 없습니다.
            </p>
            <div className="mt-5 flex gap-3">
              <Button
                variant="outline"
                className="flex-1"
                onClick={() => setShowWithdraw(false)}
                disabled={withdrawing}
              >
                취소
              </Button>
              <Button
                variant="destructive"
                className="flex-1"
                onClick={handleWithdraw}
                disabled={withdrawing}
              >
                {withdrawing ? "처리 중..." : "탈퇴하기"}
              </Button>
            </div>
          </div>
        </div>
      )}
    </main>
  );
}
