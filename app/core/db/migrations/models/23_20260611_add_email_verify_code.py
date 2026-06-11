from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `email_verify_codes` (
            `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
            `email` VARCHAR(255) NOT NULL UNIQUE,
            `code` VARCHAR(6) NOT NULL,
            `expires_at` DOUBLE NOT NULL
        ) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `email_verify_codes`;"""
