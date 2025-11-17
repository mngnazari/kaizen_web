# Kaizen 3D Printing - Backend API

Backend API برای سیستم مدیریت سفارشات پرینت سه‌بعدی Kaizen

## 🚀 راه‌اندازی سریع

### 1. نصب Dependencies

```bash
composer install
```

### 2. تنظیم Environment

```bash
cp .env.example .env
# ویرایش .env و تنظیم اطلاعات دیتابیس
```

### 3. ایجاد دیتابیس

```bash
mysql -u root -p
CREATE DATABASE kaizen_3d CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;

# Import schema
mysql -u root -p kaizen_3d < database/schema.sql
```

### 4. اجرای سرور توسعه

```bash
php -S localhost:8000 -t public
```

سرور روی http://localhost:8000 اجرا می‌شود.

## 📡 تست API

### Health Check

```bash
curl http://localhost:8000/api/health
```

**Response:**
```json
{
    "success": true,
    "data": {
        "status": "ok",
        "message": "API is running!",
        "version": "1.0.0",
        "timestamp": "2024-01-15T10:30:00+00:00",
        "environment": "development"
    }
}
```

### API Info

```bash
curl http://localhost:8000/api
```

لیست تمام endpoint های در دسترس را نمایش می‌دهد.

## 📁 ساختار پروژه

```
backend/
├── config/              # تنظیمات
├── public/
│   └── index.php       # Entry point اصلی ✅
├── src/
│   ├── Controllers/    # API Controllers
│   ├── Services/       # Business Logic
│   ├── Models/         # Database Models
│   ├── Middleware/     # Auth, CORS, etc.
│   ├── Utils/          # Helper Classes ✅
│   │   ├── Database.php    # Database connection ✅
│   │   ├── Response.php    # JSON responses ✅
│   │   └── helpers.php     # Global helpers ✅
│   └── Routes/         # API Routes
├── database/
│   └── schema.sql      # Database schema ✅
├── storage/
│   ├── uploads/        # Uploaded files
│   ├── logs/           # Application logs
│   └── cache/          # Cache files
├── vendor/             # Composer dependencies ✅
├── .env                # Environment variables ✅
└── composer.json       # Composer config ✅
```

## ✅ آنچه تاکنون پیاده‌سازی شده

- [x] Entry Point اصلی با Slim Framework
- [x] CORS Middleware
- [x] Database Connection Helper (Singleton Pattern)
- [x] Response Helper Classes
- [x] Global Helper Functions
- [x] Health Check Endpoint
- [x] API Info Endpoint
- [x] 404 Handler
- [x] Error Handling

## 🔜 مراحل بعدی

### فاز بعدی: Authentication
- [ ] User Model
- [ ] AuthController (register, login)
- [ ] JWT Token Generation
- [ ] Auth Middleware
- [ ] Protected Routes

### بعد از Auth:
- [ ] File Upload System
- [ ] Order Management
- [ ] Telegram Integration
- [ ] Admin Panel

## 🔧 Helper Functions موجود

فایل `src/Utils/helpers.php` شامل توابع کمکی زیر است:

```php
env($key, $default)              // دریافت متغیر محیطی
config($key, $default)           // دریافت تنظیمات
now()                            // تاریخ و زمان فعلی
generateToken($length)           // تولید توکن تصادفی
hashPassword($password)          // Hash کردن رمز عبور
verifyPassword($password, $hash) // تایید رمز عبور
sanitizeInput($input)            // پاکسازی ورودی
validateEmail($email)            // اعتبارسنجی ایمیل
validatePhone($phone)            // اعتبارسنجی شماره تلفن
formatPrice($amount)             // فرمت قیمت به تومان
generateOrderNumber($count)      // تولید شماره سفارش
logError($message, $context)     // ثبت خطا
logInfo($message, $context)      // ثبت اطلاعات
uuid()                           // تولید UUID
```

## 📚 Database Helper

کلاس `Database` با الگوی Singleton:

```php
use Kaizen\Utils\Database;

$db = Database::getInstance();

// SELECT queries
$users = $db->select("SELECT * FROM users WHERE status = ?", ['active']);
$user = $db->selectOne("SELECT * FROM users WHERE id = ?", [1]);

// INSERT
$userId = $db->insert('users', [
    'name' => 'علی احمدی',
    'email' => 'ali@example.com',
    'password_hash' => hashPassword('password123')
]);

// UPDATE
$affected = $db->update('users',
    ['name' => 'علی احمدی جدید'],
    'id = :id',
    [':id' => 1]
);

// DELETE
$deleted = $db->delete('users', 'id = ?', [1]);

// Transactions
$db->beginTransaction();
try {
    $db->insert('orders', [...]);
    $db->insert('order_timeline', [...]);
    $db->commit();
} catch (Exception $e) {
    $db->rollBack();
}
```

## 📝 Response Helper

کلاس `Response` برای پاسخ‌های استاندارد:

```php
use Kaizen\Utils\Response;

// Success
return Response::success($response, $data, 'عملیات موفق');

// Error
return Response::error($response, 'خطا رخ داد', $errors, 400);

// Validation Error
return Response::validationError($response, [
    'email' => ['ایمیل نامعتبر است']
]);

// Unauthorized
return Response::unauthorized($response);

// Not Found
return Response::notFound($response, 'کاربر یافت نشد');

// Paginated
return Response::paginated($response, $items, $total, $page, $perPage);
```

## 🧪 تست با curl

```bash
# Health check
curl http://localhost:8000/api/health

# API info
curl http://localhost:8000/api

# Test 404
curl http://localhost:8000/api/not-found

# Test database (نیاز به دیتابیس دارد)
curl http://localhost:8000/api/test/db
```

## 🔐 امنیت

- ✅ CORS configured
- ✅ Prepared Statements (SQL Injection protection)
- ✅ Password Hashing (bcrypt)
- ✅ Input Sanitization
- ✅ Error Logging
- ⏳ JWT Authentication (در حال توسعه)
- ⏳ Rate Limiting (در حال توسعه)

## 📖 مستندات بیشتر

- [API Documentation](../docs/API.md)
- [Database Schema](../docs/DATABASE.md)
- [Architecture](../ARCHITECTURE.md)
- [Quick Start Guide](../QUICKSTART.md)

## ⚙️ تنظیمات مهم .env

```env
APP_ENV=development          # محیط: development, production
APP_DEBUG=true              # نمایش خطاها
APP_URL=http://localhost:8000

DB_HOST=localhost
DB_DATABASE=kaizen_3d
DB_USERNAME=root
DB_PASSWORD=

JWT_SECRET=<random-32-char-string>
JWT_EXPIRATION=86400        # 24 hours

CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

## 🐛 عیب‌یابی

### خطای "Class not found"
```bash
composer dump-autoload
```

### خطای "Cannot connect to database"
- بررسی تنظیمات .env
- مطمئن شوید MySQL در حال اجرا است
- دیتابیس ساخته شده باشد

### خطای CORS
- بررسی `CORS_ALLOWED_ORIGINS` در .env
- مطمئن شوید origin frontend در لیست باشد

---

**وضعیت فعلی**: API پایه آماده است ✅
**مرحله بعدی**: پیاده‌سازی Authentication System
