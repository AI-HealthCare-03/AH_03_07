from app.dtos.vaccinations import (
    PreventionTip,
    VaccinationInfoResponse,
    VaccineInfo,
    VaccineResource,
)

class VaccinationService:
    """백신·감염 예방 정보 (REQ-AUTO-PREV-001)"""

    def get_vaccination_info(self) -> VaccinationInfoResponse:
        """면역억제 치료 중인 자가면역 환자를 위한 백신 정보 안내"""
        return VaccinationInfoResponse(
            recommended_vaccines=[
                VaccineInfo(
                    name="독감 (인플루엔자)",
                    description="매년 가을·겨울철 접종 권장 (불활성화 백신)",
                    notice="접종 가능 여부는 담당 의료진과 상담하세요",
                ),
                VaccineInfo(
                    name="코로나19",
                    description="질병관리청 권장 일정에 따라 접종",
                    notice="접종 가능 여부는 담당 의료진과 상담하세요",
                ),
                VaccineInfo(
                    name="폐렴구균",
                    description="13가/23가 폐렴구균 백신 (불활성화 백신)",
                    notice="접종 가능 여부는 담당 의료진과 상담하세요",
                ),
                VaccineInfo(
                    name="대상포진",
                    description="재조합 대상포진 백신 (싱그릭스) 권장",
                    notice="생백신(조스타박스)은 면역억제제 복용자에게 권장되지 않습니다. 담당 의료진과 상담하세요",
                ),
            ],
            live_vaccine_notice=(
                "면역억제제(메토트렉세이트, 스테로이드, 생물학적 제제 등)를 복용 중인 경우, "
                "생백신(MMR, 수두, BCG, 황열, 경구용 장티푸스, 조스타박스 등) 접종은 권장되지 않을 수 있습니다. "
                "반드시 담당 의료진과 상담 후 결정하세요."
            ),
            prevention_tips=[
                PreventionTip(
                    title="손씻기",
                    description="외출 후, 식사 전, 화장실 사용 후 비누로 30초 이상 손씻기",
                ),
                PreventionTip(
                    title="마스크 착용",
                    description="사람이 많은 곳, 환절기, 호흡기 증상 시 마스크 착용 권장",
                ),
                PreventionTip(
                    title="감염자 접촉 주의",
                    description="감기, 독감 등 감염 환자와의 밀접 접촉 피하기",
                ),
                PreventionTip(
                    title="생식품 주의",
                    description="익히지 않은 음식, 생수 섭취 시 식중독·감염 위험 주의",
                ),
                PreventionTip(
                    title="규칙적인 생활",
                    description="충분한 수면, 균형 잡힌 식사, 적절한 운동으로 면역력 유지",
                ),
            ],
            external_resources=[
                VaccineResource(
                    name="질병관리청 예방접종도우미",
                    description="국가 예방접종 일정 및 백신 정보",
                    url="https://nip.kdca.go.kr",
                ),
                VaccineResource(
                    name="대한류마티스학회",
                    description="자가면역 환자 백신 가이드라인",
                    url="https://www.rheum.or.kr",
                ),
            ],
            disclaimer=(
                "본 정보는 일반적인 안내이며, 의학적 판단을 대체하지 않습니다. "
                "접종 가능 여부, 시기, 종류는 반드시 담당 의료진과 상담하여 결정하세요."
            ),
        )