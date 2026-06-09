"use client";

import { useState } from "react";
import { useParams, useRouter } from "next/navigation";
import {
  ChevronLeft,
  Download,
  Share2,
  ThumbsUp,
  ThumbsDown,
  Newspaper,
  Volume2,
  Activity,
  Loader2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { feedbackGuide, generateCardNews, generateTTS } from "@/features/guides/api";
import { useGuide } from "@/features/guides/queries";
import { withTimeout } from "@/lib/query/util";

// 데모용 고정 데이터 (백엔드 연동 시 guide 필드로 대체)
const MOCK = {
  visit_date: "2026-05-28",
  activity_score: 3.2,
  activity_level: "중등도",
  crp: "1.8 mg/dL",
  esr: "42 mm/hr",
  ra_factor: "양성",
  medication_adherence: 85,
  key_symptoms: ["관절 통증 (양측 손목)", "아침 강직 40분", "피로감 증가", "미열 (37.2°C)"],
};

export default function GuideDetailPage() {
  const router = useRouter();
  const params = useParams();
  const id = Number(params.id);
  const { data: guide, isLoading } = useGuide(id);
  const [feedback, setFeedback] = useState<"up" | "down" | null>(null);
  const [feedbackSent, setFeedbackSent] = useState(false);
  const [cardNewsLoading, setCardNewsLoading] = useState(false);
  const [ttsLoading, setTtsLoading] = useState(false);
  const [contentMessage, setContentMessage] = useState<{ text: string; ok: boolean } | null>(null);
  const [shareMessage, setShareMessage] = useState<string | null>(null);

  async function handleCardNews() {
    setCardNewsLoading(true);
    setContentMessage(null);
    try {
      await withTimeout(generateCardNews(id));
      setContentMessage({ text: "카드뉴스 생성이 완료됐어요.", ok: true });
    } catch {
      setContentMessage({ text: "카드뉴스 생성에 실패했어요.", ok: false });
    } finally {
      setCardNewsLoading(false);
    }
  }

  async function handleTTS() {
    setTtsLoading(true);
    setContentMessage(null);
    try {
      await withTimeout(generateTTS(id));
      setContentMessage({ text: "음성 변환이 완료됐어요.", ok: true });
    } catch {
      setContentMessage({ text: "음성 변환에 실패했어요.", ok: false });
    } finally {
      setTtsLoading(false);
    }
  }

  async function handleShare() {
    const url = window.location.href;
    if (navigator.share) {
      try {
        await navigator.share({ title: "진료 전 요약", url });
      } catch {
        /* 사용자가 취소한 경우 무시 */
      }
      return;
    }
    try {
      await navigator.clipboard.writeText(url);
      setShareMessage("링크가 복사됐어요");
      setTimeout(() => setShareMessage(null), 2500);
    } catch {
      setShareMessage("복사에 실패했어요");
      setTimeout(() => setShareMessage(null), 2500);
    }
  }

  async function handleFeedback(type: "up" | "down") {
    if (feedbackSent) return;
    setFeedback(type);
    setFeedbackSent(true);
    try {
      await withTimeout(feedbackGuide(id, type === "up" ? 5 : 1));
    } catch {
      /* no-op */
    }
  }

  if (isLoading) {
    return (
      <main className="mx-auto max-w-md px-5 py-10 text-sm text-muted-foreground">
        불러오는 중...
      </main>
    );
  }
  if (!guide) {
    return (
      <main className="mx-auto max-w-md px-5 py-10 text-sm text-destructive">
        요약을 찾을 수 없습니다.
      </main>
    );
  }

  return (
    <main className="mx-auto w-full max-w-md px-5 pt-5 pb-10 space-y-4">
      {/* 헤더 */}
      <div className="flex items-center gap-2">
        <button
          onClick={() => router.push("/guides")}
          className="p-1 -ml-1 text-muted-foreground"
          aria-label="목록으로 이동"
        >
          <ChevronLeft className="h-6 w-6" />
        </button>
        <h1 className="text-lg font-bold">진료 전 요약</h1>
      </div>

      {/* MediGuide 요약 카드 (보라색) */}
      <div className="rounded-2xl bg-[#7C5CCF] p-5 text-white">
        <div className="flex items-center gap-2 mb-2">
          <Activity className="h-4 w-4 opacity-80" />
          <span className="text-xs font-semibold opacity-80 uppercase tracking-wide">MediGuide 요약</span>
        </div>
        <p className="text-base font-bold leading-6">
          {guide.symptom_summary ?? "요약 정보가 없습니다."}
        </p>
        <p className="mt-3 text-xs opacity-60">진료 예정일 · {MOCK.visit_date}</p>
      </div>

      {/* 활성도 점수 */}
      <Card className="p-4">
        <h2 className="text-sm font-bold text-muted-foreground mb-3">활성도 추이 (DAS28)</h2>
        <div className="flex items-end gap-2">
          <span className="text-3xl font-bold text-[#7C5CCF]">{MOCK.activity_score}</span>
          <span className="text-sm text-muted-foreground mb-1">/ 10</span>
          <span className="ml-auto rounded-full bg-yellow-100 text-yellow-800 px-3 py-1 text-xs font-semibold">
            {MOCK.activity_level}
          </span>
        </div>
        <div className="mt-3 h-2 rounded-full bg-gray-100 overflow-hidden">
          <div
            className="h-full rounded-full bg-[#7C5CCF] transition-all"
            style={{ width: `${(MOCK.activity_score / 10) * 100}%` }}
          />
        </div>
      </Card>

      {/* 진료 결과 */}
      <Card className="p-4">
        <h2 className="text-sm font-bold mb-3">검사 결과</h2>
        <div className="grid grid-cols-3 gap-3">
          {[
            { label: "CRP", value: MOCK.crp },
            { label: "ESR", value: MOCK.esr },
            { label: "RF", value: MOCK.ra_factor },
          ].map(({ label, value }) => (
            <div key={label} className="rounded-xl bg-[#F5F0FF] p-3 text-center">
              <p className="text-[11px] text-muted-foreground">{label}</p>
              <p className="mt-1 text-sm font-bold text-[#7C5CCF]">{value}</p>
            </div>
          ))}
        </div>
      </Card>

      {/* 복약 현황 */}
      <Card className="p-4">
        <h2 className="text-sm font-bold mb-3">복약 현황</h2>
        <div className="rounded-xl bg-[#F5F0FF] p-4">
          <div className="flex items-center justify-between mb-2">
            <span className="text-sm text-muted-foreground">복약 순응도</span>
            <span className="text-lg font-bold text-[#7C5CCF]">{MOCK.medication_adherence}%</span>
          </div>
          <div className="h-2 rounded-full bg-white overflow-hidden">
            <div
              className="h-full rounded-full bg-[#7C5CCF] transition-all"
              style={{ width: `${MOCK.medication_adherence}%` }}
            />
          </div>
          <p className="mt-1.5 text-xs text-muted-foreground">최근 30일 기준</p>
        </div>
      </Card>

      {/* 주요 증상 */}
      <Card className="p-4">
        <h2 className="text-sm font-bold mb-3">주의 증상 기록</h2>
        <ul className="space-y-2">
          {MOCK.key_symptoms.map((sym) => (
            <li key={sym} className="flex items-center gap-2 text-sm">
              <span className="h-2 w-2 rounded-full bg-[#7C5CCF] flex-shrink-0" />
              {sym}
            </li>
          ))}
        </ul>
      </Card>

      {/* REQ-CONT-001 카드뉴스 / REQ-CONT-002 음성 */}
      <div className="grid grid-cols-2 gap-3">
        <Button
          variant="outline"
          className="h-14 flex-col gap-1 text-xs"
          onClick={handleCardNews}
          disabled={cardNewsLoading || ttsLoading}
        >
          {cardNewsLoading ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Newspaper className="h-4 w-4" />
          )}
          {cardNewsLoading ? "생성 중..." : "카드뉴스로 보기"}
        </Button>
        <Button
          variant="outline"
          className="h-14 flex-col gap-1 text-xs"
          onClick={handleTTS}
          disabled={ttsLoading || cardNewsLoading}
        >
          {ttsLoading ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Volume2 className="h-4 w-4" />
          )}
          {ttsLoading ? "변환 중..." : "음성으로 듣기"}
        </Button>
      </div>
      {contentMessage && (
        <p className={`text-center text-xs px-1 ${contentMessage.ok ? "text-[#7C5CCF]" : "text-destructive"}`}>
          {contentMessage.text}
        </p>
      )}

      {/* PDF 저장 / 공유하기 */}
      <div className="grid grid-cols-2 gap-3">
        <Button variant="outline" className="gap-2" onClick={() => window.print()}>
          <Download className="h-4 w-4" />
          PDF 저장
        </Button>
        <Button variant="outline" className="gap-2" onClick={handleShare}>
          <Share2 className="h-4 w-4" />
          공유하기
        </Button>
      </div>
      {shareMessage && (
        <p className="text-center text-xs text-[#7C5CCF]">{shareMessage}</p>
      )}

      {/* REQ-FEED-001: 👍👎 피드백 */}
      <Card className="p-4">
        <h2 className="text-sm font-bold text-center mb-3">이 요약이 도움이 됐나요?</h2>
        <div className="flex justify-center gap-6">
          <button
            onClick={() => handleFeedback("up")}
            disabled={feedbackSent}
            className={`flex flex-col items-center gap-1.5 rounded-xl px-6 py-3 text-xs font-semibold transition-colors disabled:opacity-60 ${
              feedback === "up"
                ? "bg-[#EDE9FF] text-[#7C5CCF]"
                : "bg-gray-50 text-muted-foreground hover:bg-[#EDE9FF] hover:text-[#7C5CCF]"
            }`}
          >
            <ThumbsUp className="h-6 w-6" />
            도움됐어요
          </button>
          <button
            onClick={() => handleFeedback("down")}
            disabled={feedbackSent}
            className={`flex flex-col items-center gap-1.5 rounded-xl px-6 py-3 text-xs font-semibold transition-colors disabled:opacity-60 ${
              feedback === "down"
                ? "bg-red-50 text-red-500"
                : "bg-gray-50 text-muted-foreground hover:bg-red-50 hover:text-red-500"
            }`}
          >
            <ThumbsDown className="h-6 w-6" />
            아쉬워요
          </button>
        </div>
        {feedbackSent && (
          <p className="mt-3 text-center text-xs text-muted-foreground">피드백 감사합니다 :)</p>
        )}
      </Card>

      {guide.disclaimer && (
        <p className="px-1 text-xs leading-5 text-muted-foreground">{guide.disclaimer}</p>
      )}
    </main>
  );
}
