import pytest
from app.dependencies.pdf_validator import (
    MAX_PDF_SIZE_BYTES,
    check_pdf_magic,
    check_pdf_size,
)


def test_check_pdf_magic_valid():
    assert check_pdf_magic(b"%PDF-1.4 some content") is True


def test_check_pdf_magic_invalid_zip():
    assert check_pdf_magic(b"PK\x03\x04") is False


def test_check_pdf_magic_empty():
    assert check_pdf_magic(b"") is False


def test_check_pdf_magic_short_content():
    assert check_pdf_magic(b"%PDF") is False  # 4바이트, magic은 5바이트


def test_check_pdf_size_at_limit():
    assert check_pdf_size(MAX_PDF_SIZE_BYTES) is True


def test_check_pdf_size_over_limit():
    assert check_pdf_size(MAX_PDF_SIZE_BYTES + 1) is False


def test_check_pdf_size_zero():
    assert check_pdf_size(0) is True
