-- =============================================
-- Kaizen 3D Printing Platform - Database Schema
-- Version: 1.0.0
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- Table: users
-- =============================================
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `telegram_id` BIGINT UNIQUE,
    `name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) UNIQUE,
    `phone` VARCHAR(20),
    `password_hash` VARCHAR(255),
    `role` ENUM('user', 'admin', 'operator') DEFAULT 'user',
    `status` ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    `email_verified` BOOLEAN DEFAULT FALSE,
    `phone_verified` BOOLEAN DEFAULT FALSE,
    `avatar_url` VARCHAR(500),
    `preferences` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `last_login_at` TIMESTAMP NULL,

    INDEX `idx_telegram_id` (`telegram_id`),
    INDEX `idx_email` (`email`),
    INDEX `idx_phone` (`phone`),
    INDEX `idx_role` (`role`),
    INDEX `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: files
-- =============================================
CREATE TABLE IF NOT EXISTS `files` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `original_name` VARCHAR(255) NOT NULL,
    `stored_name` VARCHAR(255) NOT NULL UNIQUE,
    `file_path` VARCHAR(500) NOT NULL,
    `file_size` BIGINT NOT NULL,
    `file_type` VARCHAR(50) NOT NULL,
    `mime_type` VARCHAR(100),
    `file_hash` VARCHAR(64),
    `name` VARCHAR(255),
    `description` TEXT,
    `metadata` JSON,
    `thumbnail_path` VARCHAR(500),
    `status` ENUM('processing', 'ready', 'error') DEFAULT 'ready',
    `error_message` TEXT,
    `downloads_count` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,

    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_file_type` (`file_type`),
    INDEX `idx_file_hash` (`file_hash`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: materials
-- =============================================
CREATE TABLE IF NOT EXISTS `materials` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) UNIQUE NOT NULL,
    `display_name` VARCHAR(100),
    `description` TEXT,
    `price_per_gram` INT NOT NULL,
    `available_colors` JSON,
    `properties` JSON,
    `in_stock` BOOLEAN DEFAULT TRUE,
    `sort_order` INT DEFAULT 0,
    `active` BOOLEAN DEFAULT TRUE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_name` (`name`),
    INDEX `idx_active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: orders
-- =============================================
CREATE TABLE IF NOT EXISTS `orders` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_number` VARCHAR(50) UNIQUE NOT NULL,
    `user_id` INT NOT NULL,
    `file_id` INT NOT NULL,

    -- Print specifications
    `material` VARCHAR(50) NOT NULL,
    `color` VARCHAR(50),
    `infill` INT DEFAULT 20,
    `layer_height` DECIMAL(4,2) DEFAULT 0.20,
    `quality` ENUM('draft', 'normal', 'high') DEFAULT 'normal',
    `supports` BOOLEAN DEFAULT TRUE,
    `raft` BOOLEAN DEFAULT FALSE,

    -- Order info
    `quantity` INT DEFAULT 1,
    `urgent` BOOLEAN DEFAULT FALSE,
    `notes` TEXT,
    `customer_notes` TEXT,

    -- Pricing
    `estimated_price` INT,
    `final_price` INT,
    `discount` INT DEFAULT 0,
    `tax` INT DEFAULT 0,
    `total_price` INT,

    -- Timing
    `estimated_weight` DECIMAL(10,2),
    `estimated_duration` INT,
    `estimated_completion_date` DATETIME,
    `actual_completion_date` DATETIME,

    -- Status
    `status` ENUM(
        'pending',
        'confirmed',
        'processing',
        'completed',
        'delivered',
        'cancelled',
        'failed'
    ) DEFAULT 'pending',
    `status_updated_at` TIMESTAMP NULL,

    -- Payment
    `payment_status` ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    `payment_method` VARCHAR(50),
    `payment_reference` VARCHAR(100),

    -- Additional
    `assigned_to` INT,
    `priority` INT DEFAULT 0,
    `source` ENUM('website', 'telegram', 'api') DEFAULT 'website',

    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`file_id`) REFERENCES `files`(`id`) ON DELETE RESTRICT,
    FOREIGN KEY (`assigned_to`) REFERENCES `users`(`id`) ON DELETE SET NULL,

    INDEX `idx_order_number` (`order_number`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_payment_status` (`payment_status`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_priority` (`priority`),
    INDEX `idx_user_status` (`user_id`, `status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: order_timeline
-- =============================================
CREATE TABLE IF NOT EXISTS `order_timeline` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `status` VARCHAR(50) NOT NULL,
    `note` TEXT,
    `changed_by` INT,
    `metadata` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`changed_by`) REFERENCES `users`(`id`) ON DELETE SET NULL,

    INDEX `idx_order_id` (`order_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: notifications
-- =============================================
CREATE TABLE IF NOT EXISTS `notifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `type` VARCHAR(50) NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `message` TEXT NOT NULL,
    `data` JSON,
    `read` BOOLEAN DEFAULT FALSE,
    `read_at` TIMESTAMP NULL,
    `sent_via_telegram` BOOLEAN DEFAULT FALSE,
    `sent_via_email` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,

    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_read` (`read`),
    INDEX `idx_type` (`type`),
    INDEX `idx_created_at` (`created_at`),
    INDEX `idx_user_read` (`user_id`, `read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: sessions
-- =============================================
CREATE TABLE IF NOT EXISTS `sessions` (
    `id` VARCHAR(128) PRIMARY KEY,
    `user_id` INT,
    `ip_address` VARCHAR(45),
    `user_agent` VARCHAR(500),
    `payload` TEXT,
    `last_activity` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,

    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_last_activity` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: api_tokens
-- =============================================
CREATE TABLE IF NOT EXISTS `api_tokens` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL,
    `token` VARCHAR(255) UNIQUE NOT NULL,
    `token_type` ENUM('jwt', 'api_key') DEFAULT 'jwt',
    `abilities` JSON,
    `expires_at` TIMESTAMP NULL,
    `last_used_at` TIMESTAMP NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,

    INDEX `idx_token` (`token`),
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: settings
-- =============================================
CREATE TABLE IF NOT EXISTS `settings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) UNIQUE NOT NULL,
    `value` TEXT,
    `type` VARCHAR(50) DEFAULT 'string',
    `group` VARCHAR(50),
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX `idx_key` (`key`),
    INDEX `idx_group` (`group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: activity_log
-- =============================================
CREATE TABLE IF NOT EXISTS `activity_log` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT,
    `action` VARCHAR(100) NOT NULL,
    `entity_type` VARCHAR(50),
    `entity_id` INT,
    `description` TEXT,
    `ip_address` VARCHAR(45),
    `user_agent` VARCHAR(500),
    `metadata` JSON,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE SET NULL,

    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_action` (`action`),
    INDEX `idx_entity` (`entity_type`, `entity_id`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Table: sync_log (for Telegram integration)
-- =============================================
CREATE TABLE IF NOT EXISTS `sync_log` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `entity_type` ENUM('user', 'order', 'file', 'notification') NOT NULL,
    `entity_id` INT NOT NULL,
    `action` ENUM('create', 'update', 'delete') NOT NULL,
    `source` ENUM('website', 'telegram') NOT NULL,
    `synced` BOOLEAN DEFAULT FALSE,
    `sync_attempts` INT DEFAULT 0,
    `last_sync_at` TIMESTAMP NULL,
    `error_message` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX `idx_synced` (`synced`),
    INDEX `idx_entity` (`entity_type`, `entity_id`),
    INDEX `idx_source` (`source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- Views
-- =============================================

-- Unified users view
CREATE OR REPLACE VIEW `unified_users` AS
SELECT
    `id`,
    `telegram_id`,
    `name`,
    `email`,
    `phone`,
    `role`,
    `status`,
    CASE
        WHEN `telegram_id` IS NOT NULL THEN 'telegram'
        ELSE 'website'
    END AS `registration_source`,
    `created_at`
FROM `users`;

-- Order statistics view
CREATE OR REPLACE VIEW `order_statistics` AS
SELECT
    DATE(`created_at`) AS `date`,
    COUNT(*) AS `total_orders`,
    SUM(CASE WHEN `status` = 'completed' THEN 1 ELSE 0 END) AS `completed_orders`,
    SUM(CASE WHEN `status` = 'cancelled' THEN 1 ELSE 0 END) AS `cancelled_orders`,
    SUM(`total_price`) AS `total_revenue`,
    AVG(`total_price`) AS `avg_order_value`
FROM `orders`
GROUP BY DATE(`created_at`);

-- =============================================
-- Triggers
-- =============================================

DELIMITER //

-- After order insert trigger
CREATE TRIGGER `after_order_insert`
AFTER INSERT ON `orders`
FOR EACH ROW
BEGIN
    -- Add to timeline
    INSERT INTO `order_timeline` (`order_id`, `status`, `note`, `changed_by`)
    VALUES (NEW.`id`, NEW.`status`, 'سفارش ثبت شد', NEW.`user_id`);

    -- Create notification
    INSERT INTO `notifications` (`user_id`, `type`, `title`, `message`, `data`)
    VALUES (
        NEW.`user_id`,
        'order_status',
        'سفارش جدید ثبت شد',
        CONCAT('سفارش شماره ', NEW.`order_number`, ' با موفقیت ثبت شد'),
        JSON_OBJECT('order_id', NEW.`id`, 'order_number', NEW.`order_number`)
    );

    -- Log for sync
    INSERT INTO `sync_log` (`entity_type`, `entity_id`, `action`, `source`)
    VALUES ('order', NEW.`id`, 'create', NEW.`source`);
END //

-- After order update trigger
CREATE TRIGGER `after_order_update`
AFTER UPDATE ON `orders`
FOR EACH ROW
BEGIN
    IF OLD.`status` != NEW.`status` THEN
        -- Add to timeline
        INSERT INTO `order_timeline` (`order_id`, `status`, `note`)
        VALUES (NEW.`id`, NEW.`status`, CONCAT('وضعیت از ', OLD.`status`, ' به ', NEW.`status`, ' تغییر کرد'));

        -- Create notification
        INSERT INTO `notifications` (`user_id`, `type`, `title`, `message`, `data`)
        VALUES (
            NEW.`user_id`,
            'order_status',
            'تغییر وضعیت سفارش',
            CONCAT('سفارش ', NEW.`order_number`, ' به وضعیت ', NEW.`status`, ' تغییر کرد'),
            JSON_OBJECT('order_id', NEW.`id`, 'old_status', OLD.`status`, 'new_status', NEW.`status`)
        );
    END IF;
END //

DELIMITER ;

-- =============================================
-- Initial Data
-- =============================================

-- Default materials
INSERT INTO `materials` (`name`, `display_name`, `description`, `price_per_gram`, `available_colors`, `properties`) VALUES
('PLA', 'PLA Standard', 'پلاستیک PLA مناسب برای اکثر کاربردها', 5000,
 '["سفید", "مشکی", "قرمز", "آبی", "سبز", "زرد"]',
 '{"temp_print": 200, "temp_bed": 60, "density": 1.24, "strength": "متوسط"}'),

('ABS', 'ABS Engineering', 'پلاستیک ABS مقاوم در برابر حرارت', 6000,
 '["سفید", "مشکی", "خاکستری"]',
 '{"temp_print": 230, "temp_bed": 100, "density": 1.04, "strength": "بالا"}'),

('PETG', 'PETG Flexible', 'پلاستیک PETG انعطاف‌پذیر', 7000,
 '["شفاف", "سفید", "مشکی", "آبی"]',
 '{"temp_print": 235, "temp_bed": 85, "density": 1.27, "strength": "بالا"}'),

('TPU', 'TPU Flexible', 'پلاستیک انعطاف‌پذیر TPU', 12000,
 '["سفید", "مشکی", "قرمز"]',
 '{"temp_print": 220, "temp_bed": 50, "density": 1.21, "strength": "انعطاف‌پذیر"}');

-- Default settings
INSERT INTO `settings` (`key`, `value`, `type`, `group`, `description`) VALUES
('site_name', 'Kaizen 3D Printing', 'string', 'general', 'نام سایت'),
('site_description', 'سیستم مدیریت سفارشات پرینت سه‌بعدی', 'string', 'general', 'توضیحات سایت'),
('default_currency', 'IRR', 'string', 'pricing', 'واحد پول پیش‌فرض'),
('price_per_gram', '5000', 'int', 'pricing', 'قیمت پیش‌فرض هر گرم'),
('default_material', 'PLA', 'string', 'general', 'ماده پیش‌فرض'),
('enable_registration', 'true', 'boolean', 'general', 'فعال‌سازی ثبت‌نام'),
('require_email_verification', 'false', 'boolean', 'general', 'نیاز به تایید ایمیل'),
('max_file_size', '52428800', 'int', 'upload', 'حداکثر حجم فایل (بایت)'),
('allowed_extensions', '["stl", "obj", "gcode", "3mf", "step", "stp"]', 'json', 'upload', 'فرمت‌های مجاز'),
('telegram_notifications', 'true', 'boolean', 'notifications', 'نوتیفیکیشن تلگرام فعال');

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- End of Schema
-- =============================================
