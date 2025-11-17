# معماری سیستم وب سایت پرینت سه‌بعدی

## 📋 نیازمندی‌های پروژه

### الزامات فعلی:
- ✅ هاست با cPanel
- ✅ بات تلگرام فعال با دیتابیس قوی
- ✅ نیاز به وب سایت برای مدیریت خدمات
- ✅ ارسال فایل برای مشتریان
- ✅ معماری ماژولار و قابل توسعه

---

## 🏗️ معماری پیشنهادی

### ساختار سه‌لایه (Three-Tier Architecture):

```
┌─────────────────────────────────────────────────────┐
│                   PRESENTATION LAYER                 │
│            (Frontend - React/Vue/Vanilla JS)         │
│                                                       │
│  - رابط کاربری مشتریان                              │
│  - پنل مدیریت                                        │
│  - آپلود و دانلود فایل                              │
└───────────────────┬─────────────────────────────────┘
                    │ REST API / AJAX
┌───────────────────▼─────────────────────────────────┐
│                   APPLICATION LAYER                  │
│              (Backend API - PHP/Node.js)             │
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │  API Controllers                              │   │
│  │  - OrderController                            │   │
│  │  - FileController                             │   │
│  │  - UserController                             │   │
│  │  - TelegramSyncController                     │   │
│  └──────────────────────────────────────────────┘   │
│                                                       │
│  ┌──────────────────────────────────────────────┐   │
│  │  Business Logic Layer                         │   │
│  │  - OrderService                               │   │
│  │  - FileService                                │   │
│  │  - NotificationService                        │   │
│  │  - TelegramBotIntegration                     │   │
│  └──────────────────────────────────────────────┘   │
└───────────────────┬─────────────────────────────────┘
                    │ Database Queries
┌───────────────────▼─────────────────────────────────┐
│                     DATA LAYER                       │
│                  (MySQL Database)                    │
│                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │   Users      │  │   Orders     │  │   Files   │ │
│  │              │  │              │  │           │ │
│  │  - id        │  │  - id        │  │  - id     │ │
│  │  - telegram  │  │  - user_id   │  │  - order  │ │
│  │  - name      │  │  - status    │  │  - path   │ │
│  │  - email     │  │  - details   │  │  - type   │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│                                                       │
│  [همان دیتابیس بات تلگرام استفاده می‌شود]          │
└─────────────────────────────────────────────────────┘

        ┌────────────────────────────────┐
        │   EXTERNAL INTEGRATION         │
        │   Telegram Bot (موجود)        │
        │   - دریافت سفارشات             │
        │   - ارسال نوتیفیکیشن           │
        └────────────────────────────────┘
```

---

## 🛠️ استک تکنولوژی پیشنهادی (بهینه برای cPanel)

### گزینه 1: Full PHP Stack (پیشنهاد اول - بهینه برای cPanel)

```yaml
Backend:
  Framework: PHP 8.1+ با Slim Framework / Laravel
  Database: MySQL/MariaDB (موجود در cPanel)
  Authentication: JWT Token
  File Upload: PHP native با validation

Frontend:
  Core: Vanilla JavaScript / Alpine.js (سبک و سریع)
  Styling: Tailwind CSS
  Build: Vite (اختیاری)

Integration:
  Telegram: PHP Telegram Bot API
  File Storage: cPanel File Manager / subdomain storage
```

### گزینه 2: Modern Stack (اگر Node.js در cPanel فعال باشد)

```yaml
Backend:
  Runtime: Node.js + Express
  ORM: Sequelize / Prisma
  Database: MySQL

Frontend:
  Framework: React / Vue.js
  State: Context API / Pinia
```

---

## 📁 ساختار ماژولار پروژه

### ساختار پیشنهادی:

```
kaizen_web/
│
├── 📁 backend/                    # Backend API
│   ├── 📁 config/                 # تنظیمات و کانفیگ
│   │   ├── database.php
│   │   ├── telegram.php
│   │   └── app.php
│   │
│   ├── 📁 src/
│   │   ├── 📁 Controllers/        # API Controllers
│   │   │   ├── OrderController.php
│   │   │   ├── FileController.php
│   │   │   ├── UserController.php
│   │   │   └── TelegramController.php
│   │   │
│   │   ├── 📁 Services/           # Business Logic
│   │   │   ├── OrderService.php
│   │   │   ├── FileService.php
│   │   │   ├── NotificationService.php
│   │   │   └── TelegramBotSync.php
│   │   │
│   │   ├── 📁 Models/             # Database Models
│   │   │   ├── User.php
│   │   │   ├── Order.php
│   │   │   ├── File.php
│   │   │   └── PrintJob.php
│   │   │
│   │   ├── 📁 Middleware/         # Authentication, CORS, etc.
│   │   │   ├── AuthMiddleware.php
│   │   │   ├── CorsMiddleware.php
│   │   │   └── ValidationMiddleware.php
│   │   │
│   │   ├── 📁 Utils/              # Helper Functions
│   │   │   ├── FileValidator.php
│   │   │   ├── Logger.php
│   │   │   └── Response.php
│   │   │
│   │   └── 📁 Routes/             # API Routes
│   │       ├── api.php
│   │       └── web.php
│   │
│   ├── 📁 database/
│   │   ├── migrations/            # Database Schema
│   │   └── seeders/               # Sample Data
│   │
│   ├── 📁 storage/
│   │   ├── uploads/               # Uploaded Files
│   │   ├── logs/                  # Application Logs
│   │   └── cache/                 # Cache Files
│   │
│   ├── public/                    # Public API Endpoint
│   │   └── index.php
│   │
│   ├── .env.example
│   ├── composer.json
│   └── README.md
│
├── 📁 frontend/                   # Frontend Application
│   ├── 📁 src/
│   │   ├── 📁 components/         # UI Components
│   │   │   ├── Header.js
│   │   │   ├── FileUploader.js
│   │   │   ├── OrderList.js
│   │   │   └── OrderCard.js
│   │   │
│   │   ├── 📁 pages/              # Pages/Views
│   │   │   ├── home.js
│   │   │   ├── upload.js
│   │   │   ├── orders.js
│   │   │   └── profile.js
│   │   │
│   │   ├── 📁 services/           # API Communication
│   │   │   ├── api.js
│   │   │   ├── auth.js
│   │   │   └── fileService.js
│   │   │
│   │   ├── 📁 utils/              # Helper Functions
│   │   │   ├── validator.js
│   │   │   └── formatter.js
│   │   │
│   │   ├── 📁 assets/             # Static Assets
│   │   │   ├── css/
│   │   │   ├── images/
│   │   │   └── fonts/
│   │   │
│   │   ├── app.js                 # Main App Entry
│   │   └── router.js              # Client-side Routing
│   │
│   ├── public/
│   │   ├── index.html
│   │   └── .htaccess              # برای cPanel
│   │
│   ├── package.json
│   └── README.md
│
├── 📁 telegram-integration/       # Integration with Bot
│   ├── webhook-handler.php        # Telegram Webhook
│   ├── sync-service.php           # دیتا sync با بات
│   └── README.md
│
├── 📁 docs/                       # Documentation
│   ├── API.md                     # API Documentation
│   ├── DATABASE.md                # Database Schema
│   ├── DEPLOYMENT.md              # راهنمای دیپلوی
│   └── TELEGRAM_INTEGRATION.md    # راهنمای اتصال به بات
│
├── 📁 scripts/                    # Automation Scripts
│   ├── setup.sh                   # اسکریپت نصب اولیه
│   ├── deploy.sh                  # دیپلوی روی cPanel
│   └── backup.sh                  # پشتیبان‌گیری
│
├── .gitignore
├── README.md
└── ARCHITECTURE.md                # این فایل
```

---

## 🚀 مراحل پیاده‌سازی (گام به گام)

### فاز 1: راه‌اندازی اولیه (هفته 1)

#### گام 1: تنظیمات محیط توسعه
- [ ] نصب Git و تنظیم repository
- [ ] نصب PHP 8.1+ و Composer
- [ ] نصب MySQL و ایجاد دیتابیس
- [ ] تنظیم .env فایل‌ها

#### گام 2: ایجاد ساختار پایه Backend
- [ ] نصب Slim Framework / Laravel
- [ ] تنظیم Database Connection
- [ ] ایجاد اولین Migration برای جداول
- [ ] تست اتصال به دیتابیس

#### گام 3: ساختار پایه Frontend
- [ ] ایجاد فایل‌های HTML/CSS/JS پایه
- [ ] نصب Tailwind CSS
- [ ] ایجاد Layout اصلی

---

### فاز 2: توسعه ماژول کاربر و احراز هویت (هفته 2)

#### گام 4: سیستم احراز هویت
- [ ] ایجاد User Model و Migration
- [ ] پیاده‌سازی ثبت‌نام و لاگین
- [ ] JWT Token Generation
- [ ] اتصال با Telegram ID (برای کاربران بات)

#### گام 5: پنل کاربری پایه
- [ ] صفحه لاگین/ثبت‌نام
- [ ] داشبورد کاربر
- [ ] مدیریت پروفایل

---

### فاز 3: ماژول مدیریت فایل (هفته 3-4)

#### گام 6: آپلود فایل
- [ ] FileController و FileService
- [ ] Validation فایل‌های STL/OBJ/GCODE
- [ ] ذخیره امن فایل‌ها
- [ ] محدودیت حجم و فرمت

#### گام 7: رابط کاربری آپلود
- [ ] Drag & Drop File Uploader
- [ ] Progress Bar
- [ ] Preview فایل (اگر ممکن باشد)
- [ ] لیست فایل‌های آپلود شده

---

### فاز 4: ماژول سفارشات (هفته 5-6)

#### گام 8: مدیریت سفارشات
- [ ] Order Model و Relations
- [ ] OrderController و OrderService
- [ ] وضعیت‌های مختلف سفارش (pending, processing, completed)
- [ ] محاسبه قیمت

#### گام 9: رابط کاربری سفارشات
- [ ] فرم ثبت سفارش
- [ ] لیست سفارشات
- [ ] جزئیات سفارش
- [ ] ردیابی وضعیت

---

### فاز 5: اتصال به بات تلگرام (هفته 7)

#### گام 10: Telegram Integration
- [ ] TelegramBotSync Service
- [ ] Webhook Handler (دریافت پیام‌ها از بات)
- [ ] ارسال نوتیفیکیشن به تلگرام
- [ ] Sync دو طرفه دیتا

#### گام 11: Notification System
- [ ] NotificationService
- [ ] ارسال پیام در مراحل مختلف سفارش
- [ ] Email Notification (اختیاری)

---

### فاز 6: پنل مدیریت (هفته 8)

#### گام 12: پنل ادمین
- [ ] داشبورد مدیریت
- [ ] مدیریت سفارشات
- [ ] مدیریت کاربران
- [ ] آمار و گزارشات

---

### فاز 7: امنیت و بهینه‌سازی (هفته 9)

#### گام 13: امنیت
- [ ] Input Validation و Sanitization
- [ ] CSRF Protection
- [ ] Rate Limiting
- [ ] File Upload Security
- [ ] SQL Injection Prevention

#### گام 14: بهینه‌سازی
- [ ] Database Indexing
- [ ] Caching (Redis/File Cache)
- [ ] Image/File Optimization
- [ ] Minify CSS/JS

---

### فاز 8: تست و دیپلوی (هفته 10)

#### گام 15: تست
- [ ] Unit Testing
- [ ] Integration Testing
- [ ] User Acceptance Testing

#### گام 16: دیپلوی روی cPanel
- [ ] آپلود فایل‌ها
- [ ] تنظیم دیتابیس
- [ ] تنظیم .htaccess
- [ ] SSL Certificate
- [ ] Backup Strategy

---

## 🔒 ملاحظات امنیتی

### برای cPanel:
1. **File Upload Security:**
   - بررسی MIME Type واقعی فایل
   - محدودیت حجم
   - ذخیره خارج از public directory
   - نام‌گذاری تصادفی فایل‌ها

2. **Database Security:**
   - استفاده از Prepared Statements
   - Hash کردن رمز عبور (bcrypt)
   - محدود کردن دسترسی دیتابیس

3. **API Security:**
   - CORS Policy
   - Rate Limiting
   - JWT Token با Expiration
   - Input Validation

4. **cPanel Specific:**
   - محافظت از .env فایل‌ها
   - تنظیم صحیح File Permissions (644 برای فایل‌ها، 755 برای پوشه‌ها)
   - استفاده از .htaccess برای محافظت

---

## 📊 دیتابیس اشتراکی با بات تلگرام

### استراتژی:
```sql
-- جداول موجود بات (نباید تغییر کنند)
existing_bot_tables

-- جداول جدید وب سایت
web_users          -- کاربران وب (با لینک به telegram_id)
web_orders         -- سفارشات وب
web_files          -- فایل‌های آپلود شده
web_sessions       -- نشست‌های کاربری

-- جداول مشترک (با دقت)
sync_log           -- لاگ همگام‌سازی
notifications      -- نوتیفیکیشن‌ها
```

### نکات مهم:
- از Transaction استفاده کنید
- Foreign Key Constraints تنظیم کنید
- Regular Backup بگیرید
- Migration Script‌ها را نگه دارید

---

## 🎯 ویژگی‌های کلیدی برای MVP

### نسخه اول (Minimum Viable Product):

1. ✅ **احراز هویت ساده**
   - ثبت‌نام با شماره تلگرام
   - لاگین

2. ✅ **آپلود فایل**
   - STL, OBJ, GCODE
   - حداکثر 50MB

3. ✅ **ثبت سفارش**
   - انتخاب فایل
   - مشخصات پرینت
   - ثبت سفارش

4. ✅ **ردیابی سفارش**
   - مشاهده وضعیت
   - دریافت نوتیفیکیشن

5. ✅ **اتصال به بات**
   - Sync سفارشات
   - ارسال نوتیفیکیشن به تلگرام

---

## 🔧 ابزارهای توسعه پیشنهادی

```yaml
IDE/Editor:
  - VS Code
  - PhpStorm (برای PHP حرفه‌ای)

Database Management:
  - phpMyAdmin (موجود در cPanel)
  - MySQL Workbench

API Testing:
  - Postman
  - Insomnia

Version Control:
  - Git
  - GitHub/GitLab

Deployment:
  - cPanel File Manager
  - FTP/SFTP
  - Git Deploy (اگر در cPanel فعال باشد)

Monitoring:
  - cPanel Logs
  - Custom Logger
  - Google Analytics (برای ترافیک)
```

---

## 📈 توسعه‌های آینده

### فاز 2 (آینده):
- پرداخت آنلاین
- گالری پروژه‌ها
- سیستم امتیازدهی
- چت آنلاین
- پنل قیمت‌گذاری پیشرفته
- اپلیکیشن موبایل (PWA)

---

## 💡 نکات طلایی

1. **شروع کوچک، توسعه تدریجی**: ابتدا MVP را کامل کنید
2. **مستند کنید**: هر چیزی را document کنید
3. **تست کنید**: قبل از دیپلوی حتما تست کنید
4. **امنیت**: از همان ابتدا به امنیت فکر کنید
5. **Backup**: همیشه قبل از تغییر بزرگ، backup بگیرید
6. **Git**: هر تغییر منطقی را commit کنید
7. **کد تمیز**: از PSR Standards در PHP پیروی کنید

---

## 🤝 همکاری با بات موجود

### سناریوی ایده‌آل:
```
مشتری در تلگرام → بات → ثبت در دیتابیس
                ↓
    وب‌سایت از دیتابیس می‌خواند
                ↓
    مشتری در وب‌سایت → ثبت سفارش
                ↓
    بات notification می‌فرستد
```

این معماری اجازه می‌دهد هر دو سیستم مستقل کار کنند اما دیتا را به اشتراک بگذارند.

---

**این معماری آماده توسعه است. آیا میخوای شروع به پیاده‌سازی کنیم؟**
