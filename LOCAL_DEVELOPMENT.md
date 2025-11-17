# 🖥️ راهنمای راه‌اندازی محیط توسعه محلی

این راهنما برای کلون کردن پروژه از GitHub و راه‌اندازی روی کامپیوتر شخصی است.

---

## 📋 پیش‌نیازها

قبل از شروع، این‌ها رو نصب کن:

### الزامی:
- ✅ **Git** - [دانلود](https://git-scm.com/)
- ✅ **PHP 8.1+** - [دانلود](https://www.php.net/downloads)
- ✅ **Composer** - [دانلود](https://getcomposer.org/)
- ✅ **MySQL/MariaDB** - [دانلود XAMPP](https://www.apachefriends.org/) یا [دانلود MySQL](https://dev.mysql.com/downloads/)

### اختیاری (ولی توصیه می‌شه):
- ✅ **Node.js** - [دانلود](https://nodejs.org/) (برای frontend tools)
- ✅ **IDE/Editor:**
  - [PhpStorm](https://www.jetbrains.com/phpstorm/) (بهترین برای PHP)
  - [VS Code](https://code.visualstudio.com/) (رایگان و عالی)
  - [Sublime Text](https://www.sublimetext.com/)

### افزونه‌های توصیه شده VS Code:
```
- PHP Intelephense
- PHP Debug
- GitLens
- Tailwind CSS IntelliSense
- ESLint
- Prettier
- MySQL (Jun Han)
```

---

## 🚀 گام 1: کلون کردن پروژه

### روش A: با Git Command Line

```bash
# 1. باز کردن Terminal/Command Prompt
# در Windows: Win + R → cmd
# در Mac/Linux: Terminal

# 2. رفتن به پوشه‌ای که می‌خوای پروژه باشه
cd Desktop
# یا
cd C:\Users\YourName\Projects

# 3. کلون کردن پروژه
git clone https://github.com/mngnazari/kaizen_web.git

# 4. ورود به پوشه پروژه
cd kaizen_web
```

### روش B: با GitHub Desktop

1. دانلود و نصب [GitHub Desktop](https://desktop.github.com/)
2. باز کردن GitHub Desktop
3. **File → Clone Repository**
4. تب **URL** را انتخاب کنید
5. آدرس بزنید: `https://github.com/mngnazari/kaizen_web.git`
6. **Local Path** را انتخاب کنید
7. **Clone** بزنید

### روش C: با دانلود مستقیم ZIP

1. به [GitHub Repository](https://github.com/mngnazari/kaizen_web) برو
2. دکمه **Code** (سبز) رو بزن
3. **Download ZIP** رو انتخاب کن
4. فایل ZIP رو Extract کن

**⚠️ نکته:** با روش ZIP، Git history نداری و نمی‌تونی راحت push/pull کنی. روش A یا B بهتره!

---

## 🔧 گام 2: باز کردن پروژه در IDE

### PhpStorm:

1. باز کردن PhpStorm
2. **File → Open**
3. پوشه `kaizen_web` رو انتخاب کن
4. **Trust Project** بزن

**تنظیمات اولیه PhpStorm:**

```
Settings/Preferences → PHP:
  ✓ PHP Language Level: 8.1+
  ✓ CLI Interpreter: (مسیر PHP روی سیستمت)

Settings → Editor → Code Style:
  ✓ Scheme: PSR-12

Settings → PHP → Composer:
  ✓ Path to composer.json: backend/composer.json
```

### VS Code:

1. باز کردن VS Code
2. **File → Open Folder**
3. پوشه `kaizen_web` رو انتخاب کن

**تنظیمات VS Code (اختیاری):**

فایل `.vscode/settings.json` بساز:

```json
{
    "php.validate.executablePath": "/path/to/php",
    "php.suggest.basic": false,
    "intelephense.environment.phpVersion": "8.1",
    "files.associations": {
        "*.php": "php"
    },
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "junstyle.php-cs-fixer",
    "emmet.includeLanguages": {
        "php": "html"
    }
}
```

---

## 📦 گام 3: نصب Dependencies

### Backend (PHP):

```bash
# ورود به پوشه backend
cd backend

# نصب Composer packages
composer install

# برگشت به root
cd ..
```

اگر Composer نصب نیست:
```bash
# دانلود Composer:
# Windows: از https://getcomposer.org/download/
# Mac/Linux:
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
```

### Frontend (اختیاری):

```bash
# ورود به پوشه frontend
cd frontend

# نصب NPM packages (اگه بخوای build کنی)
npm install

# برگشت به root
cd ..
```

**✅ Dependencies نصب شدند!**

---

## 🗄️ گام 4: راه‌اندازی دیتابیس

### روش A: استفاده از XAMPP (ساده‌ترین)

#### 1. نصب XAMPP:
- دانلود از [apachefriends.org](https://www.apachefriends.org/)
- نصب و اجرا

#### 2. شروع MySQL:
- باز کردن XAMPP Control Panel
- Start کردن **Apache** و **MySQL**

#### 3. باز کردن phpMyAdmin:
- مرورگر: `http://localhost/phpmyadmin`
- یا از XAMPP Control Panel روی دکمه **Admin** کنار MySQL کلیک کن

#### 4. ایجاد دیتابیس:
```sql
-- کلیک روی "New" در سمت چپ
-- نام دیتابیس: kaizen_3d
-- Collation: utf8mb4_unicode_ci
-- Create بزن
```

#### 5. Import Schema:
- دیتابیس `kaizen_3d` رو انتخاب کن
- تب **Import** رو باز کن
- **Choose File** بزن
- فایل `backend/database/schema.sql` رو انتخاب کن
- **Go** بزن

✅ دیتابیس آماده است!

### روش B: استفاده از MySQL Command Line

```bash
# ورود به MySQL
mysql -u root -p
# رمز عبور: (اگه نصب تازه‌ای، معمولاً خالیه)

# ایجاد دیتابیس
CREATE DATABASE kaizen_3d CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# خروج
EXIT;

# Import schema
mysql -u root -p kaizen_3d < backend/database/schema.sql
```

### روش C: استفاده از Docker (پیشرفته)

```bash
# ایجاد docker-compose.yml
# (یک فایل نمونه در مستندات وجود داره)

docker-compose up -d
```

---

## ⚙️ گام 5: تنظیم فایل .env

### 1. کپی فایل نمونه:

```bash
# در Terminal/CMD:
cd backend
cp .env.example .env
```

یا دستی:
- فایل `backend/.env.example` رو کپی کن
- نامش رو به `.env` تغییر بده

### 2. ویرایش .env:

فایل `backend/.env` رو باز کن و این موارد رو تنظیم کن:

```env
# =================================
# APPLICATION SETTINGS
# =================================
APP_NAME="Kaizen 3D Printing"
APP_ENV=development              # ← مهم!
APP_DEBUG=true                   # ← برای توسعه محلی
APP_URL=http://localhost:8000
APP_TIMEZONE=Asia/Tehran

# =================================
# DATABASE CONFIGURATION
# =================================
DB_CONNECTION=mysql
DB_HOST=localhost                # یا 127.0.0.1
DB_PORT=3306
DB_DATABASE=kaizen_3d
DB_USERNAME=root                 # نام کاربری MySQL
DB_PASSWORD=                     # رمز عبور MySQL (اگه داری)

# =================================
# SECURITY
# =================================
# تولید JWT Secret:
JWT_SECRET=برای_تولید_این_دستور_رو_بزن  # ← زیر رو ببین

# =================================
# CORS (برای توسعه محلی)
# =================================
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
```

### 3. تولید JWT_SECRET:

```bash
# در Terminal:
php -r "echo bin2hex(random_bytes(32));"

# خروجی رو کپی کن و در .env بذار
```

**✅ تنظیمات کامل شد!**

---

## 🏃 گام 6: اجرای سرورها

### روش A: اسکریپت خودکار (ساده‌ترین)

```bash
# از root پروژه:
./scripts/start-servers.sh
```

این دستور هر دو سرور (Backend + Frontend) رو شروع می‌کنه!

### روش B: دستی (دو Terminal جداگانه)

#### Terminal 1 - Backend:
```bash
cd backend
php -S localhost:8000 -t public
```

پیام موفقیت:
```
PHP 8.1.x Development Server (http://localhost:8000) started
```

#### Terminal 2 - Frontend:
```bash
cd frontend/public
python -m http.server 3000

# یا با Node.js:
npx serve -p 3000
```

پیام موفقیت:
```
Serving HTTP on 0.0.0.0 port 3000 ...
```

**✅ سرورها در حال اجرا هستند!**

---

## 🧪 گام 7: تست سیستم

### 1. تست Backend API:

باز کردن مرورگر:
```
http://localhost:8000/api/health
```

**باید ببینی:**
```json
{
    "success": true,
    "data": {
        "status": "ok",
        "message": "API is running!",
        "version": "1.0.0",
        "environment": "development"
    }
}
```

### 2. تست اتصال دیتابیس:

```
http://localhost:8000/api/test/db
```

**باید ببینی:**
```json
{
    "success": true,
    "message": "اتصال به دیتابیس موفق بود",
    "data": {
        "database": "kaizen_3d",
        "status": "connected",
        "users_count": 0
    }
}
```

### 3. تست Frontend:

```
http://localhost:3000
```

**باید ببینی:**
- صفحه زیبا با طراحی بنفش
- وضعیت "آنلاین" سبز رنگ
- 4 کارت آمار
- بخش تست API

### 4. تست تعاملی:

در صفحه Frontend:
- روی دکمه **"تست Health"** کلیک کن
- باید پاسخ JSON با syntax highlighting نمایش داده بشه
- وضعیت "موفق" سبز باشه

**✅ همه چیز کار می‌کنه!**

---

## 💻 گام 8: شروع توسعه

حالا می‌تونی شروع به توسعه کنی!

### ساختار پروژه:

```
kaizen_web/
├── backend/
│   ├── public/
│   │   └── index.php          ← Entry point
│   ├── src/
│   │   ├── Controllers/       ← اینجا API endpoints می‌نویسی
│   │   ├── Services/          ← اینجا Business Logic
│   │   ├── Models/            ← اینجا Database Models
│   │   ├── Middleware/        ← اینجا Auth, CORS, etc.
│   │   └── Utils/             ← اینجا Helper functions
│   ├── database/
│   │   └── schema.sql         ← Database schema
│   └── .env                   ← تنظیمات (GIT IGNORE!)
│
├── frontend/
│   └── public/
│       └── index.html         ← صفحه اصلی
│
└── docs/                      ← مستندات
```

### مثال: اضافه کردن یک Controller جدید

فایل `backend/src/Controllers/TestController.php`:

```php
<?php

namespace Kaizen\Controllers;

use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;
use Kaizen\Utils\Response as ApiResponse;

class TestController
{
    public function hello(Request $request, Response $response)
    {
        $data = [
            'message' => 'سلام! این یک endpoint تست است'
        ];

        return ApiResponse::success($response, $data);
    }
}
```

فایل `backend/public/index.php` - اضافه کردن route:

```php
// بعد از use ها:
use Kaizen\Controllers\TestController;

// بعد از route های موجود:
$app->get('/api/test/hello', [TestController::class, 'hello']);
```

تست:
```
http://localhost:8000/api/test/hello
```

---

## 🔄 Git Workflow برای توسعه

### هر روز کاری:

```bash
# 1. Pull کردن آخرین تغییرات
git pull origin main

# 2. ساخت یک branch جدید برای feature
git checkout -b feature/my-new-feature

# 3. کدنویسی...
# توسعه feature خودت

# 4. دیدن تغییرات
git status

# 5. Add کردن فایل‌های تغییر یافته
git add .

# 6. Commit با پیام واضح
git commit -m "feat: add user authentication endpoint"

# 7. Push کردن branch
git push origin feature/my-new-feature
```

### وقتی feature تمام شد:

```bash
# 8. Merge کردن به main
git checkout main
git merge feature/my-new-feature

# 9. Push کردن main
git push origin main
```

### نکات مهم Git:

```bash
# چک کردن branch فعلی
git branch

# تغییر branch
git checkout branch-name

# دیدن لاگ commits
git log --oneline

# برگشت تغییرات (قبل از commit)
git checkout -- filename

# Stash کردن تغییرات موقت
git stash
git stash pop
```

---

## 🐛 Debug و Troubleshooting

### مشاهده خطاها:

#### Backend Errors:

```bash
# لاگ‌های PHP
tail -f backend/storage/logs/error.log
tail -f backend/storage/logs/app.log
```

#### Database Errors:

در `backend/.env`:
```env
APP_DEBUG=true  # نمایش خطاهای مفصل
```

### استفاده از Xdebug (پیشرفته):

نصب Xdebug:
```bash
# Windows (XAMPP):
# از phpMyAdmin → phpinfo() مسیر php.ini رو پیدا کن
# Xdebug رو فعال کن

# Mac:
pecl install xdebug

# Linux:
sudo apt-get install php-xdebug
```

تنظیمات PhpStorm:
```
Settings → PHP → Debug:
  ✓ Xdebug port: 9003
  ✓ Break at first line: checked

Run → Start Listening for PHP Debug Connections
```

---

## 📝 نکات مهم توسعه

### 1. هرگز این فایل‌ها رو Commit نکن:

```
✗ backend/.env
✗ backend/vendor/
✗ node_modules/
✗ *.log
✗ .DS_Store
✗ .idea/
```

این‌ها توی `.gitignore` هستند.

### 2. قبل از Commit:

```bash
# چک کردن syntax errors
php -l backend/src/Controllers/MyController.php

# اجرای Composer autoload
cd backend
composer dump-autoload
```

### 3. Testing:

```bash
# با curl
curl http://localhost:8000/api/health

# با Postman
# دانلود Postman و import کردن collection
```

### 4. Code Style:

```bash
# نصب PHP CS Fixer
composer require --dev friendsofphp/php-cs-fixer

# فرمت کردن کد
./vendor/bin/php-cs-fixer fix backend/src
```

---

## 🎯 Workflow روزانه پیشنهادی

### صبح:

1. ☕ یک چای/قهوه بگیر
2. باز کردن IDE
3. `git pull origin main`
4. شروع سرورها: `./scripts/start-servers.sh`
5. چک کردن `http://localhost:8000/api/health`

### در طول روز:

1. کد بنویس
2. تست کن
3. Commit کن (هر 1-2 ساعت)
4. Push کن

### شب:

1. Commit تغییرات نهایی
2. Push کن
3. توقف سرورها: `./scripts/stop-servers.sh`

---

## 🔐 امنیت در محیط محلی

حتی در محیط محلی، این‌ها رو رعایت کن:

```bash
# 1. استفاده از .env برای secrets
✓ هرگز رمزها رو hardcode نکن

# 2. استفاده از HTTPS محلی (اختیاری)
# می‌تونی با mkcert یک SSL محلی بسازی

# 3. دیتابیس محلی با رمز عبور
✓ حتی روی localhost رمز بذار
```

---

## 📚 منابع یادگیری

### PHP:
- [PHP Official Docs](https://www.php.net/manual/en/)
- [Slim Framework](https://www.slimframework.com/)
- [Composer](https://getcomposer.org/doc/)

### Git:
- [Git Handbook](https://guides.github.com/introduction/git-handbook/)
- [Learn Git Branching](https://learngitbranching.js.org/)

### Database:
- [MySQL Tutorial](https://www.mysqltutorial.org/)
- [phpMyAdmin Docs](https://docs.phpmyadmin.net/)

---

## ✅ Checklist راه‌اندازی

- [ ] Git نصب شده
- [ ] PHP 8.1+ نصب شده
- [ ] Composer نصب شده
- [ ] MySQL/XAMPP نصب شده
- [ ] پروژه کلون شده
- [ ] Dependencies نصب شده (`composer install`)
- [ ] دیتابیس ساخته شده
- [ ] Schema import شده
- [ ] فایل .env تنظیم شده
- [ ] سرورها اجرا می‌شوند
- [ ] `/api/health` پاسخ می‌دهد ✓
- [ ] `/api/test/db` موفق است ✓
- [ ] Frontend نمایش داده می‌شود ✓
- [ ] IDE تنظیم شده

---

## 🆘 کمک گرفتن

اگه جایی گیر کردی:

1. **Error logs** رو چک کن
2. مستندات پروژه رو بخون (`docs/`)
3. Issue باز کن در GitHub
4. از من بپرس! 😊

---

## 🎉 آماده‌ای!

حالا می‌تونی:
- ✅ راحت توسعه بدی
- ✅ تست کنی
- ✅ Commit/Push کنی
- ✅ وقتی آماده شد، روی هاست دیپلوی کنی

**موفق باشی! 🚀**

---

**آخرین به‌روزرسانی:** 2024-11-17
**نسخه:** 1.0.0
