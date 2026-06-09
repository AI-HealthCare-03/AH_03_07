"use client";

import { useState, useRef } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { ArrowLeft, Camera, Pill, Search, X } from "lucide-react";
import { Card } from "@/components/ui/card";
import {
  recognizePill,
  searchDrugReferences,
  type PillCandidate,
  type DrugInfo,
} from "@/features/pills/api";
import { usePillRecognitions } from "@/features/pills/queries";

interface StaticCandidate {
  name: string;
  ingredient: string;
  category: string;
  confidence: number;
}

const CANDIDATES: StaticCandidate[] = [
  { name: "타이레놀 500mg", ingredient: "아세트아미노펜", category: "해열진통제", confidence: 98 },
  { name: "게보린", ingredient: "아세트아미노펜 복합", category: "진통제", confidence: 85 },
  { name: "펜잘큐", ingredient: "아세트아미노펜 복합", category: "진통제", confidence: 72 },
];

export default function PillsRecognizePage() {
  const router = useRouter();
  const [candidates, setCandidates] = useState<PillCandidate[]>([]);
  const [recognizing, setRecognizing] = useState(false);
  const [preview, setPreview] = useState<string | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const { data: history = [] } = usePillRecognitions();

  const [showSearch, setShowSearch] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [searchResults, setSearchResults] = useState<DrugInfo[]>([]);
  const [searching, setSearching] = useState(false);
  const [searchDone, setSearchDone] = useState(false);
  const searchInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    if (preview) URL.revokeObjectURL(preview);
    setPreview(URL.createObjectURL(file));
    setRecognizing(true);
    setCandidates([]);
    try {
      const result = await recognizePill(file);
      setCandidates(result);
    } catch {
      setCandidates([]);
    } finally {
      setRecognizing(false);
      e.target.value = "";
    }
  };

  const openSearch = () => {
    setShowSearch(true);
    setSearchQuery("");
    setSearchResults([]);
    setSearchDone(false);
    setTimeout(() => searchInputRef.current?.focus(), 50);
  };

  const closeSearch = () => {
    setShowSearch(false);
    setSearchQuery("");
    setSearchResults([]);
    setSearchDone(false);
  };

  const handleSearch = async () => {
    const q = searchQuery.trim();
    if (!q || searching) return;
    setSearching(true);
    setSearchDone(false);
    setSearchResults([]);
    try {
      const result = await searchDrugReferences(q);
      setSearchResults(result);
    } catch {
      setSearchResults([]);
    } finally {
      setSearching(false);
      setSearchDone(true);
    }
  };

  const recognized = candidates.length > 0;

  const displayCandidates: StaticCandidate[] = recognized
    ? candidates.map((c) => ({
        name: c.name ?? c.drug_name ?? "",
        ingredient: c.ingredient ?? "",
        category: c.category ?? "",
        confidence: c.confidence > 1 ? Math.round(c.confidence) : Math.round(c.confidence * 100),
      }))
    : [];

  return (
    <main className="mx-auto w-full max-w-md px-5 py-8">
      <h1 className="text-2xl font-bold">약품 카메라 인식</h1>

      {/* 숨김 파일 입력 */}
      <input
        ref={fileInputRef}
        type="file"
        accept="image/*"
        capture="environment"
        className="hidden"
        onChange={handleFileChange}
      />

      {/* 안내 배너 */}
      <div className="mt-5 flex items-center gap-3 rounded-2xl border border-primary/40 bg-secondary p-4">
        <Camera className="h-6 w-6 text-primary" />
        <div>
          <p className="font-bold">약품을 촬영해주세요</p>
          <p className="text-sm text-secondary-foreground">인식 후보 중 직접 선택하세요</p>
        </div>
      </div>

      {/* 카메라 프레임 */}
      <div className="mt-5 flex h-64 flex-col items-center justify-center rounded-2xl bg-[#2A2D34]">
        {preview ? (
          // eslint-disable-next-line @next/next/no-img-element
          <img src={preview} alt="미리보기" className="h-full w-full rounded-2xl object-cover" />
        ) : (
          <>
            <div className="flex h-28 w-44 items-center justify-center rounded-xl border-2 border-dashed border-white/40">
              <Pill className="h-12 w-12 text-white/50" />
            </div>
            <p className="mt-5 text-sm text-white/70">알약을 가이드 안에 맞춰주세요</p>
          </>
        )}
      </div>

      {/* 카메라 버튼 */}
      <div className="mt-4 flex justify-center gap-4">
        <button
          onClick={() => fileInputRef.current?.click()}
          disabled={recognizing}
          className="flex h-16 w-16 items-center justify-center rounded-full bg-primary text-primary-foreground shadow-lg shadow-primary/40 disabled:opacity-50"
          aria-label="촬영"
        >
          {recognizing ? (
            <span className="h-6 w-6 animate-spin rounded-full border-2 border-white border-t-transparent" />
          ) : (
            <Camera className="h-7 w-7" />
          )}
        </button>
        <button
          onClick={openSearch}
          className="flex h-16 w-16 items-center justify-center rounded-full border border-border bg-background text-muted-foreground shadow"
          aria-label="검색"
        >
          <Search className="h-6 w-6" />
        </button>
      </div>

      {/* 인식 결과 */}
      {recognized && (
        <>
          <p className="mt-7 text-sm font-semibold text-muted-foreground">인식 결과(후보)</p>
          <div className="mt-2 space-y-3">
            {displayCandidates.map((c) => {
              const high = c.confidence >= 90;
              return (
                <Card key={c.name} className="flex items-center gap-3 p-4">
                  <div className={"flex h-12 w-12 items-center justify-center rounded-xl " + (high ? "bg-secondary" : "bg-muted")}>
                    <Pill className={"h-6 w-6 " + (high ? "text-primary" : "text-muted-foreground")} />
                  </div>
                  <div className="flex-1">
                    <p className="font-bold">{c.name}</p>
                    <p className="text-sm text-muted-foreground">
                      {c.ingredient && `${c.ingredient} · `}{c.category}
                    </p>
                  </div>
                  <span
                    className={
                      "rounded-full px-2.5 py-1 text-xs font-bold " +
                      (high ? "bg-secondary text-primary" : "bg-amber-50 text-amber-700")
                    }
                  >
                    {c.confidence}%
                  </span>
                </Card>
              );
            })}
          </div>

          <button
            onClick={openSearch}
            className="mt-3 flex w-full items-center justify-center gap-2 rounded-2xl border border-border py-4 text-sm text-muted-foreground"
          >
            <Search className="h-4 w-4" /> 찾는 약품이 없어요 · 직접 검색
          </button>

          <p className="mt-4 text-center text-xs text-muted-foreground">
            AI 인식 결과는 참고용입니다<br />정확한 약품은 직접 확인 후 선택하세요
          </p>
        </>
      )}

      {/* 정적 후보 (API 미연동 상태 미리보기) */}
      {!recognized && !recognizing && (
        <>
          <p className="mt-7 text-sm font-semibold text-muted-foreground">인식 예시</p>
          <div className="mt-2 space-y-3 opacity-40">
            {CANDIDATES.map((c) => {
              const high = c.confidence >= 90;
              return (
                <Card key={c.name} className="flex items-center gap-3 p-4">
                  <div className={"flex h-12 w-12 items-center justify-center rounded-xl " + (high ? "bg-secondary" : "bg-muted")}>
                    <Pill className={"h-6 w-6 " + (high ? "text-primary" : "text-muted-foreground")} />
                  </div>
                  <div className="flex-1">
                    <p className="font-bold">{c.name}</p>
                    <p className="text-sm text-muted-foreground">{c.ingredient} · {c.category}</p>
                  </div>
                  <span
                    className={
                      "rounded-full px-2.5 py-1 text-xs font-bold " +
                      (high ? "bg-secondary text-primary" : "bg-amber-50 text-amber-700")
                    }
                  >
                    {c.confidence}%
                  </span>
                </Card>
              );
            })}
          </div>

          <div className="mt-6 text-center">
            <Link href="/pills/history" className="text-sm text-primary hover:underline">
              인식 내역 보기
            </Link>
          </div>
        </>
      )}

      {/* 검색 모달 */}
      {showSearch && (
        <div className="fixed inset-0 z-50 flex items-end bg-black/40" onClick={closeSearch}>
          <div
            className="w-full rounded-t-3xl bg-background p-6 pb-10"
            onClick={(e) => e.stopPropagation()}
          >
            <div className="mb-4 flex items-center justify-between">
              <p className="font-bold">약품 직접 검색</p>
              <button onClick={closeSearch} aria-label="닫기">
                <X className="h-5 w-5 text-muted-foreground" />
              </button>
            </div>
            <div className="flex gap-2">
              <input
                ref={searchInputRef}
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                onKeyDown={(e) => e.key === "Enter" && handleSearch()}
                placeholder="약품명 또는 성분 입력"
                className="flex-1 rounded-xl border border-border bg-muted px-4 py-3 text-sm outline-none focus:border-primary"
              />
              <button
                onClick={handleSearch}
                disabled={searching}
                className="rounded-xl bg-primary px-4 py-3 text-sm font-bold text-primary-foreground disabled:opacity-50"
              >
                검색
              </button>
            </div>
            {searching && (
              <p className="mt-4 text-center text-sm text-muted-foreground">검색 중...</p>
            )}
            {searchDone && searchResults.length === 0 && (
              <p className="mt-4 text-center text-sm text-muted-foreground">검색 결과가 없습니다</p>
            )}
            {searchResults.length > 0 && (
              <div className="mt-4 space-y-2">
                {searchResults.map((d, i) => (
                  <Card key={i} className="p-4">
                    <p className="font-bold">{d.name ?? d.drug_name}</p>
                    {d.ingredient && <p className="text-sm text-muted-foreground">{d.ingredient}</p>}
                  </Card>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </main>
  );
}
