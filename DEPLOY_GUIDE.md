# 🚀 راهنمای دیپلوی سریع روی cPanel

این راهنما برای دیپلوی اولین نسخه پروژه روی هاست cPanel است.

---

## 📋 پیش‌نیازها

قبل از شروع، از موارد زیر مطمئن شوید:

- [ ] دسترسی به cPanel دارید
- [ ] PHP 8.1+ فعال است
- [ ] MySQL/MariaDB در دسترس است
- [ ] دسترسی به File Manager یا FTP دارید
- [ ] (اختیاری) دسترسی SSH دارید

---

## 🎯 روش 1: دیپلوی دستی (ساده‌ترین)

### گام 1: آماده‌سازی فایل‌ها

در کامپیوتر محلی:

```bash
# 1. کلون پروژه از Git
git clone https://github.com/mngnazari/kaizen_web.git
cd kaizen_web

# 2. اجرای اسکریپت package
./scripts/package.sh

# این یک فایل kaizen_web_deploy.zip می‌سازد
```

اگر اسکریپت وجود نداشت، دستی این کار رو بکنید:

```bash
# حذف فایل‌های غیرضروری
rm -rf .git node_modules backend/vendor

# نصب dependencies در حالت production
cd backend
composer install --no-dev --optimize-autoloader
cd ..

# زیپ کردن
zip -r kaizen_web_deploy.zip . \
  -x "*.git*" \
  -x "*node_modules*" \
  -x "*.DS_Store" \
  -x "backend/.env"
```

---

### گام 2: آپلود به cPanel

#### روش A: استفاده از File Manager (راحت‌تر)

1. **ورود به cPanel**
   - به آدرس `yourdomain.com/cpanel` برید
   - با username و password وارد شوید

2. **باز کردن File Manager**
   - از منوی cPanel، File Manager را انتخاب کنید
   - به پوشه `public_html` بروید

3. **آپلود فایل ZIP**
   - روی دکمه "Upload" کلیک کنید
   - فایل `kaizen_web_deploy.zip` را انتخاب کنید
   - منتظر بمانید تا آپلود کامل شود

4. **Extract کردن**
   - به File Manager برگردید
   - روی فایل zip کلیک راست کنید
   - "Extract" را انتخاب کنید
   - پوشه `kaizen_web` ساخته می‌شود

#### روش B: استفاده از FTP (اگر File Manager کند است)

```bash
# با FileZilla یا هر FTP client:
Host: ftp.yourdomain.com
Username: your_cpanel_username
Password: your_cpanel_password
Port: 21

# آپلود فایل zip
# سپس از File Manager عمل Extract را انجام دهید
```

---

### گام 3: تنظیم ساختار پوشه‌ها

ساختار نهایی باید این‌طور باشد:

```
public_html/
├── kaizen_web/
│   ├── backend/
│   ├── frontend/
│   └── ...
```

یا برای استفاده بهتر:

```
yourdomain.com/
├── public_html/              ← Frontend اینجا
│   ├── index.html
│   ├── assets/
│   └── ...
│
├── api/                      ← Backend اینجا
│   ├── .htaccess
│   ├── index.php
│   ├── src/
│   └── ...
```

**برای ساختار دوم:**

1. در File Manager، یک پوشه `api` در کنار `public_html` بسازید
2. محتویات `backend/public/` را در `public_html` کپی کنید
3. بقیه فایل‌های `backend/` را در `api` کپی کنید
4. محتویات `frontend/public/` را در `public_html` کپی کنید

---

### گام 4: ایجاد دیتابیس

1. **ورود به MySQL Databases در cPanel**

2. **Create New Database:**
   ```
   Database Name: username_kaizen3d
   ```
   روی "Create Database" کلیک کنید

3. **Create New User:**
   ```
   Username: username_kaizen
   Password: [یک رمز قوی بسازید و یادداشت کنید]
   ```
   روی "Create User" کلیک کنید

4. **Add User to Database:**
   - User: `username_kaizen`
   - Database: `username_kaizen3d`
   - Privileges: **ALL PRIVILEGES** را علامت بزنید
   - "Make Changes" کلیک کنید

5. **Import Schema:**
   - به phpMyAdmin بروید
   - دیتابیس `username_kaizen3d` را انتخاب کنید
   - تب "SQL" را باز کنید
   - محتویات فایل `backend/database/schema.sql` را کپی کنید
   - Paste کنید و "Go" بزنید

---

### گام 5: تنظیم فایل .env

1. در File Manager، به پوشه `api` (یا `backend`) بروید
2. فایل `.env.example` را پیدا کنید
3. کپی کنید و نامش را به `.env` تغییر دهید
4. فایل `.env` را ویرایش کنید (Edit):

```env
# =================================
# APPLICATION SETTINGS
# =================================
APP_NAME="Kaizen 3D Printing"
APP_ENV=production               # ← تغییر به production
APP_DEBUG=false                  # ← تغییر به false
APP_URL=https://yourdomain.com
APP_TIMEZONE=Asia/Tehran

# =================================
# DATABASE CONFIGURATION
# =================================
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=username_kaizen3d   # ← نام دیتابیس شما
DB_USERNAME=username_kaizen     # ← نام کاربری شما
DB_PASSWORD=your_password       # ← رمز عبور شما

# Database Charset
DB_CHARSET=utf8mb4
DB_COLLATION=utf8mb4_unicode_ci

# =================================
# SECURITY & AUTHENTICATION
# =================================
JWT_SECRET=your-random-64-char-secret-key-here  # ← یک رشته تصادفی 64 کاراکتری
JWT_EXPIRATION=86400
JWT_ALGORITHM=HS256

# =================================
# FILE UPLOAD SETTINGS
# =================================
MAX_FILE_SIZE=52428800
UPLOAD_PATH=storage/uploads
ALLOWED_EXTENSIONS=stl,obj,gcode,3mf,step,stp

# =================================
# CORS SETTINGS
# =================================
CORS_ALLOWED_ORIGINS=https://yourdomain.com   # ← دامنه شما
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=Content-Type,Authorization,X-Requested-With
CORS_ALLOW_CREDENTIALS=true

# =================================
# TELEGRAM BOT INTEGRATION
# =================================
TELEGRAM_BOT_TOKEN=your-telegram-bot-token-here     # ← توکن بات
TELEGRAM_BOT_USERNAME=YourBotUsername
TELEGRAM_WEBHOOK_URL=https://yourdomain.com/api/telegram/webhook
TELEGRAM_ADMIN_CHAT_ID=your-telegram-chat-id       # ← Chat ID شما
```

5. "Save Changes" کنید

**نکته:** برای تولید JWT_SECRET:
```bash
# در کامپیوتر محلی:
php -r "echo bin2hex(random_bytes(32));"
```

---

### گام 6: تنظیم File Permissions

در File Manager:

```
backend/.env          → 644 (مهم!)
backend/storage/      → 755
backend/storage/uploads/ → 755
backend/storage/logs/    → 755
backend/storage/cache/   → 755
```

یا اگر SSH دارید:

```bash
cd /home/username/public_html/kaizen_web
chmod 644 backend/.env
chmod -R 755 backend/storage
```

---

### گام 7: تنظیم .htaccess

#### A) برای Backend (در پوشه api یا backend/public)

فایل `.htaccess` بسازید:

```apache
# Backend API .htaccess

<IfModule mod_rewrite.c>
    RewriteEngine On

    # Redirect to HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Handle API Routes
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.php [QSA,L]
</IfModule>

# Security Headers
<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
    Header set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>

# Disable Directory Browsing
Options -Indexes

# Protect .env file
<Files .env>
    Order allow,deny
    Deny from all
</Files>

# PHP Settings
<IfModule mod_php7.c>
    php_value upload_max_filesize 50M
    php_value post_max_size 50M
    php_value memory_limit 256M
    php_value max_execution_time 300
</IfModule>
```

#### B) برای Frontend (در public_html)

```apache
# Frontend .htaccess

<IfModule mod_rewrite.c>
    RewriteEngine On

    # Redirect to HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # Redirect api requests to api folder
    RewriteRule ^api/(.*)$ /api/index.php [QSA,L]

    # SPA Routing
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.html [QSA,L]
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# Browser Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
</IfModule>
```

---

### گام 8: تنظیم URL در Frontend

فایل `frontend/public/index.html` را ویرایش کنید:

```javascript
// قبل:
apiUrl: 'http://localhost:8000/api',

// بعد:
apiUrl: 'https://yourdomain.com/api',
```

---

### گام 9: تست سیستم

#### 1. تست Backend API

```bash
# در مرورگر یا با curl:
https://yourdomain.com/api/health
```

**پاسخ مورد انتظار:**
```json
{
    "success": true,
    "data": {
        "status": "ok",
        "message": "API is running!",
        "version": "1.0.0"
    }
}
```

#### 2. تست اتصال دیتابیس

```bash
https://yourdomain.com/api/test/db
```

**پاسخ مورد انتظار:**
```json
{
    "success": true,
    "message": "اتصال به دیتابیس موفق بود",
    "data": {
        "database": "username_kaizen3d",
        "status": "connected",
        "users_count": 0
    }
}
```

#### 3. تست Frontend

```bash
https://yourdomain.com
```

باید صفحه اصلی با طراحی زیبا نمایش داده شود.

#### 4. تست تعاملی

- روی دکمه‌های تست API کلیک کنید
- باید پاسخ‌ها نمایش داده شوند
- وضعیت باید "آنلاین" باشد

---

## 🐛 عیب‌یابی رایج

### مشکل 1: 500 Internal Server Error

**راه حل:**
1. چک کردن error log:
   - cPanel → Error Log
   - یا `~/public_html/error_log`

2. بررسی .htaccess (ممکن است اشتباه باشد)

3. بررسی file permissions

### مشکل 2: "Class not found"

**راه حل:**
```bash
# از SSH:
cd /home/username/api
composer dump-autoload --optimize
```

### مشکل 3: خطای اتصال دیتابیس

**راه حل:**
1. بررسی `.env`:
   - نام دیتابیس صحیح است؟
   - نام کاربری و رمز عبور درست است؟
   - `DB_HOST=localhost` است؟

2. بررسی دسترسی کاربر در phpMyAdmin

### مشکل 4: CORS Error

**راه حل:**
در `.env` بررسی کنید:
```env
CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

### مشکل 5: Frontend API رو صدا نمی‌زنه

**راه حل:**
در `index.html` بررسی کنید:
```javascript
apiUrl: 'https://yourdomain.com/api',  // باید HTTPS باشد
```

---

## ✅ Checklist نهایی

قبل از اعلام موفقیت:

- [ ] Backend API در `https://yourdomain.com/api/health` پاسخ می‌دهد
- [ ] اتصال دیتابیس موفق است (`/api/test/db`)
- [ ] Frontend در `https://yourdomain.com` نمایش داده می‌شود
- [ ] تست‌های API در صفحه اصلی کار می‌کنند
- [ ] وضعیت "آنلاین" نمایش داده می‌شود
- [ ] فایل `.env` محافظت شده است (644)
- [ ] پوشه storage قابل نوشتن است (755)
- [ ] SSL نصب شده (HTTPS فعال است)

---

## 🎉 تبریک!

سیستم شما روی cPanel دیپلوی شده است!

### مراحل بعدی:

1. ✅ نصب SSL Certificate (Let's Encrypt رایگان)
2. ✅ تنظیم Cron Jobs برای cleanup
3. ✅ راه‌اندازی Backup خودکار
4. ✅ اتصال به بات تلگرام
5. ✅ توسعه ماژول‌های بعدی

---

## 📞 پشتیبانی

اگر مشکلی پیش آمد:

1. لاگ‌ها را چک کنید (cPanel → Error Log)
2. مستندات را بخوانید: `docs/DEPLOYMENT.md`
3. Issue باز کنید در GitHub

---

**نسخه:** 1.0.0
**آخرین به‌روزرسانی:** 2024-11-17
