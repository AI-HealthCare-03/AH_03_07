"use client";

import Link from "next/link";
import { ArrowRight, Camera } from "lucide-react";
import HomeHeader from "./components/HomeHeader";
import MedicationCard from "./components/MedicationCard";
import SectionCard from "./components/SectionCard";
import type { MedicationStatus } from "@/features/dashboard/api";

interface GeneralHomeProps {
  name: string;
  medications: MedicationStatus[];
}

export default function GeneralHome({ name, medications }: GeneralHomeProps) {
  return (
    <main className="mx-auto w-full max-w-md px-5 pb-24 pt-10">
      <HomeHeader name={name} mode="general" />

      <div className="mt-10 flex flex-col gap-8">
        {/* 오늘 컨디션 */}
        <SectionCard title="오늘 컨디션" moreHref="/diary" moreLabel="기록하기">
          <p className="mt-2 text-sm text-muted-foreground">
            오늘 몸 상태를 일기로 기록해보세요.
          </p>
        </SectionCard>

        {/* 오늘 복용약 */}
        <MedicationCard medications={medications} />

        {/* 통합 캘린더 */}
        <SectionCard title="통합 캘린더" moreHref="/schedule" moreLabel="전체 보기">
          <p className="mt-2 text-sm text-muted-foreground">
            복약·일정을 한눈에 확인하세요.
          </p>
        </SectionCard>

        {/* 약품 카메라 빠른 진입 */}
        <Link href="/documents">
          <SectionCard>
            <div className="flex items-center gap-3">
              <Camera className="h-5 w-5 text-primary" />
              <span className="flex-1 text-sm font-medium">약품 카메라로 빠르게 등록</span>
              <ArrowRight className="h-4 w-4 text-primary" />
            </div>
          </SectionCard>
        </Link>
      </div>
    </main>
  );
}
