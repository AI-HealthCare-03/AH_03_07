from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `feedback_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `target_type` VARCHAR(20) NOT NULL COMMENT 'GUIDE: GUIDE\nCHAT: CHAT\nOCR: OCR\nPILL: PILL',
    `target_id` CHAR(36) NOT NULL,
    `feedback_type` VARCHAR(20) NOT NULL COMMENT 'RATING: RATING\nTHUMBS_UP: THUMBS_UP\nTHUMBS_DOWN: THUMBS_DOWN\nREGENERATE: REGENERATE',
    `rating` INT,
    `comment` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_feedback_users_2eb526a4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `feedback_logs`;"""


MODELS_STATE = (
    "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"
    "cQ2jcb/+Dz89Q0Y="
)
