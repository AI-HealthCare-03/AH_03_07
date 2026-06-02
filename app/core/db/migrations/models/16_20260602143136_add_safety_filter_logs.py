from tortoise import BaseDBAsyncClient

RUN_IN_TRANSACTION = True


async def upgrade(db: BaseDBAsyncClient) -> str:
    return """
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
        ALTER TABLE `health_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `audit_logs` MODIFY COLUMN `detail` JSON;
        ALTER TABLE `disease_activity_logs` MODIFY COLUMN `joint_swelling_areas` JSON;
        ALTER TABLE `symptom_check_logs` MODIFY COLUMN `checked_symptoms` JSON NOT NULL;
        ALTER TABLE `chat_messages` MODIFY COLUMN `rag_sources` JSON NOT NULL;
        ALTER TABLE `user_consents` MODIFY COLUMN `consent_type` VARCHAR(50) NOT NULL COMMENT 'TERMS_OF_SERVICE: TERMS_OF_SERVICE\nPRIVACY_POLICY: PRIVACY_POLICY\nMEDICAL_DATA: MEDICAL_DATA\nMARKETING: MARKETING\nMODEL_IMPROVEMENT: MODEL_IMPROVEMENT';
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `body_parts` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `feeling` JSON;
        ALTER TABLE `emergency_cards` MODIFY COLUMN `emergency_contacts` JSON;
        ALTER TABLE `pharmacies` MODIFY COLUMN `operating_hours` JSON;
        ALTER TABLE `share_links` MODIFY COLUMN `categories` JSON NOT NULL;
        ALTER TABLE `prompts` MODIFY COLUMN `variables` JSON;
        ALTER TABLE `health_guide_contents` MODIFY COLUMN `metadata` JSON;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `vaccination_history` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `risk_factors` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `sources` JSON NOT NULL;"""


async def downgrade(db: BaseDBAsyncClient) -> str:
    return """
        ALTER TABLE `prompts` MODIFY COLUMN `variables` JSON;
        ALTER TABLE `audit_logs` MODIFY COLUMN `detail` JSON;
        ALTER TABLE `pharmacies` MODIFY COLUMN `operating_hours` JSON;
        ALTER TABLE `auto_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `auto_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `share_links` MODIFY COLUMN `categories` JSON NOT NULL;
        ALTER TABLE `chat_messages` MODIFY COLUMN `rag_sources` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `side_effect_monitoring` JSON NOT NULL;
        ALTER TABLE `health_guides` MODIFY COLUMN `sources` JSON NOT NULL;
        ALTER TABLE `user_consents` MODIFY COLUMN `consent_type` VARCHAR(50) NOT NULL COMMENT 'TERMS_OF_SERVICE: TERMS_OF_SERVICE\nPRIVACY_POLICY: PRIVACY_POLICY\nMEDICAL_DATA: MEDICAL_DATA\nMARKETING: MARKETING';
        ALTER TABLE `emergency_cards` MODIFY COLUMN `emergency_contacts` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `body_parts` JSON;
        ALTER TABLE `diary_symptom_logs` MODIFY COLUMN `feeling` JSON;
        ALTER TABLE `symptom_check_logs` MODIFY COLUMN `checked_symptoms` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `vaccination_history` JSON NOT NULL;
        ALTER TABLE `autoimmune_profiles` MODIFY COLUMN `risk_factors` JSON NOT NULL;
        ALTER TABLE `disease_activity_logs` MODIFY COLUMN `joint_swelling_areas` JSON;
        ALTER TABLE `health_guide_contents` MODIFY COLUMN `metadata` JSON;
        DROP TABLE IF EXISTS `guide_generation_jobs`;
        DROP TABLE IF EXISTS `safety_filter_logs`;
        DROP TABLE IF EXISTS `prompt_versions`;
        DROP TABLE IF EXISTS `model_versions`;
        DROP TABLE IF EXISTS `model_improvement_datasets`;"""


MODELS_STATE = (
    "eJztXftz6riS/lcofpqpyjkLBBJCbW0VIU7CHF4L5Nw5O0y5jC2Ib4zNtU3O5O7O/76S/M"
    "APyWCeNulKFTG2WtifZKn761brf4sLQ0Ga9bWJTFV+LTYK/1vUpQXCB5ErV4WitFyuz5MT"
    "tjTVaFFpXWZq2aYk2/jsTNIshE8pyJJNdWmrho7P6itNIycNGRdU9fn61EpX/7VCom3Mkf"
    "2KTHzhjz/xaVVX0F/I8r4u38SZijQldKuqQn6bnhftjyU919btR1qQ/NpUlA1ttdDXhZcf"
    "9quh+6VV3SZn50hHpmQjUr1trsjtk7tzn9N7IudO10WcWwzIKGgmrTQ78LhbYiAbOsEP34"
    "1FH3BOfuVLpVy9rdavb6p1XITeiX/m9m/n8dbP7ghSBHrj4t/0umRLTgkK4xq3d2Ra5JZi"
    "4LVeJZONXkAkAiG+8SiEHmBJGHon1iCuO86BUFxIf4ka0uc26eCVWi0Bs+/NYeu5OfwFl/"
    "qVPI2BO7PTx3vupYpzjQC7BpK8GilAdIvnE8ByqbQFgLgUF0B6LQwg/kUbOe9gGMTfRv0e"
    "G8SASARIRZXtwv8VNNWKvdTZADQBP/K85KYXlvUvLQjbL93m71FEW53+PX1+w7LnJq2FVn"
    "CP0SWD5ewt8NqTE1NJfvspmYoYu2JUDF7Z+KVFZRE9I+nSnGJFnpg8nzt9vFh0KI9NK/R8"
    "4qSywiWsbM0p9+r8gqaVu0rl+vq2Urq+qdeqt7e1esmfX+KXkiaa+/YTmWtCfXPz5IMWkq"
    "qlGTV9gXyOm9Vths0qf9SsxgbNV8l6RYq4lCzrp2Ey+isfS4ZoPlEtV+rbzEaVOn82ItfC"
    "wNL/KdD0yucTwso2HbPC75iVWMfET6w4w3scQUFfLSiKbXxLki6jGJpr6TPjWew2O0KjQD"
    "4n+qPgfHP+F3fA+WYLmG+4KN9EQZ6qpv2qSB9xmB8wOOyOGpSJKk1YyFYX6Cs5yGa3TcDv"
    "oTkWIvgs8dMhEfe2Ka8rsjGKyuXzpS6XtxkWy/xRsRztb0RF2/WV9mRPh2XxSegJw2anGH"
    "+r3SuNgnsw0Zsv4367233p4fd7fbzLO17e5iUv89/ycuw1Vy0R677qOwP7e8PQkKRz9NGg"
    "XAT3KRY8FvC+rnroV/y+3++ELKP7dkTn7L107wUML0UXF1LtkCoaxlRZqAziYyOkntgJEU"
    "1r9JwFUk2ybFEz5ixQH9yphY1qWDJpViIHW4Ds9sBsTEzjdlcYjZvdQQhnMl2RKxV69iNy"
    "NqYF+JUU/tEePxfI18L/9J0RKmj7++XG/1Mk9yStbEPUjZ+42wYf2zvtnQozMSYi0IoSg4"
    "xJbsiw5AEa8hyTKH4Gpa9rH24/yknLul0+sWFXS2XHhg1LQsOetWHpzacg99Yd4A1XoCFl"
    "jkQM12qBCDLxCdCt5PHbEGmSzab6XQ7vm1fhg1tfNpv+b68/e2fXXWANjqJaSLLQnogQVv"
    "PBqSnHWEgrRaVT8p5oNEk9HWOeYygWSFFl+pgH6Bldv7IcI0KNCtX+OED/cN+UpltjvnuK"
    "9bFY2sZClF+R/HYAcEZOfS1SXb6Rcd4hTbQwNMpK23eMdd4ibeTWlmNg8P2JWA3Av7cnJB"
    "1pOqT15BmM1XJlidabqh/g5emQyka4rny/OfKrZItYKbH2n39auKqRU1OeAcFX99dbyVzc"
    "cmrKMRZr1eQgU7Fkfqz1k3y/Nt5UfCBY3Jk435i8IkmzX8UFwnXJe6LyTOvq0qpyDMkMIY"
    "XYzHui8ehWk+/+oRu2OjuMqdMLVJVjRGbSu2GqNhKXmiTvq7Q+upUNSF05BkVaLg186QDk"
    "kavGN9cV5hiW+Qo/tSrt++Y8udXkGAnrVTKRqKn6vsPqiFTUwfXkGAx30p2vVGXfAcSZc5"
    "9ITa114GtOcVma68r3xGUQqOpCEBEPRjpeBOFoqtabONOkfXX5Ia7nEVeTYyioG+gQo0kT"
    "V0THkhyDQXEQ3Zsnr80/jene8y+u8smv8TdjmmN88JBCS+AfdPAx0dIw91Xb8HjbClQ6pH"
    "XmGCUHFJGqLfsOMLQqqrfkDJBUC0AiI/PSNGaqxopOc8X7Ohob+GM7Xo6M0oN1lVkN9dnS"
    "RyZpiHQuZNukzgNA5PnKmqTi0brevOIkE0p6qmoErIPCFKg49zChBTLxncsfoiyxlnmkx0"
    "fwamy5FeYTmCBpdcjuE2Swct97iNKoLhYrHR1yrG76teZytE65ijEe6cRY0sgMh+Kvb1yH"
    "Y03dcKHDLnT8o2irttMulrEyZSQa5lzS1X+vW3Y11VS6DuwDSWbxz8jSyD+KFlbyVlYRn/"
    "+juFpqhqTgstMPkSzNdM4GYj7/hKWU51pK6Tf0tmtcfIF8Lm6pbLUEvZKwBL0SX4JOBrG0"
    "C/+CMjmF8hjpEAgs4lKyX9Ni6QvlE8zaVv2yltAva/F+6Q7CTCQ3r7xaS59w7dVA6D20e0"
    "/FGK7elUbBPZjog2G/JYxGzkn/eKI/9MlqLPI50R+b7Y7w0Cg4/4s7tEx5u5wVCSkrYhkr"
    "Xlf6GwZ6xcpawZ3aIlKb57hMqFGHyUMT6NJsfWTbkYKnzuRyzDhKOpWIZhfDdrSQNI3bSe"
    "PSO/XTc0DrdNTryu2N30fJl6TuOeo2O514H0WmaZjiAlkWNgniCI7RXxz0YoI79ctsLWIT"
    "fqc6KT8pjb8gptPvPXnFo5lqIgMoLDS7hPVIFBhYaHZ5DRsjkqIMgJjWrudUkLPJ5QS2fm"
    "x5H78R4i3waJhInevf0EfMMuC7XbKJOI++w6dN6afPNPE6Fn5U/IDIWbLeao5azQeh+Dd/"
    "qWQqN1hKBjEQv1NkcIfBy1dJrGEspCg72dEuiM87WsZN7rjJHzRzO1AezlxMYEA4FuIZWI"
    "9DGoXX29iE13yT8DpmEQZWizgPz0i9x7dp2NInZJTiVFJm7RqLhCWh2QzJtrgwdNU2TKZb"
    "kp/ZlF/D6ROdFv9zttJlgnlhulI1W9Wtr+T3/us4LXKw9KehpYXqDFn2h4ZEVZ8Zafp9XB"
    "L6PLPPuyuurNViIZmMlHR8iBmigDETY8p6MqbBhIFkLQIjxy4jh6JasiapC5adxe/SYam8"
    "aCDA/wFNtDP/F2MszmNlB/PvcJKOB9LzJOceF4MpgTZa2cWh8N9fHtoj4UupVP6PUqlSmK"
    "wqpXIV/5Nv70qTlSSX8OdUuq3iMzWkFMgXqY4/q4pMSpUkGX/eSHeehHxbq5NS1VkZf9Zr"
    "RES+k7GIclOrf426Qc9zB5BhPbthQW4HxhDunrk1Wse5UzIPm43CsDnRRyQX82i3RMyHT9"
    "KqqNJcNyw8J3nZk+PzGU9XiErumZc5U45DRlpm3WABxFemvPLgRQUt6tK1KPCiXlzDxhNN"
    "Uo/ULu0aloREyWdOlLybCzy33pwzu73B1e26urPp3vZTvTKs7mAa2IQ9JENJZzfb273H4Z"
    "dWvzvotLG9W13butPpTCa2bpnYr/VyDZ+RZ9QIlu+IrXsnEVvXvV6iX7BlS0SUWb3wC75B"
    "pCtfDDz1/Bo3sU/1o2BVZ9eqluS08cpribxwwZGNi6pb2Ms3Vf7WRdWYvYxs5uZvfFfGWm"
    "IvT0amVJ6juCzAILwIuwH0TdA3Qd9MdPQEU4VwnD2RbCIbHD7BfCYpvD5kxzDic9nC3yLX"
    "qkQdLE2rRGe8rlOvi6Lgz/J12fG9UPESvq7UlDo5dUfEb29JWaVGLjiao1KrVgu/sLw208"
    "rsrlCm6qbM0GHzccugAWdXA16aaK5LJB/JfmtTWfWcMPan587TUcOSLjzt0YWng6Hw1Gv2"
    "xmRpqnM00e+HQnM0fhQEZyFr6CuW6DR7PWcxq3uUDQ+ViXRJE9XFUlLNBXOn9cSt71jisA"
    "VeZDtmtJRsVd4dZHYFAHNk80adBMaSUORXbPMZ6aINmcLgWmS6FhVzNRclTUPmPBXGUTmA"
    "l+25NRaGOVUV1VZZUZ18fGOCADC4xj8VEwKu8Uto2PgC40wwXJdjw+0VlLuJC/NSBR6ZCT"
    "t2axyHB9ub2wpkbudQW+Hc7huYrUhG+VS8VjCOOEbcEMIoFCFMWJ6anEQoSQo9Va9QKql2"
    "q1BeSU4kqk55D8A8ZZd5SpufL9+5+cqV+jY0UKXO54HINYZVJ2uStTNtF67h3AHho7Ew7L"
    "cfGgX3YKK3u92XXn/0MhgMhdGIsnexUxMdf7S7zU5z2G52GoXgt4l+3+53+k/tVqPgHU30"
    "3qhJfoX+24XSq2zjRK/wneiVmBNdtURV/yfihCMkMk1RUeCYIEgdLHEw2MAS/5QNC0HqEK"
    "QOQUMQNHThQUPu0m9vDx1OuDqj1FUSweKtkPU3/dk+hp0yHK3x921CcYIrr2ks+ayGv5Sn"
    "tQI9J3sBOdNrmVbiRKHfyk50zq3sfBJJdF1yV3MzY3FKpentWiQcnXNb5QUU5fEpmJtmeC"
    "8xbkVnSW50Wwxgf87F/vhNwtRJ2CAHZfZcWX2+AZcFIWNp9RLLie8Sg9jhp/oOiORsrj9Y"
    "esGZZKvzFaNXcVELSHxW0BaGqePfEy1bnc10ZFniQmWwUFwIufKfdEuEf5Jd0EXrJ9I0Ao"
    "uETctUqb548rBaJjnBl6RqH6KC+6Aq4/tnxDlxezBL9LOOBsCXAl8KtBrwpZ+kYTMauQQ0"
    "G9BsxfPTbCMno2/rFclvHI4tWuQqiWDzMgTLpHRKdm30ozuI8lLeSjWazPCOUFIluRxhrG"
    "SZrHdTSjdhrulrwcRj8EyT5iJuwvkcmYTSmlbuqgX3lyo0tcOMBiTdIcJ6oRsacSRPaeUz"
    "TqBTVm8UoqGyy4fRFwI3s/uCpLIXWbKnzxGdL2Mx/koxOnjyKjpWBRB8A9bPBSrJ4IwGLR"
    "m0ZH7GNNdd3NSQaY+QbTvPGs+exiqXqC/7jmiJiIiWI5PeJX29RdC9fCeXqZuW6qXlStXz"
    "2boR+Cyfbiho30lAXqE+4TLVXu8cHbdWlcmX6Vqvle+wyM4ZL/L/TKCKZ1cVp35U+xXPla"
    "+GlmZ7t7jgJ3WAUSDIbyB5hccvJCrSR2pPNkv+k+IZd7Du0j031PJJsXX9/zshypT9pDg6"
    "CsoOe6zHBPOywOvUnkTVEpFOHjctVREWPCFF4asHwFAAQwH+WWjYy/HPXo4pBJklcplZws"
    "kZoY3kV6Ss2FlTo0WukpgmJ62EJlpu6fTJJaqFzRlI3WQNTg59siUdcVzK8npFQL1cIxyK"
    "JNdLHpPihv/fyVWnsH+mThL1kzLJmVHPfV/A9WSX6/F6uwNWDOvtkijEKjl3HoX7Tr//II"
    "7xRNsorI8n+suw3RPc8+vjiS78EETh92a3UfCOJnpzMOhj/LoCybkQ+DLR273fhNa43e81"
    "Cv5h9P3jtPmRE6Paqq2lyiniC+QkeDWShqJU2iYPRanET0RBrkW2pnY7c/rtD+OSl75Ix0"
    "QLcism5SfFKZoZZpqlJzzx0/lGy3uP3xB2nk2yCGiNi7B+gda40IaFNB2QpgMioyAy6sIj"
    "ozrSdIgsB4gYP7W+eJXETGH0RZOWS8FJdZr3kRD87UKEbus1mkx0HSK0pnxCEfU00qdSJk"
    "TRtXIXEXWIILJvpEMtcQiqLN4ksFXZZatsZNmpzfKQ0KVb5PRhVRstUrFAQaG8RB+cIL3s"
    "u6SxUmnwgfQF8gni4fdGNdEMmQirHqIp6aywGD6WDNGcUB3HBhWYImCKgFAApuiTNCwwRc"
    "AUAVMETNGlM0Wr5coavak6J81E6PpVIl9ESooWLpoywUTnZfAyChIyo45A1ohVppSOua3S"
    "PZCvybovpV6KZnKIZDGtlGWHe6GpT2l6h1updkWroIFH5bKzJbN8Qy5VeUFMWbgp4ISyyw"
    "l5GVX2CmCK1HHu+KVhc/TcKJDPid4fNjviS6clDBuF9fFEf262h2KnPxo1Cv5h9AU6TxQS"
    "pLZN5ujAfgf7Hcw8sN8/ScOC/Q72O9jvYL9fuP2OLQ17hCyLs81t8PJVkvUu44Ki5ZTczn"
    "bnIwx2a3btVtL0u9qrnuy57dQnoScMyZaj7sFEJ0vO6AalQqOwPs6GXQqGwkXok3E9BBTK"
    "7LcjKJSgUF6eQhmYzp38PYwsX/eu5OO3IdIkzi7VAS2xu84ElB9M/z62au2hwlGtA6BtUK"
    "2DDQWq9UWq1qbBWwW9WbX2ZM+tWr+MiMOHfGKlejRq46mVLkT3DjOiUhu6jXSG2sX3ZgRE"
    "8hIle2qPhinNRctYmTJrOuGnwY+InT4DfvE/ZytdJugWpitVs1Xd+kp+77+KR8H+KHnxp5"
    "pB9xKYfuDf1GyWipSYa44pD1nxGSCLZFs/g7HPIj8mPCqXE4/osQPCgdi4UGLDpYFTm8Rh"
    "ObCKU1jF1pqj39MwjjD+2cN7W/s43Jt2N5FnCCmkzAFs5Ee3qnwBe3Qj2YeFYyUHYdtgJo"
    "caC+zki7STLTldvia/fM5mlIPlaJKNxSK1ueuL5ERbhfg90F4Por26TGtq7TUsl7Ox5rza"
    "K3f7gZ2011x6IqLaa7g3ZSliiHjOWmSTF52ZHSZ4OVFfo/4r2SmZMXXt5aX9kEJZW61U5S"
    "uR2aXLbdbZAvwk/SXyUT0SOUlnxWtn9A2Oq/TpNmyF6jTlXitaonWc250xFobdkdh/FEfC"
    "8Hu7JTQK0TMTfTBsf2+2foiDfqfd+tEohL9P9K7w0G41OyKe25qNQvAbvtYcfsMTXu8JX/"
    "AO8dn+g9AR293BsP9dcDL5xk7t4kipbZN3tsZPO1uLZZ2VcP9Aafc1WQudkGA+mnJ5QH75"
    "HZlsEichdctaJC9uqWgy5C36ZCUpFTK7T+6gl4cEQS3PmFr+U7VfFawi6Tu0bFQWIuYgYu"
    "4072MWrCuImMv2EoymLBNXxVTFmsFH4jbEjHJXydsQByTS7UIMtlaWba2ZgY0kS/33zoZW"
    "qILTaY5FYv68dON4FkfdZqfTKNB/js300nWspZfuRO80h0/Y+KL/Jvrv7lfn/y6W0OG1Tt"
    "vedZvHiCQE3YSBRZL1IWqSPl8xGcJEaGOyAG4YXAyMqaiSLlp41EA7dmB+JQB3NMWITKME"
    "RDL3vpFNnXdDPLEeAB0cdZ+CEYBEGxfRsLBTLOwUe/bWOA6FsBct8KBK5oezFyx5Gk5+RU"
    "apqyRKQCHlxYUvsH2uRWAEsswIQPa65Ox1irmai/RLDCC+dy0klFf/2hE2GyU9Q7Q0g6F4"
    "bUc/hSo4b4Bhsdsf9hwPvHMw0TsvvdZzo0D/TfSHdq9HFjU6/yf6vfBAdJxGwT3ICP8kvS"
    "GG5ziZefJkTmgy+uNrhi1Giovoqf5pDIuwJLgZz+xmJClIGcs2knOWslahQtCzq2VgndFe"
    "sTJAPSBZXUgaR9EIiEVfCkfuqyufN5QfhFa72+z8Ui5dVSPjigd3NTZWa4Y+3wnGoBzguK"
    "ZBTSQbprITFcSrA8buM4/dQNteBLsHtO2FNmxGaVuI6YKYriKXkD1ZTBelZUfO/hxJzG2g"
    "yNVm2tbb8AM42yvgbC+fszXe8e1rGhkEFNXLrrAL3cis6Nxri74Lwx/iffOhUfCOJjr9So"
    "96/WGXpCh2/k/0p34fXyKfE52Wd074h9lgIaeG8iEuJdNOlQEsLLVXArBM2VxHyfQ1Q0hz"
    "A3+3xTcgAuAmgrtACyMNX+iVB7oQciRcrqkHNvyFNizY8GDDgw3Ps+GFBTIxqPJHC1dVZF"
    "jw4QJXSfY78oqKMi4Lxnv+jfepZhhKQrILjqkTksqJ2hhJx72N1VjmW43l+Ip9TcNvh5rO"
    "VR8SygmQJ9e/X01DV+U175EKYbY0QM2EOjDAG7qNh/VUDAhbGoz1RGPdUk2ki/tsSBau4Y"
    "TLYB1WLz6nFaO036jdofl/nP8Tvf/42Cjgj2zQfWDfX4QZCPb9hTZsRu17WFoFS6vOurTq"
    "GUma/dpF+MblIsOwD12/SrLrX2lJcUGLglmff7PeackEu36LbW7DVZzbz3zf6fcfxMFQGI"
    "1ehmTZSuj7RHe+j16emkPvIv0y0f8htJ+esfLp/J/oz0JzOBaHeBprFNbHu6ii19uootd8"
    "VfQ6porS0cOP4X2XtFXa6GpODXvHWWcszGIdaF3ZOtB6gSRrZe6kD0ZE86kQ5kQBhDUxmx"
    "oLnNxgK21vBGfCWAJnKDhDi1wz6GTOUG8PJk4wc/DyVZLB5G3QBDHMl2Ev2ZKJ0d/LXopU"
    "cW576Qk/NDZw6L+JjqHBFhD5nOj9FraQ8MdEH7RJskrymQ0i3oUwXa8OCR2yc59Vx9vYl+"
    "M7++3Ve2OVnLv/YpucprNw/k/08fNL934kvgwaBf/QP/vQ/0fPP0++TPSh8CT0BMfKXx9n"
    "o59jBJmxz1x1bC2wkzZ2hlgL2PsNTD4w+cDkO8UoAybfKYalvJp8PcNWZ26awCLD5gtdv0"
    "oy+vRASTD68m/0BdtzL+WZWdG5FWhni7Zxu9/ztmsjxyQRXHP4g+SBw/+oM6wzfha7wnjY"
    "blF/2PrrRBe6whCrzmQ/OP9woodNy1HrWXh46eAT3lE2XGm2amupgpp9AUiRGNwN0U6td/"
    "sieQHy1Iq3aolE+WToZ0l5DgNSkBw/EkMrvyJlpe1ky0Rl82nN5MR62cq3S/dO3aEh12KQ"
    "9gzSngG1ANTCHk0I1AJQC2mohYQdD1nFrrYlGmC/w8shHAL7Vey2Yxa7Ash7HpqinCRzuw"
    "EckwVsQ9iGFgrsiDG3DsCasxZ3N5yZ8oBxCON/rVRki6/GyrRErEaZLKaLa6owhXkWS17N"
    "zpAFwrQ+1gRiPTYpEgFibHBBRzqjW28HuSsKgG8EHKzxS7XGYYHzJTQsLHCGBc5nb40MLn"
    "AevErmQpI/igxSxb92lcSkLJ1Sbn4loE9yTZ+k3fcQtjyM5yhTFIw3Y+EkH8WASD6BrG0F"
    "ZC0ByFocyCUGIlVn9AVyEox87Bj4LOzBli0/fWBN+23ONmG7ACCNJXJWWTjsQhxOfto7hi"
    "jkvEvMeadaYqX6Kkrvkuo8dAztTZFQMXEIiYpB/GpoqiJ97AMzswqAGui1C2RhHHptL6rg"
    "gAvVpXfDxD1uoEkyKrKWqocKXCUuVneLiktSFizh/FvCtCH3WrIQruHcaxWe+6NBe0wyxn"
    "pHE32A4ek2ydID76i43Xh0ZMMFWIg8shDnNqCBhMgiCQEbZcGCclCEIeo7Ax5JiPre09N4"
    "MtOsS4NwteZyaeB7pzlGGPYZo9RVkpHmhPZqorQWAEst/5ZaoDkTNknmT4ws+XxOjzmZDr"
    "3HTpwPXw1rqdr4bU1rDMYEwSpcx+0bsm2YqSGNiOVENY9uRrbdbmRJ25HFrcOVift9Ovtw"
    "LZJLHI/SLyHV9IHNxNDytt3WNvCqgOUNYJB/CoMcAr8voWEzGvgNRAsQLcXzEy1PK1yFKj"
    "Gz9vnXrpJIlblbCpiU/DMpn8vvehyLkLj/RH21mLIGvg1uw4BcTuyaY3sP0UJStTQ4+gK5"
    "BPAoXdJEmpNP9VVdpoEyKpdLRGvbxQQkhARE4VQtEc9w6vsOoZ5rOTCiwYi+PFsLvNpgbO"
    "Xc2AqkyMQTIxI1VX9jMNP3rvDjt6E7S/LxHJGKOriefIH69zHtzjUmDMMzBBjf8ow0ENie"
    "ubY9beMN6WnUU1/gMNbn0TMxHF/RV1amPxTtErAelD93uDpWR8SH5o9GwT2Y6OTgH4LwzT"
    "lFjpxz3X5v/OycpIcT/aU3bnfEofC9/014aBRCX4s7NNbhE+fLGMO5Yaospyd/EWRYaq/1"
    "j9kKTjnOAkhd1lYKEq3VYkEyDhpEwY5P5IkmG6cKsN7CJM1fSxU3xA7WW1gyn9ZbTqy1rY"
    "Ku6P4H73hi3WnjBF8QVq8CvfEp6A3P+ZVyP9WI2GfcURWIoSsghrJHDLFe7gMgF3Sl5xe9"
    "yLC1O7Xm7ei+L6fmbCGfH0BPQKkZzO0RgnBtJNQM2AjhAvi0dxX93EnlDAmCxpkxjZO2Dp"
    "7DUnnyQ0Lgxo94D1Iq7zHBz6K+JyiYa0wOoCzl1F8W1ZZi/SRLcZ8D01gsmYtq3SuJisKS"
    "ljmClvCHW7XTJXCZd2RapJ4/QX84sf4QaYhd/EmRKs7tUnI3Xna3Vg5+m+j91lAUfh8Pm6"
    "1xoxD44lwZjYcvrfHLUHCu+V8n+nrXZ7Hde+wHt4GmJ3ZxNx1+rvtccb1HWaHoDURptK61"
    "yOmALL6Xv5b2GEyOHdBro8USG/d42Ed/pdrzOiaYl8556qWf75KpkqdN5VoOCUFm3U2ZdS"
    "EAuAgeMuArYBXtZ2lYn73eMm9vTHHak+93rNLva40qq7PQaTn/Z7rP5xO2IFHL0G1OnixG"
    "qask897dPXROBMgD2ZAo6+oSTHqnQfex6MM1nNugF34Xhq32CFvl3tFEf2gL2IInnxO903"
    "7Eo9yPDi7gHwZN9qC1PtGfhJ4wJPmR3YNsmO64IewVJ43v5vZaS5/QAh0IvYd27yne/b0r"
    "jYJ7MNEHw35LGI2ck/7xRG/1u4OOMCbhu/7hRH9stjvklPN/lwY6fCgvDSnA6FjsyGu+QR"
    "sTBIOWbdCG5qE0CMcEc+L6OjXALk+LO6SS0hcWl9xj4s0U0ClC2RbIlsicm4ZvCcoA3ZJI"
    "twA1cBEWJFADF9qwkGALQnszEG6R0QRbAzP02Ixwi8D1q+Sgi3VJYGPyz8YYsimSHpzWER"
    "qVA6OGadSoC/xCiiszVfaokFBOgD3BJkiggl+EpsZQwUFVA1UtT6pakHVR3OTke7oWu35F"
    "mRzez+JXDGDC0FnDiG3abwf01cvQVxVzNadbgIjO+6svVwx1IGETEY58XtweJ9mexcLvYy"
    "pQfYmcaquH9pfOTIQfRZcZqV74KIaEAEinL7rJoERF+mDMsFztMCa3k454BjwdFbFSrt5W"
    "69c3VV8z9M8kKYTxiEasxplJ+5Gx0QtLJdlLmQQxASFi7kTzBulKaoCCMhcOD4kXxsabul"
    "isdCSS6ZOh6G4KOI5XAMl5IgMd0Uvc1GqpZo2YIMwc9Bps5gV7Ph+yu14w/QYe8Eto2JgH"
    "POiqSx1RFRP9hCFVwEtfAS+dPV6a944fAL1oHEBWX+yNIDIGsBCYI2Fc6L10OucKyBiq1t"
    "ujJjHTZPnXrpJobROXEme42HasdnEo/PeX5su4/6VUuilMVpVSuYr/STIqTVbybak6WSk1"
    "pV4g/0ryZDW9vavjy8qMnJLrJVpKquHPcl3+SiXrMjl3SyQrU1qspuAv8p1Map7eIfIF3S"
    "i08LREPmek5rtbufBwT4uXiNRNqUyrVb4WI30gNzd9YM9A0vyy7dTivhX7OQXyMq9cJXgM"
    "LGNlyvstOIpUce4VR6MfWCvsd8XWs9D61iiEvk70YXv0TRwM+49tsuQo+G2id5r34lAYvX"
    "TGjcL6OPrabWOwl2+2MNjLUeU3sHHATWyNkQNy2vchJJYvlvckL0bAKYEnCwycksq1ExLK"
    "p5PsprpFV72pcrsqucRAEj8fShXWFZbKJ5blSn2b975S57/45BpzH4pUtOfejOfZobyubL"
    "MIsMJfBFiJ4rhAFttzyyc9AyJ5QfHUvKeJFKpnp3R7BMXA2RF54fGP4tt1PLQmko3FAuFn"
    "SrvdQ1I1kNkm7wu4m61x+zulRSPqr3OhUXD+Y4VXGPU738mKbO+ILMAfddujETnpH2ZDzQ"
    "U3ykWw7eBGudCGhYWE4AXIAIGd0YWETT+SZ2AaM5WiGCOw44WukpjsQHTQ0imfsUBtoGMP"
    "SMc6fgvcroaZKjdoVO70G08GIuSnK1WzVd36Sn72SEHyR0ljsTTRXMdj54e4n0XAqueEto"
    "Fu6IhhGfSwAoCRxhdJTifhqdfsjRsF917tiX4/FJqj8aMgOPmfplhnsewZQgpuIizRafZ6"
    "9MJSk3SdNFsmLIZ3SZZV3bFyX3H/ZjJlSUl1meLZeH/I7+Xp/QHr7SKUfLDeLrRhM2q9XY"
    "5qF7Pd0tghm+y8vo7GBv44spV37NY4jo23t91GU+8WOfaac/Fqk53mpONNH3JUW0fvyLd3"
    "NKyGROdMJRKJI9eQQoNvFIS/KBItVavW8anSFF+fTq9ppE5JUUjMzXU5FJwTisaZrJSbWj"
    "UxkOgMtwL2aHbt0fx5RthBQU6+YJqr1j/EFk+n3/omPIjP7adnkcQCNQqxU17SYbpdkJfc"
    "NnZqF1uosk3kRYUfeVGJRV6sF/OLDrSMCIwkbzdLGhzfbMe3RfLWotkMyba4MHQVW46uTb"
    "yt6cmv4fTW59GwP4qdqakzZNkfGhJVfWak6eNxSejfnP79sVjaxkK0VouFxOJU+CAzRAFl"
    "Dso0PjMV1RsQgXEieZxQVEvWJHXBsqb43TcsBT0XFrwyNLlLoYQYXF8mOCHw6INHv8hlez"
    "houo9PLJh/GtM9c85RzufJr/E3Y7oFwtlZ83fU3HMMbBjMGRtBPoXm7AXCaEQIdgByKRPk"
    "0hH3TXKJJ5+BOsROSkfYGthU53M8UvPXC7LfjahcXrTqY+M51Qz5DevCJNYi3c7VccmcZO"
    "YJQ1rdBtIqH9Iqt4sibMDNScJAEU81LCY0cfVEQi2wXiWSIs40DVPcYXlVTDAnPRhMbTC1"
    "IawGGpYbVuMYMmnth6AULNVPWKoPDNWh0QWG6sCZp+ZewNCesIWCjzL3+m8LXXBky1SiqY"
    "FJdlv3l0kP0dIwmduzswtebdgLTIyswSZCQGgBofUpCK0s0lfvqqWmT/geltozo3m2XMOM"
    "lOZLZKqGknZLgYjU6VSsu9Leo8bB9hNYKjPWCKtL5gcHNUcgyih9uLm2szrhM0dMNybDt8"
    "7wa3jf7jWHP9jUxz0jhuP+x1hoArsE7BKQEMAuQcNmetEW0B9AfxQbKQN0LGwIsaJd08Tl"
    "OLb3iNSUL0SPGpETRIWVNTsMWkLibFpQXDcUUBUXSVWYSFaXKtJtES0kNVWmVoZoTsM5ar"
    "VtCIZajc8wkGuR8APjDaUK5PAFDgPi0btvOJ/HVltslhO22CzHt9hEfy1VPPrsoLiGJfOp"
    "uOZEUfUeO9EEUS3RRO+4g6dNXhoWhIgbMNkv0LKLvy+u9pVW+wmJgXkHsQMZMZ5N3026p/"
    "nMdb9mD/ht7enQO7s5oAB4iP15iGPa3yNphmzcCpqNzI7B3LkqWuQqyQ63aGH866S0qBlb"
    "bmR1MmOcvzvi3hsi7mDSBJLn0V8iH9UjZc7buEUi3+g+y+TzWaICbcnEXTv9ypSwWD6ZjM"
    "NvEO3CwuqsG7FkdtasultPwGecfZHP2fvnUWA1THWu6pIm2ugvhpLJjwyICeYF1JNnJ8FK"
    "CAlb1CQZLQjhmxZpbgWAOBtxV9/Dajwr2CVh97SIXF7wjWz6tc0occ0fJK5jYwQwZRfElM"
    "WYhvOYel3yr71YmsY7HdRwP5IsxAwb5xW9SjL96ClRXUuR0FMiliKxKMni/qVUqgSyedZn"
    "cqFM0m7WaSbOO6VM0nLK1XCOzl/WGT/rZGtgmewZPL2TiIxy42wDLEnk3PVtnYqWyZ7B5Q"
    "rZ9xefK/kbCJevyXG5Ov2VnXA0W7c40fGfV/T2tk7upoxrn8qzqvep3FyTWuU7kiS1VJJu"
    "K/UvlULC3cjY5CGnKu6OyyT36Y10h3+s238QOmK7Oxj2vwtdoTemt6bckR+v1Z3cq8y7nd"
    "7J9DmvkUz2db6pHyOFKhj3Oxj37ksqviPTYu43z5+9GaJ5dAYfPl7/J0JvRKlhkcjJ03dY"
    "Mp/Td06m6608wbQ9kM4YbLZoR1cOWvHcrajh4hRdJ9M5bqeVzng1uVwmV/50brUMLRd5Ve"
    "evoiGbGAbTRHSGS41oYh2fElX7dbWYWqJi/MRIvEp2akj5FXxOPA1b0ugGwqaSZkVYTO5T"
    "okeqJyacQazwGHgbN3AOisKmzeHFdhZaKYb+sVD/vRPBw5IHDePcGkagVZxV8xp6R6nCk/"
    "k15JMUrWzlO6kk+E4qcd8J8KKfkxcN7nVpLJY+5bDnmpwBrez7mr7InJv3LItyKP3rocKj"
    "hwOobeKEg421Gw/cbEfZ0alcr1JykpCLFUUpeHzjtF6pbcfc7lIpg7H8w31KChIu4rFhfw"
    "KVucvUvweVGW6HbSfesFQ+J9ujBCrswAgfnAk+vdZyaC44eFsxJBN28wiL5SQq6eSRHvnL"
    "XNRq9h7aNH9NfOrzrzUK/uFEfxAGnf4PkpPIO5roQ6yxDckp9yA64Z2nr4N6/jnV82Mqo2"
    "EdnZnjLqLEJ+W2ixkPu8YlKLUS1QtvZO9YqUxjbvu0KukO9ZIIAAcCEmGg3BAR+daNKqjJ"
    "zoamvxberUIIKCccIVAlCUFwIgZC9f9a8Hz70+mM6sgK0ZFJpAD+aWdTLy/Qo0H3VaU7ql"
    "ZoHACJjKBxBtVQXAQppdAQhrIcfbL1bZDfr9FwBHzFj2uolqlufkcquZPpjyh3jtJehpiC"
    "jCji7nvGj2nfPDdHqjj3RqzPQrMzfhaf8LPjyTn4baL3W0MRayvDZmvcKAS+OFdG4+FLa/"
    "wyFJxr/teJ3hUe2i1nN9Z277HfKERO7DKnHz6iHqyAQ2hGNlosNfzEqUORY4J5QfTUpkAw"
    "8JC3YoEPM1sasP7EZldzQKMcsY3lHRGz6zehNXbsLucIDK/zd/8LM7wgGeLFNWwsGWLYcG"
    "KuV+RbHkzhPQyRTPGEG82OGIiuqbAThiHZTwJhQuaLECpxOHdIgOFVlFX8NiZuYHUUzmYQ"
    "/Bf8AFAmrMnJO7bhgSwDO238/f+tdJE8"
)
