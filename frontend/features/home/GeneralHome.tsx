import { FileText, Stethoscope } from "lucide-react";
import HomeHeader from "./components/HomeHeader";
import MedicationCard, { type Medication } from "./components/MedicationCard";
import SectionCard from "./components/SectionCard";

interface GeneralHomeProps {
  name: string;
  medications: Medication[];
}

// TODO(데이터): OCR / 진료기록 / 가이드 — 담당 API 연결 전까지 placeholder.
const ocrJobs = [
  { id: "o1", fileName: "진료기록_2026-05.jpg", status: "OCR 텍스트 추출중...", progress: 0.7 },
];
const records = [
  { id: "r1", place: "서울대학교병원 내과", note: "위염", date: "05.20" },
  { id: "r2", place: "서울가정의학과의원", note: "상기도 감염", date: "05.10" },
  { id: "r3", place: "건강한약국", note: "처방전 확인", date: "04.25" },
];
const guides = [
  { id: "g1", title: "위염 복약 가이드", meta: "2026.05.20 · 최신" },
  { id: "g2", title: "감기 생활습관 안내", meta: "2026.05.15" },
  { id: "g3", title: "고혈압 관리 가이드", meta: "2026.05.10" },
];

export default function GeneralHome({ name, medications }: GeneralHomeProps) {
  return (
    <main className="mx-auto w-full max-w-md px-5 pb-24 pt-10">
      <HomeHeader name={name} mode="general" />

      <div className="mt-6">
        <MedicationCard medications={medications} />
      </div>

      {ocrJobs.length > 0 && (
        <>
          <h2 className="mb-3 mt-7 text-sm font-semibold text-muted-foreground">
            진행 중인 OCR 처리 작업
          </h2>
          <SectionCard>
            {ocrJobs.map((job) => (
              <div key={job.id} className="flex items-center gap-3">
                <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-amber-50">
                  <FileText className="h-6 w-6 text-amber-500" />
                </div>
                <div className="min-w-0 flex-1">
                  <p className="truncate text-sm font-medium text-foreground">{job.fileName}</p>
                  <p className="mb-2 text-xs text-muted-foreground">{job.status}</p>
                  <div className="h-1.5 w-full overflow-hidden rounded-full bg-muted">
                    <div
                      className="h-full rounded-full bg-amber-500"
                      style={{ width: `${job.progress * 100}%` }}
                    />
                  </div>
                </div>
              </div>
            ))}
          </SectionCard>
        </>
      )}

      <h2 className="mb-3 mt-7 text-sm font-semibold text-muted-foreground">최근 진료 기록</h2>
      <SectionCard moreHref="/records">
        <ul className="space-y-4">
          {records.map((r) => (
            <li key={r.id} className="flex items-center gap-3">
              <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-sky-50">
                <Stethoscope className="h-5 w-5 text-sky-500" />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[15px] font-medium text-foreground">{r.place}</p>
                <p className="text-sm text-muted-foreground">{r.note}</p>
              </div>
              <span className="shrink-0 text-xs text-muted-foreground">{r.date}</span>
            </li>
          ))}
        </ul>
      </SectionCard>

      <h2 className="mb-3 mt-7 text-sm font-semibold text-muted-foreground">최근 가이드</h2>
      <SectionCard moreHref="/guides">
        <ul className="space-y-4">
          {guides.map((g) => (
            <li key={g.id} className="flex items-center gap-3">
              <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10">
                <FileText className="h-5 w-5 text-primary" />
              </div>
              <div className="min-w-0 flex-1">
                <p className="text-[15px] font-medium text-foreground">{g.title}</p>
                <p className="text-sm text-muted-foreground">{g.meta}</p>
              </div>
            </li>
          ))}
        </ul>
      </SectionCard>
    </main>
  );
}