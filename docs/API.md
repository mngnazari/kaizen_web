# 📡 مستندات API

این مستند شامل تمام endpoint های API سیستم مدیریت پرینت سه‌بعدی Kaizen است.

## 🔗 Base URL

```
Development: http://localhost:8000/api
Production: https://yourdomain.com/api
```

## 🔐 Authentication

API از JWT (JSON Web Token) برای احراز هویت استفاده می‌کند.

### دریافت Token

هنگام لاگین، یک JWT Token دریافت می‌کنید که باید در header درخواست‌های بعدی قرار دهید:

```http
Authorization: Bearer {your-jwt-token}
```

### مدت اعتبار Token

Token ها به مدت 24 ساعت (قابل تنظیم) معتبر هستند.

---

## 📋 Endpoints

### 🔹 Health Check

برای چک کردن وضعیت API.

```http
GET /api/health
```

**Response:**
```json
{
    "status": "ok",
    "message": "API is running!",
    "version": "1.0.0",
    "timestamp": "2024-01-15T10:30:00Z"
}
```

---

## 👤 Authentication & User Management

### 🔹 ثبت‌نام (Register)

```http
POST /api/auth/register
Content-Type: application/json
```

**Request Body:**
```json
{
    "name": "علی احمدی",
    "email": "ali@example.com",
    "phone": "09123456789",
    "telegram_id": 123456789,
    "password": "SecurePassword123",
    "password_confirmation": "SecurePassword123"
}
```

**Response (Success - 201):**
```json
{
    "success": true,
    "message": "ثبت‌نام با موفقیت انجام شد",
    "data": {
        "user": {
            "id": 1,
            "name": "علی احمدی",
            "email": "ali@example.com",
            "phone": "09123456789",
            "telegram_id": 123456789,
            "role": "user",
            "created_at": "2024-01-15T10:30:00Z"
        },
        "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "expires_at": "2024-01-16T10:30:00Z"
    }
}
```

**Response (Error - 422):**
```json
{
    "success": false,
    "message": "خطا در اعتبارسنجی",
    "errors": {
        "email": ["ایمیل قبلا ثبت شده است"],
        "password": ["رمز عبور باید حداقل 8 کاراکتر باشد"]
    }
}
```

---

### 🔹 لاگین (Login)

```http
POST /api/auth/login
Content-Type: application/json
```

**Request Body:**
```json
{
    "email": "ali@example.com",
    "password": "SecurePassword123"
}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "ورود موفقیت‌آمیز",
    "data": {
        "user": {
            "id": 1,
            "name": "علی احمدی",
            "email": "ali@example.com",
            "role": "user"
        },
        "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
        "expires_at": "2024-01-16T10:30:00Z"
    }
}
```

**Response (Error - 401):**
```json
{
    "success": false,
    "message": "ایمیل یا رمز عبور اشتباه است"
}
```

---

### 🔹 دریافت اطلاعات کاربر

```http
GET /api/auth/me
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "name": "علی احمدی",
        "email": "ali@example.com",
        "phone": "09123456789",
        "telegram_id": 123456789,
        "role": "user",
        "status": "active",
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-15T10:30:00Z"
    }
}
```

---

### 🔹 به‌روزرسانی پروفایل

```http
PUT /api/auth/profile
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "name": "علی احمدی",
    "phone": "09123456789"
}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "پروفایل با موفقیت به‌روزرسانی شد",
    "data": {
        "id": 1,
        "name": "علی احمدی",
        "phone": "09123456789"
    }
}
```

---

### 🔹 تغییر رمز عبور

```http
PUT /api/auth/password
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "current_password": "OldPassword123",
    "new_password": "NewPassword123",
    "new_password_confirmation": "NewPassword123"
}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "رمز عبور با موفقیت تغییر کرد"
}
```

---

### 🔹 خروج (Logout)

```http
POST /api/auth/logout
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "با موفقیت خارج شدید"
}
```

---

## 📁 File Management

### 🔹 آپلود فایل

```http
POST /api/files/upload
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Request Body (Form Data):**
```
file: <file-binary>
name: "قطعه موتور" (optional)
description: "توضیحات فایل" (optional)
```

**Allowed Extensions:** `.stl`, `.obj`, `.gcode`, `.3mf`, `.step`, `.stp`
**Max Size:** 50MB

**Response (Success - 201):**
```json
{
    "success": true,
    "message": "فایل با موفقیت آپلود شد",
    "data": {
        "id": 1,
        "user_id": 1,
        "original_name": "motor_part.stl",
        "stored_name": "kaizen_abc123def456.stl",
        "file_path": "storage/uploads/2024/01/kaizen_abc123def456.stl",
        "file_size": 2048576,
        "file_type": "stl",
        "mime_type": "application/sla",
        "name": "قطعه موتور",
        "description": "توضیحات فایل",
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

**Response (Error - 422):**
```json
{
    "success": false,
    "message": "خطا در آپلود فایل",
    "errors": {
        "file": ["فرمت فایل مجاز نیست"],
        "size": ["حجم فایل بیشتر از حد مجاز است (حداکثر 50MB)"]
    }
}
```

---

### 🔹 لیست فایل‌های کاربر

```http
GET /api/files
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optional): شماره صفحه (default: 1)
- `per_page` (optional): تعداد در صفحه (default: 20)
- `type` (optional): فیلتر بر اساس نوع فایل (stl, obj, gcode)

**Example:**
```http
GET /api/files?page=1&per_page=10&type=stl
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": 1,
                "original_name": "motor_part.stl",
                "file_size": 2048576,
                "file_type": "stl",
                "name": "قطعه موتور",
                "created_at": "2024-01-15T10:30:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 10,
            "total": 25,
            "total_pages": 3,
            "has_more": true
        }
    }
}
```

---

### 🔹 جزئیات فایل

```http
GET /api/files/{id}
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "user_id": 1,
        "original_name": "motor_part.stl",
        "stored_name": "kaizen_abc123def456.stl",
        "file_path": "storage/uploads/2024/01/kaizen_abc123def456.stl",
        "file_size": 2048576,
        "file_type": "stl",
        "name": "قطعه موتور",
        "description": "توضیحات",
        "download_url": "/api/files/1/download",
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

---

### 🔹 دانلود فایل

```http
GET /api/files/{id}/download
Authorization: Bearer {token}
```

**Response:** Binary file with appropriate headers

---

### 🔹 حذف فایل

```http
DELETE /api/files/{id}
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "فایل با موفقیت حذف شد"
}
```

---

## 📦 Orders Management

### 🔹 ثبت سفارش جدید

```http
POST /api/orders
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "file_id": 1,
    "material": "PLA",
    "color": "سفید",
    "infill": 20,
    "layer_height": 0.2,
    "quality": "normal",
    "quantity": 1,
    "urgent": false,
    "notes": "توضیحات اضافی"
}
```

**Materials:** `PLA`, `ABS`, `PETG`, `TPU`, `Nylon`
**Quality:** `draft` (سریع), `normal` (معمولی), `high` (بالا)

**Response (Success - 201):**
```json
{
    "success": true,
    "message": "سفارش با موفقیت ثبت شد",
    "data": {
        "id": 1,
        "order_number": "KZ-20240115-0001",
        "user_id": 1,
        "file_id": 1,
        "status": "pending",
        "material": "PLA",
        "color": "سفید",
        "infill": 20,
        "layer_height": 0.2,
        "quality": "normal",
        "quantity": 1,
        "urgent": false,
        "estimated_price": 150000,
        "estimated_weight": 50,
        "estimated_duration": "3 hours",
        "notes": "توضیحات اضافی",
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

---

### 🔹 لیست سفارشات

```http
GET /api/orders
Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (optional): شماره صفحه
- `per_page` (optional): تعداد در صفحه
- `status` (optional): فیلتر وضعیت (pending, processing, completed, cancelled)

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": 1,
                "order_number": "KZ-20240115-0001",
                "status": "processing",
                "file_name": "motor_part.stl",
                "material": "PLA",
                "estimated_price": 150000,
                "created_at": "2024-01-15T10:30:00Z"
            }
        ],
        "pagination": {
            "current_page": 1,
            "per_page": 20,
            "total": 10,
            "total_pages": 1
        }
    }
}
```

---

### 🔹 جزئیات سفارش

```http
GET /api/orders/{id}
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "id": 1,
        "order_number": "KZ-20240115-0001",
        "status": "processing",
        "user": {
            "id": 1,
            "name": "علی احمدی",
            "phone": "09123456789"
        },
        "file": {
            "id": 1,
            "name": "motor_part.stl",
            "download_url": "/api/files/1/download"
        },
        "material": "PLA",
        "color": "سفید",
        "infill": 20,
        "layer_height": 0.2,
        "quality": "normal",
        "quantity": 1,
        "estimated_price": 150000,
        "final_price": 145000,
        "estimated_weight": 50,
        "estimated_duration": "3 hours",
        "notes": "توضیحات",
        "timeline": [
            {
                "status": "pending",
                "timestamp": "2024-01-15T10:30:00Z",
                "note": "سفارش ثبت شد"
            },
            {
                "status": "processing",
                "timestamp": "2024-01-15T11:00:00Z",
                "note": "پرینت شروع شد"
            }
        ],
        "created_at": "2024-01-15T10:30:00Z",
        "updated_at": "2024-01-15T11:00:00Z"
    }
}
```

---

### 🔹 کنسل کردن سفارش

```http
POST /api/orders/{id}/cancel
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "reason": "دلیل کنسلی"
}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "سفارش کنسل شد"
}
```

---

## 🔔 Notifications

### 🔹 لیست نوتیفیکیشن‌ها

```http
GET /api/notifications
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id": 1,
                "type": "order_status",
                "title": "سفارش شما آماده شد",
                "message": "سفارش KZ-20240115-0001 تکمیل و آماده تحویل است",
                "read": false,
                "created_at": "2024-01-15T15:00:00Z"
            }
        ],
        "unread_count": 3
    }
}
```

---

### 🔹 خواندن نوتیفیکیشن

```http
POST /api/notifications/{id}/read
Authorization: Bearer {token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "message": "نوتیفیکیشن خوانده شد"
}
```

---

## 👨‍💼 Admin Endpoints

این endpoint ها فقط برای ادمین در دسترس هستند.

### 🔹 لیست تمام کاربران (Admin)

```http
GET /api/admin/users
Authorization: Bearer {admin-token}
```

### 🔹 لیست تمام سفارشات (Admin)

```http
GET /api/admin/orders
Authorization: Bearer {admin-token}
```

### 🔹 تغییر وضعیت سفارش (Admin)

```http
PUT /api/admin/orders/{id}/status
Authorization: Bearer {admin-token}
Content-Type: application/json
```

**Request Body:**
```json
{
    "status": "processing",
    "note": "پرینت شروع شد",
    "estimated_completion": "2024-01-15T18:00:00Z"
}
```

---

## 📊 Statistics (Admin)

### 🔹 آمار کلی

```http
GET /api/admin/stats
Authorization: Bearer {admin-token}
```

**Response (Success - 200):**
```json
{
    "success": true,
    "data": {
        "total_users": 150,
        "total_orders": 500,
        "pending_orders": 25,
        "total_revenue": 50000000,
        "this_month_revenue": 8000000
    }
}
```

---

## ⚠️ Error Responses

همه endpoint ها در صورت خطا، response زیر را برمی‌گردانند:

### 400 Bad Request
```json
{
    "success": false,
    "message": "درخواست نامعتبر"
}
```

### 401 Unauthorized
```json
{
    "success": false,
    "message": "احراز هویت ناموفق. لطفا ابتدا وارد شوید"
}
```

### 403 Forbidden
```json
{
    "success": false,
    "message": "شما دسترسی به این منبع را ندارید"
}
```

### 404 Not Found
```json
{
    "success": false,
    "message": "منبع مورد نظر یافت نشد"
}
```

### 422 Validation Error
```json
{
    "success": false,
    "message": "خطا در اعتبارسنجی",
    "errors": {
        "field_name": ["پیام خطا"]
    }
}
```

### 429 Too Many Requests
```json
{
    "success": false,
    "message": "تعداد درخواست‌های شما بیش از حد مجاز است. لطفا کمی صبر کنید"
}
```

### 500 Internal Server Error
```json
{
    "success": false,
    "message": "خطای سرور. لطفا با پشتیبانی تماس بگیرید"
}
```

---

## 📝 Rate Limiting

- **عمومی**: 100 request در دقیقه
- **Auth endpoints**: 5 request در دقیقه
- **Upload**: 10 request در دقیقه

Header های response:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1642248000
```

---

## 🔧 Testing با cURL

### Login Example:
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"ali@example.com","password":"SecurePassword123"}'
```

### Upload File Example:
```bash
curl -X POST http://localhost:8000/api/files/upload \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@/path/to/file.stl" \
  -F "name=قطعه موتور"
```

---

**Version**: 1.0.0
**Last Updated**: 2024-01-15
