"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import { Search, Store, Clock, Phone, ArrowLeft, MapPin } from "lucide-react";
import { Card } from "@/components/ui/card";
import {
  getPharmacies,
  getNearbyPharmacies,
  Pharmacy,
} from "@/features/pharmacy/api";

const FALLBACK_PHARMACIES: Pharmacy[] = [
  {
    id: 1,
    name: "서울온누리약국",
    address: "관악구 봉천동 1530",
    phone: "02-000-0001",
    hours: "09:00-18:00",
  },
  {
    id: 2,
    name: "건강드림약국",
    address: "관악구 봉천동 977",
    phone: "02-000-0002",
    hours: "09:00-21:00",
  },
  {
    id: 3,
    name: "24시 열린약국",
    address: "관악구 신림동 1430",
    phone: "02-000-0003",
    hours: "24시간",
    is24h: true,
  },
  {
    id: 4,
    name: "행복한약국",
    address: "관악구 신림동 240",
    phone: "02-000-0004",
    hours: "10:00-19:00",
  },
  {
    id: 5,
    name: "야간두리약국",
    address: "관악구 봉천동 700",
    phone: "02-000-0005",
    hours: "10:00-23:00",
    isNight: true,
  },
];

function isOpenNow(hours?: string, is24h?: boolean): boolean {
  if (is24h) return true;
  if (!hours || hours === "24시간") return false;
  const now = new Date();
  const current = now.getHours() * 60 + now.getMinutes();
  const match = hours.match(/(\d{2}):(\d{2})-(\d{2}):(\d{2})/);
  if (!match) return false;
  const start = parseInt(match[1]) * 60 + parseInt(match[2]);
  const end = parseInt(match[3]) * 60 + parseInt(match[4]);
  return current >= start && current < end;
}

function withOpenStatus(list: Pharmacy[]): Pharmacy[] {
  return list.map((p) => ({ ...p, open: p.is24h ? true : isOpenNow(p.hours, p.is24h) }));
}

export default function PharmacyPage() {
  const router = useRouter();
  const [pharmacies, setPharmacies] = useState<Pharmacy[]>([]);
  const [loading, setLoading] = useState(true);
  const [searching, setSearching] = useState(false);
  const [query, setQuery] = useState("");
  const baseRef = useRef<Pharmacy[]>([]);

  useEffect(() => {
    async function loadAllPharmacies() {
      try {
        const data = await getPharmacies();
        const list = withOpenStatus(data);
        baseRef.current = list;
        setPharmacies(list);
      } catch {
        const list = withOpenStatus(FALLBACK_PHARMACIES);
        baseRef.current = list;
        setPharmacies(list);
      } finally {
        setLoading(false);
      }
    }

    const isHttp =
      typeof window !== "undefined" && window.location.protocol !== "https:";

    if (!navigator.geolocation || isHttp) {
      loadAllPharmacies();
      return;
    }

    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        try {
          const data = await getNearbyPharmacies(
            pos.coords.latitude,
            pos.coords.longitude
          );
          const list = withOpenStatus(data);
          baseRef.current = list;
          setPharmacies(list);
          setLoading(false);
        } catch {
          loadAllPharmacies();
        }
      },
      () => {
        loadAllPharmacies();
      }
    );
  }, []);

  useEffect(() => {
    if (!query.trim()) {
      setPharmacies(baseRef.current);
      return;
    }

    const timer = setTimeout(async () => {
      setSearching(true);
      try {
        const data = await getPharmacies({ keyword: query.trim() });
        setPharmacies(withOpenStatus(data));
      } catch {
        // 검색 실패 시 기존 목록 유지
      } finally {
        setSearching(false);
      }
    }, 300);

    return () => clearTimeout(timer);
  }, [query]);

  return (
    <main className="mx-auto w-full max-w-md px-5 py-8">
      {/* 헤더 */}
      <div className="flex items-center gap-3">
        <button
          onClick={() => router.push("/home")}
          className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted"
          aria-label="뒤로가기"
        >
          <ArrowLeft className="h-5 w-5" />
        </button>
        <h1 className="text-xl font-bold">약국 찾기</h1>
      </div>

      {/* 검색바 */}
      <div className="mt-5 flex items-center gap-2 rounded-full border border-border bg-card px-4 py-3">
        <Search className="h-4 w-4 text-muted-foreground" />
        <input
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="약국 이름·지역 검색"
          className="flex-1 bg-transparent text-sm outline-none"
        />
      </div>

      {/* 지도 placeholder */}
      <div className="mt-4 flex h-44 flex-col items-center justify-center rounded-2xl bg-muted">
        <MapPin className="h-6 w-6 text-blue-500" />
        <p className="mt-3 text-sm text-muted-foreground">현재 위치 기준 지도</p>
      </div>

      {/* 약국 목록 헤더 */}
      <div className="mt-6">
        <p className="font-bold">
          {query.trim() ? "검색 결과" : "내 주변 약국"}{" "}
          {!loading && !searching && (
            <span className="text-primary">{pharmacies.length}</span>
          )}
        </p>
      </div>

      {(loading || searching) && (
        <div className="mt-8 flex justify-center">
          <p className="text-sm text-muted-foreground">
            {loading ? "위치 정보를 불러오는 중…" : "검색 중…"}
          </p>
        </div>
      )}

      <div className="mt-3 space-y-3">
        {pharmacies.map((p) => (
          <a
            key={p.id}
            href={`https://map.kakao.com/?q=${encodeURIComponent(p.name)}`}
            target="_blank"
            rel="noopener noreferrer"
          >
            <Card className="flex items-start gap-3 p-4">
              {/* 아이콘 */}
              <div
                className={
                  "flex h-11 w-11 shrink-0 items-center justify-center rounded-xl " +
                  (p.open ? "bg-secondary" : "bg-muted")
                }
              >
                {p.is24h ? (
                  <Clock
                    className={
                      "h-6 w-6 " +
                      (p.open ? "text-primary" : "text-muted-foreground")
                    }
                  />
                ) : (
                  <Store
                    className={
                      "h-6 w-6 " +
                      (p.open ? "text-primary" : "text-muted-foreground")
                    }
                  />
                )}
              </div>

              {/* 정보 */}
              <div className="min-w-0 flex-1">
                {/* 약국명 + 뱃지 */}
                <div className="flex flex-wrap items-center gap-1.5">
                  <p className="font-bold">{p.name}</p>
                  <span
                    className={
                      "rounded-md px-1.5 py-0.5 text-[11px] font-semibold " +
                      (p.open
                        ? "bg-secondary text-primary"
                        : "bg-muted text-muted-foreground")
                    }
                  >
                    {p.open ? "영업중" : "영업종료"}
                  </span>
                  {p.is24h && (
                    <span className="rounded-md bg-blue-50 px-1.5 py-0.5 text-[11px] font-semibold text-blue-500">
                      24시
                    </span>
                  )}
                  {p.isNight && !p.is24h && (
                    <span className="rounded-md bg-indigo-50 px-1.5 py-0.5 text-[11px] font-semibold text-indigo-500">
                      야간
                    </span>
                  )}
                </div>

                {/* 주소 · 거리 */}
                <p className="mt-0.5 truncate text-xs text-muted-foreground">
                  {p.distance ? `${p.distance} · ` : ""}
                  {p.address}
                </p>

                {/* 운영시간 */}
                {p.hours && (
                  <p className="mt-0.5 flex items-center gap-1 text-xs text-muted-foreground">
                    <Clock className="h-3 w-3" />
                    {p.hours}
                  </p>
                )}

                {/* 전화번호 */}
                {p.phone && (
                  <p className="mt-0.5 flex items-center gap-1 text-xs text-muted-foreground">
                    <Phone className="h-3 w-3" />
                    {p.phone}
                  </p>
                )}
              </div>
            </Card>
          </a>
        ))}

        {!loading && !searching && pharmacies.length === 0 && (
          <p className="mt-6 text-center text-sm text-muted-foreground">
            검색 결과가 없습니다.
          </p>
        )}
      </div>
    </main>
  );
}
