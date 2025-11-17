# 📦 راهنمای دیپلوی روی cPanel

این راهنما مراحل کامل دیپلوی پروژه روی هاست cPanel را شرح می‌دهد.

## 📋 پیش‌نیازها

قبل از شروع، اطمینان حاصل کنید که:

- ✅ دسترسی کامل به cPanel دارید
- ✅ PHP 8.1 یا بالاتر فعال است
- ✅ MySQL/MariaDB در دسترس است
- ✅ دسترسی SSH (اختیاری اما توصیه می‌شود)
- ✅ SSL Certificate نصب شده (رایگان با Let's Encrypt)

---

## 🚀 روش 1: دیپلوی با File Manager (ساده‌ترین)

### گام 1: آماده‌سازی فایل‌ها

در کامپیوتر محلی:

```bash
cd kaizen_web

# حذف فایل‌های غیرضروری
rm -rf .git node_modules backend/vendor

# نصب dependencies در محیط production
cd backend
composer install --no-dev --optimize-autoloader
cd ..

# زیپ کردن پروژه
zip -r kaizen_web.zip . -x "*.git*" -x "*node_modules*" -x "*.DS_Store"
```

### گام 2: آپلود به cPanel

1. وارد **cPanel** شوید
2. به **File Manager** بروید
3. به پوشه `public_html` بروید (یا subdomain مورد نظر)
4. فایل `kaizen_web.zip` را آپلود کنید
5. روی فایل زیپ کلیک راست کنید و **Extract** را انتخاب کنید

### گام 3: تنظیم ساختار پوشه‌ها

ساختار باید به این شکل باشد:

```
public_html/
├── kaizen_web/
│   ├── backend/
│   ├── frontend/
│   ├── telegram-integration/
│   └── ...
```

یا برای subdomain:

```
yourdomain.com/
├── public_html/          # Frontend
│   └── (frontend files)
├── api/                   # Backend
│   └── (backend files)
```

### گام 4: ایجاد دیتابیس

1. در cPanel به **MySQL Databases** بروید
2. **Create New Database**:
   - نام: `username_kaizen3d`
   - Create Database
3. **Create New User**:
   - Username: `username_kaizen`
   - Password: یک رمز قوی
   - Create User
4. **Add User to Database**:
   - User: `username_kaizen`
   - Database: `username_kaizen3d`
   - Privileges: **ALL PRIVILEGES**

### گام 5: تنظیم .env

در File Manager:

1. به پوشه `backend/` بروید
2. فایل `.env.example` را کپی کنید و نام آن را به `.env` تغییر دهید
3. Edit کنید و تنظیمات را وارد کنید:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://yourdomain.com

DB_HOST=localhost
DB_DATABASE=username_kaizen3d
DB_USERNAME=username_kaizen
DB_PASSWORD=your-strong-password

JWT_SECRET=your-random-32-character-secret-here
```

### گام 6: اجرای Migrations

دو روش:

#### الف) از طریق phpMyAdmin:
1. وارد **phpMyAdmin** شوید
2. دیتابیس `username_kaizen3d` را انتخاب کنید
3. به تب **SQL** بروید
4. فایل‌های migration را یکی یکی کپی و Execute کنید

#### ب) از طریق SSH (اگر دارید):
```bash
ssh username@yourdomain.com
cd public_html/kaizen_web/backend
php database/migrate.php
```

### گام 7: تنظیم Permissions

در File Manager:

```
backend/.env          → 644
backend/storage/      → 755
backend/storage/uploads/ → 755
backend/storage/logs/    → 755
backend/storage/cache/   → 755
```

یا از SSH:

```bash
cd public_html/kaizen_web
chmod 644 backend/.env
chmod 755 backend/storage backend/storage/uploads backend/storage/logs backend/storage/cache
```

### گام 8: تنظیم .htaccess

#### Backend (.htaccess در backend/public/):

```apache
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

#### Frontend (.htaccess در frontend/public/):

```apache
<IfModule mod_rewrite.c>
    RewriteEngine On

    # Redirect to HTTPS
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

    # SPA Routing (Single Page Application)
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule ^ index.html [QSA,L]
</IfModule>

# Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript
</IfModule>

# Browser Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/x-icon "access plus 1 year"
</IfModule>
```

### گام 9: تست سیستم

1. **تست Backend API**:
   ```
   https://yourdomain.com/api/health
   ```
   باید بازگرداند: `{"status":"ok"}`

2. **تست Frontend**:
   ```
   https://yourdomain.com
   ```
   باید صفحه اصلی نمایش داده شود.

3. **تست Database**:
   از phpMyAdmin چک کنید که جداول ساخته شده‌اند.

---

## 🚀 روش 2: دیپلوی با SSH (پیشرفته‌تر)

### گام 1: اتصال SSH

```bash
ssh username@yourdomain.com
cd public_html
```

### گام 2: کلون یا آپلود پروژه

#### از Git:
```bash
git clone https://github.com/yourusername/kaizen_web.git
cd kaizen_web
```

#### یا آپلود با rsync:
```bash
# از کامپیوتر محلی
rsync -avz --exclude 'node_modules' --exclude '.git' kaizen_web/ username@yourdomain.com:public_html/kaizen_web/
```

### گام 3: نصب Dependencies

```bash
cd kaizen_web/backend
composer install --no-dev --optimize-autoloader
```

### گام 4: تنظیم .env

```bash
cp .env.example .env
nano .env  # یا vi .env
# تنظیمات را وارد کنید
```

### گام 5: Migration و Setup

```bash
php database/migrate.php
```

### گام 6: تنظیم Permissions

```bash
chmod 644 .env
chmod -R 755 storage
```

---

## 🔧 روش 3: دیپلوی با Git Deploy (حرفه‌ای)

بعضی از cPanel ها از Git Deploy پشتیبانی می‌کنند:

### گام 1: ایجاد Git Repository در cPanel

1. به **Git Version Control** در cPanel بروید
2. **Create** را کلیک کنید
3. Clone URL: `https://github.com/yourusername/kaizen_web.git`
4. Repository Path: `/home/username/repositories/kaizen_web`
5. Create

### گام 2: Deploy

1. روی repository کلیک کنید
2. **Pull or Deploy** → **Update from Remote**
3. Script بعد از deploy:

```bash
#!/bin/bash
cd /home/username/public_html/kaizen_web/backend
composer install --no-dev --optimize-autoloader
php database/migrate.php
```

---

## 🔐 امنیت در Production

### 1. تنظیمات PHP (php.ini یا .htaccess)

```ini
; غیرفعال کردن نمایش خطاها
display_errors = Off
log_errors = On
error_log = /home/username/public_html/kaizen_web/backend/storage/logs/php_errors.log

; امنیت
expose_php = Off
allow_url_fopen = Off
allow_url_include = Off
```

### 2. محافظت از فایل‌های حساس

**.htaccess در root**:
```apache
# Protect sensitive files
<FilesMatch "\.(env|log|sql|md|json|lock)$">
    Order allow,deny
    Deny from all
</FilesMatch>

# Protect directories
RedirectMatch 403 ^/backend/storage/
RedirectMatch 403 ^/backend/database/
RedirectMatch 403 ^/backend/config/
```

### 3. SSL/HTTPS

در cPanel:
1. به **SSL/TLS** بروید
2. **Let's Encrypt** را انتخاب کنید
3. دامنه را انتخاب و Issue کنید

### 4. File Permissions استاندارد

```bash
# Directories
find . -type d -exec chmod 755 {} \;

# Files
find . -type f -exec chmod 644 {} \;

# Specific
chmod 644 backend/.env
chmod 755 backend/storage
chmod 755 backend/storage/uploads
chmod 755 backend/storage/logs
```

### 5. Database Security

```sql
-- فقط دسترسی‌های لازم را بدهید
REVOKE ALL PRIVILEGES ON kaizen_3d.* FROM 'username_kaizen'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON kaizen_3d.* TO 'username_kaizen'@'localhost';
FLUSH PRIVILEGES;
```

---

## 📊 Monitoring و Logging

### 1. فعال‌سازی Logging

در `backend/.env`:
```env
LOG_CHANNEL=daily
LOG_LEVEL=error  # در production فقط error
LOG_PATH=storage/logs
```

### 2. چک کردن Logs

```bash
# Error logs
tail -f backend/storage/logs/app.log

# PHP errors
tail -f backend/storage/logs/php_errors.log

# cPanel Error logs
tail -f ~/public_html/error_log
```

### 3. Cron Job برای Cleanup (اختیاری)

در cPanel → **Cron Jobs**:

```bash
# هر روز ساعت 2 صبح، لاگ‌های قدیمی را پاک کن
0 2 * * * find /home/username/public_html/kaizen_web/backend/storage/logs -name "*.log" -mtime +30 -delete
```

---

## 🔄 به‌روزرسانی (Update)

### روش 1: Manual

```bash
# از کامپیوتر محلی
rsync -avz kaizen_web/ username@yourdomain.com:public_html/kaizen_web/

# روی سرور
ssh username@yourdomain.com
cd public_html/kaizen_web/backend
composer install --no-dev
php database/migrate.php
```

### روش 2: Git Pull

```bash
ssh username@yourdomain.com
cd public_html/kaizen_web
git pull origin main
cd backend
composer install --no-dev
php database/migrate.php
```

---

## 💾 Backup Strategy

### 1. Database Backup

#### Manual:
```bash
# از cPanel → phpMyAdmin → Export
# یا از SSH:
mysqldump -u username_kaizen -p username_kaizen3d > backup_$(date +%Y%m%d).sql
```

#### Automated (Cron):
```bash
# هر روز ساعت 3 صبح
0 3 * * * mysqldump -u username_kaizen -p'password' username_kaizen3d > /home/username/backups/db_$(date +\%Y\%m\%d).sql
```

### 2. File Backup

```bash
# Backup uploaded files
tar -czf uploads_backup_$(date +%Y%m%d).tar.gz backend/storage/uploads/

# Full project backup
tar -czf kaizen_full_backup_$(date +%Y%m%d).tar.gz kaizen_web/
```

### 3. از cPanel Backup استفاده کنید

cPanel → **Backup** → **Generate Backup**

---

## 🐛 عیب‌یابی رایج در cPanel

### مشکل 1: 500 Internal Server Error

**علل احتمالی**:
- .htaccess اشتباه
- Permission نادرست
- خطای PHP

**راه حل**:
```bash
# چک کردن error log
tail -f ~/public_html/error_log

# تست .htaccess
mv .htaccess .htaccess.bak
# اگر سایت کار کرد، مشکل از .htaccess است
```

### مشکل 2: Class Not Found

**راه حل**:
```bash
cd backend
composer dump-autoload --optimize
```

### مشکل 3: Database Connection Failed

**راه حل**:
```bash
# چک کردن اطلاعات دیتابیس در .env
# چک کردن دسترسی کاربر از phpMyAdmin
# اطمینان از اینکه DB_HOST=localhost است
```

### مشکل 4: Upload نمی‌کند

**راه حل**:
```apache
# در .htaccess اضافه کنید:
php_value upload_max_filesize 50M
php_value post_max_size 50M
```

### مشکل 5: CORS Error

**راه حل**:
در `backend/public/index.php` اضافه کنید:
```php
header('Access-Control-Allow-Origin: https://yourdomain.com');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');
```

---

## ✅ Checklist نهایی

قبل از live کردن سایت:

- [ ] SSL Certificate نصب شده
- [ ] Database ساخته و migrate شده
- [ ] .env تنظیمات production دارد
- [ ] APP_DEBUG=false
- [ ] File Permissions صحیح است
- [ ] .htaccess تنظیم شده
- [ ] Backup اولیه گرفته شده
- [ ] API endpoints تست شده‌اند
- [ ] Frontend بدون مشکل لود می‌شود
- [ ] Telegram Bot متصل شده (اگر لازم است)
- [ ] Error logging فعال است
- [ ] Security headers تنظیم شده

---

## 📞 پشتیبانی

اگر مشکلی داشتید:
1. Error logs را چک کنید
2. مستندات cPanel را مطالعه کنید
3. با پشتیبانی هاست تماس بگیرید

---

**موفق باشید! 🎉**
