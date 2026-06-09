// 맞춤 안내문 서버 상태 (TanStack Query) — 데모 폴백 유지
import { useQuery } from "@tanstack/react-query";
import { getGuides, getGuide, getSources, getSections, type Guide } from "./api";
import { withTimeout } from "@/lib/query/util";

export const guideKeys = {
  all: ["guides"] as const,
  detail: (id: number) => ["guides", id] as const,
  sources: (id: number) => ["guides", id, "sources"] as const,
  sections: (id: number) => ["guides", id, "sections"] as const,
};

const DUMMY_LIST: Guide[] = [
  { id: 1, status: "완료", symptom_summary: "최근 관절 통증·아침 강직 30분 이상을 기록하셨습니다. 최근 변화를 다음 진료 시 의료진과 공유하세요.", created_at: "2026-05-20" },
  { id: 2, status: "완료", symptom_summary: "혈압 130/85, 가벼운 두통 동반. 저염식·규칙적 복약 안내 포함.", created_at: "2026-05-10" },
];

function dummyGuide(id: number): Guide {
  return {
    id,
    status: "완료",
    medication_general:
      "처방받은 약은 정해진 시간에 복용하세요.\n등록하신 복약 일정과 메모를 확인하시고, 복용 방법은 처방받은 대로 따르세요.\n복용을 잊었다면 임의로 조정하지 마시고 담당 의료진·약사와 상담하세요.",
    symptom_summary:
      "최근 관절 통증과 아침 강직이 30분 이상 지속되었습니다. 최근 변화를 다음 진료 시 의료진과 공유하세요.",
    lifestyle_info:
      "규칙적인 저강도 운동(걷기·수영)이 일반적으로 권장됩니다.\n충분한 수면과 수분 섭취, 금연도 일반적으로 권장됩니다.",
    side_effect_monitoring:
      "구내염, 메스꺼움, 발열, 심한 피로 등의 증상이 나타나면 임의로 약을 조정하지 마시고 담당 의료진과 상담하세요.\n혈액검사(간기능·혈구수 등) 항목·주기는 담당 의료진과 상담하세요.",
    disclaimer:
      "본 안내문은 일반 정보이며 진단·처방을 대체하지 않습니다. 증상 변화 시 담당 의료진과 상담하세요.",
  } as Guide;
}

export function useGuides() {
  return useQuery({
    queryKey: guideKeys.all,
    queryFn: async () => {
      try {
        const data = await withTimeout(getGuides());
        return data.length ? data : DUMMY_LIST;
      } catch {
        return DUMMY_LIST;
      }
    },
  });
}

export function useGuide(id: number) {
  return useQuery({
    queryKey: guideKeys.detail(id),
    queryFn: async () => {
      try {
        return await withTimeout(getGuide(id));
      } catch {
        return dummyGuide(id);
      }
    },
    enabled: Number.isFinite(id),
  });
}

export function useGuideSources(guideId: number) {
  return useQuery({
    queryKey: guideKeys.sources(guideId),
    queryFn: () => getSources(guideId),
    enabled: !!guideId,
  });
}

export function useGuideSections(guideId: number) {
  return useQuery({
    queryKey: guideKeys.sections(guideId),
    queryFn: () => getSections(guideId),
    enabled: !!guideId,
  });
}
