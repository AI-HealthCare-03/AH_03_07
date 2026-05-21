from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `guardians` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `phone_number` VARCHAR(20),
    `email` VARCHAR(100),
    `relationship` VARCHAR(50),
    `is_active` BOOL NOT NULL DEFAULT 1,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_guardian_users_216ee0a6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
        CREATE TABLE IF NOT EXISTS `share_links` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `token` VARCHAR(100) NOT NULL UNIQUE,
    `duration` VARCHAR(30) NOT NULL COMMENT 'ONE_DAY: ONE_DAY\nONE_WEEK: ONE_WEEK\nONE_MONTH: ONE_MONTH\nUNTIL_REVOKED: UNTIL_REVOKED',
    `categories` JSON NOT NULL,
    `include_summary_only` BOOL NOT NULL DEFAULT 1,
    `expires_at` DATETIME(6) NOT NULL,
    `is_revoked` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `guardian_id` CHAR(36) NOT NULL,
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_share_li_guardian_5f30bd4f` FOREIGN KEY (`guardian_id`) REFERENCES `guardians` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_share_li_users_fa56d203` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
        CREATE TABLE IF NOT EXISTS `share_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `viewed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `viewer_ip` VARCHAR(50),
    `share_link_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_share_lo_share_li_41c3d41b` FOREIGN KEY (`share_link_id`) REFERENCES `share_links` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `share_logs`;
        DROP TABLE IF EXISTS `guardians`;
        DROP TABLE IF EXISTS `share_links`;"""


MODELS_STATE = (
    "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"
    "6og="
)
