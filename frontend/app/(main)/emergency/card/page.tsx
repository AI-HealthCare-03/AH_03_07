"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { FileText, ArrowLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  getEmergencyCard,
  updateEmergencyCard,
  type EmergencyCard,
} from "@/features/emergency/api";

const RED = "#EF5B5B";

const MOCK_CARD: EmergencyCard = {
  blood_type: "A형 Rh+",
  conditions: "류마티스 관절염",
  medications: "메토트렉세이트 7.5mg",
  allergies: "페니실린",
  show_on_lock_screen: true,
  send_location: true,
};

function Toggle({ on, onChange }: { on: boolean; onChange: (v: boolean) => void }) {
  return (
    <button
      role="switch"
      aria-checked={on}
      onClick={() => onChange(!on)}
      className={"relative h-6 w-11 rounded-full transition-colors " + (on ? "bg-primary" : "bg-muted")}
    >
      <span className={"absolute top-0.5 h-5 w-5 rounded-full bg-white transition-transform " + (on ? "translate-x-5" : "translate-x-0.5")} />
    </button>
  );
}

export default function EmergencyCardPage() {
  const router = useRouter();
  const [bloodType, setBloodType] = useState("");
  const [conditions, setConditions] = useState("");
  const [medications, setMedications] = useState("");
  const [allergies, setAllergies] = useState("");
  const [lockScreen, setLockScreen] = useState(true);
  const [sendLocation, setSendLocation] = useState(true);
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    getEmergencyCard()
      .then((data) => {
        setBloodType(data.blood_type ?? MOCK_CARD.blood_type ?? "");
        setConditions(data.conditions ?? MOCK_CARD.conditions ?? "");
        setMedications(data.medications ?? MOCK_CARD.medications ?? "");
        setAllergies(data.allergies ?? MOCK_CARD.allergies ?? "");
        setLockScreen(data.show_on_lock_screen ?? true);
        setSendLocation(data.send_location ?? true);
      })
      .catch(() => {
        setBloodType(MOCK_CARD.blood_type ?? "");
        setConditions(MOCK_CARD.conditions ?? "");
        setMedications(MOCK_CARD.medications ?? "");
        setAllergies(MOCK_CARD.allergies ?? "");
        setLockScreen(MOCK_CARD.show_on_lock_screen ?? true);
        setSendLocation(MOCK_CARD.send_location ?? true);
      });
  }, []);

  async function handleSave() {
    setSaving(true);
    setError("");
    try {
      await updateEmergencyCard({
        blood_type: bloodType,
        conditions,
        medications,
        allergies,
        show_on_lock_screen: lockScreen,
        send_location: sendLocation,
      });
      setSaved(true);
      setTimeout(() => router.push("/emergency"), 800);
    } catch {
      setError("저장에 실패했습니다. 다시 시도해 주세요.");
      setSaving(false);
    }
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 py-8 pb-28">
      {/* 뒤로가기 */}
      <button
        onClick={() => router.push("/emergency")}
        className="mb-4 flex items-center gap-1 text-sm text-muted-foreground"
      >
        <ArrowLeft className="h-4 w-4" />
        응급 SOS
      </button>

      <h1 className="text-xl font-bold">응급 카드 설정</h1>

      {/* 배너 */}
      <div
        className="mt-4 flex items-center gap-3 rounded-2xl border p-4"
        style={{ borderColor: RED + "55", background: RED + "12" }}
      >
        <FileText className="h-6 w-6" style={{ color: RED }} />
        <div>
          <p className="font-bold" style={{ color: RED }}>응급 카드 정보 관리</p>
          <p className="text-sm" style={{ color: RED }}>응급 시 구급대원에게 표시될 정보입니다</p>
        </div>
      </div>

      {/* 기본 의료정보 입력 */}
      <p className="mt-6 text-sm text-muted-foreground">기본 의료정보</p>
      <Card className="mt-2 divide-y divide-border">
        <div className="px-4 py-3">
          <Label htmlFor="blood-type" className="text-xs text-muted-foreground">혈액형</Label>
          <Input
            id="blood-type"
            value={bloodType}
            onChange={(e) => setBloodType(e.target.value)}
            placeholder="예: A형 Rh+"
            className="mt-1 border-0 p-0 text-sm font-semibold shadow-none focus-visible:ring-0"
          />
        </div>
        <div className="px-4 py-3">
          <Label htmlFor="conditions" className="text-xs text-muted-foreground">기저 질환</Label>
          <Input
            id="conditions"
            value={conditions}
            onChange={(e) => setConditions(e.target.value)}
            placeholder="예: 류마티스 관절염"
            className="mt-1 border-0 p-0 text-sm font-semibold shadow-none focus-visible:ring-0"
          />
        </div>
        <div className="px-4 py-3">
          <Label htmlFor="medications" className="text-xs text-muted-foreground">복용 약물</Label>
          <Input
            id="medications"
            value={medications}
            onChange={(e) => setMedications(e.target.value)}
            placeholder="예: 메토트렉세이트 7.5mg"
            className="mt-1 border-0 p-0 text-sm font-semibold shadow-none focus-visible:ring-0"
          />
        </div>
        <div className="px-4 py-3">
          <Label htmlFor="allergies" className="text-xs text-muted-foreground">알레르기</Label>
          <Input
            id="allergies"
            value={allergies}
            onChange={(e) => setAllergies(e.target.value)}
            placeholder="예: 페니실린"
            className="mt-1 border-0 p-0 text-sm font-semibold shadow-none focus-visible:ring-0"
          />
        </div>
      </Card>

      {/* 표시 설정 */}
      <p className="mt-6 text-sm text-muted-foreground">표시 설정</p>
      <Card className="mt-2 divide-y divide-border">
        <div className="flex items-center justify-between px-4 py-3.5">
          <div>
            <p className="text-sm">잠금화면에 표시</p>
            <p className="text-xs text-muted-foreground">잠금 상태에서도 응급 카드 접근</p>
          </div>
          <Toggle on={lockScreen} onChange={setLockScreen} />
        </div>
        <div className="flex items-center justify-between px-4 py-3.5">
          <div>
            <p className="text-sm">위치정보 함께 전송</p>
            <p className="text-xs text-muted-foreground">119 신고 시 현재 위치 자동 전송</p>
          </div>
          <Toggle on={sendLocation} onChange={setSendLocation} />
        </div>
      </Card>

      {error && (
        <p className="mt-3 text-center text-sm text-destructive">{error}</p>
      )}

      <div className="fixed inset-x-0 bottom-0 mx-auto max-w-md px-5 pb-6 pt-3 bg-background">
        <Button
          className="w-full"
          size="lg"
          disabled={saving || saved}
          onClick={handleSave}
        >
          {saved ? "저장됨 ✓" : saving ? "저장 중…" : "저장하기"}
        </Button>
      </div>
    </main>
  );
}
