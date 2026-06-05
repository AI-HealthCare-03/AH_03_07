"use client";

import { useState, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import {
  ArrowLeft, CalendarDays, ChevronLeft, ChevronRight,
  ChevronDown, FlaskConical, Plus, Syringe, Stethoscope, Trash2, X,
} from "lucide-react";
import { Card } from "@/components/ui/card";
import {
  getSchedules, createSchedule, updateSchedule, deleteSchedule,
  type CareSchedule,
} from "@/features/schedule/api";

const PURPLE = "#7C5CCF";

type EventType = "exam" | "injection" | "visit";
interface ScheduleEvent {
  id?: number;
  day: number;
  month: number;
  year: number;
  title: string;
  date: string;
  detail: string;
  type: EventType;
  badge: string;
  raw?: CareSchedule;
}

const MOCK_EVENTS: ScheduleEvent[] = [
  { day: 25, month: 5, year: 2026, title: "정기 혈액 검사", date: "2026.05.25 (월) · 오전 09:30", detail: "서울대병원 류마티스내과", type: "exam", badge: "검사" },
  { day: 2,  month: 6, year: 2026, title: "메토트렉세이트 주사", date: "2026.06.02 (화) · 매주 반복", detail: "자가 주사 · 알림 ON", type: "injection", badge: "주사" },
  { day: 8,  month: 6, year: 2026, title: "류마티스내과 진료", date: "2026.06.08 (월) · 오후 02:00", detail: "김의사 · 서울대병원", type: "visit", badge: "진료" },
];

const ICONS: Record<EventType, React.ElementType> = { exam: FlaskConical, injection: Syringe, visit: Stethoscope };
const BADGE_BG: Record<EventType, string> = { exam: "#EDE7FB", injection: "#FDE4E4", visit: "#E3F3E6" };
const ICON_COLOR: Record<EventType, string> = { exam: PURPLE, injection: "#E05555", visit: "#3A9B57" };
const TYPE_LABEL: Record<string, string> = { exam: "검사", injection: "주사", visit: "진료" };
const WEEKDAY = ["일", "월", "화", "수", "목", "금", "토"] as const;

function pad(n: number) { return String(n).padStart(2, "0"); }

function toScheduleEvent(s: CareSchedule): ScheduleEvent {
  const dt = new Date(s.scheduled_at);
  const type: EventType = ["exam", "injection", "visit"].includes(s.type) ? (s.type as EventType) : "exam";
  const dateStr = `${dt.getFullYear()}.${pad(dt.getMonth() + 1)}.${pad(dt.getDate())}`;
  const timeStr = dt.toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" });
  return {
    id: s.id,
    day: dt.getDate(),
    month: dt.getMonth() + 1,
    year: dt.getFullYear(),
    title: s.title,
    date: `${dateStr} · ${s.repeat_type ?? timeStr}`,
    detail: s.location ?? s.detail ?? "",
    type,
    badge: TYPE_LABEL[type] ?? "일정",
    raw: s,
  };
}

interface FormValues {
  title: string;
  scheduled_at: string;
  type: EventType;
  location: string;
  reminder_enabled: boolean;
}

const EMPTY_FORM: FormValues = {
  title: "", scheduled_at: "", type: "exam", location: "", reminder_enabled: false,
};

function toFormValues(s: CareSchedule): FormValues {
  const dt = new Date(s.scheduled_at);
  const localDT = `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())}T${pad(dt.getHours())}:${pad(dt.getMinutes())}`;
  return {
    title: s.title,
    scheduled_at: localDT,
    type: ["exam", "injection", "visit"].includes(s.type) ? (s.type as EventType) : "exam",
    location: s.location ?? "",
    reminder_enabled: s.reminder_enabled ?? false,
  };
}

export default function SchedulePage() {
  const router = useRouter();
  const now = new Date();

  const [month, setMonth] = useState({ year: now.getFullYear(), m: now.getMonth() + 1 });
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const [showPicker, setShowPicker] = useState(false);
  const [pickerYear, setPickerYear] = useState(now.getFullYear());
  const pickerRef = useRef<HTMLDivElement>(null);

  const [allEvents, setAllEvents] = useState<ScheduleEvent[]>([]);
  const [sheet, setSheet] = useState<{ open: boolean; mode: "add" | "edit"; raw?: CareSchedule }>({ open: false, mode: "add" });
  const [form, setForm] = useState<FormValues>(EMPTY_FORM);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");

  useEffect(() => {
    getSchedules()
      .then((data) => setAllEvents(data.map(toScheduleEvent)))
      .catch(() => setAllEvents(MOCK_EVENTS));
  }, []);

  // 피커 외부 클릭 시 닫기
  useEffect(() => {
    if (!showPicker) return;
    function onClickOutside(e: MouseEvent) {
      if (pickerRef.current && !pickerRef.current.contains(e.target as Node)) {
        setShowPicker(false);
      }
    }
    document.addEventListener("mousedown", onClickOutside);
    return () => document.removeEventListener("mousedown", onClickOutside);
  }, [showPicker]);

  const firstWeekday = new Date(month.year, month.m - 1, 1).getDay();
  const daysInMonth = new Date(month.year, month.m, 0).getDate();
  const isCurrentMonth = month.year === now.getFullYear() && month.m === now.getMonth() + 1;
  const todayDay = isCurrentMonth ? now.getDate() : -1;

  const monthEvents = allEvents.filter((e) => e.year === month.year && e.month === month.m);
  const eventDays = new Set(monthEvents.map((e) => e.day));
  const visibleEvents = selectedDay !== null
    ? monthEvents.filter((e) => e.day === selectedDay)
    : monthEvents;

  const cells: (number | null)[] = [
    ...Array(firstWeekday).fill(null),
    ...Array.from({ length: daysInMonth }, (_, i) => i + 1),
  ];

  function prevMonth() {
    setSelectedDay(null);
    setMonth((p) => p.m === 1 ? { year: p.year - 1, m: 12 } : { ...p, m: p.m - 1 });
  }
  function nextMonth() {
    setSelectedDay(null);
    setMonth((p) => p.m === 12 ? { year: p.year + 1, m: 1 } : { ...p, m: p.m + 1 });
  }
  function selectMonthFromPicker(m: number) {
    setSelectedDay(null);
    setMonth({ year: pickerYear, m });
    setShowPicker(false);
  }
  function openPickerToggle() {
    setPickerYear(month.year);
    setShowPicker((v) => !v);
  }
  function handleDayClick(day: number) {
    setSelectedDay((prev) => prev === day ? null : day);
  }

  function openAdd() {
    setError("");
    // 날짜 선택 상태면 해당 날짜로 pre-fill
    const preDate = selectedDay !== null
      ? `${month.year}-${pad(month.m)}-${pad(selectedDay)}T09:00`
      : "";
    setForm({ ...EMPTY_FORM, scheduled_at: preDate });
    setSheet({ open: true, mode: "add" });
  }
  function openEdit(e: ScheduleEvent) {
    setError("");
    setForm(e.raw ? toFormValues(e.raw) : { ...EMPTY_FORM, title: e.title, type: e.type, location: e.detail });
    setSheet({ open: true, mode: "edit", raw: e.raw });
  }
  function closeSheet() { setSheet({ open: false, mode: "add" }); }

  async function handleSave() {
    if (!form.title.trim() || !form.scheduled_at) { setError("제목과 날짜를 입력해주세요."); return; }
    setSaving(true); setError("");
    try {
      const payload = {
        title: form.title.trim(),
        scheduled_at: new Date(form.scheduled_at).toISOString(),
        type: form.type,
        ...(form.location && { location: form.location }),
        reminder_enabled: form.reminder_enabled,
      };
      if (sheet.mode === "add") {
        const created = await createSchedule(payload);
        setAllEvents((prev) => [...prev, toScheduleEvent(created)]);
      } else if (sheet.raw?.id) {
        const updated = await updateSchedule(sheet.raw.id, payload);
        setAllEvents((prev) => prev.map((e) => e.raw?.id === sheet.raw!.id ? toScheduleEvent(updated) : e));
      }
      closeSheet();
    } catch {
      setError("저장에 실패했습니다. 다시 시도해주세요.");
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete() {
    if (!sheet.raw?.id) return;
    setSaving(true);
    try {
      await deleteSchedule(sheet.raw.id);
      setAllEvents((prev) => prev.filter((e) => e.raw?.id !== sheet.raw!.id));
      closeSheet();
    } catch {
      setError("삭제에 실패했습니다.");
    } finally {
      setSaving(false);
    }
  }

  const sectionTitle = selectedDay !== null
    ? `${month.m}월 ${selectedDay}일 (${WEEKDAY[new Date(month.year, month.m - 1, selectedDay).getDay()]}) 일정`
    : `${month.year}년 ${month.m}월 일정`;

  return (
    <>
      <main className="mx-auto w-full max-w-md px-5 py-8">
        {/* 헤더 */}
        <div className="mb-5 flex items-center gap-3">
          <button
            onClick={() => router.push("/home")}
            className="flex h-9 w-9 items-center justify-center rounded-full hover:bg-muted"
            aria-label="뒤로가기"
          >
            <ArrowLeft className="h-5 w-5" />
          </button>
          <h1 className="text-2xl font-bold">검사·진료 일정</h1>
        </div>

        {/* 자가면역 배너 */}
        <div
          className="flex items-center gap-3 rounded-2xl border p-4"
          style={{ borderColor: PURPLE + "55", background: PURPLE + "12" }}
        >
          <CalendarDays className="h-6 w-6" style={{ color: PURPLE }} />
          <div>
            <p className="font-bold">자가면역 일정 통합 관리</p>
            <p className="text-sm" style={{ color: PURPLE }}>검사·진료·주사를 한 번에</p>
          </div>
        </div>

        {/* 캘린더 */}
        <Card className="relative mt-5 p-4">
          {/* 월 네비게이션 */}
          <div className="flex items-center justify-between">
            <button
              onClick={prevMonth}
              className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted"
              aria-label="이전 달"
            >
              <ChevronLeft className="h-5 w-5" />
            </button>

            {/* 년/월 클릭 → 드롭다운 */}
            <button
              onClick={openPickerToggle}
              className="flex items-center gap-1 rounded-lg px-2 py-1 font-bold hover:bg-muted"
            >
              {month.year}년 {month.m}월
              <ChevronDown
                className="h-4 w-4 transition-transform"
                style={{ transform: showPicker ? "rotate(180deg)" : "rotate(0deg)", color: PURPLE }}
              />
            </button>

            <button
              onClick={nextMonth}
              className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted"
              aria-label="다음 달"
            >
              <ChevronRight className="h-5 w-5" />
            </button>
          </div>

          {/* 연/월 피커 인라인 패널 */}
          {showPicker && (
            <div
              ref={pickerRef}
              className="absolute left-0 right-0 top-14 z-20 mx-4 rounded-2xl border bg-white p-4 shadow-lg"
            >
              {/* 연도 선택 */}
              <div className="mb-3 flex items-center justify-between">
                <button
                  onClick={() => setPickerYear((y) => y - 1)}
                  className="flex h-7 w-7 items-center justify-center rounded-full hover:bg-muted"
                >
                  <ChevronLeft className="h-4 w-4" />
                </button>
                <span className="font-bold">{pickerYear}년</span>
                <button
                  onClick={() => setPickerYear((y) => y + 1)}
                  className="flex h-7 w-7 items-center justify-center rounded-full hover:bg-muted"
                >
                  <ChevronRight className="h-4 w-4" />
                </button>
              </div>
              {/* 월 그리드 */}
              <div className="grid grid-cols-4 gap-2">
                {Array.from({ length: 12 }, (_, i) => i + 1).map((m) => {
                  const isSelected = pickerYear === month.year && m === month.m;
                  return (
                    <button
                      key={m}
                      onClick={() => selectMonthFromPicker(m)}
                      className="rounded-xl py-2 text-sm font-bold transition-colors"
                      style={
                        isSelected
                          ? { background: PURPLE, color: "#fff" }
                          : { color: "#333" }
                      }
                    >
                      {m}월
                    </button>
                  );
                })}
              </div>
            </div>
          )}

          {/* 요일 헤더 */}
          <div className="mt-4 grid grid-cols-7 text-center text-xs">
            {WEEKDAY.map((d, i) => (
              <span
                key={d}
                className={i === 0 ? "text-destructive" : i === 6 ? "text-blue-500" : "text-muted-foreground"}
              >
                {d}
              </span>
            ))}
          </div>

          {/* 날짜 셀 */}
          <div className="mt-2 grid grid-cols-7 gap-y-1 text-center text-sm">
            {cells.map((day, i) => {
              if (!day) return <div key={i} />;
              const isToday = day === todayDay;
              const isSelected = day === selectedDay;
              const hasEvent = eventDays.has(day);

              let spanStyle: React.CSSProperties = {};
              let spanClass = "flex h-8 w-8 items-center justify-center rounded-full cursor-pointer transition-colors ";

              if (isToday) {
                spanClass += "font-bold text-white";
                spanStyle = { background: PURPLE };
              } else if (isSelected) {
                spanClass += "font-bold";
                spanStyle = { background: PURPLE + "22", color: PURPLE, outline: `2px solid ${PURPLE}` };
              } else {
                spanClass += "hover:bg-muted/60";
              }

              return (
                <div
                  key={i}
                  className="flex flex-col items-center"
                  onClick={() => handleDayClick(day)}
                >
                  <span className={spanClass} style={spanStyle}>
                    {day}
                  </span>
                  {hasEvent && !isToday && (
                    <span
                      className="mt-0.5 h-1 w-1 rounded-full"
                      style={{ background: isSelected ? PURPLE : PURPLE + "99" }}
                    />
                  )}
                  {hasEvent && isToday && (
                    <span className="mt-0.5 h-1 w-1 rounded-full bg-white opacity-80" />
                  )}
                </div>
              );
            })}
          </div>
        </Card>

        {/* 일정 목록 */}
        <section className="mt-6">
          <div className="flex items-center justify-between">
            <h2 className="text-sm font-bold text-muted-foreground">{sectionTitle}</h2>
            {selectedDay !== null && (
              <button
                onClick={() => setSelectedDay(null)}
                className="text-xs text-muted-foreground underline underline-offset-2"
              >
                전체 보기
              </button>
            )}
          </div>

          <div className="mt-2 space-y-3">
            {visibleEvents.length === 0 && (
              <p className="py-6 text-center text-sm text-muted-foreground">
                {selectedDay !== null ? "이 날의 일정이 없습니다." : "이 달의 일정이 없습니다."}
              </p>
            )}
            {visibleEvents.map((e, i) => {
              const Icon = ICONS[e.type];
              return (
                <Card
                  key={e.id ?? i}
                  className="flex cursor-pointer items-center gap-3 p-4 transition-colors hover:bg-muted/40 active:bg-muted/60"
                  onClick={() => openEdit(e)}
                >
                  <div
                    className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl"
                    style={{ background: BADGE_BG[e.type] }}
                  >
                    <Icon className="h-6 w-6" style={{ color: ICON_COLOR[e.type] }} />
                  </div>
                  <div className="flex-1 overflow-hidden">
                    <p className="truncate font-bold">{e.title}</p>
                    <p className="truncate text-xs text-muted-foreground">{e.date}</p>
                    <p className="truncate text-xs text-muted-foreground">{e.detail}</p>
                  </div>
                  <span
                    className="shrink-0 rounded-md px-2 py-1 text-xs font-bold"
                    style={{ background: BADGE_BG[e.type], color: ICON_COLOR[e.type] }}
                  >
                    {e.badge}
                  </span>
                </Card>
              );
            })}
          </div>

          {/* 일정 추가 버튼 */}
          <button
            onClick={openAdd}
            className="mt-4 flex w-full items-center justify-center gap-2 rounded-2xl border-2 border-dashed py-4 text-sm font-bold transition-colors hover:bg-muted/40"
            style={{ borderColor: PURPLE + "66", color: PURPLE }}
          >
            <Plus className="h-5 w-5" />
            {selectedDay !== null ? `${month.m}월 ${selectedDay}일 일정 추가` : "일정 추가"}
          </button>
        </section>
      </main>

      {/* 바텀 시트 */}
      {sheet.open && (
        <div className="fixed inset-0 z-50 flex flex-col justify-end">
          <div className="absolute inset-0 bg-black/40" onClick={closeSheet} />
          <div className="relative mx-auto w-full max-w-md overflow-y-auto rounded-t-3xl bg-white px-5 pb-10 pt-5 shadow-xl" style={{ maxHeight: "90vh" }}>
            {/* 핸들 */}
            <div className="mx-auto mb-4 h-1 w-10 rounded-full bg-muted" />
            <div className="mb-5 flex items-center justify-between">
              <h2 className="text-lg font-bold">
                {sheet.mode === "add" ? "일정 추가" : "일정 수정"}
              </h2>
              <button
                onClick={closeSheet}
                className="flex h-8 w-8 items-center justify-center rounded-full hover:bg-muted"
                aria-label="닫기"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <div className="space-y-4">
              {/* 제목 */}
              <div>
                <label className="mb-1 block text-sm font-bold">제목 *</label>
                <input
                  type="text"
                  value={form.title}
                  onChange={(ev) => setForm((f) => ({ ...f, title: ev.target.value }))}
                  placeholder="일정 제목을 입력하세요"
                  className="w-full rounded-xl border bg-muted/30 px-4 py-3 text-sm outline-none focus:ring-2"
                />
              </div>

              {/* 날짜 및 시간 */}
              <div>
                <label className="mb-1 block text-sm font-bold">날짜 및 시간 *</label>
                <input
                  type="datetime-local"
                  value={form.scheduled_at}
                  onChange={(ev) => setForm((f) => ({ ...f, scheduled_at: ev.target.value }))}
                  className="w-full rounded-xl border bg-muted/30 px-4 py-3 text-sm outline-none"
                />
              </div>

              {/* 종류 */}
              <div>
                <label className="mb-1 block text-sm font-bold">종류</label>
                <div className="flex gap-2">
                  {(["exam", "injection", "visit"] as EventType[]).map((t) => (
                    <button
                      key={t}
                      onClick={() => setForm((f) => ({ ...f, type: t }))}
                      className="flex-1 rounded-xl py-2.5 text-sm font-bold transition-colors"
                      style={
                        form.type === t
                          ? { background: BADGE_BG[t], color: ICON_COLOR[t] }
                          : { background: "#f5f5f5", color: "#999" }
                      }
                    >
                      {TYPE_LABEL[t]}
                    </button>
                  ))}
                </div>
              </div>

              {/* 장소/메모 */}
              <div>
                <label className="mb-1 block text-sm font-bold">장소 / 메모</label>
                <input
                  type="text"
                  value={form.location}
                  onChange={(ev) => setForm((f) => ({ ...f, location: ev.target.value }))}
                  placeholder="병원명, 메모 등"
                  className="w-full rounded-xl border bg-muted/30 px-4 py-3 text-sm outline-none"
                />
              </div>

              {/* 알림 */}
              <div className="flex items-center justify-between rounded-xl border bg-muted/30 px-4 py-3">
                <span className="text-sm font-bold">알림 설정</span>
                <button
                  role="switch"
                  aria-checked={form.reminder_enabled}
                  onClick={() => setForm((f) => ({ ...f, reminder_enabled: !f.reminder_enabled }))}
                  className="relative h-6 w-11 rounded-full transition-colors"
                  style={{ background: form.reminder_enabled ? PURPLE : "#d1d5db" }}
                >
                  <span
                    className="absolute top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform"
                    style={{ transform: form.reminder_enabled ? "translateX(20px)" : "translateX(2px)" }}
                  />
                </button>
              </div>

              {error && <p className="text-sm text-destructive">{error}</p>}
            </div>

            {/* 액션 버튼 */}
            <div className="mt-6 flex gap-3">
              {sheet.mode === "edit" && sheet.raw?.id && (
                <button
                  onClick={handleDelete}
                  disabled={saving}
                  className="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl border text-destructive hover:bg-destructive/10 disabled:opacity-50"
                  aria-label="삭제"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              )}
              <button
                onClick={handleSave}
                disabled={saving}
                className="flex h-12 flex-1 items-center justify-center rounded-xl font-bold text-white disabled:opacity-50"
                style={{ background: PURPLE }}
              >
                {saving ? "저장 중…" : sheet.mode === "add" ? "추가하기" : "저장하기"}
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}
