# 📘 راهنمای گام به گام: کلون پروژه در PyCharm/PhpStorm

این راهنما برای کلون کردن پروژه Kaizen از GitHub به PyCharm یا PhpStorm است.

---

## 🎯 روش 1: کلون مستقیم از PyCharm/PhpStorm (ساده‌ترین!)

### گام 1: باز کردن PyCharm/PhpStorm

<kbd>باز کردن برنامه</kbd>

اگه اولین باره:
- صفحه Welcome نمایش داده میشه

اگه پروژه قبلی داری:
- **File** → **Close Project** بزن تا به صفحه Welcome بری

---

### گام 2: کلیک روی "Get from VCS"

در صفحه Welcome:

```
┌─────────────────────────────────┐
│  Welcome to PyCharm/PhpStorm    │
├─────────────────────────────────┤
│  ○  New Project                 │
│  ○  Open                        │
│  ○  Get from VCS  ← این رو بزن!│
└─────────────────────────────────┘
```

یا از منو:
**File** → **New** → **Project from Version Control...**

---

### گام 3: وارد کردن آدرس GitHub

یک پنجره باز میشه:

```
┌────────────────────────────────────────────┐
│  Get from Version Control               [×]│
├────────────────────────────────────────────┤
│  Version control: ▼ Git                    │
│                                             │
│  URL: [________________________]            │
│       ↑ اینجا آدرس رو بذار                │
│                                             │
│  Directory: [C:\Users\...\kaizen_web]      │
│              ↑ پوشه‌ای که می‌خوای ذخیره شه│
│                                             │
│           [Cancel]  [Clone]  ← بزن اینو!  │
└────────────────────────────────────────────┘
```

#### الف) در قسمت URL:
کپی کن و Paste کن:
```
https://github.com/mngnazari/kaizen_web.git
```

#### ب) در قسمت Directory:
- پیش‌فرض رو نگه دار
- یا پوشه‌ای که می‌خوای انتخاب کن
- مثلاً: `C:\Users\YourName\Projects\kaizen_web`

#### ج) کلیک روی Clone

---

### گام 4: صبر کن تا کلون کامل بشه

یک Progress Bar نمایش داده میشه:

```
Cloning repository...
████████████░░░░░░░░  60%
```

این ممکنه 1-3 دقیقه طول بکشه (بسته به سرعت اینترنت).

---

### گام 5: Trust Project

بعد از کلون، یک پیام میاد:

```
┌────────────────────────────────────┐
│  Trust and Open Project?           │
├────────────────────────────────────┤
│  This project contains code from   │
│  an external source.               │
│                                     │
│  Do you trust this project?        │
│                                     │
│    [Cancel]  [Trust Project]       │
│               ↑ بزن اینو!          │
└────────────────────────────────────┘
```

کلیک روی **Trust Project**

---

### گام 6: پروژه باز شد! 🎉

حالا باید ساختار پروژه رو در سمت چپ ببینی:

```
Project
├─ kaizen_web
   ├─ backend
   │  ├─ config
   │  ├─ database
   │  ├─ public
   │  ├─ src
   │  │  ├─ Controllers
   │  │  ├─ Models
   │  │  ├─ Services
   │  │  └─ Utils
   │  ├─ storage
   │  ├─ .env.example
   │  └─ composer.json
   │
   ├─ frontend
   │  └─ public
   │     └─ index.html
   │
   ├─ docs
   ├─ scripts
   ├─ README.md
   └─ ARCHITECTURE.md
```

**✅ کلون موفقیت‌آمیز بود!**

---

## 🎯 روش 2: کلون با Terminal (اگه روش 1 کار نکرد)

### گام 1: باز کردن Terminal در PyCharm

**View** → **Tool Windows** → **Terminal**

یا کلید میانبر:
- Windows/Linux: `Alt + F12`
- Mac: `Option + F12`

---

### گام 2: رفتن به پوشه مورد نظر

```bash
# مثلاً:
cd C:\Users\YourName\Projects

# یا در Mac/Linux:
cd ~/Projects
```

---

### گام 3: اجرای دستور Git Clone

```bash
git clone https://github.com/mngnazari/kaizen_web.git
```

صبر کن تا دانلود کامل بشه:

```
Cloning into 'kaizen_web'...
remote: Enumerating objects: 150, done.
remote: Counting objects: 100% (150/150), done.
remote: Compressing objects: 100% (95/95), done.
remote: Total 150 (delta 45), reused 140 (delta 40)
Receiving objects: 100% (150/150), 250.00 KiB | 1.50 MiB/s, done.
Resolving deltas: 100% (45/45), done.
```

---

### گام 4: باز کردن پروژه

**File** → **Open**

پوشه `kaizen_web` رو انتخاب کن و **OK** بزن.

---

## 🎯 روش 3: دانلود ZIP و باز کردن (اگه Git نصب نیست)

### گام 1: دانلود ZIP از GitHub

1. برو به: https://github.com/mngnazari/kaizen_web
2. کلیک روی دکمه سبز **Code**
3. انتخاب **Download ZIP**
4. ذخیره فایل

---

### گام 2: Extract کردن ZIP

- روی فایل ZIP کلیک راست کن
- **Extract Here** یا **Extract All** رو بزن
- یک پوشه `kaizen_web-main` ساخته میشه

---

### گام 3: Rename کردن پوشه (اختیاری)

نام پوشه رو از `kaizen_web-main` به `kaizen_web` تغییر بده.

---

### گام 4: باز کردن در PyCharm

**File** → **Open**

پوشه `kaizen_web` رو انتخاب کن.

**⚠️ نکته:** با این روش Git history نداری و نمی‌تونی pull/push کنی.

---

## ✅ بعد از کلون - مراحل بعدی

### 1️⃣ نصب Dependencies

باز کردن Terminal در PyCharm:

```bash
cd backend
composer install
```

اگه Composer نصب نیست:
- **Windows:** دانلود از https://getcomposer.org/
- **Mac:** `brew install composer`
- **Linux:** `sudo apt install composer`

---

### 2️⃣ تنظیم PHP Interpreter (مهم!)

برای PhpStorm/PyCharm Professional:

**File** → **Settings** (Windows/Linux) یا **Preferences** (Mac)

```
Settings
├─ PHP
   ├─ PHP Language Level: 8.1 یا بالاتر
   └─ CLI Interpreter:
      └─ [+] Add
         └─ مسیر PHP روی سیستمت
```

مثلاً:
- **Windows (XAMPP):** `C:\xampp\php\php.exe`
- **Mac:** `/usr/local/bin/php`
- **Linux:** `/usr/bin/php`

---

### 3️⃣ فعال‌سازی Composer

**File** → **Settings** → **PHP** → **Composer**

```
Composer
├─ Path to composer.json: backend/composer.json
└─ [✓] Synchronize IDE settings with composer.json
```

---

### 4️⃣ تنظیم Database (اختیاری ولی خوب!)

**View** → **Tool Windows** → **Database**

کلیک روی **+** → **Data Source** → **MySQL**

```
Host: localhost
Port: 3306
Database: kaizen_3d
User: root
Password: (رمز MySQL)
```

**Test Connection** بزن، بعد **OK**.

---

## 🔍 چک کردن موفقیت کلون

### چک 1: فایل‌ها موجودند؟

در Project Explorer (سمت چپ)، باید ببینی:
- ✅ پوشه `backend`
- ✅ پوشه `frontend`
- ✅ فایل `README.md`
- ✅ فایل `ARCHITECTURE.md`

---

### چک 2: Git فعال است؟

در پایین پنجره، تب **Git** رو ببینی؟
- ✅ اگه ببینی: Git فعاله
- ❌ اگه نبینی: ممکنه با ZIP دانلود کرده باشی

---

### چک 3: Composer Dependencies نصب شدند؟

چک کن پوشه `backend/vendor` وجود داره؟
- ✅ اگه هست: نصب شده
- ❌ اگه نیست: `composer install` رو بزن

---

## 🐛 مشکلات رایج و راه‌حل

### مشکل 1: "Git is not installed"

**راه‌حل:**
1. نصب Git از: https://git-scm.com/
2. Restart کردن PyCharm
3. دوباره تلاش کن

---

### مشکل 2: "Authentication failed"

اگه repository خصوصی بود:

**راه‌حل:**
- از Personal Access Token استفاده کن
- یا اطلاعات GitHub رو وارد کن

---

### مشکل 3: "Permission denied"

**راه‌حل:**
در Terminal:
```bash
# Windows
# اجرای PyCharm با Administrator

# Mac/Linux
sudo chown -R $USER:$USER kaizen_web
```

---

### مشکل 4: "Composer not found"

**راه‌حل:**
نصب Composer:

```bash
# Windows: از https://getcomposer.org/ دانلود کن

# Mac:
brew install composer

# Linux:
sudo apt install composer
```

---

### مشکل 5: کلون خیلی کنده

**راه‌حل:**
اینترنت کنده یا GitHub کنده.

```bash
# دانلود Shallow clone (سریع‌تر):
git clone --depth 1 https://github.com/mngnazari/kaizen_web.git
```

---

## 🎓 نکات مهم

### نکته 1: بعد از کلون
```bash
# همیشه اول این رو بزن:
cd backend
composer install
```

### نکته 2: قبل از هر کار
```bash
# Pull کردن آخرین تغییرات:
git pull origin main
```

### نکته 3: Branch فعلی
توی پایین سمت راست PyCharm، branch فعلی رو میبینی.

### نکته 4: Git Graph
**Git** → **Show Git Log** برای دیدن تاریخچه commits

---

## 📹 خلاصه تصویری

```
1. باز کردن PyCharm/PhpStorm
   ↓
2. Get from VCS
   ↓
3. Paste کردن URL:
   https://github.com/mngnazari/kaizen_web.git
   ↓
4. Clone
   ↓
5. Trust Project
   ↓
6. نصب Dependencies:
   composer install
   ↓
7. تنظیم .env
   ↓
8. اجرای سرورها
   ↓
9. شروع به کدنویسی! 🎉
```

---

## ✅ Checklist کلون موفق

- [ ] PyCharm/PhpStorm نصب شده
- [ ] Git نصب شده
- [ ] پروژه کلون شده
- [ ] فایل‌ها در Project Explorer دیده میشن
- [ ] Composer dependencies نصب شده
- [ ] PHP Interpreter تنظیم شده
- [ ] Terminal کار می‌کنه
- [ ] Git در PyCharm فعاله

---

## 🎉 موفق شدی!

حالا می‌تونی:
- ✅ کدنویسی کنی
- ✅ تست کنی
- ✅ Git استفاده کنی
- ✅ توسعه بدی

---

## 🆘 کمک بیشتر

اگه هنوز مشکل داری:
1. Screenshot بگیر از خطا
2. بهم نشون بده
3. من کمکت می‌کنم! 😊

---

**موفق باشی! 🚀**
