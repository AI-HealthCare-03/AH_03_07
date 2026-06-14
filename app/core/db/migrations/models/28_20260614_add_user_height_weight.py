from tortoise import BaseDBAsyncClient


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        ALTER TABLE `users` ADD COLUMN `height` DOUBLE NULL;
        ALTER TABLE `users` ADD COLUMN `weight` DOUBLE NULL;
    """


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        ALTER TABLE `users` DROP COLUMN `height`;
        ALTER TABLE `users` DROP COLUMN `weight`;
    """
