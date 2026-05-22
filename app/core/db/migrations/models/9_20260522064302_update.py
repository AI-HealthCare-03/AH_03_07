from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `pill_recognitions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `image_url` VARCHAR(500) NOT NULL,
    `status` VARCHAR(30) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED\nLOW_CONFIDENCE: LOW_CONFIDENCE' DEFAULT 'PENDING',
    `top1_drug_name` VARCHAR(200),
    `top1_confidence` DOUBLE,
    `top2_drug_name` VARCHAR(200),
    `top2_confidence` DOUBLE,
    `top3_drug_name` VARCHAR(200),
    `top3_confidence` DOUBLE,
    `selected_drug_name` VARCHAR(200),
    `error_message` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_pill_rec_users_2e103417` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `pill_recognitions`;"""


MODELS_STATE = (
    "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"
    "NLlrVaovDn/wPvJnqw"
)
