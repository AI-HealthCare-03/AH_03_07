from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `accessibility_settings` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `font_size` VARCHAR(20) NOT NULL COMMENT 'SMALL: SMALL\nMEDIUM: MEDIUM\nLARGE: LARGE\nXLARGE: XLARGE' DEFAULT 'MEDIUM',
    `tts_enabled` BOOL NOT NULL DEFAULT 0,
    `easy_language` BOOL NOT NULL DEFAULT 0,
    `guardian_share_enabled` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL UNIQUE,
    CONSTRAINT `fk_accessib_users_09246b14` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `accessibility_settings`;"""


MODELS_STATE = (
    "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"
    "P5+5U04="
)
