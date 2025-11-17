# 🖨️ Kaizen 3D Printing Web Platform

> سیستم مدیریت سفارشات پرینت سه‌بعدی با اتصال به بات تلگرام

## 📖 درباره پروژه

این پروژه یک پلتفرم وب برای مدیریت سفارشات پرینت سه‌بعدی است که با بات تلگرام موجود یکپارچه شده و امکانات زیر را فراهم می‌کند:

- ✅ آپلود فایل‌های پرینت سه‌بعدی (STL, OBJ, GCODE)
- ✅ ثبت و مدیریت سفارشات
- ✅ ردیابی وضعیت سفارش
- ✅ یکپارچگی با بات تلگرام موجود
- ✅ پنل مدیریت برای ادمین
- ✅ سیستم نوتیفیکیشن

## 🏗️ معماری

پروژه با معماری سه‌لایه (Three-Tier Architecture) طراحی شده:

- **Frontend**: رابط کاربری وب
- **Backend API**: سرویس‌های RESTful
- **Database**: MySQL مشترک با بات تلگرام

برای مطالعه جزئیات کامل معماری، فایل [ARCHITECTURE.md](./ARCHITECTURE.md) را مطالعه کنید.

## 🛠️ تکنولوژی‌ها

### Backend
- PHP 8.1+
- Slim Framework / Laravel
- MySQL/MariaDB
- Composer

### Frontend
- HTML5, CSS3, JavaScript (ES6+)
- Tailwind CSS
- Alpine.js / Vanilla JS

### Integration
- Telegram Bot API
- JWT Authentication

## 📁 ساختار پروژه

```
kaizen_web/
├── backend/              # Backend API
│   ├── config/          # تنظیمات
│   ├── src/             # کدهای اصلی
│   ├── database/        # Migrations
│   ├── storage/         # فایل‌ها و لاگ‌ها
│   └── public/          # Entry point
├── frontend/            # Frontend App
│   ├── src/             # کدهای اصلی
│   └── public/          # فایل‌های استاتیک
├── telegram-integration/ # اتصال به بات
├── docs/                # مستندات
└── scripts/             # اسکریپت‌های کمکی
```

## 🚀 نصب و راه‌اندازی

### پیش‌نیازها

```bash
- PHP >= 8.1
- Composer
- MySQL >= 5.7
- Node.js >= 16 (اختیاری)
- Git
```

### مراحل نصب

#### 1. کلون پروژه
```bash
git clone <repository-url>
cd kaizen_web
```

#### 2. نصب Backend

```bash
cd backend
composer install
cp .env.example .env
# ویرایش .env و تنظیم دیتابیس
php database/migrate.php
```

#### 3. نصب Frontend

```bash
cd ../frontend
npm install  # یا استفاده مستقیم از CDN
```

#### 4. تنظیم دیتابیس

```sql
CREATE DATABASE kaizen_3d CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### 5. اجرای Migration‌ها

```bash
cd backend
php database/migrate.php
```

## 🔧 تنظیمات محیط توسعه

### Backend Configuration (.env)

```env
# Application
APP_NAME="Kaizen 3D Printing"
APP_ENV=development
APP_DEBUG=true
APP_URL=http://localhost

# Database
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=kaizen_3d
DB_USERNAME=root
DB_PASSWORD=

# JWT Secret
JWT_SECRET=your-secret-key-here
JWT_EXPIRATION=86400

# File Upload
MAX_FILE_SIZE=52428800  # 50MB
UPLOAD_PATH=storage/uploads
ALLOWED_EXTENSIONS=stl,obj,gcode,3mf

# Telegram Bot
TELEGRAM_BOT_TOKEN=your-bot-token
TELEGRAM_WEBHOOK_URL=https://yourdomain.com/webhook

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com
```

## 🎯 استفاده

### Backend API

```bash
cd backend
php -S localhost:8000 -t public
```

API در آدرس `http://localhost:8000` در دسترس خواهد بود.

### Frontend Development

```bash
cd frontend
# استفاده از یک سرور ساده
python -m http.server 3000
# یا
npx serve public
```

Frontend در آدرس `http://localhost:3000` باز می‌شود.

## 📚 مستندات API

### Authentication

#### ثبت‌نام
```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "نام کاربر",
  "email": "user@example.com",
  "phone": "09123456789",
  "telegram_id": "123456789",
  "password": "secure-password"
}
```

#### لاگین
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure-password"
}
```

### File Upload

```http
POST /api/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "file": <file-binary>
}
```

### Orders

#### ثبت سفارش جدید
```http
POST /api/orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "file_id": 123,
  "material": "PLA",
  "color": "white",
  "infill": 20,
  "quality": "normal",
  "notes": "توضیحات اضافی"
}
```

#### دریافت سفارشات
```http
GET /api/orders
Authorization: Bearer {token}
```

برای مستندات کامل API، فایل [docs/API.md](./docs/API.md) را مطالعه کنید.

## 🧪 تست

```bash
# Backend Tests
cd backend
./vendor/bin/phpunit

# Frontend Tests (اگر داشته باشیم)
cd frontend
npm test
```

## 📦 دیپلوی روی cPanel

### گام 1: آماده‌سازی فایل‌ها

```bash
# بیلد فایل‌های فرانت‌اند
cd frontend
npm run build

# زیپ کردن پروژه
cd ..
zip -r kaizen_web.zip backend frontend telegram-integration
```

### گام 2: آپلود به cPanel

1. وارد File Manager شوید
2. فایل zip را آپلود کنید
3. Extract کنید

### گام 3: تنظیم دیتابیس

1. از MySQL Databases یک دیتابیس بسازید
2. کاربر دیتابیس ایجاد کنید
3. Import فایل `database/schema.sql`

### گام 4: تنظیم .htaccess

```apache
# در پوشه public
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.php [QSA,L]
</IfModule>
```

### گام 5: تنظیم File Permissions

```bash
chmod 644 .env
chmod 755 storage
chmod 755 storage/uploads
chmod 755 storage/logs
```

راهنمای کامل در [docs/DEPLOYMENT.md](./docs/DEPLOYMENT.md)

## 🔐 امنیت

- ✅ Prepared Statements برای جلوگیری از SQL Injection
- ✅ JWT Authentication
- ✅ File Upload Validation
- ✅ CORS Policy
- ✅ Rate Limiting
- ✅ Input Sanitization
- ✅ HTTPS Only در production

## 🔄 اتصال به بات تلگرام

این وب‌سایت با بات تلگرام موجود یکپارچه می‌شود:

1. **دیتابیس مشترک**: هر دو از یک دیتابیس استفاده می‌کنند
2. **Webhook**: بات می‌تواند به API وب‌سایت درخواست بفرستد
3. **Notification**: سفارشات جدید از طریق تلگرام اطلاع‌رسانی می‌شوند
4. **Sync Service**: سرویس همگام‌سازی دو طرفه

راهنمای اتصال در [docs/TELEGRAM_INTEGRATION.md](./docs/TELEGRAM_INTEGRATION.md)

## 📊 دیتابیس

### جداول اصلی:

- `users` - کاربران سیستم
- `orders` - سفارشات
- `files` - فایل‌های آپلود شده
- `print_jobs` - جزئیات کار پرینت
- `notifications` - نوتیفیکیشن‌ها
- `sync_log` - لاگ همگام‌سازی

اسکیمای کامل در [docs/DATABASE.md](./docs/DATABASE.md)

## 🤝 مشارکت

برای مشارکت در این پروژه:

1. Fork کنید
2. یک Branch جدید بسازید (`git checkout -b feature/AmazingFeature`)
3. تغییرات را Commit کنید (`git commit -m 'Add some AmazingFeature'`)
4. Push کنید (`git push origin feature/AmazingFeature`)
5. یک Pull Request باز کنید

## 📝 لاگ تغییرات

تمام تغییرات مهم در فایل [CHANGELOG.md](./CHANGELOG.md) ثبت می‌شود.

## 🗺️ Roadmap

### نسخه 1.0 (MVP)
- [x] معماری سیستم
- [ ] سیستم احراز هویت
- [ ] آپلود فایل
- [ ] مدیریت سفارشات
- [ ] اتصال به بات تلگرام

### نسخه 1.1
- [ ] پنل مدیریت پیشرفته
- [ ] گزارش‌گیری و آمار
- [ ] سیستم پرداخت

### نسخه 2.0
- [ ] PWA (Progressive Web App)
- [ ] گالری پروژه‌ها
- [ ] سیستم امتیازدهی
- [ ] چت آنلاین

## 📞 پشتیبانی

در صورت بروز مشکل:

1. ابتدا [مستندات](./docs) را مطالعه کنید
2. [Issues](../../issues) را بررسی کنید
3. یک Issue جدید باز کنید

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است. فایل [LICENSE](./LICENSE) را مطالعه کنید.

## 👨‍💻 توسعه‌دهنده

توسعه داده شده با ❤️ برای کسب‌وکار پرینت سه‌بعدی Kaizen

---

**Ready to revolutionize your 3D printing business! 🚀**
