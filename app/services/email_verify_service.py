"""REQ-USER-002 이메일 인증 서비스 — DB 기반 저장 (멀티워커/재시작 안전)"""

from __future__ import annotations

import asyncio
import logging
import random
import smtplib
import string
import time
from email.mime.text import MIMEText

from app.core import config
from app.core.config import Env
from app.models.email_verify_code import EmailVerifyCode

logger = logging.getLogger(__name__)

CODE_TTL = 300  # 5분
CODE_LEN = 6


def _generate_code() -> str:
    return "".join(random.choices(string.digits, k=CODE_LEN))


def _send_gmail_sync(to: str, code: str) -> None:
    msg = MIMEText(f"MediGuide 이메일 인증 코드: {code}\n\n유효시간: 5분", "plain", "utf-8")
    msg["Subject"] = f"[MediGuide] 이메일 인증 코드: {code}"
    msg["From"] = config.GMAIL_USER
    msg["To"] = to
    with smtplib.SMTP("smtp.gmail.com", 587) as smtp:
        smtp.starttls()
        smtp.login(config.GMAIL_USER, config.GMAIL_APP_PASSWORD)
        smtp.send_message(msg)


async def send_verification_code(email: str) -> str:
    """인증코드 생성·DB 저장·발송 (로컬: 콘솔 출력, 프로덕션: Gmail SMTP)"""
    code = _generate_code()
    expires_at = time.time() + CODE_TTL

    # 기존 코드 삭제 후 새 코드 저장 (upsert 대신 delete+create로 unique 보장)
    await EmailVerifyCode.filter(email=email).delete()
    await EmailVerifyCode.create(email=email, code=code, expires_at=expires_at)

    if config.ENV == Env.PROD and config.GMAIL_USER and config.GMAIL_APP_PASSWORD:
        try:
            await asyncio.to_thread(_send_gmail_sync, email, code)
            logger.info(f"Gmail 인증코드 발송 완료 → {email}")
        except Exception as e:
            logger.error(f"Gmail 발송 실패 ({e}) — 콘솔 폴백 | {email} → {code}")
    else:
        logger.warning(f"[DEV] 이메일 인증코드 | {email} → {code}")

    return code


async def confirm_code(email: str, code: str) -> bool:
    """인증코드 검증 — 일치 시 삭제 (1회용)"""
    entry = await EmailVerifyCode.filter(email=email).first()
    if not entry:
        return False
    if time.time() > entry.expires_at:
        await entry.delete()
        return False
    if entry.code != code:
        return False
    await entry.delete()
    return True


def generate_email_token(email: str) -> str:
    """검증 완료 후 회원가입용 단기 토큰 (단순 구현)"""
    import base64
    import time as _t

    raw = f"{email}:{int(_t.time()) + 600}"
    return base64.urlsafe_b64encode(raw.encode()).decode()


def verify_email_token(token: str, email: str) -> bool:
    """회원가입 시 email_token 검증"""
    try:
        import base64
        import time as _t

        raw = base64.urlsafe_b64decode(token.encode()).decode()
        token_email, expires = raw.rsplit(":", 1)
        return token_email == email and _t.time() < int(expires)
    except Exception:
        return False
