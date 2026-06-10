"""RA·SLE 식이 정보 시드 데이터.

실행:
    DB_HOST=localhost uv run python -m app.core.db.seeds.diet_info_seed
"""

import asyncio
import sys

sys.path.insert(0, ".")

SEED_DATA = [
    # RA 추천
    {"disease_code": "RA", "category": "RECOMMEND", "food_name": "등푸른 생선 (고등어·연어)", "reason": "오메가-3 지방산이 염증성 사이토카인 생성을 억제하여 관절 통증과 부종 완화에 도움을 줍니다."},
    {"disease_code": "RA", "category": "RECOMMEND", "food_name": "올리브오일", "reason": "올레오칸탈 성분이 COX 효소를 억제해 항염 효과를 나타냅니다."},
    {"disease_code": "RA", "category": "RECOMMEND", "food_name": "브로콜리·케일 등 십자화채소", "reason": "설포라판과 비타민C가 산화 스트레스를 줄이고 관절 연골 보호에 기여합니다."},
    # RA 제한
    {"disease_code": "RA", "category": "AVOID", "food_name": "붉은 고기 (소·돼지 가공육)", "reason": "포화지방과 아라키돈산이 염증 매개물질(프로스타글란딘) 합성을 촉진해 증상을 악화시킬 수 있습니다."},
    {"disease_code": "RA", "category": "AVOID", "food_name": "설탕·정제 탄수화물", "reason": "혈당 급등 후 CRP 등 염증 지표가 상승하며 관절 부종을 유발할 수 있습니다."},
    {"disease_code": "RA", "category": "AVOID", "food_name": "알코올", "reason": "면역억제제(메토트렉세이트 등) 병용 시 간독성 위험이 높아지고 염증 반응을 악화시킵니다."},
    # SLE 추천
    {"disease_code": "SLE", "category": "RECOMMEND", "food_name": "연어·참치 (오메가-3 풍부)", "reason": "오메가-3가 면역 과활성을 억제하고 루푸스 활성도(SLEDAI) 감소에 기여한다는 연구 결과가 있습니다."},
    {"disease_code": "SLE", "category": "RECOMMEND", "food_name": "강황 (커큐민)", "reason": "커큐민이 NF-κB 경로를 억제해 항염 효과를 내며 루푸스 신염 보호에 도움이 될 수 있습니다."},
    {"disease_code": "SLE", "category": "RECOMMEND", "food_name": "비타민D 강화 식품 (두유·달걀노른자)", "reason": "루푸스 환자는 비타민D 결핍이 흔하며, 비타민D가 조절T세포를 활성화해 자가면역 반응을 완화합니다."},
    # SLE 제한
    {"disease_code": "SLE", "category": "AVOID", "food_name": "알팔파 새싹", "reason": "L-카나바닌 성분이 루푸스 면역 활성을 자극해 플레어(급격한 악화)를 유발할 수 있습니다."},
    {"disease_code": "SLE", "category": "AVOID", "food_name": "자외선 감작 식품 (셀러리·무화과)", "reason": "광과민성을 높이는 푸로쿠마린 성분이 포함되어 자외선 노출 시 피부 증상을 악화시킬 수 있습니다."},
    {"disease_code": "SLE", "category": "AVOID", "food_name": "고염식 (가공식품·인스턴트)", "reason": "나트륨 과다 섭취 시 고혈압 악화 및 루푸스 신염 진행 위험이 높아집니다."},
]


async def run() -> None:
    from tortoise import Tortoise

    from app.core.db.databases import TORTOISE_ORM
    from app.models.diet_info import DietInfo

    await Tortoise.init(config=TORTOISE_ORM)

    inserted = 0
    for data in SEED_DATA:
        _, created = await DietInfo.get_or_create(
            disease_code=data["disease_code"],
            category=data["category"],
            food_name=data["food_name"],
            defaults={"reason": data["reason"]},
        )
        if created:
            inserted += 1

    print(f"시드 완료: {inserted}건 삽입 (전체 {len(SEED_DATA)}건)")
    await Tortoise.close_connections()


if __name__ == "__main__":
    asyncio.run(run())
