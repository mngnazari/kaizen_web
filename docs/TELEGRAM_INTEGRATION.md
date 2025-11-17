# 🤖 راهنمای اتصال به بات تلگرام

این مستند نحوه یکپارچه‌سازی وب‌سایت با بات تلگرام موجود را شرح می‌دهد.

## 🎯 اهداف یکپارچگی

1. **اشتراک دیتابیس**: وب‌سایت و بات از یک دیتابیس استفاده می‌کنند
2. **Sync دوطرفه**: سفارشات از هر دو طرف قابل ثبت و مشاهده هستند
3. **نوتیفیکیشن**: رویدادهای مهم از طریق تلگرام اطلاع‌رسانی می‌شوند
4. **احراز هویت**: کاربران بات می‌توانند با Telegram ID وارد وب‌سایت شوند

---

## 🏗️ معماری یکپارچگی

```
┌─────────────────────────────────────────────────────┐
│                  TELEGRAM BOT                        │
│              (بات موجود شما)                        │
│                                                       │
│  - دریافت سفارشات از کاربران                        │
│  - مدیریت کاربران                                   │
│  - ارسال نوتیفیکیشن                                 │
└──────────────────┬──────────────────────────────────┘
                   │
                   │  1. Shared Database
                   │  2. Webhook
                   │  3. API Calls
                   │
┌──────────────────▼──────────────────────────────────┐
│              SHARED MYSQL DATABASE                   │
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │  Existing Bot Tables                          │   │
│  │  - bot_users                                  │   │
│  │  - bot_orders                                 │   │
│  │  - bot_files                                  │   │
│  └──────────────────────────────────────────────┘   │
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │  Website Tables                               │   │
│  │  - web_users (با foreign key به telegram_id) │   │
│  │  - web_orders                                 │   │
│  │  - web_files                                  │   │
│  └──────────────────────────────────────────────┘   │
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │  Shared/Bridge Tables                         │   │
│  │  - unified_users (view)                       │   │
│  │  - unified_orders (view)                      │   │
│  │  - sync_log                                   │   │
│  └──────────────────────────────────────────────┘   │
└──────────────────┬──────────────────────────────────┘
                   │
                   │
┌──────────────────▼──────────────────────────────────┐
│                 WEBSITE (PHP)                        │
│                                                       │
│  - دریافت سفارشات از مشتریان                        │
│  - نمایش وضعیت سفارشات                              │
│  - ارسال نوتیفیکیشن به بات                          │
└─────────────────────────────────────────────────────┘
```

---

## 🔧 روش‌های اتصال

### روش 1: Shared Database (پیشنهاد اول)

ساده‌ترین و بهترین روش برای شما.

#### مزایا:
- ✅ بدون نیاز به API پیچیده
- ✅ Real-time sync
- ✅ کارایی بالا
- ✅ پیاده‌سازی ساده

#### پیاده‌سازی:

**1. شناسایی جداول بات:**

ابتدا ساختار دیتابیس بات را بررسی کنید:

```sql
-- وارد دیتابیس بات شوید
USE telegram_bot_database;

-- لیست جداول
SHOW TABLES;

-- ساختار جدول کاربران بات
DESCRIBE users;  -- یا bot_users یا هر نام دیگر

-- ساختار جدول سفارشات بات
DESCRIBE orders;
```

**2. ایجاد جداول وب‌سایت در همان دیتابیس:**

```sql
-- جدول کاربران وب (با لینک به کاربران بات)
CREATE TABLE web_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telegram_user_id INT,  -- لینک به جدول کاربران بات
    email VARCHAR(255) UNIQUE,
    password_hash VARCHAR(255),
    created_via ENUM('telegram', 'website') DEFAULT 'website',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Foreign Key به جدول بات
    FOREIGN KEY (telegram_user_id) REFERENCES bot_users(telegram_id) ON DELETE CASCADE,

    INDEX idx_telegram_user (telegram_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- جدول سفارشات وب
CREATE TABLE web_orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    bot_order_id INT,  -- اگر از طریق بات ثبت شده باشد
    order_source ENUM('website', 'telegram') DEFAULT 'website',
    status VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES web_users(id),
    FOREIGN KEY (bot_order_id) REFERENCES bot_orders(id) ON DELETE SET NULL,

    INDEX idx_bot_order (bot_order_id),
    INDEX idx_source (order_source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- جدول لاگ همگام‌سازی
CREATE TABLE sync_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_type ENUM('user', 'order', 'file'),
    entity_id INT,
    action ENUM('create', 'update', 'delete'),
    source ENUM('website', 'telegram'),
    synced BOOLEAN DEFAULT FALSE,
    sync_attempts INT DEFAULT 0,
    last_sync_at TIMESTAMP NULL,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_synced (synced),
    INDEX idx_entity (entity_type, entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

**3. ایجاد View های یکپارچه:**

```sql
-- View برای نمایش یکپارچه کاربران
CREATE VIEW unified_users AS
SELECT
    bu.telegram_id,
    bu.first_name,
    bu.last_name,
    bu.username AS telegram_username,
    bu.phone,
    wu.email,
    COALESCE(wu.created_via, 'telegram') AS registration_source,
    bu.created_at AS telegram_join_date,
    wu.created_at AS website_join_date
FROM bot_users bu
LEFT JOIN web_users wu ON bu.telegram_id = wu.telegram_user_id

UNION

SELECT
    wu.telegram_user_id AS telegram_id,
    NULL AS first_name,
    NULL AS last_name,
    NULL AS telegram_username,
    NULL AS phone,
    wu.email,
    wu.created_via AS registration_source,
    NULL AS telegram_join_date,
    wu.created_at AS website_join_date
FROM web_users wu
WHERE wu.telegram_user_id IS NULL;

-- View برای نمایش یکپارچه سفارشات
CREATE VIEW unified_orders AS
SELECT
    wo.id AS order_id,
    wo.order_source AS source,
    wo.user_id,
    wo.status,
    wo.created_at,
    'website' AS platform
FROM web_orders wo

UNION ALL

SELECT
    bo.id AS order_id,
    'telegram' AS source,
    bo.user_id,
    bo.status,
    bo.created_at,
    'telegram' AS platform
FROM bot_orders bo;
```

**4. استفاده در کد PHP:**

```php
<?php
// backend/src/Services/TelegramSyncService.php

namespace Kaizen\Services;

class TelegramSyncService {
    private $db;

    public function __construct($database) {
        $this->db = $database;
    }

    /**
     * دریافت کاربر از طریق Telegram ID
     */
    public function getUserByTelegramId($telegramId) {
        $stmt = $this->db->prepare("
            SELECT * FROM unified_users
            WHERE telegram_id = ?
        ");
        $stmt->execute([$telegramId]);
        return $stmt->fetch();
    }

    /**
     * ثبت سفارش و sync با بات
     */
    public function createOrder($userId, $orderData) {
        // شروع Transaction
        $this->db->beginTransaction();

        try {
            // ثبت سفارش در جدول وب‌سایت
            $stmt = $this->db->prepare("
                INSERT INTO web_orders
                (user_id, order_source, status, ...)
                VALUES (?, 'website', 'pending', ...)
            ");
            $stmt->execute([$userId, ...]);
            $orderId = $this->db->lastInsertId();

            // ثبت در لاگ برای sync
            $this->logSync('order', $orderId, 'create', 'website');

            $this->db->commit();
            return $orderId;

        } catch (\Exception $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    /**
     * ثبت لاگ همگام‌سازی
     */
    private function logSync($entityType, $entityId, $action, $source) {
        $stmt = $this->db->prepare("
            INSERT INTO sync_log
            (entity_type, entity_id, action, source)
            VALUES (?, ?, ?, ?)
        ");
        $stmt->execute([$entityType, $entityId, $action, $source]);
    }
}
```

---

### روش 2: Webhook Integration

برای ارسال نوتیفیکیشن از وب‌سایت به تلگرام.

#### پیاده‌سازی Telegram Bot API:

```php
<?php
// telegram-integration/TelegramNotifier.php

namespace Kaizen\Telegram;

class TelegramNotifier {
    private $botToken;
    private $apiUrl;

    public function __construct() {
        $this->botToken = $_ENV['TELEGRAM_BOT_TOKEN'];
        $this->apiUrl = "https://api.telegram.org/bot{$this->botToken}";
    }

    /**
     * ارسال پیام به کاربر
     */
    public function sendMessage($chatId, $message, $parseMode = 'HTML') {
        $url = $this->apiUrl . '/sendMessage';

        $data = [
            'chat_id' => $chatId,
            'text' => $message,
            'parse_mode' => $parseMode
        ];

        return $this->makeRequest($url, $data);
    }

    /**
     * ارسال نوتیفیکیشن سفارش جدید
     */
    public function notifyNewOrder($chatId, $orderData) {
        $message = "🆕 <b>سفارش جدید ثبت شد</b>\n\n";
        $message .= "📋 شماره سفارش: {$orderData['order_number']}\n";
        $message .= "📁 فایل: {$orderData['file_name']}\n";
        $message .= "🎨 مواد: {$orderData['material']} - {$orderData['color']}\n";
        $message .= "💰 قیمت تخمینی: " . number_format($orderData['price']) . " تومان\n";
        $message .= "\n✅ سفارش در انتظار تایید است.";

        return $this->sendMessage($chatId, $message);
    }

    /**
     * ارسال نوتیفیکیشن تغییر وضعیت
     */
    public function notifyStatusChange($chatId, $orderNumber, $newStatus) {
        $statusMessages = [
            'processing' => '⚙️ سفارش شما در حال پرینت است',
            'completed' => '✅ سفارش شما تکمیل شد و آماده تحویل است',
            'cancelled' => '❌ سفارش شما کنسل شد'
        ];

        $message = "<b>به‌روزرسانی سفارش {$orderNumber}</b>\n\n";
        $message .= $statusMessages[$newStatus] ?? 'وضعیت سفارش تغییر کرد';

        return $this->sendMessage($chatId, $message);
    }

    /**
     * ارسال فایل
     */
    public function sendFile($chatId, $filePath, $caption = '') {
        $url = $this->apiUrl . '/sendDocument';

        $data = [
            'chat_id' => $chatId,
            'document' => new \CURLFile($filePath),
            'caption' => $caption
        ];

        return $this->makeRequest($url, $data, true);
    }

    /**
     * درخواست API
     */
    private function makeRequest($url, $data, $multipart = false) {
        $ch = curl_init($url);

        if ($multipart) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        } else {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        }

        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode !== 200) {
            error_log("Telegram API Error: " . $response);
            return false;
        }

        return json_decode($response, true);
    }
}
```

#### استفاده در Controller:

```php
<?php
// backend/src/Controllers/OrderController.php

use Kaizen\Telegram\TelegramNotifier;

class OrderController {
    private $telegram;

    public function __construct() {
        $this->telegram = new TelegramNotifier();
    }

    public function createOrder($request, $response) {
        // ثبت سفارش
        $order = $this->orderService->create($data);

        // دریافت Telegram ID کاربر
        $user = $this->userService->getById($order['user_id']);

        if ($user['telegram_id']) {
            // ارسال نوتیفیکیشن به کاربر
            $this->telegram->notifyNewOrder($user['telegram_id'], $order);

            // ارسال نوتیفیکیشن به ادمین
            $adminChatId = $_ENV['TELEGRAM_ADMIN_CHAT_ID'];
            $this->telegram->notifyNewOrder($adminChatId, $order);
        }

        return $response->withJson(['success' => true, 'data' => $order]);
    }
}
```

---

### روش 3: Webhook Handler (دریافت از بات)

اگر می‌خواهید بات بتواند به API وب‌سایت درخواست بفرستد:

```php
<?php
// telegram-integration/webhook-handler.php

require_once __DIR__ . '/../backend/vendor/autoload.php';

use Kaizen\Services\OrderService;
use Kaizen\Services\UserService;

// دریافت داده از Telegram
$content = file_get_contents('php://input');
$update = json_decode($content, true);

// بررسی امنیت (Secret Token)
$secretToken = $_SERVER['HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN'] ?? '';
if ($secretToken !== $_ENV['TELEGRAM_WEBHOOK_SECRET']) {
    http_response_code(403);
    exit('Forbidden');
}

// پردازش update
if (isset($update['message'])) {
    $message = $update['message'];
    $chatId = $message['chat']['id'];
    $text = $message['text'] ?? '';

    // مثال: دریافت سفارش از بات
    if (strpos($text, '/new_order') === 0) {
        // پردازش سفارش جدید
        $orderService = new OrderService();
        $order = $orderService->createFromTelegram($chatId, $message);

        // پاسخ به بات
        echo json_encode(['method' => 'sendMessage', 'chat_id' => $chatId, 'text' => 'سفارش ثبت شد']);
    }
}

http_response_code(200);
```

**تنظیم Webhook:**

```bash
# از خط فرمان یا Postman
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -d "url=https://yourdomain.com/telegram-integration/webhook-handler.php" \
  -d "secret_token=YOUR_SECRET_TOKEN"
```

---

## 🔐 امنیت

### 1. محافظت از Webhook

```php
// تأیید درخواست از تلگرام
$secretToken = $_SERVER['HTTP_X_TELEGRAM_BOT_API_SECRET_TOKEN'] ?? '';
if ($secretToken !== $_ENV['TELEGRAM_WEBHOOK_SECRET']) {
    http_response_code(403);
    exit;
}
```

### 2. محدود کردن IP

در `.htaccess`:

```apache
<Files "webhook-handler.php">
    # فقط از IP های Telegram
    Order Deny,Allow
    Deny from all
    Allow from 149.154.160.0/20
    Allow from 91.108.4.0/22
</Files>
```

### 3. محافظت از Bot Token

```php
// هرگز Bot Token را commit نکنید
// فقط در .env ذخیره کنید
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_WEBHOOK_SECRET=random-secret-string-here
```

---

## 📊 سناریوهای کاربردی

### سناریو 1: کاربر از تلگرام، سفارش از وب‌سایت

```
1. کاربر در بات ثبت‌نام می‌کند → ذخیره در bot_users
2. کاربر به وب‌سایت می‌آید
3. با Telegram Login وارد می‌شود
4. سفارش ثبت می‌کند → ذخیره در web_orders
5. نوتیفیکیشن به تلگرام ارسال می‌شود
```

### سناریو 2: سفارش از بات، پیگیری در وب‌سایت

```
1. کاربر در بات سفارش می‌دهد → ذخیره در bot_orders
2. کاربر به وب‌سایت می‌آید
3. با Telegram ID لاگین می‌کند
4. سفارشات را می‌بیند (از unified_orders view)
```

### سناریو 3: آپدیت وضعیت از پنل ادمین

```
1. ادمین در وب‌سایت وضعیت را تغییر می‌دهد
2. رکورد در web_orders یا bot_orders به‌روز می‌شود
3. نوتیفیکیشن به کاربر در تلگرام ارسال می‌شود
```

---

## 🧪 تست یکپارچگی

### تست 1: ارسال نوتیفیکیشن

```php
// test_telegram.php
require 'vendor/autoload.php';

use Kaizen\Telegram\TelegramNotifier;

$telegram = new TelegramNotifier();

// تست ارسال پیام ساده
$result = $telegram->sendMessage(
    YOUR_CHAT_ID,
    "✅ تست اتصال به تلگرام موفق بود!"
);

var_dump($result);
```

### تست 2: دریافت کاربر از Telegram ID

```php
$syncService = new TelegramSyncService($db);
$user = $syncService->getUserByTelegramId(123456789);

if ($user) {
    echo "کاربر یافت شد: " . $user['first_name'];
} else {
    echo "کاربر یافت نشد";
}
```

---

## 🔄 Cron Jobs برای Sync

برای همگام‌سازی خودکار:

```bash
# هر 5 دقیقه، موارد sync نشده را پردازش کن
*/5 * * * * php /path/to/backend/scripts/sync-pending.php

# هر روز، cleanup لاگ‌های قدیمی
0 3 * * * php /path/to/backend/scripts/cleanup-sync-logs.php
```

**sync-pending.php:**
```php
<?php
// بررسی موارد sync نشده در sync_log
$stmt = $db->query("SELECT * FROM sync_log WHERE synced = FALSE AND sync_attempts < 3");
$pendingItems = $stmt->fetchAll();

foreach ($pendingItems as $item) {
    try {
        // انجام sync
        // ...

        // علامت‌گذاری به عنوان sync شده
        $db->prepare("UPDATE sync_log SET synced = TRUE, last_sync_at = NOW() WHERE id = ?")
           ->execute([$item['id']]);

    } catch (Exception $e) {
        // افزایش تعداد تلاش‌ها
        $db->prepare("UPDATE sync_log SET sync_attempts = sync_attempts + 1, error_message = ? WHERE id = ?")
           ->execute([$e->getMessage(), $item['id']]);
    }
}
```

---

## 📞 پشتیبانی

اگر مشکلی در یکپارچه‌سازی داشتید:

1. **چک کردن لاگ‌ها:**
   ```bash
   tail -f backend/storage/logs/telegram.log
   ```

2. **تست اتصال به API تلگرام:**
   ```bash
   curl https://api.telegram.org/bot<TOKEN>/getMe
   ```

3. **بررسی Webhook:**
   ```bash
   curl https://api.telegram.org/bot<TOKEN>/getWebhookInfo
   ```

---

**موفق باشید! 🤖**
