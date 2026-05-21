from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `medical_appointments` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `appointment_date` DATETIME(6) NOT NULL,
    `hospital_name` VARCHAR(200) NOT NULL,
    `doctor_name` VARCHAR(100),
    `purpose` VARCHAR(200),
    `notes` LONGTEXT,
    `notification_enabled` BOOL NOT NULL DEFAULT 1,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_medical__users_64c49d52` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
        CREATE TABLE IF NOT EXISTS `favorite_places` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `place_type` VARCHAR(20) NOT NULL COMMENT 'HOSPITAL: HOSPITAL\nPHARMACY: PHARMACY',
    `name` VARCHAR(200) NOT NULL,
    `address` VARCHAR(500),
    `phone` VARCHAR(20),
    `memo` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_favorite_users_2bae7c72` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        DROP TABLE IF EXISTS `favorite_places`;
        DROP TABLE IF EXISTS `medical_appointments`;"""


MODELS_STATE = (
    "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"
    "vH/wH30r66"
)
