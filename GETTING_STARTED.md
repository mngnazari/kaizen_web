# 🚀 شروع سریع - 5 دقیقه!

راهنمای فوری برای شروع کار با پروژه.

---

## 📦 نصب سریع

### 1️⃣ کلون پروژه (30 ثانیه)

```bash
git clone https://github.com/mngnazari/kaizen_web.git
cd kaizen_web
```

### 2️⃣ نصب Dependencies (2 دقیقه)

```bash
cd backend
composer install
cd ..
```

### 3️⃣ دیتابیس (1 دقیقه)

```bash
# باز کردن MySQL/phpMyAdmin
# ایجاد دیتابیس: kaizen_3d
# Import فایل: backend/database/schema.sql
```

### 4️⃣ تنظیم .env (1 دقیقه)

```bash
cd backend
cp .env.example .env
# ویرایش .env و تنظیم دیتابیس
```

تولید JWT Secret:
```bash
php -r "echo bin2hex(random_bytes(32));"
```

### 5️⃣ اجرا! (30 ثانیه)

```bash
# از root پروژه:
./scripts/start-servers.sh

# یا دستی:
# Terminal 1:
cd backend && php -S localhost:8000 -t public

# Terminal 2:
cd frontend/public && python -m http.server 3000
```

---

## ✅ تست

بازکن:
- 📡 Backend: `http://localhost:8000/api/health`
- 🌐 Frontend: `http://localhost:3000`

---

## 📚 راهنماهای کامل

انتخاب کن بسته به نیازت:

### برای توسعه محلی:
👉 **[LOCAL_DEVELOPMENT.md](./LOCAL_DEVELOPMENT.md)** - راهنمای کامل راه‌اندازی محلی

### برای دیپلوی روی هاست:
👉 **[DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)** - راهنمای دیپلوی روی cPanel

### برای درک معماری:
👉 **[ARCHITECTURE.md](./ARCHITECTURE.md)** - معماری سیستم

### برای شروع سریع:
👉 **[QUICKSTART.md](./QUICKSTART.md)** - راهنمای سریع

### برای API:
👉 **[docs/API.md](./docs/API.md)** - مستندات API

---

## 🎯 مراحل بعدی

بعد از راه‌اندازی:

1. ✅ بخون: **LOCAL_DEVELOPMENT.md** برای جزئیات بیشتر
2. ✅ شروع کن: توسعه ماژول Authentication
3. ✅ تست کن: با Postman یا curl
4. ✅ Commit کن: تغییراتت رو

---

## 🆘 مشکل داری؟

### خطاهای رایج:

**"Class not found":**
```bash
cd backend && composer dump-autoload
```

**"Database connection failed":**
```bash
# چک کن .env فایل
# مطمئن شو MySQL داره کار می‌کنه
```

**"CORS error":**
```bash
# در .env:
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

---

## 💡 نکته طلایی

همیشه قبل از شروع کار:
```bash
git pull origin main
```

همیشه بعد از کار:
```bash
git add .
git commit -m "feat: توضیح تغییرات"
git push origin main
```

---

**حالا بریم کد بزنیم! 🎉**
