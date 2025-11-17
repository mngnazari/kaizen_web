# 🚀 راهنمای شروع سریع (Quick Start Guide)

این راهنما به شما کمک می‌کند تا در کمترین زمان ممکن پروژه را راه‌اندازی کنید.

## ⚡ نصب سریع (5 دقیقه)

### گام 1: کلون و نصب Dependencies

```bash
# کلون پروژه (اگر هنوز نکردید)
git clone <your-repo-url>
cd kaizen_web

# نصب Backend Dependencies
cd backend
composer install

# کپی تنظیمات محیط
cp .env.example .env

# بازگشت به root
cd ..
```

### گام 2: تنظیم دیتابیس

```bash
# ورود به MySQL
mysql -u root -p

# ایجاد دیتابیس
CREATE DATABASE kaizen_3d CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### گام 3: ویرایش .env

فایل `backend/.env` را باز کنید و این موارد را تنظیم کنید:

```env
# دیتابیس
DB_DATABASE=kaizen_3d
DB_USERNAME=root
DB_PASSWORD=your_password

# امنیت (یک رشته تصادفی 32 کاراکتری)
JWT_SECRET=your-random-32-character-secret-key

# تلگرام (اگر دارید)
TELEGRAM_BOT_TOKEN=your-bot-token
```

💡 **نکته**: برای تولید JWT_SECRET از این دستور استفاده کنید:
```bash
php -r "echo bin2hex(random_bytes(32));"
```

### گام 4: اجرای Migrations

```bash
cd backend
php database/migrate.php
```

### گام 5: راه‌اندازی سرور

```bash
# Backend (Terminal 1)
cd backend
php -S localhost:8000 -t public

# Frontend (Terminal 2) - اختیاری
cd frontend
python3 -m http.server 3000
# یا
npx serve public -p 3000
```

### گام 6: تست

باز کنید:
- Backend API: http://localhost:8000
- Frontend: http://localhost:3000

---

## 🎯 چک‌لیست آماده‌سازی

قبل از شروع کدنویسی، این موارد را چک کنید:

- [ ] PHP 8.1+ نصب شده
- [ ] Composer نصب شده
- [ ] MySQL/MariaDB نصب و راه‌اندازی شده
- [ ] دیتابیس ساخته شده
- [ ] فایل .env تنظیم شده
- [ ] Composer dependencies نصب شده
- [ ] سرور Backend اجرا می‌شود

---

## 📋 مراحل توسعه پیشنهادی

### فاز 1: Backend API (هفته 1-2)

#### 1.1 ساختار پایه

```bash
# فایل‌های اولیه که باید بسازید:
backend/
├── public/index.php          # ✅ Entry point
├── config/database.php       # ✅ Database config
├── src/
│   ├── Models/User.php       # ✅ User model
│   ├── Controllers/
│   │   └── AuthController.php # ✅ Authentication
│   └── Utils/
│       ├── Database.php      # ✅ Database helper
│       └── Response.php      # ✅ JSON response helper
```

#### 1.2 اولین API Endpoint

ساخت endpoint ساده برای تست:

**backend/public/index.php**:
```php
<?php
require_once __DIR__ . '/../vendor/autoload.php';

use Slim\Factory\AppFactory;

$app = AppFactory::create();

$app->get('/api/health', function ($request, $response) {
    $data = ['status' => 'ok', 'message' => 'API is running!'];
    $response->getBody()->write(json_encode($data));
    return $response->withHeader('Content-Type', 'application/json');
});

$app->run();
```

تست:
```bash
curl http://localhost:8000/api/health
# باید برگرداند: {"status":"ok","message":"API is running!"}
```

#### 1.3 اتصال به دیتابیس

**backend/src/Utils/Database.php**:
```php
<?php
namespace Kaizen\Utils;

use PDO;

class Database {
    private static $instance = null;
    private $connection;

    private function __construct() {
        $host = $_ENV['DB_HOST'];
        $db = $_ENV['DB_DATABASE'];
        $user = $_ENV['DB_USERNAME'];
        $pass = $_ENV['DB_PASSWORD'];

        $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";

        $this->connection = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES => false,
        ]);
    }

    public static function getInstance() {
        if (self::$instance === null) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    public function getConnection() {
        return $this->connection;
    }
}
```

### فاز 2: Frontend (هفته 2-3)

#### 2.1 ساختار HTML پایه

**frontend/public/index.html**:
```html
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kaizen 3D Printing</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-50">
    <div id="app">
        <h1 class="text-3xl font-bold text-center mt-10">
            Kaizen 3D Printing Platform
        </h1>
        <div class="container mx-auto mt-8">
            <div id="content"></div>
        </div>
    </div>

    <script src="../src/app.js" type="module"></script>
</body>
</html>
```

#### 2.2 اولین API Call

**frontend/src/app.js**:
```javascript
// تست اتصال به API
async function testAPI() {
    try {
        const response = await fetch('http://localhost:8000/api/health');
        const data = await response.json();
        console.log('API Response:', data);

        document.getElementById('content').innerHTML = `
            <div class="bg-green-100 p-4 rounded">
                ✅ اتصال به API موفق: ${data.message}
            </div>
        `;
    } catch (error) {
        console.error('API Error:', error);
        document.getElementById('content').innerHTML = `
            <div class="bg-red-100 p-4 rounded">
                ❌ خطا در اتصال به API
            </div>
        `;
    }
}

testAPI();
```

### فاز 3: Database Schema (هفته 1)

#### 3.1 ساخت اولین Migration

**backend/database/migrations/001_create_users_table.sql**:
```sql
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    telegram_id BIGINT UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    password_hash VARCHAR(255),
    role ENUM('user', 'admin') DEFAULT 'user',
    status ENUM('active', 'inactive', 'banned') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_telegram_id (telegram_id),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

اجرا:
```bash
mysql -u root -p kaizen_3d < backend/database/migrations/001_create_users_table.sql
```

---

## 🧪 تست اولیه

### تست Backend:

```bash
# Health check
curl http://localhost:8000/api/health

# باید response بدهد:
# {"status":"ok","message":"API is running!"}
```

### تست Database:

```bash
mysql -u root -p
use kaizen_3d;
SHOW TABLES;
DESCRIBE users;
```

### تست Frontend:

1. مرورگر را باز کنید: http://localhost:3000
2. Console را چک کنید (F12)
3. باید پیام موفقیت‌آمیز اتصال به API را ببینید

---

## 🎨 بهترین شیوه‌های توسعه

### 1. Git Workflow

```bash
# هر feature در branch جدا
git checkout -b feature/user-authentication
# کد بنویسید...
git add .
git commit -m "feat: add user authentication"
git push origin feature/user-authentication
```

### 2. Commit Message Convention

```
feat: اضافه کردن ویژگی جدید
fix: رفع باگ
docs: تغییرات مستندات
style: تغییرات فرمت (بدون تغییر کد)
refactor: بازسازی کد
test: اضافه کردن تست
chore: تغییرات ابزارها و کانفیگ
```

### 3. Code Organization

- یک کلاس = یک فایل
- نام‌گذاری واضح و معنادار
- کامنت برای کدهای پیچیده
- از PSR-12 برای PHP پیروی کنید

### 4. Security First

```php
// ❌ اشتباه
$query = "SELECT * FROM users WHERE id = " . $_GET['id'];

// ✅ درست
$stmt = $pdo->prepare("SELECT * FROM users WHERE id = ?");
$stmt->execute([$_GET['id']]);
```

---

## 🐛 عیب‌یابی رایج

### خطای اتصال به دیتابیس

```
Error: SQLSTATE[HY000] [1049] Unknown database 'kaizen_3d'
```

**راه حل**: دیتابیس را بسازید:
```bash
mysql -u root -p -e "CREATE DATABASE kaizen_3d"
```

### خطای Composer

```
Error: Class 'Dotenv\Dotenv' not found
```

**راه حل**: Dependencies را نصب کنید:
```bash
cd backend && composer install
```

### خطای CORS

```
Access to fetch at 'http://localhost:8000/api' from origin 'http://localhost:3000'
has been blocked by CORS policy
```

**راه حل**: در `backend/public/index.php` اضافه کنید:
```php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

### خطای Permission (cPanel)

```
Warning: file_put_contents(): failed to open stream: Permission denied
```

**راه حل**:
```bash
chmod 755 storage/
chmod 755 storage/uploads/
chmod 755 storage/logs/
```

---

## 📚 منابع مفید

### مستندات:
- [PHP Documentation](https://www.php.net/docs.php)
- [Slim Framework](https://www.slimframework.com/)
- [MySQL Reference](https://dev.mysql.com/doc/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### ابزارهای توسعه:
- **Postman**: تست API
- **phpMyAdmin**: مدیریت دیتابیس
- **VS Code Extensions**:
  - PHP Intelephense
  - ESLint
  - Tailwind CSS IntelliSense

---

## ✅ Checklist برای Production

قبل از دیپلوی روی cPanel:

- [ ] `APP_ENV=production` در .env
- [ ] `APP_DEBUG=false` در .env
- [ ] JWT_SECRET تصادفی و قوی
- [ ] Database backup گرفته شده
- [ ] تمام dependencies نصب شده
- [ ] فایل‌های .env حذف شده از git
- [ ] SSL certificate نصب شده
- [ ] File permissions صحیح (644 برای فایل‌ها، 755 برای پوشه‌ها)
- [ ] Error logging فعال
- [ ] Rate limiting فعال

---

## 🎯 مرحله بعدی

حالا که محیط کار آماده است، به ترتیب این کارها را انجام دهید:

1. ✅ **بخوانید**: [ARCHITECTURE.md](./ARCHITECTURE.md) - معماری کلی
2. ✅ **پیاده کنید**: سیستم احراز هویت (User Registration/Login)
3. ✅ **تست کنید**: API endpoints با Postman
4. ✅ **ادامه دهید**: ماژول بعدی طبق roadmap

---

**موفق باشید! 🚀**

اگر سوالی داشتید، به فایل [README.md](./README.md) یا مستندات [docs/](./docs) مراجعه کنید.
