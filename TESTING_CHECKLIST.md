# ✅ چک‌لیست تست بعد از دیپلوی

این چک‌لیست را بعد از دیپلوی روی cPanel کامل کنید تا مطمئن شوید همه چیز درست کار می‌کند.

---

## 1️⃣ تست Backend API

### ✅ Health Check

**URL:**
```
https://yourdomain.com/api/health
```

**پاسخ مورد انتظار:**
```json
{
    "success": true,
    "data": {
        "status": "ok",
        "message": "API is running!",
        "version": "1.0.0",
        "timestamp": "2024-...",
        "environment": "production"
    }
}
```

- [ ] کد وضعیت: **200 OK**
- [ ] `success: true`
- [ ] `status: "ok"`
- [ ] `environment: "production"`

---

### ✅ API Info

**URL:**
```
https://yourdomain.com/api
```

**پاسخ مورد انتظار:**
```json
{
    "success": true,
    "data": {
        "name": "Kaizen 3D Printing API",
        "version": "1.0.0",
        "endpoints": { ... }
    }
}
```

- [ ] لیست endpoints نمایش داده می‌شود
- [ ] نام و نسخه صحیح است

---

### ✅ Database Connection

**URL:**
```
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

- [ ] اتصال موفق است
- [ ] نام دیتابیس صحیح است
- [ ] تعداد کاربران 0 یا بیشتر است

---

### ✅ 404 Handler

**URL:**
```
https://yourdomain.com/api/not-found-endpoint
```

**پاسخ مورد انتظار:**
```json
{
    "success": false,
    "message": "Endpoint مورد نظر یافت نشد",
    "errors": {
        "path": "/api/not-found-endpoint"
    }
}
```

- [ ] کد وضعیت: **404**
- [ ] پیام خطا نمایش داده می‌شود

---

## 2️⃣ تست Frontend

### ✅ صفحه اصلی

**URL:**
```
https://yourdomain.com
```

**باید ببینید:**
- [ ] صفحه لود می‌شود (نه 404 یا 500)
- [ ] Header بنفش با لوگو نمایش داده می‌شود
- [ ] فونت فارسی صحیح است
- [ ] 4 کارت آمار نمایش داده می‌شود
- [ ] بخش "تست API Endpoints" وجود دارد

---

### ✅ وضعیت API در Frontend

- [ ] نشانگر وضعیت **"آنلاین"** است (سبز)
- [ ] نسخه API نمایش داده می‌شود: **1.0.0**
- [ ] محیط نمایش داده می‌شود: **production**

---

### ✅ تست تعاملی API

روی هر یک از دکمه‌های زیر کلیک کنید:

**دکمه 1: تست Health**
- [ ] دکمه کلیک می‌شود
- [ ] Loading نمایش داده می‌شود
- [ ] پاسخ JSON با syntax highlighting نمایش داده می‌شود
- [ ] وضعیت "موفق" (سبز) نمایش داده می‌شود

**دکمه 2: تست API Info**
- [ ] پاسخ صحیح نمایش داده می‌شود
- [ ] لیست endpoints قابل مشاهده است

**دکمه 3: تست 404**
- [ ] خطای 404 نمایش داده می‌شود
- [ ] وضعیت "خطا" (قرمز) نمایش داده می‌شود

---

## 3️⃣ تست امنیت

### ✅ محافظت از فایل .env

**URL:**
```
https://yourdomain.com/api/.env
```

- [ ] فایل قابل دسترسی **نیست**
- [ ] خطای 403 Forbidden نمایش داده می‌شود

---

### ✅ HTTPS

- [ ] سایت با HTTPS لود می‌شود
- [ ] قفل سبز در مرورگر نمایش داده می‌شود
- [ ] HTTP به HTTPS redirect می‌شود

---

### ✅ CORS

از Developer Tools مرورگر (F12 → Console):

```javascript
fetch('https://yourdomain.com/api/health')
  .then(res => res.json())
  .then(data => console.log(data));
```

- [ ] خطای CORS ندارد
- [ ] پاسخ برگردانده می‌شود

---

## 4️⃣ تست File Permissions

### ✅ Storage Directories

در File Manager بررسی کنید:

```
backend/storage/uploads/    → 755 ✓
backend/storage/logs/       → 755 ✓
backend/storage/cache/      → 755 ✓
backend/.env                → 644 ✓
```

- [ ] همه permissions صحیح هستند

---

## 5️⃣ تست Error Logging

### ✅ لاگ خطاها

در cPanel → **Error Log** یا `~/public_html/error_log`:

- [ ] خطاهای PHP وجود ندارد
- [ ] اگر خطا وجود دارد، بررسی و رفع شده است

---

## 6️⃣ تست عملکرد

### ✅ سرعت

- [ ] صفحه اصلی در کمتر از 2 ثانیه لود می‌شود
- [ ] API در کمتر از 500ms پاسخ می‌دهد

---

### ✅ Responsive Design

سایز پنجره مرورگر را تغییر دهید:

- [ ] در موبایل (< 768px) صحیح نمایش داده می‌شود
- [ ] در تبلت (768px - 1024px) صحیح نمایش داده می‌شود
- [ ] در دسکتاپ (> 1024px) صحیح نمایش داده می‌شود

---

### ✅ مرورگرهای مختلف

سایت را در مرورگرهای زیر تست کنید:

- [ ] Chrome/Edge (آخرین نسخه)
- [ ] Firefox (آخرین نسخه)
- [ ] Safari (اگر macOS/iOS)
- [ ] موبایل (Chrome Mobile / Safari iOS)

---

## 7️⃣ تست دیتابیس

### ✅ جداول

در phpMyAdmin بررسی کنید:

- [ ] 11 جدول ساخته شده است:
  - users
  - files
  - materials
  - orders
  - order_timeline
  - notifications
  - sessions
  - api_tokens
  - settings
  - activity_log
  - sync_log

- [ ] Views ساخته شده‌اند:
  - unified_users
  - order_statistics

- [ ] Triggers ساخته شده‌اند:
  - after_order_insert
  - after_order_update

---

### ✅ داده‌های اولیه

- [ ] جدول `materials` شامل 4 ماده اولیه است (PLA, ABS, PETG, TPU)
- [ ] جدول `settings` شامل تنظیمات پیش‌فرض است

---

## 8️⃣ تست تنظیمات محیط

### ✅ فایل .env

بررسی کنید که تمام موارد زیر در `.env` تنظیم شده باشد:

- [ ] `APP_ENV=production`
- [ ] `APP_DEBUG=false`
- [ ] `APP_URL` صحیح است
- [ ] اطلاعات دیتابیس صحیح است
- [ ] `JWT_SECRET` یک رشته تصادفی 32+ کاراکتری است
- [ ] `CORS_ALLOWED_ORIGINS` شامل دامنه شما است

---

## 9️⃣ تست Backup

### ✅ پشتیبان‌گیری

- [ ] یک backup دستی از دیتابیس گرفته شده است
- [ ] یک backup از فایل‌های پروژه گرفته شده است

**دستور backup دیتابیس:**
```bash
mysqldump -u username -p database_name > backup_$(date +%Y%m%d).sql
```

---

## 🔟 تست نهایی

### ✅ End-to-End Test

یک سناریوی کامل را تست کنید:

1. [ ] وارد سایت شوید: `https://yourdomain.com`
2. [ ] روی دکمه "تست Health" کلیک کنید
3. [ ] پاسخ JSON صحیح نمایش داده شود
4. [ ] روی دکمه "تست API Info" کلیک کنید
5. [ ] لیست endpoints نمایش داده شود
6. [ ] روی دکمه "تست 404" کلیک کنید
7. [ ] خطای 404 صحیح نمایش داده شود

همه مراحل بدون خطا کار کنند: ✅

---

## 📊 نتیجه کلی

### تعداد تست‌های موفق:

```
Backend API:          __ از 4  ✓
Frontend:             __ از 6  ✓
امنیت:               __ از 3  ✓
File Permissions:     __ از 4  ✓
Error Logging:        __ از 1  ✓
عملکرد:             __ از 6  ✓
دیتابیس:            __ از 5  ✓
تنظیمات محیط:        __ از 6  ✓
Backup:              __ از 2  ✓
تست نهایی:          __ از 7  ✓
```

**جمع کل: __ از 44**

---

## ✅ اگر همه تست‌ها موفق بود:

**🎉 تبریک! سیستم شما با موفقیت دیپلوی شده است!**

### مراحل بعدی:

1. ✅ نصب SSL Certificate (اگر هنوز نکردید)
2. ✅ راه‌اندازی Cron Jobs برای cleanup
3. ✅ تنظیم Backup خودکار روزانه
4. ✅ اتصال به بات تلگرام موجود
5. ✅ شروع توسعه ماژول Authentication
6. ✅ پیاده‌سازی File Upload
7. ✅ توسعه Order Management

---

## ❌ اگر تست‌هایی ناموفق بود:

1. خطاها را در cPanel → Error Log بررسی کنید
2. راهنمای عیب‌یابی در `DEPLOY_GUIDE.md` را مطالعه کنید
3. تنظیمات `.env` و `.htaccess` را دوباره بررسی کنید
4. File permissions را چک کنید

---

**تاریخ تست:** __________
**تست شده توسط:** __________
**نتیجه نهایی:** ☐ موفق   ☐ نیاز به رفع مشکل

---

**ذخیره کنید این چک‌لیست را برای مراجعات بعدی! 📋**
