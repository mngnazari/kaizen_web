# 🗄️ Database Schema Documentation

این مستند ساختار کامل دیتابیس سیستم مدیریت پرینت سه‌بعدی Kaizen را شرح می‌دهد.

## 📋 جداول اصلی

### 1. users - کاربران سیستم

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telegram_id BIGINT UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    role ENUM('user', 'admin', 'operator') DEFAULT 'user',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    avatar_url VARCHAR(500),
    preferences JSON,  -- تنظیمات شخصی کاربر
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,

    INDEX idx_telegram_id (telegram_id),
    INDEX idx_email (email),
    INDEX idx_phone (phone),
    INDEX idx_role (role),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**فیلدها:**
- `id`: شناسه یکتا
- `telegram_id`: شناسه تلگرام (برای اتصال به بات)
- `name`: نام کاربر
- `email`: ایمیل (اختیاری)
- `phone`: شماره تلفن
- `password_hash`: رمز عبور هش شده (bcrypt)
- `role`: نقش کاربر (user, admin, operator)
- `status`: وضعیت حساب
- `preferences`: تنظیمات شخصی (JSON)

**Example Data:**
```sql
INSERT INTO users (telegram_id, name, email, phone, password_hash, role) VALUES
(123456789, 'علی احمدی', 'ali@example.com', '09123456789', '$2y$12$...', 'user'),
(987654321, 'Admin', 'admin@kaizen.com', '09121234567', '$2y$12$...', 'admin');
```

---

### 2. files - فایل‌های آپلود شده

```sql
CREATE TABLE files (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    stored_name VARCHAR(255) NOT NULL UNIQUE,
    file_path VARCHAR(500) NOT NULL,
    file_size BIGINT NOT NULL,  -- به بایت
    file_type VARCHAR(50) NOT NULL,  -- stl, obj, gcode, etc.
    mime_type VARCHAR(100),
    file_hash VARCHAR(64),  -- SHA256 hash برای تشخیص duplicate
    name VARCHAR(255),  -- نام دلخواه کاربر
    description TEXT,
    metadata JSON,  -- اطلاعات اضافی (ابعاد، وزن تخمینی، etc.)
    thumbnail_path VARCHAR(500),  -- پیش‌نمایش (در آینده)
    status ENUM('processing', 'ready', 'error') DEFAULT 'ready',
    error_message TEXT,
    downloads_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    INDEX idx_file_type (file_type),
    INDEX idx_file_hash (file_hash),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Metadata Example (JSON):**
```json
{
    "dimensions": {
        "x": 100.5,
        "y": 50.2,
        "z": 25.8,
        "unit": "mm"
    },
    "estimated_weight": 45.5,
    "volume": 1250,
    "triangles": 15000
}
```

---

### 3. orders - سفارشات

```sql
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,  -- KZ-20240115-0001
    user_id INT NOT NULL,
    file_id INT NOT NULL,

    -- مشخصات پرینت
    material VARCHAR(50) NOT NULL,  -- PLA, ABS, PETG, TPU, Nylon
    color VARCHAR(50),
    infill INT DEFAULT 20,  -- درصد
    layer_height DECIMAL(4,2) DEFAULT 0.20,  -- mm
    quality ENUM('draft', 'normal', 'high') DEFAULT 'normal',
    supports BOOLEAN DEFAULT TRUE,
    raft BOOLEAN DEFAULT FALSE,

    -- اطلاعات سفارش
    quantity INT DEFAULT 1,
    urgent BOOLEAN DEFAULT FALSE,
    notes TEXT,
    customer_notes TEXT,  -- یادداشت مشتری

    -- قیمت‌گذاری
    estimated_price INT,  -- تومان
    final_price INT,
    discount INT DEFAULT 0,
    tax INT DEFAULT 0,
    total_price INT,

    -- زمان‌بندی
    estimated_weight DECIMAL(10,2),  -- گرم
    estimated_duration INT,  -- دقیقه
    estimated_completion_date DATETIME,
    actual_completion_date DATETIME,

    -- وضعیت
    status ENUM(
        'pending',      -- در انتظار تایید
        'confirmed',    -- تایید شده
        'processing',   -- در حال پرینت
        'completed',    -- تکمیل شده
        'delivered',    -- تحویل داده شده
        'cancelled',    -- لغو شده
        'failed'        -- ناموفق
    ) DEFAULT 'pending',
    status_updated_at TIMESTAMP,

    -- پرداخت
    payment_status ENUM('unpaid', 'paid', 'refunded') DEFAULT 'unpaid',
    payment_method VARCHAR(50),  -- cash, online, etc.
    payment_reference VARCHAR(100),

    -- اطلاعات اضافی
    assigned_to INT,  -- operator_id
    priority INT DEFAULT 0,  -- 0: عادی, 1-5: اولویت
    source ENUM('website', 'telegram', 'api') DEFAULT 'website',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE RESTRICT,
    FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_order_number (order_number),
    INDEX idx_user_id (user_id),
    INDEX idx_status (status),
    INDEX idx_payment_status (payment_status),
    INDEX idx_created_at (created_at),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Order Number Format:**
```
KZ-YYYYMMDD-NNNN
KZ-20240115-0001
```

---

### 4. order_timeline - تاریخچه سفارش

```sql
CREATE TABLE order_timeline (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    note TEXT,
    changed_by INT,  -- user_id که تغییر ایجاد کرد
    metadata JSON,  -- اطلاعات اضافی
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_order_id (order_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Example:**
```sql
INSERT INTO order_timeline (order_id, status, note, changed_by) VALUES
(1, 'pending', 'سفارش ثبت شد', 1),
(1, 'confirmed', 'سفارش تایید شد', 2),
(1, 'processing', 'پرینت شروع شد', 2);
```

---

### 5. notifications - نوتیفیکیشن‌ها

```sql
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,  -- order_status, payment, system, etc.
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    data JSON,  -- داده‌های اضافی
    read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    sent_via_telegram BOOLEAN DEFAULT FALSE,
    sent_via_email BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    INDEX idx_read (read),
    INDEX idx_type (type),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Types:**
- `order_status`: تغییر وضعیت سفارش
- `payment`: پرداخت
- `system`: اطلاعیه سیستم
- `promotion`: تخفیف و پیشنهاد

---

### 6. sessions - نشست‌های کاربری

```sql
CREATE TABLE sessions (
    id VARCHAR(128) PRIMARY KEY,
    user_id INT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    payload TEXT,
    last_activity TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_user_id (user_id),
    INDEX idx_last_activity (last_activity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 7. api_tokens - توکن‌های API

```sql
CREATE TABLE api_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    token_type ENUM('jwt', 'api_key') DEFAULT 'jwt',
    abilities JSON,  -- دسترسی‌ها
    expires_at TIMESTAMP NULL,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,

    INDEX idx_token (token),
    INDEX idx_user_id (user_id),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### 8. settings - تنظیمات سیستم

```sql
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT,
    type VARCHAR(50) DEFAULT 'string',  -- string, int, float, boolean, json
    group VARCHAR(50),  -- pricing, general, email, etc.
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_key (key),
    INDEX idx_group (group)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Example:**
```sql
INSERT INTO settings (key, value, type, `group`, description) VALUES
('price_per_gram', '5000', 'int', 'pricing', 'قیمت هر گرم (تومان)'),
('default_material', 'PLA', 'string', 'general', 'ماده پیش‌فرض'),
('enable_registration', 'true', 'boolean', 'general', 'فعال‌سازی ثبت‌نام'),
('supported_materials', '["PLA","ABS","PETG","TPU"]', 'json', 'general', 'مواد پشتیبانی شده');
```

---

### 9. materials - مواد اولیه

```sql
CREATE TABLE materials (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    description TEXT,
    price_per_gram INT NOT NULL,  -- تومان
    available_colors JSON,
    properties JSON,  -- مشخصات فنی
    in_stock BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_name (name),
    INDEX idx_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Example:**
```sql
INSERT INTO materials (name, display_name, price_per_gram, available_colors, properties) VALUES
('PLA', 'PLA پلاستیک', 5000, '["سفید","مشکی","قرمز","آبی"]',
 '{"temp_print":200,"temp_bed":60,"density":1.24}'),
('ABS', 'ABS پلاستیک', 6000, '["سفید","مشکی"]',
 '{"temp_print":230,"temp_bed":100,"density":1.04}');
```

---

### 10. activity_log - لاگ فعالیت‌ها

```sql
CREATE TABLE activity_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),  -- user, order, file, etc.
    entity_id INT,
    description TEXT,
    ip_address VARCHAR(45),
    user_agent VARCHAR(500),
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,

    INDEX idx_user_id (user_id),
    INDEX idx_action (action),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Actions:**
- `user.login`, `user.logout`, `user.register`
- `order.create`, `order.update`, `order.cancel`
- `file.upload`, `file.download`, `file.delete`

---

## 🔗 جداول یکپارچگی با تلگرام

### 11. sync_log - لاگ همگام‌سازی

```sql
CREATE TABLE sync_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('user', 'order', 'file', 'notification') NOT NULL,
    entity_id INT NOT NULL,
    action ENUM('create', 'update', 'delete') NOT NULL,
    source ENUM('website', 'telegram') NOT NULL,
    synced BOOLEAN DEFAULT FALSE,
    sync_attempts INT DEFAULT 0,
    last_sync_at TIMESTAMP NULL,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_synced (synced),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 📊 Views

### unified_users - نمای یکپارچه کاربران

```sql
CREATE VIEW unified_users AS
SELECT
    u.id,
    u.telegram_id,
    u.name,
    u.email,
    u.phone,
    u.role,
    u.status,
    CASE
        WHEN u.telegram_id IS NOT NULL THEN 'telegram'
        ELSE 'website'
    END AS registration_source,
    u.created_at
FROM users u;
```

### order_statistics - آمار سفارشات

```sql
CREATE VIEW order_statistics AS
SELECT
    DATE(created_at) AS date,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
    SUM(total_price) AS total_revenue,
    AVG(total_price) AS avg_order_value
FROM orders
GROUP BY DATE(created_at);
```

---

## 🔐 Stored Procedures

### generate_order_number - تولید شماره سفارش

```sql
DELIMITER //

CREATE PROCEDURE generate_order_number(OUT order_num VARCHAR(50))
BEGIN
    DECLARE today_count INT;
    DECLARE today_date VARCHAR(8);

    SET today_date = DATE_FORMAT(NOW(), '%Y%m%d');

    SELECT COUNT(*) INTO today_count
    FROM orders
    WHERE DATE(created_at) = CURDATE();

    SET order_num = CONCAT('KZ-', today_date, '-', LPAD(today_count + 1, 4, '0'));
END //

DELIMITER ;
```

**Usage:**
```sql
CALL generate_order_number(@order_number);
SELECT @order_number;  -- KZ-20240115-0001
```

---

## 🔍 Triggers

### after_order_insert - بعد از ثبت سفارش

```sql
DELIMITER //

CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    -- ثبت در timeline
    INSERT INTO order_timeline (order_id, status, note, changed_by)
    VALUES (NEW.id, NEW.status, 'سفارش ثبت شد', NEW.user_id);

    -- ثبت نوتیفیکیشن
    INSERT INTO notifications (user_id, type, title, message, data)
    VALUES (
        NEW.user_id,
        'order_status',
        'سفارش جدید ثبت شد',
        CONCAT('سفارش شماره ', NEW.order_number, ' با موفقیت ثبت شد'),
        JSON_OBJECT('order_id', NEW.id, 'order_number', NEW.order_number)
    );

    -- ثبت در لاگ همگام‌سازی
    INSERT INTO sync_log (entity_type, entity_id, action, source)
    VALUES ('order', NEW.id, 'create', NEW.source);
END //

DELIMITER ;
```

### after_order_update - بعد از به‌روزرسانی سفارش

```sql
DELIMITER //

CREATE TRIGGER after_order_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    -- اگر وضعیت تغییر کرد
    IF OLD.status != NEW.status THEN
        -- ثبت در timeline
        INSERT INTO order_timeline (order_id, status, note)
        VALUES (NEW.id, NEW.status, CONCAT('وضعیت از ', OLD.status, ' به ', NEW.status, ' تغییر کرد'));

        -- ارسال نوتیفیکیشن
        INSERT INTO notifications (user_id, type, title, message, data)
        VALUES (
            NEW.user_id,
            'order_status',
            'تغییر وضعیت سفارش',
            CONCAT('سفارش ', NEW.order_number, ' ', NEW.status, ' شد'),
            JSON_OBJECT('order_id', NEW.id, 'old_status', OLD.status, 'new_status', NEW.status)
        );
    END IF;
END //

DELIMITER ;
```

---

## 📈 Indexes برای بهینه‌سازی

```sql
-- بهینه‌سازی جستجو
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
CREATE INDEX idx_files_user_type ON files(user_id, file_type);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read);

-- Full-text search
ALTER TABLE files ADD FULLTEXT INDEX ft_name_desc (name, description);
```

---

## 🧪 Sample Data

```sql
-- کاربر نمونه
INSERT INTO users (telegram_id, name, email, phone, password_hash, role) VALUES
(123456789, 'علی احمدی', 'ali@example.com', '09123456789', '$2y$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyMpW5AlO4nS', 'user');

-- مواد نمونه
INSERT INTO materials (name, display_name, price_per_gram, available_colors) VALUES
('PLA', 'PLA Standard', 5000, '["سفید","مشکی","قرمز","آبی","سبز"]'),
('ABS', 'ABS Engineering', 6000, '["سفید","مشکی"]'),
('PETG', 'PETG Flexible', 7000, '["شفاف","سفید","مشکی"]');

-- تنظیمات نمونه
INSERT INTO settings (`key`, value, type, `group`) VALUES
('site_name', 'Kaizen 3D Printing', 'string', 'general'),
('default_currency', 'IRR', 'string', 'pricing'),
('enable_registration', 'true', 'boolean', 'general');
```

---

## 🔧 Maintenance Queries

### پاک‌سازی لاگ‌های قدیمی

```sql
-- حذف لاگ‌های بیش از 90 روز
DELETE FROM activity_log WHERE created_at < DATE_SUB(NOW(), INTERVAL 90 DAY);
DELETE FROM sync_log WHERE synced = TRUE AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY);
```

### بهینه‌سازی جداول

```sql
OPTIMIZE TABLE users, orders, files, notifications;
```

### آمار دیتابیس

```sql
SELECT
    table_name,
    table_rows,
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'kaizen_3d'
ORDER BY (data_length + index_length) DESC;
```

---

## 📦 Backup

```bash
# Full backup
mysqldump -u root -p kaizen_3d > backup_$(date +%Y%m%d).sql

# Structure only
mysqldump -u root -p --no-data kaizen_3d > schema.sql

# Data only
mysqldump -u root -p --no-create-info kaizen_3d > data.sql
```

---

**Version**: 1.0.0
**Last Updated**: 2024-01-15
