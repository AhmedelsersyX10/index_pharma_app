# Index Pharma API Reference

> مرجع عملي لمبرمج Flutter + ملف تجارب للـ API.  
> مبني على Backend نسخة Web/Customer التي نعمل عليها، وليس Desktop UI.

## 1) Base URL

```text
Local:
http://localhost:5000

API Base:
http://localhost:5000/api
```

في Production استبدل الدومين فقط، مثال:

```text
https://api.example.com/api
```

**مهم للصور:** قيم مثل `/uploads/products/...` أو `/uploads/prescriptions/...` تتركب على **Server Origin بدون `/api`**:

```text
http://localhost:5000/uploads/...
```

## 2) Authentication — نقطة مهمة جدًا لـ Flutter

الـ backend الحالي عند `register/login` ينشئ JWT لكنه يرسله في **HttpOnly cookie اسمها `token`**، ولا يعيد الـ token داخل JSON.

الـ middleware يقبل:
- `Authorization: Bearer <JWT>`، أو
- Cookie: `token=<JWT>`

لكن لأن login لا يعيد الـ JWT في body حاليًا، أسهل تكامل Flutter بدون تعديل backend هو استخدام cookie jar دائم، مثل:

```dart
Dio + dio_cookie_manager + cookie_jar
```

Postman يحتفظ بالكوكي تلقائيًا بعد Login.

> لو المطور يريد `flutter_secure_storage` + Bearer token بدل cookies، يلزم تعديل صغير في backend ليعيد `token` داخل استجابة login/register. هذا **غير موجود حاليًا** في الـ API الفعلي.

## 3) Flutter Store — الـ APIs المطلوبة فعليًا

### 3.1 تحميل الفروع

`GET /api/store/branches`

لا يحتاج Login.

Response:

```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "branch_id",
      "name": "Main",
      "address": "Address",
      "phone": "010..."
    }
  ]
}
```

احفظ `branchId` المختار واستخدمه في كل استدعاءات المنتجات والـ checkout.

### 3.2 التصنيفات

`GET /api/store/categories`

Public.

### 3.3 المنتجات

`GET /api/store/products?branchId={branchId}&page=1&limit=20&keyword=&category=`

`branchId` **إجباري**.

Query:
- `branchId`: الفرع المختار
- `page`: default 1
- `limit`: default 20, max 100
- `keyword`: الاسم / scientificName / barcode
- `category`: categoryId

الـ API يعرض فقط:
- المنتجات `isAvailableOnline=true`
- والمتوفرة فعليًا في مخزون الفرع.

Response يحتوي `stockQuantity`, `looseQuantity`, `sellingPrice`, `requiresPrescription`, `image`, `category`.

### 3.4 تفاصيل منتج

`GET /api/store/products/:id?branchId={branchId}`

`branchId` إجباري.

### 3.5 تسجيل عميل

`POST /api/auth/register`

```json
{
  "name": "Ahmed",
  "email": "customer@example.com",
  "password": "12345678",
  "phone": "01000000000",
  "address": "Menoufia"
}
```

- password: 8 أحرف على الأقل.
- الحساب ينشأ role=`customer`.
- الاستجابة تنشئ Cookie `token`.

### 3.6 Login

`POST /api/auth/login`

```json
{
  "email": "customer@example.com",
  "password": "12345678"
}
```

Response:

```json
{
  "success": true,
  "user": {
    "id": "...",
    "name": "Ahmed",
    "email": "customer@example.com",
    "role": "customer",
    "phone": "...",
    "address": "...",
    "permissions": null,
    "branchId": null
  }
}
```

### 3.7 بيانات العميل الحالي

`GET /api/auth/me`

Authenticated.

### 3.8 تعديل Profile

`PUT /api/auth/profile`

```json
{
  "name": "Ahmed Mohamed",
  "phone": "01000000000",
  "address": "New address"
}
```

### 3.9 إنشاء Online Order

`POST /api/store/orders`

Authenticated customer.

```json
{
  "branchId": "{branchId}",
  "orderItems": [
    {
      "productId": "{productId}",
      "quantity": 2
    }
  ],
  "deliveryAddress": "Shibin El Kom, Menoufia",
  "customerPhone": "01000000000",
  "notes": "اتصل قبل التوصيل"
}
```

ملاحظات مهمة:
- Checkout online يدعم **علب فقط** حاليًا.
- لا ترسل `isUnit=true` أو `isSecondaryUnit=true`.
- السعر لا يأتي من Flutter؛ backend يقرأ السعر الحقيقي من DB.
- المخزون يخصم atomically داخل transaction.
- `paymentMethod` للطلب الأونلاين حاليًا `cash`.
- الحالة تبدأ `pending`.

Order statuses الممكنة:
`pending`, `processing`, `completed`, `delivered`, `cancelled`.

### 3.10 طلباتي

`GET /api/store/orders/my?page=1&limit=20`

Authenticated.

### 3.11 رفع صورة روشتة

`POST /api/prescriptions/upload-image`

Authenticated.

`multipart/form-data`:
- field name = `image`
- image only
- max size = **5 MB**
- في Web تم تخصيص timeout أطول للرفع؛ يفضل Flutter timeout >= 60s.

Response:

```json
{
  "success": true,
  "data": {
    "image": "/uploads/prescriptions/rx-....jpg",
    "filename": "rx-....jpg",
    "mimeType": "image/jpeg",
    "size": 123456,
    "extension": ".jpg"
  }
}
```

### 3.12 إرسال الروشتة

بعد upload خذ `data.image`:

`POST /api/prescriptions`

```json
{
  "imageUrl": "/uploads/prescriptions/rx-....jpg",
  "notes": "ملاحظات اختيارية"
}
```

### 3.13 روشتاتي

`GET /api/prescriptions/my`

Authenticated.

**Flow المطلوب حاليًا للاستور:**

```text
pending → preparing → completed
```

وفي Flutter اعرضها:

```text
pending    = قيد الانتظار
preparing  = جاري التحضير
completed  = تم التوصيل
```

للتوافق مع بيانات قديمة:
- `reviewed`, `quoted` → اعرضهم كـ "قيد الانتظار"
- `ready` → اعرضها كـ "جاري التحضير"
- `rejected` → "مرفوضة"

**لا تستخدم `/api/prescriptions/:id/respond` في تطبيق Flutter الجديد**؛ ده endpoint Legacy من نظام عرض السعر القديم.

### 3.14 Reviews

`GET /api/products/:id/reviews`

Public.

`POST /api/products/:id/reviews`

```json
{
  "rating": 5,
  "comment": "منتج ممتاز",
  "userName": "Ahmed"
}
```

rating من 1 إلى 5.

### 3.15 Public Settings

`GET /api/settings/public`

Public keys الحالية:
- `pharmacy_name`
- `home_hero_title`
- `home_hero_subtitle`
- `home_hero_desc`
- `home_promo_title`
- `home_promo_desc`
- `home_promo_badge`
- `home_hero_bg`
- `home_promo_bg`
- `whatsapp_number`

## 4) Error handling في Flutter

الـ API عادة يرجع:

```json
{
  "success": false,
  "message": "سبب الخطأ"
}
```

أحيانًا بعض endpoints القديمة ترجع فقط:

```json
{
  "message": "سبب الخطأ"
}
```

تعامل مع:
- `400` validation
- `401` غير مسجل
- `403` غير مصرح / حساب معطل
- `404` غير موجود
- `409` stock conflict / duplicate
- `429` rate limit
- `500` server error

## 5) كل Endpoints الموجودة

إجمالي الـ endpoints الموثقة هنا: **108**


### Auth

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/api/auth/register` | Public | تسجيل عميل جديد |
| `POST` | `/api/auth/register-staff` | Admin/Superadmin | إنشاء موظف |
| `POST` | `/api/auth/login` | Public | تسجيل الدخول |
| `POST` | `/api/auth/logout` | Public | تسجيل الخروج/مسح الكوكي |
| `GET` | `/api/auth/me` | Authenticated | بيانات المستخدم الحالي |
| `PUT` | `/api/auth/profile` | Authenticated | تعديل الملف الشخصي |

### Store (Flutter أهم مجموعة)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/store/branches` | Public | الفروع النشطة المتاحة للاستور |
| `GET` | `/api/store/categories` | Public | تصنيفات الاستور |
| `GET` | `/api/store/products` | Public | منتجات الاستور حسب الفرع + بحث/تصنيف/صفحات |
| `GET` | `/api/store/products/:id` | Public | تفاصيل منتج داخل فرع |
| `POST` | `/api/store/orders` | Customer/Admin/Pharmacist | إنشاء طلب أونلاين |
| `GET` | `/api/store/orders/my` | Customer/Admin/Pharmacist | طلبات المستخدم |

### Prescriptions

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/api/prescriptions/upload-image` | Customer/Admin/Pharmacist | رفع صورة الروشتة multipart |
| `POST` | `/api/prescriptions` | Customer/Admin/Pharmacist | إنشاء روشتة بعد رفع الصورة |
| `GET` | `/api/prescriptions/my` | Customer/Admin/Pharmacist | روشتات العميل |
| `PUT` | `/api/prescriptions/:id/respond` | Legacy | قديم: رد العميل على عرض السعر؛ Flutter الجديد لا يستخدمه |
| `GET` | `/api/prescriptions` | Admin/Pharmacist | كل الروشتات |
| `PUT` | `/api/prescriptions/:id/review` | Admin/Pharmacist | تحديث حالة الروشتة |

### Product Reviews

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/products/:id/reviews` | Public | تقييمات منتج |
| `POST` | `/api/products/:id/reviews` | Public | إضافة تقييم |

### Public Settings / Leads

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/settings/public` | Public | إعدادات الاستور العامة |
| `POST` | `/api/leads` | Public | نموذج التواصل/التحميل بالموقع |

### Products (Staff)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/products/shortages-insights` | Admin/Pharmacist | تحليل النواقص |
| `GET` | `/api/products` | Authenticated | قائمة المنتجات الداخلية |
| `GET` | `/api/products/:id` | Authenticated | تفاصيل منتج داخلي |
| `POST` | `/api/products` | Admin | إضافة منتج |
| `POST` | `/api/products/upload-image` | Admin | رفع صورة منتج |
| `POST` | `/api/products/auto-fetch-images` | Admin/Superadmin | جلب صور تلقائي |
| `POST` | `/api/products/fetch-single-image` | Admin/Superadmin | جلب صورة منتج |
| `PUT` | `/api/products/:id` | Admin | تعديل منتج |
| `DELETE` | `/api/products/:id` | Admin | حذف منتج |

### Categories

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/categories` | Public | كل التصنيفات |
| `POST` | `/api/categories` | Admin/Pharmacist | إضافة تصنيف |
| `PUT` | `/api/categories/:id` | Admin/Pharmacist | تعديل تصنيف |
| `DELETE` | `/api/categories/:id` | Admin/Pharmacist | حذف تصنيف |

### Orders (Staff / POS)

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/orders` | Admin/Pharmacist | قائمة الأوردرات |
| `POST` | `/api/orders` | Admin/Pharmacist | إنشاء أوردر POS |
| `GET` | `/api/orders/today-sales` | Admin/Pharmacist | مبيعات اليوم |
| `GET` | `/api/orders/online` | Admin/Pharmacist | طلبات الأونلاين |
| `GET` | `/api/orders/:id` | Admin/Pharmacist | تفاصيل أوردر |
| `PUT` | `/api/orders/:id/status` | Admin/Pharmacist | تغيير حالة الأوردر |
| `PUT` | `/api/orders/:id/settle` | Admin/Pharmacist | تسوية فاتورة معلقة |

### Customers / Loyalty

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/customers/lookup` | Admin/Pharmacist | البحث عن عميل |
| `GET` | `/api/customers` | Admin/Pharmacist | قائمة العملاء |
| `POST` | `/api/customers` | Admin/Pharmacist | إنشاء عميل |
| `GET` | `/api/customers/:id/purchases` | Admin/Pharmacist* | سجل مشتريات العميل؛ حسب باتش الصلاحية الأخير |
| `PUT` | `/api/customers/:id` | Admin/Pharmacist | تعديل عميل |
| `POST` | `/api/customers/:id/redeem` | Admin/Pharmacist | استبدال نقاط |

### Branches / Transfers

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/branches` | Admin/Pharmacist/Superadmin | كل الفروع |
| `POST` | `/api/branches` | Superadmin | إضافة فرع |
| `PUT` | `/api/branches/:id` | Superadmin | تعديل فرع |
| `GET` | `/api/transfers` | Admin/Pharmacist | تحويلات المخزون |
| `POST` | `/api/transfers` | Admin/Pharmacist | إنشاء تحويل |
| `PUT` | `/api/transfers/:id/accept` | Admin/Pharmacist | قبول تحويل |
| `PUT` | `/api/transfers/:id/reject` | Admin/Pharmacist | رفض تحويل |
| `PUT` | `/api/transfers/:id/cancel` | Admin/Pharmacist | إلغاء تحويل |

### Purchases / Suppliers

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/purchases/suppliers` | Admin/Pharmacist | الموردون |
| `POST` | `/api/purchases/suppliers` | Admin/Pharmacist | إضافة مورد |
| `POST` | `/api/purchases` | Admin/Pharmacist | إنشاء فاتورة شراء |

### Returns

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/returns` | Admin/Pharmacist | سجل المرتجعات |
| `POST` | `/api/returns/sales` | Admin/Pharmacist | مرتجع مبيعات |
| `POST` | `/api/returns/purchase` | Admin/Pharmacist | مرتجع مشتريات |
| `GET` | `/api/returns/search-order` | Admin/Pharmacist | البحث عن أوردر |
| `GET` | `/api/returns/search-purchase` | Admin/Pharmacist | البحث عن فاتورة شراء |

### Shifts / Cash / Expenses

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/api/shifts/open` | Admin/Pharmacist | فتح وردية |
| `PUT` | `/api/shifts/close` | Admin/Pharmacist | إغلاق وردية |
| `GET` | `/api/shifts/current` | Admin/Pharmacist | الوردية الحالية |
| `GET` | `/api/shifts` | Admin/Pharmacist | سجل الورديات |
| `GET` | `/api/cash-movements` | Admin/Pharmacist | حركات النقدية |
| `POST` | `/api/cash-movements` | Admin/Pharmacist | إضافة حركة نقدية |
| `GET` | `/api/expenses` | Admin/Pharmacist | المصروفات |
| `POST` | `/api/expenses` | Admin/Pharmacist | إضافة مصروف |
| `DELETE` | `/api/expenses/:id` | Admin/Pharmacist | حذف مصروف |

### Reports

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/reports/daily` | Admin/Pharmacist | تقرير يومي |
| `GET` | `/api/reports/monthly` | Admin/Pharmacist | تقرير شهري |
| `GET` | `/api/reports/top-products` | Admin/Pharmacist | الأكثر مبيعًا |
| `GET` | `/api/reports/expiry-alerts` | Admin/Pharmacist | تنبيهات الصلاحية |
| `GET` | `/api/reports/low-stock` | Admin/Pharmacist | مخزون منخفض |
| `GET` | `/api/reports/shortages` | Admin/Pharmacist | تحليل النواقص |
| `GET` | `/api/reports/financial-analysis` | Admin/Pharmacist | تحليل مالي |
| `GET` | `/api/reports/targets` | Admin/Pharmacist | التارجت |

### Attendance / Payroll

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `POST` | `/api/attendance/check-in` | Admin/Pharmacist | حضور |
| `POST` | `/api/attendance/check-out` | Admin/Pharmacist | انصراف |
| `GET` | `/api/attendance/today` | Admin/Pharmacist | حالة اليوم |
| `GET` | `/api/attendance/my` | Admin/Pharmacist | حضوري |
| `GET` | `/api/attendance` | Admin | كل الحضور |
| `POST` | `/api/attendance/manual` | Admin | إضافة حضور يدوي |
| `GET` | `/api/payroll/calculate` | Admin | حساب الرواتب |
| `GET` | `/api/payroll/employees` | Admin | الموظفون |
| `PUT` | `/api/payroll/employees/:id/rate` | Admin | تعديل معدل الموظف |

### Notifications

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/notifications` | Authenticated | الإشعارات |
| `POST` | `/api/notifications` | Authenticated | إنشاء إشعار |
| `POST` | `/api/notifications/mark-all-read` | Authenticated | تعليم الكل كمقروء |
| `PUT` | `/api/notifications/:id` | Authenticated | تعليم إشعار كمقروء |
| `DELETE` | `/api/notifications/:id` | Authenticated | حذف إشعار |

### Settings

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/settings` | Authenticated | كل الإعدادات |
| `PUT` | `/api/settings` | Admin | تعديل الإعدادات |
| `POST` | `/api/settings/upload-image` | Admin | رفع صورة إعداد |

### Subscriptions

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/subscriptions/customers` | Admin/Pharmacist | عملاء الاشتراكات |
| `GET` | `/api/subscriptions` | Admin/Pharmacist | الاشتراكات |
| `POST` | `/api/subscriptions` | Admin/Pharmacist | إضافة اشتراك |
| `PUT` | `/api/subscriptions/:id` | Admin/Pharmacist | تعديل اشتراك |
| `DELETE` | `/api/subscriptions/:id` | Admin/Pharmacist | حذف اشتراك |

### Users

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/users` | Admin | المستخدمون |
| `DELETE` | `/api/users/:id` | Admin | حذف مستخدم |
| `PUT` | `/api/users/:id/permissions` | Superadmin | تعديل الصلاحيات |

### Backup

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/backup/export` | Admin | تصدير قاعدة البيانات |
| `POST` | `/api/backup/import` | Admin | استيراد SQL multipart |

## 6) Realtime / Socket.IO

الويب يستخدم Socket.IO. أهم الأحداث الموجودة:
- `new-online-order` للموظفين عند إنشاء طلب Online.
- `new_prescription` عند إنشاء روشتة.
- `update_prescription` عند تحديثها.
- `data:changed` generic invalidation.

Flutter **مش لازم** يبدأ بالـ Socket.IO؛ ممكن أول نسخة تعتمد polling / refresh. لو عايز realtime استخدم `socket_io_client` مع نفس server origin بدون `/api`.

## 7) Header خاص بالفروع للـ Staff

بعض APIs الداخلية تستخدم:

```text
X-Branch-Id: <branchId>
```

لكن **عميل الاستور** لا يعتمد عليه في checkout؛ يرسل `branchId` في body/query كما هو موضح فوق.

## 8) ملاحظات للمبرمج

1. لا تثق في price قادم من Flutter؛ backend بالفعل يعيد حساب السعر.
2. خزّن `branchId` المختار محليًا.
3. أعد تحميل cart availability قبل checkout.
4. لو API رجع `409` بسبب تغير المخزون، اعرض رسالة وأعد تحميل المنتجات.
5. الصور ذات المسار النسبي تبنى على server origin بدون `/api`.
6. للـ auth الحالي استخدم CookieJar مستمر.
7. لا تستخدم Prescription Quote flow في تطبيق Flutter الجديد.
