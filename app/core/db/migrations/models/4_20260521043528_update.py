from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `pharmacies` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(200) NOT NULL,
    `address` VARCHAR(500) NOT NULL,
    `phone` VARCHAR(20),
    `latitude` DECIMAL(10,7) NOT NULL,
    `longitude` DECIMAL(10,7) NOT NULL,
    `operating_hours` JSON,
    `is_24h_available` BOOL NOT NULL DEFAULT 0,
    `is_holiday_available` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `pharmacies`;"""


MODELS_STATE = (
    "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"
)
