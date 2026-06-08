from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `medical_documents` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `document_type` VARCHAR(20) NOT NULL COMMENT 'prescription: prescription\nmedical_record: medical_record\npill_bag: pill_bag\nlab_result: lab_result\nhealth_checkup: health_checkup\nother: other',
    `file_path` VARCHAR(500) NOT NULL,
    `original_filename` VARCHAR(255) NOT NULL,
    `stored_filename` VARCHAR(100) NOT NULL,
    `file_size` INT,
    `mime_type` VARCHAR(100),
    `upload_status` VARCHAR(20) NOT NULL COMMENT 'uploaded: uploaded\nconfirmed: confirmed\ndeleted: deleted' DEFAULT 'uploaded',
    `is_user_confirmed` BOOL NOT NULL DEFAULT 0,
    `confirmed_data` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_medical__users_9d9be28d` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
        CREATE TABLE IF NOT EXISTS `ocr_jobs` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `status` VARCHAR(20) NOT NULL COMMENT 'pending: pending\nprocessing: processing\ncompleted: completed\nfailed: failed' DEFAULT 'pending',
    `raw_text` LONGTEXT,
    `structured_data` LONGTEXT,
    `confidence_score` DOUBLE,
    `field_confidences` LONGTEXT,
    `error_message` VARCHAR(500),
    `started_at` DATETIME(6),
    `completed_at` DATETIME(6),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `document_id` INT NOT NULL,
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_ocr_jobs_medical__2dba6c0e` FOREIGN KEY (`document_id`) REFERENCES `medical_documents` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_ocr_jobs_users_1ad1c7c0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
        ALTER TABLE `prescriptions` ADD `document_id` INT;
        ALTER TABLE `prescriptions` ADD `diagnosis_text` LONGTEXT;
        ALTER TABLE `prescriptions` ADD `image_s3_url` LONGTEXT NOT NULL;
        ALTER TABLE `prescriptions` ADD `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6);
        ALTER TABLE `prescriptions` ADD `prescription_date` DATE;
        ALTER TABLE `prescriptions` ADD `ocr_status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING';
        ALTER TABLE `prescriptions` ADD `user_confirmed` BOOL NOT NULL DEFAULT 0;
        ALTER TABLE `prescriptions` ADD `hospital_name` VARCHAR(100);
        ALTER TABLE `prescriptions` DROP COLUMN `image_url`;
        ALTER TABLE `prescriptions` ADD CONSTRAINT `fk_prescrip_medical__7df49791` FOREIGN KEY (`document_id`) REFERENCES `medical_documents` (`id`) ON DELETE SET NULL;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        ALTER TABLE `prescriptions` DROP FOREIGN KEY `fk_prescrip_medical__7df49791`;
        ALTER TABLE `prescriptions` ADD `image_url` VARCHAR(500);
        ALTER TABLE `prescriptions` DROP COLUMN `document_id`;
        ALTER TABLE `prescriptions` DROP COLUMN `diagnosis_text`;
        ALTER TABLE `prescriptions` DROP COLUMN `image_s3_url`;
        ALTER TABLE `prescriptions` DROP COLUMN `updated_at`;
        ALTER TABLE `prescriptions` DROP COLUMN `prescription_date`;
        ALTER TABLE `prescriptions` DROP COLUMN `ocr_status`;
        ALTER TABLE `prescriptions` DROP COLUMN `user_confirmed`;
        ALTER TABLE `prescriptions` DROP COLUMN `hospital_name`;
        DROP TABLE IF EXISTS `medical_documents`;
        DROP TABLE IF EXISTS `ocr_jobs`;"""


MODELS_STATE = (
    "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"
    "KGP25BQd2+BAloNMG//8fzmGliM="
)
