from pydantic import BaseModel

class DrugInfo(BaseModel):
    """식약처 의약품 정보"""
    item_name: str  # 제품명
    entp_name: str | None = None  # 업체명
    item_seq: str | None = None  # 품목기준코드
    efcy_qesitm: str | None = None  # 효능·효과
    use_method_qesitm: str | None = None  # 용법·용량
    atpn_warn_qesitm: str | None = None  # 경고사항
    atpn_qesitm: str | None = None  # 주의사항
    intrc_qesitm: str | None = None  # 상호작용
    se_qesitm: str | None = None  # 부작용
    deposit_method_qesitm: str | None = None  # 보관법
    item_image: str | None = None  # 의약품 이미지 URL


class DrugSearchResponse(BaseModel):
    """약품 검색 응답"""
    query: str  # 검색어
    total_count: int  # 전체 검색 결과 수
    drugs: list[DrugInfo]  # 약품 목록
    notice: str = "본 정보는 식품의약품안전처 의약품안전나라 자료입니다. 정확한 약품 정보 및 복용은 의료진·약사와 상담하세요."