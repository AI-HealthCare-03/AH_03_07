from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
        CREATE TABLE IF NOT EXISTS `aerich` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `version` VARCHAR(255) NOT NULL,
    `app` VARCHAR(100) NOT NULL,
    `content` JSON NOT NULL
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `email` VARCHAR(40) NOT NULL,
    `hashed_password` VARCHAR(128) NOT NULL,
    `name` VARCHAR(20) NOT NULL,
    `gender` VARCHAR(6) NOT NULL COMMENT 'MALE: MALE\nFEMALE: FEMALE',
    `birthday` DATE NOT NULL,
    `phone_number` VARCHAR(11) NOT NULL,
    `height` DOUBLE,
    `weight` DOUBLE,
    `mode` VARCHAR(16) NOT NULL COMMENT 'GENERAL: general\nAUTOIMMUNE: autoimmune' DEFAULT 'general',
    `mode_selected_at` DATETIME(6),
    `is_active` BOOL NOT NULL DEFAULT 1,
    `is_admin` BOOL NOT NULL DEFAULT 0,
    `last_login` DATETIME(6),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `knowledge_base` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(200) NOT NULL,
    `filename` VARCHAR(255) NOT NULL,
    `file_path` VARCHAR(500) NOT NULL,
    `status` VARCHAR(10) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nDONE: DONE\nFAILED: FAILED' DEFAULT 'PENDING',
    `chunk_count` INT,
    `source_organization` VARCHAR(100) NOT NULL,
    `published_year` SMALLINT NOT NULL,
    `error_message` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `uploaded_by_user_id` BIGINT NOT NULL,
    UNIQUE KEY `uid_knowledge_b_title_ab92ff` (`title`, `source_organization`, `published_year`),
    CONSTRAINT `fk_knowledg_users_de6f71a5` FOREIGN KEY (`uploaded_by_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    KEY `idx_knowledge_b_status_3e2bc0` (`status`),
    KEY `idx_knowledge_b_uploade_65f25d` (`uploaded_by_user_id`),
    KEY `idx_knowledge_b_created_82eded` (`created_at`)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `health_guides` (
    `id` INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `status` VARCHAR(30) NOT NULL,
    `medication_general` LONGTEXT NOT NULL,
    `side_effect_monitoring` JSON NOT NULL,
    `lifestyle_info` LONGTEXT NOT NULL,
    `symptom_summary` LONGTEXT NOT NULL,
    `sources` JSON NOT NULL,
    `disclaimer` LONGTEXT NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `user_diseases` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `disease_code` VARCHAR(20) NOT NULL COMMENT 'RA: RA\nSLE: SLE\nDM1: DM1\nDM2: DM2\nHTN: HTN\nHYPERLIPIDEMIA: HYPERLIPIDEMIA\nASTHMA: ASTHMA\nCOPD: COPD\nPARKINSON: PARKINSON\nMS: MS\nBREAST_CANCER: BREAST_CANCER\nCOLON_CANCER: COLON_CANCER\nLUNG_CANCER: LUNG_CANCER',
    `diagnosed_date` DATE,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_user_dis_users_d457ee90` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-DISE-001/002 — 자가면역 모드 사용자의 등록 질환.';
CREATE TABLE IF NOT EXISTS `audit_logs` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `action` VARCHAR(64) NOT NULL,
    `detail` JSON,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_audit_lo_users_4188f9a7` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='NFR-COMPLI-004 — 민감정보 처리 감사 로그 (append-only).';
CREATE TABLE IF NOT EXISTS `user_risk_profiles` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `pregnancy_status` VARCHAR(16) NOT NULL COMMENT 'NONE: NONE\nPREGNANT: PREGNANT\nBREASTFEEDING: BREASTFEEDING\nPLANNING: PLANNING' DEFAULT 'NONE',
    `renal_impairment` BOOL NOT NULL DEFAULT 0,
    `hepatic_impairment` BOOL NOT NULL DEFAULT 0,
    `infection_history` LONGTEXT,
    `drug_allergy` LONGTEXT,
    `comorbidities` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_user_ris_users_911480e2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-AUTO-001 — 자가면역 안내문 생성용 위험요인 프로필 (사용자당 1개).';
CREATE TABLE IF NOT EXISTS `user_medications` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(128) NOT NULL,
    `drug_class` VARCHAR(24) NOT NULL COMMENT 'STEROID: STEROID\nIMMUNOSUPPRESSANT: IMMUNOSUPPRESSANT\nANTIMALARIAL: ANTIMALARIAL\nBIOLOGIC: BIOLOGIC\nNSAID: NSAID',
    `is_injection` BOOL NOT NULL DEFAULT 0,
    `end_date` DATE,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_user_med_users_e877c4e6` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-AUTO-002 — 사용자가 등록한 자가면역 관련 약물.';
CREATE TABLE IF NOT EXISTS `disease_activity_logs` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `log_date` DATE NOT NULL,
    `pain_vas` INT NOT NULL,
    `fatigue` INT NOT NULL,
    `morning_stiffness_min` INT,
    `joint_swelling_areas` JSON,
    `daily_difficulty` INT NOT NULL,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    UNIQUE KEY `uid_disease_act_user_id_21c8d9` (`user_id`, `log_date`),
    CONSTRAINT `fk_disease__users_54d06ecb` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-ACTV-001 — 자가면역질환 공통 활성도 정량 일일 기록 (사용자·일자당 1건).';
CREATE TABLE IF NOT EXISTS `symptom_check_logs` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `checked_symptoms` JSON NOT NULL,
    `red_flag_triggered` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_symptom__users_bf034718` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-SYMP-001 — 위험 증상 자가체크 기록. red_flag_triggered는 SYMP-002 룰 매칭 결과.';
CREATE TABLE IF NOT EXISTS `activity_alert_settings` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `pain_threshold` INT,
    `pain_consecutive_days` INT,
    `morning_stiffness_threshold` INT,
    `fatigue_threshold` INT,
    `alert_message` LONGTEXT NOT NULL,
    `is_enabled` BOOL NOT NULL DEFAULT 1,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_activity_users_891c1cc4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-ACTV-003 — 사용자가 직접 설정한 활성도 자가 모니터링 알림 기준 (사용자당 1개).';
CREATE TABLE IF NOT EXISTS `medical_schedules` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `schedule_type` VARCHAR(16) NOT NULL COMMENT 'BLOOD_TEST: BLOOD_TEST\nURINE_TEST: URINE_TEST\nEYE_EXAM: EYE_EXAM\nAPPOINTMENT: APPOINTMENT\nINJECTION: INJECTION',
    `title` VARCHAR(200),
    `scheduled_date` DATE NOT NULL,
    `reminder_days_before` INT NOT NULL DEFAULT 1,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_medical__users_8614df87` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-AUTO-004 — 자가면역 관리 의료 일정 (검사·진료·주사).';
CREATE TABLE IF NOT EXISTS `lab_references` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `code` VARCHAR(64) NOT NULL UNIQUE,
    `name_ko` VARCHAR(128) NOT NULL,
    `abbr` VARCHAR(64),
    `category` VARCHAR(64),
    `description` VARCHAR(255),
    `unit` VARCHAR(32),
    `reference_range_general` VARCHAR(255),
    `reference_note` VARCHAR(255),
    `source` VARCHAR(255),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `lab_results` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `test_date` DATE NOT NULL,
    `test_item` VARCHAR(128) NOT NULL,
    `value` VARCHAR(64) NOT NULL,
    `reference_range` VARCHAR(64),
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_lab_resu_users_6c32f6c9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-LAB-001 — 사용자가 직접 입력한 검사 결과 (수동 입력·보관).';
CREATE TABLE IF NOT EXISTS `lupus_skin_logs` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `symptom_type` VARCHAR(16) NOT NULL COMMENT 'RASH: RASH\nORAL_ULCER: ORAL_ULCER\nHAIR_LOSS: HAIR_LOSS\nRAYNAUD: RAYNAUD',
    `log_date` DATE NOT NULL,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_lupus_sk_users_b213a5b4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-LUPUS-001 — SLE 특이 피부 증상 기록 (순수 저장, 해석 없음).';
CREATE TABLE IF NOT EXISTS `lupus_daily_contexts` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `log_date` DATE NOT NULL,
    `uv_exposure_minutes` INT,
    `sleep_hours` DOUBLE,
    `stress_level` VARCHAR(8) COMMENT 'LOW: LOW\nMID: MID\nHIGH: HIGH',
    `med_taken` BOOL,
    `note` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    UNIQUE KEY `uid_lupus_daily_user_id_c17419` (`user_id`, `log_date`),
    CONSTRAINT `fk_lupus_da_users_66615162` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-LUPUS-001 — SLE 환자 생활 맥락 일일 기록 (순수 저장, 해석·판정 없음). 사용자·일자당 1건.';
CREATE TABLE IF NOT EXISTS `chat_sessions` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `mode` VARCHAR(16) NOT NULL COMMENT 'GENERAL: GENERAL\nAUTOIMMUNE: AUTOIMMUNE',
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_chat_ses_users_520002c0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `chat_messages` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `role` VARCHAR(16) NOT NULL COMMENT 'USER: USER\nASSISTANT: ASSISTANT',
    `content` LONGTEXT NOT NULL,
    `rag_sources` JSON NOT NULL,
    `blocked_by_filter` BOOL NOT NULL DEFAULT 0,
    `block_reason` VARCHAR(64),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `session_id` BIGINT NOT NULL,
    CONSTRAINT `fk_chat_mes_chat_ses_0d4a2737` FOREIGN KEY (`session_id`) REFERENCES `chat_sessions` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `chat_feedbacks` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `score` INT NOT NULL,
    `comment` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `message_id` BIGINT NOT NULL,
    CONSTRAINT `fk_chat_fee_chat_mes_a116c643` FOREIGN KEY (`message_id`) REFERENCES `chat_messages` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `user_consents` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `consent_type` VARCHAR(50) NOT NULL COMMENT 'TERMS_OF_SERVICE: TERMS_OF_SERVICE\nPRIVACY_POLICY: PRIVACY_POLICY\nMEDICAL_DATA: MEDICAL_DATA\nMARKETING: MARKETING\nMODEL_IMPROVEMENT: MODEL_IMPROVEMENT',
    `agreed` BOOL NOT NULL,
    `version` VARCHAR(20) NOT NULL,
    `agreed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `withdrawn_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_user_con_users_4a5cdd72` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `accessibility_settings` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `font_size` VARCHAR(20) NOT NULL COMMENT 'SMALL: SMALL\nMEDIUM: MEDIUM\nLARGE: LARGE\nXLARGE: XLARGE' DEFAULT 'MEDIUM',
    `tts_enabled` BOOL NOT NULL DEFAULT 0,
    `easy_language` BOOL NOT NULL DEFAULT 0,
    `guardian_share_enabled` BOOL NOT NULL DEFAULT 0,
    `location_tracking_enabled` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_accessib_users_09246b14` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `diary_medication_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `log_date` DATE NOT NULL,
    `drug_name` VARCHAR(200) NOT NULL,
    `time_slot` VARCHAR(20) COMMENT 'MORNING: MORNING\nLUNCH: LUNCH\nDINNER: DINNER\nBEDTIME: BEDTIME',
    `taken` BOOL NOT NULL DEFAULT 1,
    `taken_time` DATETIME(6),
    `notes` LONGTEXT,
    `latitude` DECIMAL(10,4),
    `longitude` DECIMAL(10,4),
    `location_recorded_at` DATETIME(6),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_diary_me_users_bc0b4b94` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `diary_symptom_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `log_date` DATE NOT NULL,
    `overall_condition` VARCHAR(20) NOT NULL COMMENT 'VERY_BAD: VERY_BAD\nBAD: BAD\nNORMAL: NORMAL\nGOOD: GOOD\nVERY_GOOD: VERY_GOOD',
    `body_parts` JSON,
    `feeling` JSON,
    `memo` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_diary_sy_users_2491f500` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `emergency_cards` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `blood_type` VARCHAR(10),
    `allergies` LONGTEXT,
    `chronic_conditions` LONGTEXT,
    `emergency_contacts` JSON,
    `siren_mode` VARCHAR(20) NOT NULL COMMENT 'NORMAL: NORMAL\nSILENT: SILENT\nOFF: OFF' DEFAULT 'NORMAL',
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_emergenc_users_72a898e0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `health_metrics` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `metric_type` VARCHAR(30) NOT NULL COMMENT 'BLOOD_PRESSURE: BLOOD_PRESSURE\nBLOOD_SUGAR: BLOOD_SUGAR\nWEIGHT: WEIGHT\nHEART_RATE: HEART_RATE',
    `user_recorded_value` DECIMAL(10,2) NOT NULL,
    `measured_at` DATETIME(6) NOT NULL,
    `notes` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_health_m_users_769d851c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `feedback_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `target_type` VARCHAR(20) NOT NULL COMMENT 'GUIDE: GUIDE\nCHAT: CHAT\nOCR: OCR\nPILL: PILL',
    `target_id` CHAR(36) NOT NULL,
    `feedback_type` VARCHAR(20) NOT NULL COMMENT 'RATING: RATING\nTHUMBS_UP: THUMBS_UP\nTHUMBS_DOWN: THUMBS_DOWN\nREGENERATE: REGENERATE',
    `rating` INT,
    `comment` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_feedback_users_2eb526a4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `notification_type` VARCHAR(30) NOT NULL COMMENT 'MEDICATION: MEDICATION\nDIARY: DIARY\nHEALTH_METRIC: HEALTH_METRIC\nEMERGENCY: EMERGENCY\nGUIDE: GUIDE\nSCHEDULE: SCHEDULE',
    `title` VARCHAR(200) NOT NULL,
    `content` LONGTEXT NOT NULL,
    `is_read` BOOL NOT NULL DEFAULT 0,
    `scheduled_at` DATETIME(6) NOT NULL,
    `sent_at` DATETIME(6),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_notifica_users_ca29871f` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `notification_settings` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `medication_enabled` BOOL NOT NULL DEFAULT 1,
    `diary_enabled` BOOL NOT NULL DEFAULT 1,
    `health_metric_enabled` BOOL NOT NULL DEFAULT 1,
    `emergency_enabled` BOOL NOT NULL DEFAULT 1,
    `quiet_hours_start` TIME(6),
    `quiet_hours_end` TIME(6),
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_notifica_users_ea1f99f3` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
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
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `favorite_places` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `place_type` VARCHAR(20) NOT NULL COMMENT 'HOSPITAL: HOSPITAL\nPHARMACY: PHARMACY',
    `name` VARCHAR(200) NOT NULL,
    `address` VARCHAR(500),
    `phone` VARCHAR(20),
    `memo` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_favorite_users_2bae7c72` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
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
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_medical__users_64c49d52` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
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
CREATE TABLE IF NOT EXISTS `guardians` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `phone_number` VARCHAR(20),
    `email` VARCHAR(100),
    `relationship` VARCHAR(50),
    `is_active` BOOL NOT NULL DEFAULT 1,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
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
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_share_li_guardian_5f30bd4f` FOREIGN KEY (`guardian_id`) REFERENCES `guardians` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_share_li_users_fa56d203` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `share_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `viewed_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `viewer_ip` VARCHAR(50),
    `share_link_id` CHAR(36) NOT NULL,
    CONSTRAINT `fk_share_lo_share_li_41c3d41b` FOREIGN KEY (`share_link_id`) REFERENCES `share_links` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `prompts` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `prompt_type` VARCHAR(50) NOT NULL COMMENT 'HEALTH_GUIDE: HEALTH_GUIDE\nOCR_EXTRACT: OCR_EXTRACT\nOCR_STRUCTURE: OCR_STRUCTURE\nMEDICATION_INFO: MEDICATION_INFO',
    `name` VARCHAR(200) NOT NULL,
    `version` VARCHAR(20) NOT NULL DEFAULT 'v1.0',
    `template_text` LONGTEXT NOT NULL,
    `variables` JSON,
    `is_active` BOOL NOT NULL DEFAULT 1,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    UNIQUE KEY `uid_prompts_prompt__d4c8d3` (`prompt_type`, `version`)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `health_guide_contents` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `guide_type` VARCHAR(50) NOT NULL COMMENT 'EXERCISE: EXERCISE\nDIET: DIET\nLIFESTYLE: LIFESTYLE\nMEDICATION: MEDICATION\nGENERAL: GENERAL',
    `status` VARCHAR(30) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING',
    `user_question` LONGTEXT NOT NULL,
    `guide_content` LONGTEXT,
    `prompt_used_id` CHAR(36),
    `metadata` JSON,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_health_g_users_a1cb2840` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `prescriptions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `image_s3_url` LONGTEXT NOT NULL,
    `ocr_raw_text` LONGTEXT,
    `ocr_status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING',
    `user_confirmed` BOOL NOT NULL DEFAULT 0,
    `prescription_date` DATE,
    `hospital_name` VARCHAR(100),
    `diagnosis_text` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `document_id` INT,
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_prescrip_medical__7df49791` FOREIGN KEY (`document_id`) REFERENCES `medical_documents` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_prescrip_users_75d98828` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `medications` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `drug_name_user_input` VARCHAR(200) NOT NULL,
    `dosage` VARCHAR(50),
    `frequency` VARCHAR(50),
    `duration_days` INT,
    `start_date` DATE,
    `end_date` DATE,
    `is_autoimmune_drug` BOOL NOT NULL DEFAULT 0,
    `drug_category` VARCHAR(50),
    `notes` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `prescription_id` CHAR(36),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_medicati_prescrip_1f35ac11` FOREIGN KEY (`prescription_id`) REFERENCES `prescriptions` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_medicati_users_5f6773a0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `risk_flags` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `source_type` VARCHAR(16) NOT NULL COMMENT 'SYMPTOM_CHECK: SYMPTOM_CHECK\nRISK_PROFILE: RISK_PROFILE\nLAB_RESULT: LAB_RESULT',
    `source_id` BIGINT,
    `flag_code` VARCHAR(64) NOT NULL,
    `flag_label` VARCHAR(128) NOT NULL,
    `category` VARCHAR(32) NOT NULL,
    `message` LONGTEXT NOT NULL,
    `red_flag` BOOL NOT NULL DEFAULT 0,
    `consultation_recommended` BOOL NOT NULL DEFAULT 1,
    `status` VARCHAR(16) NOT NULL COMMENT 'ACTIVE: ACTIVE\nRESOLVED: RESOLVED\nDISMISSED: DISMISSED' DEFAULT 'ACTIVE',
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_risk_fla_users_95269dc4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-AUTO-006 — 고위험 플래그 저장소. 게이트 엔진 매칭 결과를 DB에 영속.';
CREATE TABLE IF NOT EXISTS `autoimmune_profiles` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `risk_factors` JSON NOT NULL,
    `pregnancy_status` VARCHAR(16) NOT NULL COMMENT 'NONE: none\nPREGNANT: pregnant\nBREASTFEEDING: breastfeeding\nPLANNING: planning' DEFAULT 'none',
    `vaccination_history` JSON NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL UNIQUE,
    CONSTRAINT `fk_autoimmu_users_83724aa4` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `auto_guides` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `status` VARCHAR(24) NOT NULL COMMENT 'GENERATED: GENERATED\nBLOCKED_HIGH_RISK: BLOCKED_HIGH_RISK\nGENERATION_FAILED: GENERATION_FAILED',
    `medication_general` LONGTEXT NOT NULL,
    `side_effect_monitoring` JSON NOT NULL,
    `lifestyle_info` LONGTEXT NOT NULL,
    `symptom_summary` LONGTEXT NOT NULL,
    `sources` JSON NOT NULL,
    `disclaimer` LONGTEXT NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `deleted_at` DATETIME(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_auto_gui_users_62041970` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-AUTO-005 — 자가면역 맞춤 안내문 생성 결과 영속화.';
CREATE TABLE IF NOT EXISTS `guide_generation_jobs` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nBLOCKED: BLOCKED\nFAILED: FAILED' DEFAULT 'PENDING',
    `trigger_type` VARCHAR(20) NOT NULL,
    `blocked_reason` VARCHAR(40),
    `trigger_emergency_modal` BOOL NOT NULL DEFAULT 0,
    `error_message` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `guide_id` BIGINT,
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_guide_ge_auto_gui_5fb3fa1d` FOREIGN KEY (`guide_id`) REFERENCES `auto_guides` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_guide_ge_users_4ebc89ac` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `pre_consultation_reports` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING',
    `visit_date` DATE NOT NULL,
    `period_days` INT NOT NULL DEFAULT 90,
    `pdf` LONGBLOB,
    `error_message` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_pre_cons_users_a207beb8` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `report_shares` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `recipient_email` VARCHAR(255) NOT NULL,
    `token` VARCHAR(100) NOT NULL UNIQUE,
    `expires_at` DATETIME(6) NOT NULL,
    `is_revoked` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `report_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_report_s_pre_cons_8b8cd9f2` FOREIGN KEY (`report_id`) REFERENCES `pre_consultation_reports` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_report_s_users_dad40958` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `safety_filter_logs` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `user_id` BIGINT,
    `target_type` VARCHAR(50) NOT NULL,
    `target_id` VARCHAR(100),
    `blocked_reason` VARCHAR(100) NOT NULL,
    `original_text` LONGTEXT NOT NULL,
    `safe_replacement_text` LONGTEXT NOT NULL,
    `filter_stage` VARCHAR(30) NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `model_improvement_datasets` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `dataset_version` VARCHAR(20) NOT NULL UNIQUE,
    `week_start` DATETIME(6) NOT NULL,
    `week_end` DATETIME(6) NOT NULL,
    `low_rated_guide_count` INT NOT NULL DEFAULT 0,
    `high_ocr_correction_count` INT NOT NULL DEFAULT 0,
    `thumbs_down_chat_count` INT NOT NULL DEFAULT 0,
    `total_records` INT NOT NULL DEFAULT 0,
    `consent_only` BOOL NOT NULL DEFAULT 1,
    `pseudonymized_at` DATETIME(6) NOT NULL,
    `pseudonymization_level` VARCHAR(200) NOT NULL,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4 COMMENT='REQ-FEED-002 — 주 1회 집계 결과 (가명처리 후 모델 개선 데이터셋).';
CREATE TABLE IF NOT EXISTS `model_versions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `model_name` VARCHAR(100) NOT NULL,
    `version` VARCHAR(20) NOT NULL,
    `description` LONGTEXT,
    `status` VARCHAR(20) NOT NULL COMMENT 'CANDIDATE: CANDIDATE\nDEPLOYED: DEPLOYED\nRETIRED: RETIRED' DEFAULT 'CANDIDATE',
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    UNIQUE KEY `uid_model_versi_model_n_8d5edb` (`model_name`, `version`)
) CHARACTER SET utf8mb4 COMMENT='REQ-FEED-002 — AI 모델 버저닝 이력.';
CREATE TABLE IF NOT EXISTS `prompt_versions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `prompt_type` VARCHAR(50) NOT NULL COMMENT 'HEALTH_GUIDE: HEALTH_GUIDE\nOCR_EXTRACT: OCR_EXTRACT\nOCR_STRUCTURE: OCR_STRUCTURE\nMEDICATION_INFO: MEDICATION_INFO',
    `version` VARCHAR(20) NOT NULL,
    `template_text` LONGTEXT NOT NULL,
    `improvement_reason` LONGTEXT NOT NULL,
    `status` VARCHAR(20) NOT NULL COMMENT 'CANDIDATE: CANDIDATE\nAPPROVED: APPROVED\nREJECTED: REJECTED' DEFAULT 'CANDIDATE',
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `source_dataset_id` CHAR(36),
    `source_prompt_id` CHAR(36),
    CONSTRAINT `fk_prompt_v_model_im_edb0e6ef` FOREIGN KEY (`source_dataset_id`) REFERENCES `model_improvement_datasets` (`id`) ON DELETE SET NULL,
    CONSTRAINT `fk_prompt_v_prompts_4601ba87` FOREIGN KEY (`source_prompt_id`) REFERENCES `prompts` (`id`) ON DELETE SET NULL
) CHARACTER SET utf8mb4 COMMENT='REQ-FEED-002 — 프롬프트 개선 이력.';
CREATE TABLE IF NOT EXISTS `pill_recognitions` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `image_url` VARCHAR(512) NOT NULL,
    `original_filename` VARCHAR(255) NOT NULL,
    `candidates` JSON,
    `selected_drug_name` VARCHAR(128),
    `user_confirmed` BOOL NOT NULL DEFAULT 0,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `updated_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_pill_rec_users_2e103417` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4 COMMENT='REQ-PILL-001 / REQ-PILL-004 — 약품 이미지 인식 이력.';
CREATE TABLE IF NOT EXISTS `diet_infos` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `disease_code` VARCHAR(20) NOT NULL COMMENT 'RA: RA\nSLE: SLE\nDM1: DM1\nDM2: DM2\nHTN: HTN\nHYPERLIPIDEMIA: HYPERLIPIDEMIA\nASTHMA: ASTHMA\nCOPD: COPD\nPARKINSON: PARKINSON\nMS: MS\nBREAST_CANCER: BREAST_CANCER\nCOLON_CANCER: COLON_CANCER\nLUNG_CANCER: LUNG_CANCER',
    `category` VARCHAR(10) NOT NULL COMMENT 'RECOMMEND: RECOMMEND\nAVOID: AVOID',
    `food_category` VARCHAR(30),
    `food_name` VARCHAR(100) NOT NULL,
    `reason` LONGTEXT NOT NULL,
    `terms` JSON,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `content_conversions` (
    `id` CHAR(36) NOT NULL PRIMARY KEY,
    `conversion_type` VARCHAR(20) NOT NULL COMMENT 'CARD: CARD\nTTS: TTS',
    `status` VARCHAR(20) NOT NULL COMMENT 'PENDING: PENDING\nPROCESSING: PROCESSING\nCOMPLETED: COMPLETED\nFAILED: FAILED' DEFAULT 'PENDING',
    `file_url` VARCHAR(500),
    `file_urls` JSON,
    `error_message` LONGTEXT,
    `created_at` DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    `completed_at` DATETIME(6),
    `guide_id` INT NOT NULL,
    `user_id` BIGINT NOT NULL,
    CONSTRAINT `fk_content__health_g_46b5b166` FOREIGN KEY (`guide_id`) REFERENCES `health_guides` (`id`) ON DELETE CASCADE,
    CONSTRAINT `fk_content__users_89ac2208` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS `email_verify_codes` (
    `id` BIGINT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `code` VARCHAR(6) NOT NULL,
    `expires_at` DOUBLE NOT NULL
) CHARACTER SET utf8mb4 COMMENT='인증코드 DB 저장 — 멀티워커/재시작 환경에서 인메모리 _store 대체';"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        """


MODELS_STATE = (
    "eJztXftz6jiW/ldc/NRdlb4DBBJCbW0VASehL6815E7fbU+5jC2I5xqZsU26Mzv9v68kP/"
    "BDNjZPm6hSRYytI+xPsnTOp6Nz/q+yMlSgW186wNSUt0qb+78KlFcAHUSu3HAVeb3enscn"
    "bHmuk6Lytszcsk1ZsdHZhaxbAJ1SgaWY2trWDIjOwo2u45OGggpqcLk9tYHavzZAso0lsN"
    "+AiS78/g90WoMq+BNY3tf1D2mhAV0N3aqm4t8m5yX7Y03O9aH9RAriX5tLiqFvVnBbeP1h"
    "vxnQL61BG59dAghM2Qa4etvc4NvHd+c+p/dEzp1uizi3GJBRwULe6HbgcTNioBgQ44fuxi"
    "IPuMS/8ku91rhvtG7vGi1UhNyJf+b+L+fxts/uCBIERrPKX+S6bMtOCQLjFrd3YFr4lmLg"
    "dd9kk45eQCQCIbrxKIQeYGkYeie2IG47zpFQXMl/SjqASxt38HqzmYLZt47QfekIP6FSP+"
    "OnMVBndvr4yL1Ud65hYLdA4lcjB4hu8XICWKtWMwCISiUCSK6FAUS/aAPnHQyD+Ot0PKKD"
    "GBCJAKlqis39h9M1K/ZSFwPQFPzw8+KbXlnWv/QgbD8NO79FEe0Oxo/k+Q3LXpqkFlLBI0"
    "IXD5aLH4HXHp+Yy8qPP2RTlWJXjLqRVDZ+aVVfRc/IUF4SrPAT4+dzp49XiwzlsWmFnE+d"
    "VDaohFWsOeVRW17RtPJQr9/e3tert3etZuP+vtmq+vNL/FLaRPPYf8ZzTahv7p58wErW9D"
    "yjpi9QznGzkWXYbCSPmo3YoPkmW29AldayZf1hmJT+mowlRbScqNbqrSyzUb2VPBvha2Fg"
    "yf8caHrlywlhPUvHrCd3zHqsY6InVp3hPY4gDzcrgmIf3ZIMFRBDcyt9YTwrw86Ab3P4U4"
    "RPvPPN+V/ZA+e7DDDfJaJ8FwV5rpn2myp/xGHuIXDoHTUoE1WakJCtrcAXfFDMbpuCX68z"
    "4yP4rNHTAQn1tnlSV6RjFJUr50tdq2UZFmvJo2ItNtsAbflG0dCfdENO0Im2IhEQF1gmA4"
    "yu4lOQPjZ+fRzw3ETgu/1p31XTP1w13bmIT6ETmk2eUuA7gwiIf+QH8Q8GYgREbCzsO7l4"
    "sud7q91KieYamV+e+REvdAZtzi0iws7rbNwfDl9HaKaRN7ahrVYbCPaZbWpZppta8nxTi0"
    "04GDrJAjpQEECSTOnFPXcOoXdkmnzaJIQPyta9Z/0hP511hpOQDY9nJ3ylHu7t7tnYpO9X"
    "wv29P3vh8Ffuf8cjPmrq++Vm/1vB94Q7jASNPyRZDT62d9o7FWpUzZKQaa29U16oR8PQgQ"
    "wTzN2gXKQV50jwVG+Tbwofu+Uex+NBqNEe+xGTdvQ6fOTRO/NzeIDyLN0wpupKo/CqOyH1"
    "xM6IaF5O5SKQ6rJlS7qxpIGaPuqEJdl4c+HxRjGBvN/0EZY8QkNeQkdHz6COof7h9qOStK"
    "zb5VMbdrNW92zYsCRr2Is2LLn5HGsH2w7wA1WgA3UJJATXZgUwMvEJ0K3k6asAdNmmryS6"
    "SwRfvQp7bn3FbPq/vP7snd12gS04qmYB2QIHIoIXTXpOTSXGQt6oGpmSD0Sjg+sZGMsSQ7"
    "ECqqaQxzxCzxj6lZUYEWJUaPbHEfqH+6Z03BrL3VOsj9XaNlaS8gaUH0cAZ+rU18XVlRsZ"
    "5x3SJQtBo270Q8dY5y3Sp25tJQYG3Z+E1AD0ewdCMpDnAqmnzGBs1htLsn5o8AgvzwBXNk"
    "V1lfvNcTBRZU3/kIg3zZ8H9xRcYw9X2HXqKzE6yptsS0hlsw6fnbuoqqlTU5kBQVcP1+qx"
    "ptJ1aioxFlvF7SiKimx+bLW3cg8qnqJyJFhcPaXcmLwBWbffpBVAdSkHovJC6hqSqkoMyQ"
    "IAFTMKB6Lx5FZT7v4BDVtbHMcQHAWqKjEiC/ndMDUbSGtdVg5V6Z/cyia4rhKDIq/XBrp0"
    "BGrNNXI62wpLDItnAB6JdnSxuQLS0VBM6Z/G/EA8xor5qzEvMQzLDXpSTT50ZH12qykxEt"
    "abbAJJ1+Ch0+4UVzRA9ZQYDFcpW2409dAJxtHJnnFN3e2ulJLisja3lR+IyyRQ1ZUgIh2N"
    "sr8Kut7UrB/SQpcPtfUEVM8TqqbEUJBF1GOMJh1UERlLSgwGwUFybx6/NofrIQSSZ7/Gcu"
    "skaEghJdAPOviYYG2Yh6quaLztBioVSJ0lRskBRSJqy6EDDKmK6C0lBmSt6TrqKoqxhNox"
    "5mdUnbCtrcTAoKvuzvRDqXpHf+v69ZUMlFx7eSPz+No0FppO8wR2xccQzAz0kY3lx3P6ZF"
    "tlUd0qM/ojyDrAQxGwbVznESDy/BI6uOLptt6y4qTgBa65pmOwjgpToOLSwwRWwER3rnxI"
    "ikzbsZsfH96rsetWWE5gghT4MbtPkA8vfe/Z7gg65ljd8Wst5WidMyBF3KuUEp2C6nqaHK"
    "pi6/o6d10zjxuz4veKrdlOu1jGxlSAZJhLGWr/3rbsZq5rZEv/B5DNyj8iUS5+r1jIJNhY"
    "FXT+98pmrRuyisrOPyQcZcM5G/Cv/weLinGpqBh+Q2fdruwLlHOfcj1TNKF6SjShejyaEB"
    "7E8sZwCMqUFMpTRLbCsEhr2X7Li6UvVE4wm5n6ZTOlXzbj/dIdhKlI7t66vJU+4+blCT/q"
    "9UfPlRiu3pU25x6IcCKMu/x06pz0j0XYG+PtzPhThE+d/oDvtTnnf2WPlqllCz+WEn0sFn"
    "zsbQN/IKA3tABkiVNbRGr3HFcINeo4IQUDXZquj2QdKZLUmVKOGSeJjBfR7GLYTleyrid2"
    "0rj0Xv30EtA6HfW2fn/n91H8Ja17ToedwSDeR4FpGqa0ApaFTII4gjPwZwJ6McG9+mWxNg"
    "zzvxGdNDm+oL/5cDAePXvFo0EHIwMo29R7DXs/CTBsU+/1NWyMSIoyAFJeuz6hgpJNLmew"
    "9WNbqZMbId4CT4YJtCX8Cj5ilkHysksxEU+i79BpU/7DZ5qSOhZ6VPSAwAkP0u1Mu50eX/"
    "kreVt6rmWwnAxiwNurQuEOg5dv0ljDmANacQLdXhGfd7Lg6YnjZvKgWdqB8njmYgoDkmAh"
    "XoD1OKZReJvFJrxNNglvYxZhYO9ZILRcVpuGLn1GRilOJRXWrrGwExtYLIBiSysDarZhUp"
    "clk4PUJ9dw/pj1lf9abKCCMefmG023NWh9wb/336dpkaNFsg9tWdYWwLI/dCBpcGHk6fdx"
    "SdbnqX3e3b9pbVYr2aREF06GmCLKMKZiTFhPyjSYMpBsRdjIsc/IoWqWosvaimZnJXfpsF"
    "RZNBDG/zGaaG/+L8ZYJFvZzP/2MP/bnMRDMPxbQkqdQHS49Mw6UjAi3U7ioSLw//NLrz/l"
    "f6lWa3+rVuucuKlXaw30T7l/qIobWamiz7l830BnmkDl8Be5hT4bqoJLVWUFfd7JD56Ect"
    "9s4VKNRQ19tppYRHlQkIh612x9ia4MX+YOWP6g4npKuR0YQbh/NPhoHZdOOCJ02pzQEeEU"
    "ZxqZ4rQjvWGtzaEPfFTHR3URvsxGbQ59oKPvE14Y9Cf9Hj/sI9nwdxF2prOXITrv/Bdhdz"
    "zptTn8KcJJR/jaHyFNqc35hyIcTtvccCrCR4FHQlK3M+ryQpsLfcX1IOXAvxj8JsLB6+jZ"
    "vxT4En2js3mHZXIOy5GaRtXkJTQspHJ4eU7i6kqSKhiVPDCDSqHWhSkJVKBBAyhZV/bKs0"
    "VypiRfu5LMFsmvrmHjMZvJguM+7RqWZDkHLpxzYD8Ph9Iu1l3Yq4F5MrieDMX0XvCjplMY"
    "hGBE9ZRs76H47bu5g9GT8Et3PJwM+sh2b2zt9vl8oWC7vYZt8Vatic4oC2LQKw/Ybn+Qsd"
    "3uXq+SL8hKxyLqosX9hG4QQPUXA009P8fpgnP9KGMIissQyEped/StRFmo/kiK0UYGe/mu"
    "kZxktBGzl4FNTdOcvFK1lThooapQKs9JVqSYQXgVdgPTN5m+yfTN1EWrYCSYhIWrSLCYHY"
    "tXwXA1OVawcHZVvH6UYe1IaTawOlidN7DOeNsiK0iqij5rtzVnHYmIV9F1tam28KkHLH5/"
    "j8uqTXzB0RzVZqPB/URbgZrXFw9cjaibCkWHLcctMw24uBrw2gRLKONwM4dtPabVc0bXrp"
    "E7T0cNS7KveET2FU8E/nnUGc3wzmPnyFvDeuJ5Z59y6CuSGHRGI2evsnu0zwrV8dMsmwDK"
    "uqSt1rJmeqFHIq9IWhZZmjjLJhtNZb+WbU3ZH2R6BQzmSB5kiP2esaf5G7L5jHzOpFRhtr"
    "RIXVpUzc1SknUdmMtcGEflGLz0lVtjZZhzTdVsjea0m4xvTJABzJbGPxUTwpbGr6Fh4/vH"
    "C8FwXY8Nl8PnOs7V7OLCvEiQJ2bCTt0ap+HBDua2AmkcEqitcKKHHcxWJL1ELl4r6BMdI2"
    "4wYRTydsYsT1NJI5RklZxq1QmV1LxXCa+kpBJV57wHxjwVl3nKG36x3KEXa/VWFhqo3krm"
    "gfA1ilWn6LK1N20XruHSzu3TGS+M+7025x6IsD8cvo7G09fJROCnU8LexU6JEH30h51BR+"
    "h3Bm0u+E2Ej/3xYPzc77Y570iEo2kH/wr5tw+lV8+yiF5PXkSvxxbRNUvS4D9BgjtCKtMU"
    "FWUcUyS2G8zvyR+UYT78zIefERWfzJ5lRMWVNizz4Wc+/MynivlUXblPlbvL38sgleDNTy"
    "l1k8Y/eZuh/ZRX2V38CQHUnX3L4qkU3GRPXO0XTfSlNm9y5Jzi+SvNbxVSieOkf684zkv3"
    "ivOJJcFt1d24T3VVqlbn91uRsPPSfSPJ36qMT0FNGeO9xKgVHWsnmhSGkWOXIsf8JqHqJH"
    "SQgzIHGq2XG3AzWq1rJCe9yxTeKznQfUCkZHP90YJrLmRbW24ovSoRtYDEZwVtZZgQ/Z5k"
    "2dpiAYFlSSuNQtIlQpgo/0kTgvzTQDVL1h9A1zEsMjItcwW6S5Jnm4nSw9vJmv4hqagPag"
    "q6f4obWGIPpol+1tGA8aWML2W0GuNLP0nDFtSxi9FsjGarXJ5mmzrxrLtvQPmRwLFFi9yk"
    "EWxefGwFl87Jrk2/DydRXsrbyEfiVj5gSqqq1CKMlaLg7YBq9S7MNX3hTDQGL3R5KaEmXC"
    "6BiSmtef2hwbm/VCeRLxbEX+sBYNYL3BGHLGVOKl8k+IEV9UaZs1hx+TDyQqBmdl+QXPYi"
    "Tfb8EdLLZSzGXylKB0/fZEirgPkmMevnCpVkthjNtGSmJScHlHOXizs6MO0psG3nWePB5W"
    "jlUvVlfyFaxiKS5cjkX5K+zbAnQXlQamSZluiltXrDW7N1NyjQ1nRDexqcWPN1siZcI9rr"
    "g6PjNhsK/jLf6rXKAxLZOyBI+Z+JqeLFVcXJOqr9hubKN0PPk9wwLvhJF8AIEPg3gLJB4x"
    "eQVPkj90o2Tf6T4hlfYN2ne+6o5ZNi667/74UoVfaT4ugoKCvUrZCOlGf9MCZYlv1v515J"
    "1CwJQPy4eamKsOAZKQpfPWAMBWMo2Posa9jrWZ+9HlOIBd4oZeANJ6SGPlXegLqhB5WNFr"
    "lJY5qcqBu6ZLml88feaHC7A7S6sSycFAM4+yBeuFSU7Y6AVq2JORRZaVU9JsV1/39QGk5h"
    "/0wL5zHAZdIDx176vhjXU1yux+vtDlgxrLPFmIhVcukwE4+D8bgnzdBE2+a2xyJ8Ffoj3j"
    "2/PRYh/52X+N86wzbnHYmwM5mMEX5DHoekCHwRYX/0K9+d9XHWRP8w+v4ltPmJ48bamq3n"
    "CrniC5TEeTWaGjJbbsi05JCx7JBeZ84fUyIuee2bdEywwrdiEn5SmoOFYebZepIkfr610d"
    "rB4zdzOy8mWcRojauwfhmtcaUNy8J0sDAdzDOKeUZduWfUQJ4LYAFMgOGnUFSh6zdp/BRq"
    "A8n0imYjp5JBZpRMcSkZBbV9HhveK38c0uXkGJ84WSX+L/0w8gAYECnL0vsZQs/K8zllZk"
    "nJm+qWL4k9eup+qKCHXVLz3aS8yQEZBqNrFWxvKweSEbFSgllvNrOwm81mMruJr4XxRE9D"
    "sa+SgfTKlxLB23oGAG/rifjhS1HC01XAJFOGSyA5AFByIycjmlJFKUE+STfdgkSnRbPAWz"
    "KC9AyoWsbGVHKhuZVgKDJmuXJNBCRjlq+0YcnNH+TUdWT6x3Kah879kIs3u4kfXC6HS9Kg"
    "8xiJwJBth9h9q0lS7Wx3iG09fkIBFchGr3oN+wndqg8RUccPaK4sGo5nUYJ/UhFvkjFjxW"
    "XGbGDZub0yQkLX7pBBHlazwSqPkhcSYgyYD+a7rNMiqSYD6QuUE8TjszcRW/cAM7m0JsgJ"
    "GG7mKMQchZjWz8y5z9GwzFGIOQoxRyHmKHTtjkKb9caa/tBgQpTR0PWbVL4Il5QsVDRnfN"
    "HB6+R1GiRkpgMehwiqzwkdc48ZGrV5i8P+qK1qNJBnJIlNvaY43AvJfEOie97LzRtSBdl3"
    "VqupJIyQcocvNZL2sBXhphgnVFxOyAuoe9D+tUgdl96+JnSmL20Of4pwLHQG0uugywttbn"
    "sswpdOX5AG4+m0zfmHIhQ630ed1x4WJgfRVyoTl3L0bWks1xHL0Mssemb4MYueNWyFWfTM"
    "omcWPbPoP4dF38OJ1boGtJEyV0ky60OFbnbb9k62NsUROIKBf4fDvWB/C+KCoapOWGAnmQ"
    "ZJWXuv7khZm8Ww9jwu1Nta1Q0oEza1qQ4g6blv83EGJX9OluK3eOPzTQo1wczedLN38y6B"
    "P5EKsjEBTpi6sUGeGMkJ0p80+qylA7CW3oyNScHwSTfkBBQjchH0FliwkPil9bTx6yMa7y"
    "cC3+1P3dBMWzWZXMSntjFRBb4ziMJpmzg+tA7eQcLmjgysYqSOy7I1lcH4720OfYhw2O+1"
    "OfQhwpf+80ubw5/7EIVZXK6SHa5i7lYrZMfZ8g9A2eiVGt03JLdfcN9C9d8jxvZlxCIjFh"
    "n/xIjFT9KwBQ2VzPgoxkdVLs9HIa3VniKN1HnqGBMVvHyTxkEpqKBkOSVZHJrrpS9WiXFo"
    "dts+q6PGpNnf6HnmR7zQGbQ590CEOCZ2fzh8HfFtbntcDD8Jpl9ehRoS1y/ZAmfx25EtcD"
    "KF8voUyiC9RhKMUejhR1fy6asAdDkhZlJASxxuU5WVB9O/Tq1ae6gkqNYB0Hao1sGGYqr1"
    "VarWppGUpmG3au3JXlq1fp1il2T8iZTq6bSPplaSKcM7LIhKjZ0kIEXtSibBAyJl2cd9bi"
    "LclJeSExqKMp38Oh2P6MhGxKLarKbY3H84XbNOphRV/muxgQpGl5tvNN3WoPUF/95/V06C"
    "PUYiHfsozBGVFVcQxX6uG8oPZBHMP9Bv6jZNRUpdLqPKnzEnZt557CILZwQkCRmkVr64k1"
    "G5kiyknTwYKiM2rpPYcGng3CZxWI5ZxTmsYmvL0R9oGEcY/+LhndU+Dvem/U3kBQAqLnME"
    "G/nJrapcwJ7cSPZhSbCSg7DtMJNDjcXs5Ku0ky0lX0I5v3zJZpSjuYEqxmqV29z1RUqirT"
    "K3L6a9HkV7dZnW3NprWK5kY81ltdfVlgY/gvZaypWIqPYa7k1F8hjCK2dddPsAUveuBS+n"
    "6mtk/UpxShZMXXt97fdyKGubjaZ+wTL7dLndOluAnyS/hD8aJyInneQXzugbHFfJ0+3KUE"
    "Wa8qCYK9E6Lr2cMeOF4VQaP0lTXvjW7/JtLnpGhBOh/63T/S5NxoN+93ubC38X4ZDv9bud"
    "gYTmtk6bC35D1zrCVzThjZ7RBe8QnR33+IHUH06E8TfeSTUeO7XPQkozS2LsZnJe7GYsLb"
    "aM+gegzZNpXPNW6IwE88mUyyPyy+/ApJM4KcGFtyJlWZaKZmvP0Cfrabna6X1yD708JMjU"
    "8oKp5X9o9puKVCS4R8tGZZnHHPOYO8/7WATrinnMFXsLRkdR8FLFXEOawccU2LbzrDHLil"
    "ruJs3EkoMSkuWIMFur/LbWwkBGkqX9e29DK1TB+TTHCjZ/XodxPCvTYWcwaHPkn2MzvQ4d"
    "a+l1KMJBR3hGxhf5J8Lf3K/O/30soeNrnbZtSQBibPKaQxFJ5nQTBhbI1oeky3C5oTKEqd"
    "DGZBm4YXARMKaqyVCy0KgB9uzAyZUwuKMhbxXiJSDhufcHup89EU+th4HOFuo+BSPA4jNc"
    "RcMWND7D9fjSxKiBPGbuLhphDMHMQB8nJhFO3RqnoRAOogV6mmx+DIGqOXN9QgYQSqmbNE"
    "pAxeWllS+QPRsIYwSKzAiwsJLpYSVVc7OUyJcYQMmrayGhsq6vZaM60riOONmBeoZk6QZF"
    "8cpGP4UquHAIxOFYGDkr8M6BCAevo+5LmyP/RNjrj0Z4U6PzX4SPfA/rOG3OPSgI/7RHjM"
    "QD4yPu1bf98bXAFiPBRfJU/zyGRViSLTNeeJkRR66kbNtID3VJ24XKnJ5dLQPpjPaGFgGq"
    "BxRtJesJikZALPpSOHJfXPmyodzju/1hZ/BTrXrTiIwrHtyN2FitG3C5F4xBOYbjlgY1gW"
    "KY6l5UUFIdbOy+8NjNaNurYPcYbXulDVtQ2pb5dDGfrkoiIXs2ny5Cy06dDLJpzG2gyM1u"
    "2tZLScs42xvG2V4/Z2u8o9vXdTwIqJoXXWEfupFa0aX3Fn3jhe/SY6fX5rwjEZKv5Gg0Fo"
    "Y4RLHzX4TP4zG6hD9FSMo7J/zDYrCQc0P9kNayaeeKABaWOigAWKFsrpNE+loAoLuOv1nx"
    "DYgwcFPBXYGVkYcv9MozupDFSLheU4/Z8FfasMyGZzY8s+GTbHh+BUwEqvLRRVVVKBZ8uM"
    "BNmv0OvKKSgsoy4738xvtcNww1JdhFgqkTkiqJ2hgJx53FaqwlW421+I59XUdvh5ZvqT4k"
    "VBIgz65/v5kG1JQt75ELYbo0g5oKdWCAN6CNhvVcDAhdmhnrqca6pZkASockJAvXcMZtsA"
    "6rF5/TKlHab9ofkPg/zn8Rjp+e2hz6KAbdx+z7qzADmX1/pQ1bUPueba1iW6suurXqBci6"
    "/TYE6MaVCsWwD12/SbPr30hJaUWKMrO+/Ga905Ipdn2GNLfhKi69zvw4GI970kTgp9NXAW"
    "9bCX0XofN9+vrcEbyL5IsI/873n1+Q8un8F+EL3xFmkoCmsTa3Pd5HFb3NooreJquitzFV"
    "lIwevg/vu6xv8npXJ9RwsJ91wdwsto7W9cyO1isgWxtzL30wIlpOhbAkCiDbE7OrsdgiN7"
    "OVshvBhTCW2GIoWwytJJpBZ1sM9XIwJTgzBy/fpBlMXoIm5sN8HfaSLZsI/YPspUgVl7aX"
    "ntFDIwOH/BMhggZZQPhThOMuspDQhwgnfRysEn8Wg4h3IczXq0NCx+zcF9XxdvbleGa/g3"
    "pvrJJL919kk5NwFs5/Ec5eXoePU+l10ub8Q/9sb/z3kX8efxGhwD/zI96x8rfHxejnCEGq"
    "73OiOrYV2Esbu4CvBcv9xkw+ZvIxk+8cowwz+c4xLJXV5BsZtrZwwwRWKDZf6PpNmtEHAy"
    "WZ0Vd+oy/Yngcpz9SKLq1AOynaZv3xyEvXho9xILiO8B3HgUP/yGLYYPYiDfmZ0O+S9bDt"
    "VxHyQ15AqjPOB+cfijBsWk67L3zvdYBOeEfFWEqzNVvP5dTsC7AQicFsiHZuvdsXKQuQ51"
    "a8NUvCyidFP0uLcxiQYsHxIz60yhtQN/petkxUtpzWTEmsl0xruyR36h4NuRVjYc9Y2DNG"
    "LTBq4YAmZNQCoxbyUAspGQ9pxW6yEg0s3+H1EA6BfBX7ZcyiV8DinoemKCfI3H4Ax2QZti"
    "FsQxsF9sQ4sQ6GdcJe3P1wpsozjEMY/2ujAVt6MzamJSE1yqQxXYmmClU4yWIpq9kZskCo"
    "1seWQGzFJkUsgI2NRNABpHTrbJC7ogzwnYAza/xarXG2wfkaGpZtcGYbnC/eGgXc4Dx5k8"
    "2VrHxUKKSKf+0mjUlZO6Xc+EqMPik1fZI37yFLeRiPUaaqCG/KxslkFAMi5QSymQnIZgqQ"
    "zTiQawRErs7oC5TEGfnUPvBFyMFWrHX6wJ72+5IlYbsCII01cHZZOOxCHM7ksHcUURbzLj"
    "XmnWZJ9cabJL/LmvPQMbR3eULFxJlLVAziN0PXVPnjEJipVTCoGb12hSyMQ68dRBUccaO6"
    "/G6YqMdNdFkBFdpW9VCBm9TN6m5RaY3LMku4/JYwaciDtiyEa7j0XoWX8XTSn+GIsd6RCC"
    "cInmEHbz3wjirZxqMTGy6MhSgjC3FpA5qREEUkIViiLLahnCnCzOu7ACuSzOv7wJXGs5lm"
    "Q+KEq3fWawPdO4kxQrHPKKVu0ow0x7VXl+StALPUym+pBZozJUly8sRIky/n9FiS6dB77N"
    "T58M2w1pqN3ta8xmBMkFmFW799Q7ENMzekEbGSqObRZGTZspGlpSOLW4cbE/X7fPbhVqSU"
    "OJ6kX7JQ00c2E0Pb2/bb25BUBdvewAzyT2GQM8fva2jYgjp+M6KFES2VwhAtPUPZ7GBZ/C"
    "I3WSgW1S1dMH4l8f3O+mq7TXsYr3KU9/rAuL/JdIrXdAetfccqufTy99rcfm9zwW8i9Dqt"
    "k9KpzYW/i3Ct6bo0l5dIzj0SIbpFdN1CP9nmtscidHdeK29A+bFZt7nwdxEp1agbtznyrx"
    "iL7QtNB9JaRrVT25r+voSEykmwnGS52DC1pQZR38EA5aVZqMLlBLfebGbpp81mckfF1yIh"
    "6GwD5wfbB1qKaDmBPQmNRd5mS/s3BdLEGTMk80lD5q+Q+ZYyTSY4OASFSkJfnaEPbta6Ia"
    "s4yIO9SXBb2q12xCo5Y6Z257cdjiyifHiX2px3JEKE8EIzV/ikfyhCxzBA59yDYqgImiUR"
    "+8W/0ZxUIlWeubjH4gA74OBFSDkPGR6XLMmwwpynGKXHuFrWsIlcrTsL7tGuYUkWrPjC3h"
    "yMdL9hpHuZSPcApaOY0j+NOcUmeXQln74KQPeT29DBHCvmr8a8XHCGXV0ClOmBWEwCVRV5"
    "5I0DcsqlGLeHUFZgtn0neeEl2EvZekvxSKPk9ZbDGI+LUB1rAFU3wnZ0mcW50ubcAxGuTU"
    "MBluWc9I8x/7Fau1yHfyjChazp+JTzvxjsB55SbGR85zHJgzLMGKca4+i3N4q9MfcgPCii"
    "DGQ644GpIRWgkUOyFKQAUtRC3ZDTeKWIcATnBZYuG9K98evjgOcmAt/tT/tu7BXfXCIXw2"
    "SdwHcGsSUTXO8WoVzeq1Rh1oOpPRiYpmFKKzRtILUpzzpLTLAkAJ9hlZpE0t4vk1dIktEq"
    "l84B5WlO+1DaEVnWmJduTLY6cQ0kdrxhfWe4XCZyRKpkDOjRfCwYc3xzPuZYDTj5HsgeU9"
    "yGiwd6ViI58i7SyeRor2UU/GEU/CnJ1ucNqkKTYYVCt/rXbtII16VbqmCMK4sgEJ3AWdTz"
    "s+yExmGvJLhZzWkD345wWQG5Uhrpx+ecwUrW9FxshydQSgBP0iVNdyHSetPWeaCMypUS0W"
    "Y22iiFNaI4gaIZTnvfI8TxVo5tHmcm/2cw+ZnVesP8ncpkbAUWB9DECCRdgz8OdPOZ4ooG"
    "qJ5ygXpSJ58tJhTDMwRYsuUZaSBme5ba9rSNHwDmUU99geNYnyd3nzq9oq9uTH8o2seHKi"
    "h/6X3qSB2Rep3vbc49ECE++DvPf3VO4SPn3HA8mr04J8mhCF9Hs/5AEvhv4698r82Fvlb2"
    "aKzbLG11m9xUt7GWUhCGS8PUaO4Sycl/wlIH5f253DxDw/A0iX+gom9UIFmb1Uo2PyQDK9"
    "jxiTzVZEuogllvYZLmz7WGGmIP6y0sWU7rrSTWWqald82STPCOJtY9drYGBNmWVkZvfAp6"
    "w1v8olIcyWZAROyY9sBFx7ud6j8jhhgxVGhiiPZyHwG54FJ6edGLDFv7U2u6sTwKp2Ysyw"
    "XoGSg1Y1lJZNQcuHYSam7jMD6t1Hzauwb+2EvlDAkyjbNgGidpHTSH5VrJDwmxZfzI6kFO"
    "5T0m+FnU9xQFc4vJEZSlkq6XRbWlWD8pkt/nxDRWa2qYY/dKqqKwJmVOoCX87lbtdAlU5h"
    "2YFq7nH0x/OLP+EGmIfdaTIlVceknphe8MZi/SM3p2vs0Fv4lw3BUk/reZ0OnO2lzgi3Nl"
    "OhNeu7NXgXeu+V9FOOR7/W5n1h+PpP7oadzmIif2WW46/lz3ufx6T5KZxxuI8mhdW5Ezxq"
    "R4r32pHjCYnNqh1warNTLuQe5IEjHBsnTOc28Uf5dNDT9trqXlkNBBK8uF2vt6moVl5gDM"
    "VsgYX8Eikn6ihvXZ65iFuovrd7Wgg0PlYVPi21ajKuosdF7O/4VkVXlGFiToGtBOyFxEKX"
    "WTZt67uVqWWAA/kF28BEbMpN/DpHca9BCLPlzDpQ16/jde6PanyCr3jkTY6/PIgsefIhz0"
    "n9Ao932ACviHQZM9aK2L8Jkf8UJn0Obcg2KY7iWMijjhR73+6Dne/b0rbc49EOFEGHf56d"
    "Q56R+LsDseTgb8DLvv+ocifOr0B/iU83+fBjq+Ky9xKUDoWHTP62SDNibIDFq6QRuah/Ig"
    "HBMsydLXuQF2eVrUIdWca2FxyQMm3kIBncOVbQVsmR65M5lvCcowuiWVbmHUwFVYkIwauN"
    "KGZYmlmWtvAdwtChpgK5TjgepuEc4BkeZ0EUk8wdiYUrMx2gr1GMm6lTYmJcJRslUTlWNm"
    "I92qwZlA9klZEJVjRmMivIeRU+EaGEF1Io+LgzKWsnSl+HTaynVwWsZZOCjcOjZmkvgTin"
    "CaPVO2oQebIxHA3gxrrdmyLuX1SosJlmRkPkfkD01eQsPSrNyzXVyyJKiee75jNNRVsBWM"
    "hrrSho3nzL1YtoELTDEs2QCj8K6fwqO93kdALn+KhuK4l0UxTMvQMOVn3Oh1MMi2SX9FUD"
    "lCmtuhX1GpkD2p414AEwopHEYsmRKONBEjhEtNCKvmZklsW8kZCOF6Qxndku3jJPmyEMRn"
    "2MWlGnmzJ24lSmIXn9ohcWEC9ChQocRSTEYxJMSAdPqiG21VUuUPygybbKFE5T6pjUJScO"
    "ZmXMNSV061AqjmBigoc+Xw4A15G9vQVqsNBBKePnOujtArYCskkYEO6yVu7OJcs0ZMkM0c"
    "5Bo07Hx5tn2BkgDIuH1GATNunzVsIrcfWjfPu2UhJvoJ9ywwgv+GEfzFJvjXEc/YA9GLOt"
    "oW9cXeCSJlAMvN8p+S2hY068eTLlPj0PrXbtJobROVkhaoWDZWuyLw//NL53U2/qVavePE"
    "Tb1aa6B/sgKq4ka5rzbEjdpUWxz+V1XEzfz+oYUuqwt8SmlVSSm5iT5rLeULkWwp+Nw9lq"
    "zPSbGmir4oDwquef4A8Bdwp5LC8yr+XOCaH+4VrvdIilex1F21RqpVv1QifaA0N33klYG0"
    "+SXr1OK+FYctCpRlXrlJWTGwjI2pHLajP1LFpbf0T78jrXA8lLovfPdrmwt9FaHQn36VJs"
    "L4qY/39Ae/iXDQeZQEfvo6mLW57XH0tcvkoXeXxUEvqvwG/PPuYpv4HZDzvg8hsXKxvGd5"
    "MQKLEmiyQMCpuZZ2QkLlXCS7a2ToqneNxK6KL1GQRM8HcmXdDkuVE8tavZXlva+3kl98fI"
    "2a6C0X7Xkw43lxKG/rWaJs1JOjbNSjOK6ARV+5TSY9AyJlQfHcvKcJVKJn51z2CIqxxY7I"
    "C49+FN2us0JrAsVYrQB6prz7btKqYaEjyx4hqdOd9b8RWjSi/joX2pzzHym8/HQ8+IZ3lH"
    "lHOMLVdNifTvFJ/7AYai5bRrkKtp0to1xpw8a3SBDScJ92DUseoV0LtZBSpGb0Hjv9BWXL"
    "OWw5p3jLOZdZgOj4LlkT01hoBMXYSkS80E3akkTAzWvtlC+Yxz3j1Y/IqzsLUKhdDTNXFo"
    "Wo3EGR/fYzLbZbHeYbTbc1aH3BP3ui3Q4nCfi3NsESorHz48D4IrR6zmjkQQMCiok3QioA"
    "QhpdxMFF+OdRZzRrc+692iJ8FPjOdPbE804gkjlSPi17AYCKmghJDDqjEbmw1mUIcbNle6"
    "9ObPq9y4qiQYeueEP9m0p5pqUfoYoX4/3Bv1em94eZ4VdhrTEz/EobtqABM69HtYvZbnns"
    "kF123hiCmYE+Tmzlnbo1TmPjHWy3kSQllQR7zbl4s8tOcxKX5Pcda27dsJT7B+Ifhd2s5j"
    "J2qVKaQCVeVCpAX1SZlGo2WuhUdY6uz+e3xOWqqqrYeeq2FvKyCrlViRv1rtlI9Qi7wK0w"
    "e7S49mj5lrjo3l1OZhUSNNE/RBbPYNz9yvekl/7zi4Sdutpc7JSXnoUkVvWiLMZO7WML1b"
    "O40NSTXWjqMReabVQGyYE2V3hXujTzYKB7MFg4wwdYLIBiSysDashydG3irKZncg3ntz5P"
    "hv1J7ExdWwDL/tCBpMGFkaePxyVZ/07o3x+rtW2sJGuzWsk0TiUZZIooQzkBZeJom4vqDY"
    "iwcSJ9nFA1S9FlbUWzptICkwalWM9lO5cpmty1UEJxro+5ZhS/HZlrRjHoPeaacUzXjEDi"
    "RefxsSn6T2N+YBRIQt49+zX+asyLPPScNxokBRsKBUpHMJkLddJfUhqRea0wlrAQLOEJM7"
    "G4DKJPJRYzNwv69eUSjdTJO3jp70ZUrizm0anxnOuG8gPpvthphhY1IhnRuGRJYmWFIW1k"
    "gbSRDGkjsYsCZIkvcQhPCU01NEo7dT9TSi1sB1kkaKNpGqa0x4bHmGBJejDjTBhnwvyjWM"
    "Mm+kc5hkxe+yEoxYJnpATPYAzVsdFlDNWRY8EtPc+vA2ELeZEV7vXPCl1wZCtU6LeJCbqB"
    "wAUCWBumXaFQWfSCNzvSX0uRqAhYiBFajND6FIRWEemrd83S8qdgCEsdmGOgWGv8lCQDa2"
    "Bqhpo3yUdE6nwq1kP14FHjaBk+1uqCNsJC2fxIQM0RiDJKH270+6JO+NQR03Wu8a0z9Bo+"
    "9kcd4Tud+nikOOM8fp/xHcYuMXaJkRCMXWINW+jdd4z+YPRHpZ3TQcdChhDNbTmPX45je0"
    "9xTeVC9KQeOUFUaHHsw6ClhLInBaVtQzGq4iqpChMo2lrDeZfBStZyxU6miJbUnaPZzEIw"
    "NJvJDAO+FnE/MH6AXI4cvsBxQDx59w0HZsmU9LaWkvS2Fk96C/5ca2j02UNxDUuWU3Etia"
    "KayZdcsyQTvKMOnjeccFiQedwwk/0KLbv4++JqX3m1n5AYM++Y70BBjGfTXyY90HxOXH4t"
    "HvBZ7enQO7vboYDxEIfzEKe0v6fyAtioFXQbmAODmksuWuQmzQ63SGH067i0pBsZU8udzR"
    "hPzld6cIrSPUyaQBRE8kv4o3GiEIg7k5YmG90XmXw+i1egLZuoa+ffmRIWKyeTcfyU7S4s"
    "tM66E0tqZy3qcusZ+IyLb/K5eP88CayGqS01KOuSDf6kKJnJngExwbKAevYwM0gJwW6Luq"
    "yAFSZ88yKdWAFDnI64q+8hNZ7m7JKSzzAiVxZ8I2n4sowSt8mDxG1sjGBM2RUxZTGm4TKm"
    "3hD/66/WpvFOBjXUj2QLUN3Gk4repJl+5JSkbaWw6ykWyxEhFofj/6VarQfCsrYWClfD8V"
    "NbJKTqg1rD8VWVRjjY6k/b0K0tnKxbwVm85w8yllHvnMTcsozP3d63iGgNZ/Gu1XEmbnSu"
    "6qf0rt3i41pj/jM9cmyxblGE6M8ren/fwndTQ7XPlUXD+1TvbnGtygOOdlutyvf11i91Lu"
    "VuFGTy4FN1Nwc6DmJ7Jz+gHxuOe/xA6g8nwvgbP+RHM3Jr6gP+8WbLCaJLvdv5g0Ke8xYo"
    "ONP6XesUsXCZcb+Hce++pNI7MC0tn5pPES3jYvDx/fX/AOAHVmpoJHL69B2WLOf0XZLpOt"
    "NKMGkPACmDTYZ2dOVYK166FXVUnKDrhKxH7bSBlFczkctMlD/fslqBtou8acs3yVBMBINp"
    "AjLD5UY0tY5Piar9tlnNLUk1/kBIvMl2bkiTK/iceBq2rJOU3qaaZ0dYTO5Tooerxyacga"
    "3wGHg7U6oHRVka9fBmOwtsVAN+rLR/70Xw0OSZhnFpDSPQKs6ueR28g1zuyck1lJMUrWda"
    "O6mnrJ3U42snjBf9nLxoMGmpsVr7lMOBe3ImpLJvW/qicMu8F9mUQ+hfD5UkejiA2i5OON"
    "hY+/HAnX6UHZ0rrQYhJzG5WFdVzuMb5616Mxtzu0+lFMbyd/cpCUioiMeG/YNRmftM/QdQ"
    "meF2yDrxhqXKOdmexFFhD0b46Ezw+bWWY3PBwduKIZmSliUsVhKvpLN7epQvclG3M+r1Sf"
    "ya+NTnX2tz/qEIe/xkMP6OYxJ5RyIUkMYm4FPuQXTCu0xfZ+r551TPT6mMhnV0aoy7iBKf"
    "FtsuZjzs65egNqtEL7xTvGO1Po8t2+dVSfeoF3sAOBBgDwP1Doso965XQVNxMtP+zL1bXA"
    "goxx0hUCV2QXA8BkL1/8x5a/vz+YLoyCrWkbGnAPppJzub5+jRJglySWrcOvEDwJ4RxM+g"
    "EfKLwKVU4sJQU6JPtr0N/PtN4o6Arvh+DY0a0c0fcCUPCvkR9cFR2mvMp6Agirj7niX7tO"
    "+emyNVXDqj7gvfGcxepGf07GhyDn4T4bgrSEhbETrdWZsLfHGuTGfCa3f2KvDONf+rCId8"
    "r9910ur2R0/jNhc5sc+cfnyPemYFHEMzssFqraMnzu2KHBMsC6LnNgWCjodJOxaSYaZLM6"
    "w/sdnVmRAvR2RjeUfY7PqV784cu8s5YobX5bv/lRleLBji1TVsLBhi2HCi7ldMtjyowgcY"
    "IoXiCXeaHTEQXVNhLwxDsp8EwpTIFyFU4nDuEQDDq6io+O0M3EDrKAnJIJJf8CNAmbInp+"
    "zYhgeyYmXa0HRdAIqxhJqdxD9GitykMpCoMHEudEvn4CAn/cHgl2q1xv2NC3xtBPYhNe9V"
    "caM2Wq0tgzdftLZEmbM/KNti+Ul/jUXYvHT8iWTuTluhN0HamLmc10JCZbGaI8xZrZ6FOq"
    "vVk7kzfC1hr/9CQz+U0zGBKlxOcE8SslSRoaphA4bCRPw6HY8SDN6QVNQu0hSb+w+na1ah"
    "J1YaiPiJ04meKKcT0Q5xBTGiB03ECrYiVXOzzO1ZQ5cuiStDxMGm3sriYFNvJTvY4GuUoH"
    "7oZxeaucodajQuzMKNMlLsCrkTRopdacOyDCEsQ0gBSIiCRubsacDuw4VRoVAO/rWbNK5B"
    "1TCngooVLAYnM9ePaK6rmgVkC29JpyXuzbYgG63j0s42QqfNCR0RTgd8m0MfIuwNa20Ofe"
    "CjOj6qi/BlNmpz6AMdfZ/wwqA/6ff4YR/Jhr+LsDOdvQzReec/Tvw5ITk/Jz0RTjrC1/4I"
    "mT5tzj8U4XDa5oZTET4KPBKSup1RlxfaXOgrrmcwHvkXg99EOHgdPfuXAl8Ksl6M2nFpmJ"
    "Stvdl6TFD+4r2F746HQ35EFuXdQ9Tm38Z9vHSP/+2DeS3bhoqU/RRRzBeGoUrpwNPHxJhg"
    "KS3o4wfJI7jk5SRCQuUk006y2Se/yxRzk9rlJmUDc5WLm/QFGC2ZSksyZucqCIBC7TPpGt"
    "AG0Eb/3pP3msQL3aRZYIpTHNugufacnM0UY7sbop04w+6GbWsetMOBUs2lVeluR8CGEfoU"
    "4WyGbCD0UQyDpYQexxNkh/RHz/Hu611BFqdzgKxQYdzlp1PnpH+MLczhZMATh2P/UIRPnf"
    "4An3L+F6OB8Bp1Xq+BoEwpbZpmJk28maKJN+OauIdKLs0xJMS0x1TtEZimYUorYFnUaPXJ"
    "Fk9MsCSd9tx2D1PPr0g9D0cFXK3x8sheTRuRPULjFutNKlBbeo+d2phOKFuaVZC4OhMUKd"
    "li69EiY7JF6hu2SF28RerYm30E2F6ArNtvz15t5UUvOG4VaY2fX8kaDqSnLT66eO2VwjhF"
    "i9yk8U0AF8bhTVBpspqbcXuB763/8KCiz0UTO+s3VIXrPXJePDzlXm5uvf/ncqOKQ5Ms8J"
    "U7BcfvAKDxNyf0CHH7JwlJHmpOGJIWyYSiRgJ/OD86l8nPOXH4cAISybJRTyVpRMgPK/NG"
    "1MYtxx0zv4ni+k2QVyUPWeELlDLFyUn87xNdTpIsgEK4l+wJ4V0GAKPq/Ba+uyh44M+1hp"
    "R5qiH1pBtyEgUREosgucByxcQyBbze+PVxwHMTge/2p32X7/EtJXIRn9p6egt8Z0BTG885"
    "h//1//lRWJ0="
)
