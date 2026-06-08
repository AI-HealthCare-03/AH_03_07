import asyncio
import json
from pathlib import Path

from tortoise import Tortoise

from app.core.db.databases import TORTOISE_ORM
from app.models.lab_reference import LabReference

DATA = Path(__file__).resolve().parent.parent / "app" / "data" / "lab_reference_master.json"


async def seed() -> None:
    await Tortoise.init(config=TORTOISE_ORM)
    items = json.loads(DATA.read_text(encoding="utf-8"))["items"]
    for it in items:
        await LabReference.update_or_create(
            code=it["code"],
            defaults={
                "name_ko": it["name_ko"],
                "abbr": it.get("abbr"),
                "category": it.get("category"),
                "description": it.get("description"),
                "unit": it.get("unit"),
                "reference_range_general": it.get("reference_range_general"),
                "reference_note": it.get("reference_note"),
                "source": it.get("source"),
            },
        )
    print("seeded lab_references:", await LabReference.all().count(), "rows")
    await Tortoise.close_connections()


if __name__ == "__main__":
    asyncio.run(seed())
