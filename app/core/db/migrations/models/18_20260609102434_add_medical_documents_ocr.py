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
        ALTER TABLE `health_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `audit_logs` MODIFY COLUMN `detail` JSON;
        ALTER TABLE `disease_activity_logs` MODIFY COLUMN `joint_swelling_areas` JSON;
        ALTER TABLE `symptom_check_logs` MODIFY COLUMN `checked_symptoms` JSON NOT NULL;
        ALTER TABLE `chat_messages` MODIFY COLUMN `rag_sources` JSON NOT NULL;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `feeling` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `body_parts` JSON;
        ALTER TABLE `emergency_cards` MODIFY COLUMN `emergency_contacts` JSON;
        ALTER TABLE `pharmacies` MODIFY COLUMN `operating_hours` JSON;
        ALTER TABLE `share_links` MODIFY COLUMN `categories` JSON NOT NULL;
        ALTER TABLE `prompts` MODIFY COLUMN `variables` JSON;
        ALTER TABLE `health_guide_contents` MODIFY COLUMN `metadata` JSON;
        ALTER TABLE `prescriptions` ADD `document_id` INT;
        ALTER TABLE `prescriptions` ADD `image_s3_url` LONGTEXT NOT NULL;
        ALTER TABLE `prescriptions` ADD `hospital_name` VARCHAR(100);
        ALTER TABLE `prescriptions` ADD `ocr_status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING';
        ALTER TABLE `prescriptions` ADD `prescription_date` DATE;
        ALTER TABLE `prescriptions` ADD `diagnosis_text` LONGTEXT;
        ALTER TABLE `prescriptions` ADD `user_confirmed` BOOL NOT NULL DEFAULT 0;
        ALTER TABLE `prescriptions` ADD `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6);
        ALTER TABLE `prescriptions` DROP COLUMN `image_url`;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `risk_factors` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `vaccination_history` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `prescriptions` ADD CONSTRAINT `fk_prescrip_medical__7df49791` FOREIGN KEY (`document_id`) REFERENCES `medical_documents` (`id`) ON DELETE SET NULL;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        ALTER TABLE `prescriptions` DROP FOREIGN KEY `fk_prescrip_medical__7df49791`;
        ALTER TABLE `prompts` MODIFY COLUMN `variables` JSON;
        ALTER TABLE `audit_logs` MODIFY COLUMN `detail` JSON;
        ALTER TABLE `pharmacies` MODIFY COLUMN `operating_hours` JSON;
        ALTER TABLE `auto_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `share_links` MODIFY COLUMN `categories` JSON NOT NULL;
        ALTER TABLE `chat_messages` MODIFY COLUMN `rag_sources` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `prescriptions` ADD `image_url` VARCHAR(500);
        ALTER TABLE `prescriptions` DROP COLUMN `document_id`;
        ALTER TABLE `prescriptions` DROP COLUMN `image_s3_url`;
        ALTER TABLE `prescriptions` DROP COLUMN `hospital_name`;
        ALTER TABLE `prescriptions` DROP COLUMN `ocr_status`;
        ALTER TABLE `prescriptions` DROP COLUMN `prescription_date`;
        ALTER TABLE `prescriptions` DROP COLUMN `diagnosis_text`;
        ALTER TABLE `prescriptions` DROP COLUMN `user_confirmed`;
        ALTER TABLE `prescriptions` DROP COLUMN `updated_at`;
        ALTER TABLE `emergency_cards` MODIFY COLUMN `emergency_contacts` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `feeling` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `body_parts` JSON;
        ALTER TABLE `symptom_check_logs` MODIFY COLUMN `checked_symptoms` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `risk_factors` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `vaccination_history` JSON NOT NULL;
        ALTER TABLE `disease_activity_logs` MODIFY COLUMN `joint_swelling_areas` JSON;
        ALTER TABLE `health_guide_contents` MODIFY COLUMN `metadata` JSON;
        DROP TABLE IF EXISTS `medical_documents`;
        DROP TABLE IF EXISTS `ocr_jobs`;"""


MODELS_STATE = (
    "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"
    "G3//Pxo1bHE="
)
