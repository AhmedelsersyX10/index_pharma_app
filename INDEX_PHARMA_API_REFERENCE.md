# Index Pharma API Reference

> مرجع العميل والموظفين؛ تحديث 2026-10-24. عقود المرحلة 4 مدققة من backend main عند commit `cac43644406e075add3b99c867aa5f0458ccea9e`.
> جذر Git: `/Users/ahmedelsersy/Desktop/indexCustomer-git`؛ الباك إند تحت `luluBack/`. أدلة §9 تستخدم مسارات نسبية لهذا الجذر.
> هذا هو مرجع API الوحيد للمشروع؛ دليل التكامل في §10 والعينات التاريخية في §11. اقرأ [AGENTS.md](AGENTS.md) لقواعد العمل وسياسة المنتج. العقد الحالي المؤرخ يسبق العينة القديمة؛ التعارض مع تشغيل نفس النسخة يحتاج تحققاً. لم تُنفذ طلبات حية أو عمليات كتابة في التدقيق.
> أمثلة JSON هنا توضيحية ما لم ينص على أنها عينة ملتقطة. بقية فهرس §5 تاريخية وليست إعادة تدقيق شاملة لكل أنظمة الباك إند.

## دليل القراءة

- [عقود متجر العميل](#store-contracts): التسجيل والمنتجات والطلبات والرفع ومتابعة الروشتة.
- [فهرس المسارات](#endpoint-index): فهرس تاريخي مع تمييز غير المركب؛ لا يفترض أنه مدقق بالكامل.
- [النطاق وسياسة الوصول](#scope-policy): قواعد الفرع والتمييز بين UI policy وحماية السيرفر.
- [عقود المرحلة 4 وأدلتها](#phase4-contracts): bodies/queries/responses/roles/errors حسب الكود المدقق.
- [دليل التكامل السريع وDTOs](#integration-guide): استخدام البنية الموجودة وتدفقات العميل والموظف وpagination.
- [العينات التاريخية](#historical-samples): أمثلة محفوظة مختصرة، مفهرسة بالمصدر القديم ورقم السطر الأصلي؛ ليست عقداً أحدث أو دليلاً على صحة التشغيل الجاري.

أسماء المسارات نسبية لـ /api ما لم يذكر غير ذلك. السياسة المعتمدة في AGENTS.md §8 هي مرجع قرار العرض؛ تفاصيل استجابات السيرفر هنا لا تمنح إذناً بعرض حقول حساسة أو تنفيذ إجراءات مؤجلة.

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

Cookie maxAge سنة،HttpOnly؛في production خارج DESKTOP_MODE تكون secure=true وSameSite=None،ومحلياً/desktop تكون SameSite=Lax وفق الإعداد. JWT المولد يحتوي id مع iat/exp ومدته365d؛الدور يؤخذ من المستخدم الحالي في DB لا من claim role.
الأدلة: `luluBack/src/controllers/authController.js:9-26` و`luluBack/src/utils/generateToken.js:1-9` و`luluBack/src/middlewares/authMiddleware.js:22-35`.

> قرار Flutter الحالي: CookieJar دائم فقط؛ لا تضف flutter_secure_storage أو تخزين Bearer token، ولا تعدل backend ضمن مهمة تكامل Flutter. لا تسجل الكوكي أو التوكن.

<a id="store-contracts"></a>

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

Authenticated. الاستجابة `{success,data:User}` وليست user؛ الحقول الإضافية: isActive,monthlyTarget,createdAt. monthlyTarget نوع Float، فاقرأ num.toDouble(). login/register يعيدان user ولا يعيدان JWT في JSON.

### 3.8 تعديل Profile

`PUT /api/auth/profile`

```json
{
  "name": "Ahmed Mohamed",
  "phone": "01000000000",
  "address": "New address"
}
```

التحديث جزئي: name لا يكون فارغاً؛ phone/address بقيمة null أو "" يمسحان القيمة. السيرفر لا يحقق صيغة التليفون. monthlyTarget لتحديث الملف مسموح للـadmin فقط؛ لا تعمم تجاوز superadmin عليه لأنه شرط داخل controller.

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
- استجابة الإنشاء تتضمن items وcostAtSale؛ احجبه عن العميل.
- أخطاء المتجر:400 للمدخلات/سلة فارغة،404 لمنتج غير متاح،409 للمخزون/التزامن. لا تنسخ هذه الأكواد إلى POS الداخلي.
- لا deliveryFee؛ totalAmount=subtotal في هذا المسار فقط.

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

**تجميع حالات العرض للعميل، وليس تسلسل انتقالات السيرفر:**

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

### 3.14 Reviews — مؤجلة وغير مركبة في النسخة المدققة

لا توجد routes لـ GET/POST `/api/products/:id/reviews` في `luluBack/src/routes/productRoutes.js`؛ العينات المحفوظة تظهر404. لا تنفذ التقييمات أو تضف بدائل وهمية. وجود موديل Prisma وحده لا يعني وجود endpoint.

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
- `409` تعارض حسب المسار؛ ليس كود نقص المخزون الموحد لـPOS
- `429` rate limit
- `500` server error؛ بعض controllers تلف أخطاء الفرع/التحقق بهذا الكود

الرسائل قد تكون عربية أو إنجليزية، وبعض envelopes تستخدم status:error. اعرض Failure مترجماً، ولا تستخرج أرقاماً من النص. POS غالباً400 لنقص المخزون/منتج مفقود/لا وردية؛ لا يمكن معرفة السبب الدقيق من الكود وحده. لا تكرر أي كتابة تلقائياً بعد timeout أو429.

<a id="endpoint-index"></a>

## 5) فهرس المسارات التاريخي ونطاق التحقق

العدد القديم «108» ليس عدداً معتمداً للمسارات الحالية. مسارات المرحلة 4 تدقيقها في §9؛ بقية الجداول تحفظ الفهرس التاريخي ولا تثبت تشغيلها الحالي. غياب superadmin من خلية authorize لا يعني رفضه: middleware يتجاوزه ما لم يوجد فحص إضافي داخل controller، كما في مراجعة الروشتات.

مسارات كانت موثقة هنا لكنها غير مركبة في checkout المدقق: product reviews و`/api/leads` و`/api/cash-movements` و`/api/customers/:id/purchases`. لا تستخدمها دون دليل من نسخة أحدث.


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
| `GET` | `/api/prescriptions` | Admin/Pharmacist/Superadmin | كل الروشتات؛ عامة بلا نطاق فرع |
| `PUT` | `/api/prescriptions/:id/review` | Admin/Pharmacist فقط | controller يرفض Superadmin403 |

### Product Reviews

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/products/:id/reviews` | غير مركب | مؤجل، ليس endpoint حالياً |
| `POST` | `/api/products/:id/reviews` | غير مركب | مؤجل، ليس endpoint حالياً |

### Public Settings / Leads

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/settings/public` | Public | إعدادات الاستور العامة |
| `POST` | `/api/leads` | غير مركب | مذكور تاريخياً فقط |

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
| `GET` | `/api/customers/lookup` | Admin/Pharmacist | البحث عن عميل بالهاتف (`?phone=xxx`) |
| `GET` | `/api/customers` | Admin/Pharmacist | قائمة العملاء |
| `POST` | `/api/customers` | Admin/Pharmacist | إنشاء عميل |
| `GET` | `/api/customers/:id/purchases` | غير مركب | مذكور تاريخياً؛ ليس في customerRoutes الحالي |
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
| `GET` | `/api/cash-movements` | غير مركب | مذكور تاريخياً فقط |
| `POST` | `/api/cash-movements` | غير مركب | مذكور تاريخياً فقط |
| `GET` | `/api/expenses` | Admin/Pharmacist | المصروفات |
| `POST` | `/api/expenses` | Admin/Pharmacist | إضافة مصروف |
| `DELETE` | `/api/expenses/:id` | Admin/Pharmacist | حذف مصروف |

### Reports

| Method | Path | Auth | Purpose |
|---|---|---|---|
| `GET` | `/api/reports/daily` | Admin/Pharmacist | تقرير يومي |
| `GET` | `/api/reports/monthly` | Admin/Pharmacist | تقرير شهري (`?year=&month=`) |
| `GET` | `/api/reports/top-products` | Admin/Pharmacist | الأكثر مبيعًا (`?days=&limit=`) |
| `GET` | `/api/reports/expiry-alerts` | Admin/Pharmacist | تنبيهات الصلاحية (`?days=`) |
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

Flutter V1 يستخدم manual/pull-to-refresh افتراضياً. polling دوري أو Socket يحتاج موافقة منفصلة؛ لا تضف socket_io_client تلقائياً. وجود أحداث في السيرفر لا يسمح بإضافة جرس إشعارات أو وعود إشعار مؤجلة.

<a id="scope-policy"></a>

## 7) قواعد النطاق وقرار صلاحيات الواجهة — 2026-10-24

| السياق | السلوك المؤكد |
|---|---|
| المتجر | branchId في query/body؛ العميل لا يرسل header |
| pharmacist/admin | user.branchId؛ X-Branch-Id متجاهل |
| superadmin | X-Branch-Id يحدد النطاق ولا يغير فرع المستخدم الحقيقي |
| غياب فرع الموظف | helper يرمي403؛ controllers قد تعيده400/500؛ ليست قاعدة رفض موحدة |
| غياب header للسوبر | القراءة حسب endpoint، وليس تجميعاً موحداً |
| قائمة المنتجات دون فرع | كتالوج عام وstockQuantity/looseQuantity صفر |
| inStockOnly/lowStock وفتح وردية/POS | يلزم فرع محدد |
| قائمة الروشتات ومراجعتها | عامة بلا branchId؛ الهيدر لا يقيدها |
| التصنيفات والعملاء وقائمة الفروع | عامة على مستوى النظام |

middleware لا يحقق وجود/نشاط ID الفرع المحدد. كتالوج المنتجات وأسعاره عامة؛ المخزون فقط فرعي. تفاصيل المنتج الداخلي ترجع جميع branchStocks؛ لا تستخدم top-level legacy stock لـPOS. ألغ/تجاهل الاستجابات القديمة وأعد التحقق من الوردية والسلة عند تبديل النطاق/المستخدم، وافصل تخزين فرع الموظف وسلة POS عن المتجر.

**سياسة عرض Flutter المعتمدة من صاحب المشروع، وليست حماية مفروضة على السيرفر:**

- purchasingPrice/averageCost/costAtSale: admin/superadmin فقط، وتُحجب عن الصيدلي والعميل والسجلات.
- التقارير والربح وCOGS: pharmacist/admin مع viewReports=true، أو superadmin. لا تجاوز تلقائي للأدمن.
- استخدم PermissionService والمفاتيح editPrice/manageTransfers/viewPrescriptions/viewReports/viewReturns؛ لا تخترع مفتاح تكلفة أو إدارة. null/false تمنع غير superadmin؛ المفتاح المجهول مرفوض حتى للسوبر.
- UI visibility للروشتات حسب viewPrescriptions؛ المراجعة admin/pharmacist فقط بسبب قيد controller.
- User.permissions هو Json?؛ تحديثه يفحص object فقط، ولا يفرض whitelist/boolean schema. endpoints المرحلة 4 لا تفحص هذه flags. تفاصيل المنتج متاحة لكل مسجل وبها تكلفة ومورد وكل الفروع؛ هذه فجوة وليست إذناً بعرضها للعميل.

الأدلة: `luluBack/src/middlewares/authMiddleware.js:4-80`، `luluBack/src/utils/branch.js:3-10`، `luluBack/src/controllers/userController.js:15-24`، `luluBack/prisma/schema.prisma:121-135`، `lib/features/auth/domain/services/permission_service.dart:3-77`.

## 8) قواعد التكامل والتحقق

1. استخدم ApiClient/PersistCookieJar وAppConfig.mediaUrl الحاليين؛ لا إعداد Dio مكرر ولا JWT في JSON.
2. المبالغ النهائية للسيرفر. لا ترسل أسعار بنود POS/المتجر؛ نماذج إدارة المنتج وتسعير الروشتة لها حقول أسعار مشروعة.
3. لا تعتمد على HTTP code وحده لتسمية سبب POS400؛ لا parse لأرقام الرسالة ولا إعادة كتابة تلقائية بعد timeout.
4. backend support لا يلغي استبعادات V1: نقداً فقط، بلا إدخال خصومات/بطاقات أو طباعة أو إشعارات/شات/تأمين/ETA/رسوم أو تقييمات/مفضلة. قراءة السجلات التاريخية لا تنشئ إجراءً جديداً.
5. fixtures المشتقة من الكود توسم بوضوح؛ عينات api_samples غير متتبعة ولا يثبت ارتباطها بهذا commit. استجابات200 القديمة لا تثبت سلامة السيرفر الحالي ولا سبب500 قديم.
6. الكتابة الحية لجمع عينات ليست جزءاً من مهمة Flutter؛ تحتاج موافقة منفصلة وبيانات معزولة. لا DB migration/seed/reset أو تثبيت dependencies تلقائياً.
7. اختبارات Flutter بفakes/mocks، وتشغيل analyze وtest الكامل بعد تنفيذ الكود، مع فصل اختبار الجهاز عن الآلي وتوثيق الاختلافات عن Stitch.

<a id="phase4-contracts"></a>

## 9) عقود المرحلة 4 المدققة من الكود

كل المسارات أدناه نسبية إلى `/api`. الأمثلة عقود مشتقة من المصدر، لا captures تشغيل حديثة. أعِد التدقيق إذا تغير commit.

### 9.1 مصفوفة الوصول

| المجال | Customer | Pharmacist | Admin | Superadmin |
|---|---|---|---|---|
| shifts/orders/reports/customer lookup |403|يسمح|يسمح|يسمح|
| GET products | protect فقط؛ غالباً403 لغياب الفرع |يسمح|يسمح|يسمح|
| GET products/:id |يسمح للمسجل بلا نطاق فرع|يسمح|يسمح|يسمح|
| products CRUD/upload |403|403|يسمح|يسمح|
| GET categories |عام|عام|عام|عام|
| categories CRUD |403|يسمح|يسمح|يسمح|
| GET branches |403|يسمح|يسمح|يسمح|
| branches create/update |403|403|403|يسمح|
| GET prescriptions |403|يسمح|يسمح|يسمح|
| prescription review |403|يسمح|يسمح|403 داخل controller|

«يسمح» تعني أهلية الدور؛ شروط الفرع/المدخلات منفصلة. الجلسة المفقودة/المنتهية401، الحساب المعطل403. أدلة routes: `luluBack/src/routes/{shift,order,report,customer,product,category,branch,prescription}Routes.js`؛ استثناء الروشتة `prescriptionController.js:547-569`.

### 9.2 الفروع — 4.02 / 4.13

- GET /branches:200 {success,data:Branch[]}، جميع الفروع بما فيها inactive، الأحدث createdAt أولاً، لا فلترة حسب النطاق.
- Branch: id,name,address?,phone?,isActive,createdAt,updatedAt؛ لا كود فرع أو ساعات. /store/branches إسقاط مختلف بأربعة حقول.
- POST /branches: {name,address?,phone?}؛ name مطلوب truthy؛ create يتجاهل isActive، والـschema يجعلها true.201 {success,data}؛ خطأ400.
- PUT /branches/:id: {name?,address?,phone?,isActive?}؛200 {success,data}؛ missing404،caught400. لا validation صيغة phone أو trim name في controller ولا unique name في schema؛ التحقق المحلي لا يُنسب للسيرفر.
- لا DELETE؛ الإدارة لا تحتاج فرعاً نشطاً أو وردية. بعد تعطيل الفرع الحالي أبطل اختياره محلياً، دون ادعاء أن middleware يمنع كل وصول له.

الأدلة: `luluBack/src/routes/branchRoutes.js:12-16`، `luluBack/src/controllers/branchController.js:4-62`، `luluBack/prisma/schema.prisma:655-675`؛ عينة محفوظة `luluBack/api_samples/staff_branches.json`.

### 9.3 الورديات — 4.03

| Method/path | الطلب | النتيجة |
|---|---|---|
| POST /shifts/open | startingCash required |201 {success,data:Shift}|
| GET /shifts/current | دون body |200 {success,data:null أو ShiftWithTotals}|
| PUT /shifts/close | endingCash,endingVisa required;notes? |200 {success,data:ShiftWithTotalsAndDifferences}|
| GET /shifts | page=1,limit=20 |200 {success,count,total,page,limit,hasMore,data}|

- المبالغ finite>=0 وتُقرب2؛ notes string/null مع trim. endingVisa مطلوب لتسوية المقبوضات الرقمية الموجودة؛ لا يعني إتاحة بطاقة للدفع في V1.
- current/open/close تخص req.user.id والفرع إن تحدد؛ history للفرع كله، createdAt desc. pagination page>=1،limit>=1 ويُقص إلى100.
- superadmin دون فرع لا يفتح وردية400؛ current/close دون header قد يبحثان ورديته عبر الفروع؛ POS لا يصبح مسموحاً دون اختيار فرع.
- فتح مكرر400،unique/concurrency409؛ إغلاق بلا وردية404؛ race409؛ أخطاء parseMoney بلا statusCode تقع500. missing staff branch: open/close403,current500,history400.
- Shift: id,pharmacistId,branchId?,startTime,endTime?,startingCash,endingCash?,expectedCash,endingVisa?,expectedVisa?,totalSales,totalOrders,totalReturns,status(open|closed),notes?,createdAt,updatedAt.
- current/history تضيف pharmacist{name},grossSales,netSales,cashSales,cashReturns,netCashSales,visaSales,digitalSales. close تضيف cashDifference,visaDifference. الأرقام num وليست int حصراً.
- server totals من completed/delivered والمرتجعات المكتملة؛ لا تحسب التسوية محلياً.

الأدلة: `luluBack/src/routes/shiftRoutes.js:6-11`، `luluBack/src/controllers/shiftController.js:27-97,146-198,207-299,306-347,410-467,716-901`؛ عينة current محفوظة، وفتح/إغلاق حي لم يُنفذ في التدقيق.

### 9.4 البحث والباركود الداخلي — 4.04 / 4.06

- GET /products query: keyword(trim,case-insensitive contains في name OR barcode)،scientificName(contains مستقل)،minPrice/maxPrice(finite>=0,min<=max)،inStockOnly=true،lowStock=true،onlineOnly=true،page(default1)،limit(default50,1..100).
- لا category/categoryId أو sort query. lowStock يستخدم stockQuantity<=10؛ inStockOnly يعتمد boxes>0 أو loose>0. كلا فلترَي المخزون يحتاج branch للسوبر.
-200 {success,count,totalCount,page,limit,hasMore,data}،createdAt desc؛ عدم المطابقة200 data:[] وليس404.
- Selected list يعكس مخزون branchStocks المحددة في top-level؛ all-branches يعيد stock/loose0. الداخلي قد يشمل offline/expired/zero-stock؛ لا تضف منع انتهاء الصلاحية دون قرار.
- GET /products/:id:200 {success,data:ProductWithRelations}،missing404؛ لا resolveBranchId، ويعيد category/supplier وجميع branchStocks مع branch. لا top-level stock للبيع.
- Product catalog: id,name,scientificName?,barcode,description?,image?,categoryId?,supplierId?,purchasingPrice,sellingPrice,expiryDate,requiresPrescription,isAvailableOnline,unit,isSplittable,unitsPerBox?,unitName?,unitPrice?,hasSecondaryUnit,secondaryUnitsPerUnit?,secondaryUnitName?,secondaryUnitPrice?,stockQuantity,looseQuantity,minStockAlert,timestamps.
- BranchStock: id,productId,branchId,stockQuantity,looseQuantity,averageCost,inTransitQuantity,minStockAlert,timestamps.
- barcode unique في DB لكن keyword جزئي ومتعدد النتائج/الأسماء؛ تحقق من المطابقة المقصودة والصفحات ولا تضف أول نتيجة. لا strip للأصفار الأولى؛ mobile_scanner مثبتة، والكاميرا تحتاج جهازاً فعلياً.

الأدلة: `luluBack/src/routes/productRoutes.js:47-60`، `luluBack/src/controllers/productController.js:562-800`، `luluBack/prisma/schema.prisma:194-248,678-698`؛ عينات staff_products/super_products_aggregate محفوظة.

### 9.5 POS وlookup — 4.05

- POST /orders: orderItems required nonempty [{productId,quantity positive integer,isUnit?,isSecondaryUnit?}]،orderType default POS(أو ONLINE)،paymentMethod default cash،paidAmount default0،customerPhone?/customerId?. نفس المنتج/الوحدة يدمج، والـflags تُرسل booleans فعلية.
- V1 يرسل cash وPOS وpaidAmount الفعلي وcustomerPhone عند الحاجة؛ لا أسعار بنود/total/cost ولا discount entry. server يدعم cash,visa,pending,split,card,instapay,vodafone_cash وdiscountType fixed/percentage، لكنها لا تفتح نطاق V1 المؤجل.
- يلزم فرع ووردية للمستخدم نفسه فيه؛ stock من ProductBranchStock والوحدات من تهيئة المنتج، والأسعار والمخزون والتكلفة داخل transaction Serializable مع CAS.
- paidAmount>=0؛ المقبوض/due/change من السيرفر. POS يصبح completed عادة،لكن due>0.01 أو orderType ONLINE يجعله pending. إغفال paidAmount لا يثبت دفع الفاتورة.
-201 {success,message,data:Order,order:Order}؛ parse data مرة واحدة. داخلياً missing product/stock/insufficient stock/no shift/branch/DB errors تقع400.401/403 من middleware؛ لا تعتمد على store404/409 لتفسير POS.
- GET /customers/lookup?phone=: exact trimmed phone>=3؛200 {success,data:{id,name,phone,loyaltyPoints,totalSpent,notes?,createdAt,updatedAt}}،400 قصير،404 مفقود،500 غير متوقع،لا branch scope.
- lookup.id من Customer؛ Order.customerId يشير User. لا ترسله كـcustomerId؛ اربط V1 عبر customerPhone. loyalty يحسبها السيرفر.
- Order: id,orderNumber?,pharmacistId?,customerId?,shiftId?,branchId?,subtotal,discountType,discountValue,totalAmount,paidAmount,dueAmount,changeAmount,orderType,status,paymentMethod,splitCash,splitCard,splitInstapay,splitVodafoneCash,customerPhone?,deliveryAddress?,notes?,timestamps.
- OrderItem: id,orderId,productId,productName?,quantity,priceAtPurchase,costAtSale,isUnit,isSecondaryUnit. احجب التكلفة طبقاً للدور. نجاح الإنشاء يضيف items وbranch.

الأدلة: `luluBack/src/controllers/orderController.js:31-49,97-163,288-453,460-608,641-780,810-1056`، `luluBack/src/controllers/customerController.js:56-87`، `luluBack/prisma/schema.prisma:348-424,638-652`.

### 9.6 السجل والأونلاين — 4.07 / 4.08

- GET /orders: orderType,status,startDate,endDate؛ لا pagination،createdAt desc،assigned/selected branch أوall للسوبر. invalid date400؛ enums تمر إلى Prisma وقد تسبب500،missing staff branch500.
-200 {success,data:Order[],count,orders:Order[]}؛ nested items.product{id,name,barcode}،pharmacist{id,name,email,branchId}،customer{id,name,phone}،shift،branch؛ العلاقات nullable حيث schema يسمح.
- GET /orders/:id: {success,data,order} ويضيف returns مع items؛missing/wrong branch404،unexpected500. لا تعيد تسعير السجل بأسعار المنتج الحالية.
- GET /orders/online: لا query filters/pagination؛ONLINE pending/processing فقط،createdAt asc؛200 {success,data,count,orders,activeShift:null|ShiftWithBranch,branchId:null|string}. items.product تضيف sellingPrice. null activeShift لا يفشل القائمة.
- PUT /orders/:id/status {status}: pending->processing|completed|cancelled؛processing->completed|cancelled؛completed->delivered؛delivered/cancelled نهائيان؛نفس الحالة مرفوضة. lowercases دون trim.
- لا فحص وردية ولا إسناد shift/pharmacist أو تسوية paid/due. لا ONLINE-only guard داخلي،لكن واجهة المهمة تعمل على الأونلاين.
- CAS للحالة واستعادة المخزون عند الإلغاء؛missing/wrong branch/transition/race/transaction كلها400؛200 {success,message,data,order}. بعد completed يغادر queue ويظل في السجل.
- عينات orders/online المحفوظة200 ليست إثبات صحة السيرفر الحالي. invalid enum/DB schema/generated client drift احتمالات500؛ سبب العطل السابق غير مثبت.

الأدلة: `luluBack/src/controllers/orderController.js:43-49,1064-1270,1405-1586,2131-2223`.

### 9.7 مراجعة الروشتات — 4.09

- GET /prescriptions?status=: pending/reviewed/quoted/preparing/ready/completed/rejected،اختياري exact؛invalid400؛200 {success,count,data}،createdAt desc بلا pagination/branch. customer{name,email,phone}،pharmacist{name}?،items[]. schema لا يحتوي branchId.
- PUT /:id/review: status?,pharmacistNotes?,quotedPrice?,items?,rejectionReason?؛admin/pharmacist فعال فقط،superadmin403 داخل controller رغم route bypass.
- pending->reviewed|rejected؛reviewed->quoted|rejected؛quoted->preparing|rejected؛preparing->ready|rejected؛ready->completed|rejected. completed/rejected نهائيان لتغيير status فقط؛حقول أخرى يمكن تعديلها دون status. نفس الحالة مرفوضة.
- pharmacistNotes string/null،trim/truncate2000؛rejectionReason string/null،trim/truncate1000 ومطلوب غير فارغ للرفض. quotedPrice finite>=0 rounded2؛مطلوب عند quoted إن كانت القيمة السابقة null.
- items optional array<=100؛كل عنصر {productName:string nonempty trimmed/truncated300,quantity:positive integer,price:finite nonnegative}. supplied array تستبدل كل البنود؛[] يمسح،omission يحافظ. لا productId/unit في هذا العقد ولا شرط مجموع الأسعار=quotedPrice.
-200 {success,data:PrescriptionWithRelations}؛404 missing،400 validation/transition،403 reviewer،500 unexpected. قراءة ثم update دون CAS للحالة؛لا ضمان منع تعارض المراجعات.
- Prescription: id,prescriptionNumber?,customerId,imageUrl,notes?,status,pharmacistId?,pharmacistNotes?,quotedPrice?,customerResponse?,rejectionReason?,timestamps؛items{id,prescriptionId,productName?,quantity,price}.
- relative image يمر AppConfig.mediaUrl دون /api؛حالات الموظف سبعة منفصلة؛لا legacy PUT /:id/respond.

الأدلة: `luluBack/src/routes/prescriptionRoutes.js:42-48`، `luluBack/src/controllers/prescriptionController.js:21-75,105-128,364-844`، `luluBack/prisma/schema.prisma:542-584`.

### 9.8 إدارة المنتجات — 4.10

- POST/PUT/DELETE /products وPOST /products/upload-image:admin/superadmin فقط؛pharmacist403 ولو editPrice=true.
- create required:name,barcode,purchasingPrice,sellingPrice,expiryDate؛nonempty strings،prices finite>=0،valid date؛isSplittable=true يحتاج unitsPerBox integer>1.
- optional accepted:scientificName,description,image,categoryId,supplierId,stockQuantity,looseQuantity,minStockAlert,requiresPrescription,isAvailableOnline,unit,isSplittable,unitsPerBox,unitName,unitPrice,hasSecondaryUnit,secondaryUnitsPerUnit,secondaryUnitName,secondaryUnitPrice. averageCost ليس payload field.
- strings trim؛empty strings غالباً تحذف،categoryId/supplierId empty/null=>null؛booleans تقبل true/false أوstrings؛integer stocks/alerts>=0؛secondary count>1 عند تهيئته؛VALID_UNITS constant غير مفروضة فعلياً،فلا توثقها enum إجباري.
- create defaults stock0,loose0,min10؛branch stock منفصل عن legacy Product stock. كمية افتتاحية موجبة تحتاج branch؛الفرع المختار يجب أن يوجد ويكونactive. يمكن للسوبر إنشاء كتالوج بصفر دون اختيار فرع.
- update partial؛empty400،missing404؛branch stock update يحتاج فرعاً active،لكن catalog-only update لا يستدعي resolver. أسعار/حقول الكتالوج عامة لكل الفروع. تغيير purchasingPrice لا يعيد كتابة averageCost الحالي تلقائياً.
- create201/update200 {success,data:ProductWithRelations}؛duplicate barcode/FK400،unexpected500. supplierId اختياري؛لا تخترع قائمة موردين ضمن المهمة.
- DELETE hard global delete؛branch stock cascades حسب schema،ارتباطات تاريخية قد تمنع409؛missing404،success200 {success,message}. لا soft delete/isActive للمنتج.
- upload multipart image MIME image/* max5MiB؛timeout>=60s؛201 {success,data:{image:absoluteURL,filename,mimeType,size,extension}}. missing file400؛Multer type/size errors تقع global500 حالياً،لا تضمن413. لا auto-fetch images ضمن V1.

الأدلة: `luluBack/src/routes/productRoutes.js:20-60`، `luluBack/src/controllers/productController.js:9-558,806-1043`، `luluBack/prisma/schema.prisma:678-698`، `luluBack/src/app.js:220-227`.

### 9.9 التصنيفات — 4.11

- GET /categories public؛active=true|false اختياري،invalid400؛name asc؛200 {success,count,data}.
- Category:id,name,description?,image?,isActive,createdAt,updatedAt؛global بلا branch/shift.
- POST {name,description?,image?}؛name trimmed nonempty؛201 {success,data}.
- PUT /:id partial {name?,description?,image?,isActive?}؛nonempty name إن أرسل؛null/"" يمسح description/image؛bool أوstring true/false؛empty update400؛200 {success,data}.
- جميع الموظفين يكتبون،لا product-write restriction ولا مفتاح category مخترع. duplicate name400،missing404،unexpected500.
- DELETE فعلي200 {success,message}؛P2003=>409،P2025=>404. لا تعد بcascade أو فك ارتباط المنتجات؛سلوك FK الفعلي مرتبط بالمخطط الجاري.
- image path مدعوم،لكن لا endpoint upload category؛لا تعيد توظيف product upload دون إذن.

الأدلة: `luluBack/src/routes/categoryRoutes.js:6-12`، `luluBack/src/controllers/categoryController.js:13-295`، `luluBack/prisma/schema.prisma:181-192`.

### 9.10 التقارير الأساسية — 4.12

| GET path | Query والحدود | data |
|---|---|---|
| /reports/daily | date? default now,Cairo day |daily totals|
| /reports/monthly | year? default Cairo current,2000..2100؛month? current,1..12 |monthly totals/breakdowns|
| /reports/top-products | days default30,1..3650؛limit default10,1..100 |TopProduct[]|
| /reports/low-stock | لا query/pagination |أول15 branch-product rows|
| /reports/expiry-alerts | days default90,0..3650 |expired,expiringSoon,totalAlerts|

- daily data:date,totalSales,grossSales,totalReturns,netSales,cashSales,cardSales,creditSales,totalOrders,posOrders,onlineOrders,salesCOGS,returnsCOGS,cogs,totalExpenses,grossProfit,operatingProfit,netProfit,netRevenue.
- monthly data:year,month,totalSales,grossSales,totalReturns,netSales,totalOrders,salesCOGS,returnsCOGS,cogs,totalExpenses,grossProfit,operatingProfit,netProfit,netRevenue,dailyBreakdown[{_id:day,totalSales,grossSales,totalReturns,netSales,orderCount}],expenseBreakdown[{_id:category,total}].
- TopProduct:_id,productName,quantityUnit(base),grossQuantity,returnedQuantity,totalQuantity,grossRevenue,returnedRevenue,totalRevenue؛السيرفر يحول الوحدات ويطرح المرتجعات ويصفّي netQuantity>0 ويرتب quantity ثم revenue تنازلياً.
- low-stock: {success,count,branchId,data}؛stockQuantity<=minStockAlert لكل فرع،stock asc،count قبل slice(0,15). data منتج+category{name}?+stockQuantity,looseQuantity,minStockAlert,inTransitQuantity,branch. قد يتكرر المنتج،فمفتاح العرض branch+product؛السجلات الغائبة ليست ضمن التقرير.
- expiry:{success,data:{expired,expiringSoon,totalAlerts}}؛يشمل positive boxes OR loose،expiry asc،يجمع قيم branchStocks في all-branches. expiry على المنتج وليس batch.
- بقية التقارير {success,data}؛empty أرقام صفرية/قوائم فارغة طبيعية. invalid query400،unexpected أوmissing branch غالباً500. لا وردية مطلوبة.
- السيرفر يملك completed/delivered sales،returns،historical costAtSale/costAtReturn وCOGS والربح والمصروفات؛لا حسابات مالية محلية أو fallback وهمي. viewReports UI policy لا يفرضها controller،وتظل product purchase-cost fields محجوبة عن الصيدلي حتى لو سمح له بالتقرير.
- /reports/dashboard غير موجود؛لا تنشئ metrics من تصميم أو اختبار ضعيف. low-stock محفوظة200،لكن سبب500 قديم/سلامة deployment الحالي غير مثبتين.

الأدلة: `luluBack/src/routes/reportRoutes.js:6-15`، `luluBack/src/controllers/reportController.js:21-148,154-245,443-505,515-620,895-951,963-1003,1080-1292,1316-1539`.

### 9.11 أدلة التشغيل وQA — 4.14

المتاح عينات محفوظة للقراءات،منها staff_products/orders/orders_online/prescriptions/shift_current/branches/reports/lookup،وملفات حالات access_matrix/status. لا يثبت ذلك نفس commit أو صحة التشغيل اليوم.

لم يتم تشغيل write request أوbackend tests/app أثناء التدقيق. التحقق الحي الناقص:فتح/إغلاق وردية،POS،تحديث حالة/مراجعة،CRUD/upload،وأدوار/فروع edge cases؛الكتابة تحتاج موافقة منفصلة وبيانات معزولة. GET يمكن التحقق به بجلسات اختبار موجودة دون كشف secrets.

QA: customer/pharmacist/admin/superadmin،null/false/true flags،موظف بلا فرع،super selected/all/invalid/inactive،empty،invalid input،expired auth401 مقابل403،stock/no-shift،network/server،duplicate submit،scope race،وكاميرا جهاز فعلي. لا تقفل4.14 قبل نتائج flutter analyze وflutter test كاملة وأدلة ما تم/لم يتم يدوياً.


<a id="integration-guide"></a>

## 10) دليل التكامل السريع وقراءة النماذج

هذا القسم يدمج إرشادات التكامل العملية دون إعادة نسخ العقود التفصيلية في §3 و§9. قواعد البرمجة/الثيم/الصلاحيات المعتمدة في AGENTS.md؛ لا تنشئ إعدادات موازية.

### 10.1 المكونات الموجودة

- ApiClient في lib/core/network/api_client.dart: Dio وPersistCookieJar وinterceptors للهيدر والجلسة؛يحقن في DataSource بالـconstructor. لا عميل جديد لكل feature ولا GetIt في Widgets.
- AppConfig في lib/core/constants/app_config.dart: baseUrl وorigin وmediaUrl. Android emulator يستخدم10.0.2.2،والبقية localhost محلياً؛الجهاز الحقيقي يحتاج عنوان سيرفر مناسب. API_BASE_URL عبر dart-define يغير المضيف دون تعديل كل DataSource.
- الرفع عبر ApiClient.uploadOptions بمهلة إرسال/استقبال60s؛image_picker وcached_network_image وmobile_scanner موجودة. لا flutter_secure_storage أو حزمة scanner أخرى أو Hive تلقائياً.

```dart
// مقتطف داخل DataSource يستقبل ApiClient؛ليس Widget أو ملفاً مستقلاً.
final response = await apiClient.dio.get<Map<String, dynamic>>(
  '/store/products',
  queryParameters: {'branchId': branchId, 'page': 1, 'limit': 20},
);
// DTO parsing داخل data؛Entity/result عبر repository،والعرض من Cubit.
final imageUrl = AppConfig.mediaUrl(imagePath);
```

المسار النسبي للصورة يركب على origin دون /api؛الرابط الكامل يبقى كما هو. لا helper بمضيف ثابت داخل feature.

### 10.2 تدفقات التكامل

```text
عميل:
store/branches -> اختيار branchId -> store/categories/products
-> auth/register أو auth/login -> store/orders -> store/orders/my

روشتة عميل:
prescriptions/upload-image -> خذ data.image
-> prescriptions {imageUrl,notes?} -> prescriptions/my

موظف:
branches (اختيار superadmin فقط) -> shifts/current
-> shifts/open عند الحاجة -> products keyword -> customers/lookup اختياري
-> POST orders cash/paidAmount -> PUT shifts/close

متابعة موظف دون شرط وردية للقراءة:
orders/history/details أو orders/online/status
prescriptions/list/review وفق الدور -> reports وفق UI permission
```

هذه خريطة وليست إذناً بتنفيذ requests أوإنشاء بيانات. جميع queries/bodies الدقيقة في §3 و§9؛افصل سياق المتجر عن الموظف،ولا تستخدم lookup.id كـOrder.customerId أو product top-level legacy stock للبيع.

### 10.3 قواعد decoding وpagination

| العقد | مفاتيح النتيجة |
|---|---|
| login/register | user |
| auth/me وبقية النتائج الفردية | data حسب endpoint |
| POS/orders | data هو المصدر؛order/orders نسخة مكررة لا تقرأها كطلب إضافي |
| store products/orders my | total,totalPages,page,limit؛راجع العينة لبقية envelope |
| internal products | count,totalCount,page,limit,hasMore؛default50،max100 مرفوض إن تجاوز |
| shifts history | count,total,page,limit,hasMore؛default20،cap100 |
| orders/online/prescriptions | لا pagination |
| low-stock | count قبل القص وdata أول15 فقط؛لا pagination |

- المال/targets من JSON num إلى double؛monthlyTarget Float. nullable relations/strings والتواريخ لا تفرض عليها عينات غير فارغة فقط.
- Store Branch أربعة حقول id/name/address?/phone?؛Internal Branch يضيف isActive والتواريخ. لا تفقد حقول الإدارة لإعادة استخدام موديل عام ناقص.
- StoreProduct.branchId يمكن أن يكون سياق الطلب في entity؛لا تخترع JSON branchId أو purchasingPrice مطلوباً في استجابة المتجر. Schema staff/product/branchStock في §9.4.
- الحالة الخام تبقى قيمة domain؛النص المعروض translationKey. labels العميل للطلبات:pending=قيد الانتظار،processing=جاري التحضير،completed=تم التجهيز،delivered=تم التوصيل،cancelled=ملغي؛لا تحسب هذه strings داخل domain.
- تجميع روشتة العميل:pending/reviewed/quoted=>قيد الانتظار؛preparing/ready=>جاري التحضير؛completed=>تم التوصيل؛rejected=>مرفوضة. واجهة الموظف تحتفظ بالسبعة منفصلة لاختيار الانتقال الصحيح؛unknown يستخدم fallback مترجماً لا raw English.

### 10.4 التحقق والحدود

الاختبارات عبر mocks/fakes وtest/helpers/pump_with_providers.dart؛انظر AGENTS.md §9 لتسليم Flutter ونتائج analyze/test والجهاز. راجع pagination/role/branch/empty/errors وسباقات النتائج،ولا تتعامل مع نجاح عينة تاريخية كاختبار deployment. default manual/pull-to-refresh؛polling/socket يحتاج قراراً منفصلاً. لا تكرر كتابة ذات نتيجة مجهولة بعد timeout.

<a id="historical-samples"></a>

## 11) ملحق العينات التاريخية المدمجة

### 11.1 مصدر وحدود الاستخدام

- المصدر: ملف العينات السابق الموجود في المشروع قبل دمج2026-10-24. كان يصف الأمثلة بأنها ملتقطة من main محلياً،لكن بدون capture commit/time موثقين لكل مثال؛لذلك هذا الملحق **عينات محفوظة غير معاد التحقق منها حياً**،وليس captures جديدة.
- source-line لكل مثال يشير إلى رقم سطره في الملف السابق قبل حذفه،لا موضعه الحالي. عناوين المسارات صححت إلى العقد الحالي عند الحاجة،وأجسام JSON محفوظة مع حجب password فقط وإزالة تكرار JSON الحرفي إن وجد.
- أمثلة request هي شكل payload محفوظ وليست إثبات تنفيذ ناجح أو موافقة لتشغيلها. بعض responses مختصرة لعينة/عنصر واحد،وقد تختصر order المكرر أوnested relations وتغفل حقولاً فعلية؛لا تجعل هذا الاختصار schema صارماً أوتعد totals حقائق إنتاج.
- كل مثال له سياق مستقل؛لا تفترض أن IDs في أمثلة مختلفة متطابقة أوأنها موجودة اليوم. الأسماء/الهواتف والأرقام أمثلة تاريخية وليست قيماً لتهيئة التطبيق.
- المبالغ والتكلفة داخل الملحق أدلة شكل فقط؛قرار عرض القيم في AGENTS.md §8 يظل ملزماً،ولا تنسخ محتوى حساساً إلى logs/UI.

### 11.2 تصحيحات المصدر القديم

| عبارة قديمة لم تنقل كعقد | التصحيح المدقق |
|---|---|
| POST shifts/close | PUT،مع endingCash وendingVisa |
| الرسائل عربية دائماً | قد تكون عربية أوإنجليزية؛map إلى Failure مترجم |
| كل موظف بلا فرع يرفض403 | resolver فقط ثم تتغير الاستجابة حسب controller؛مسارات عامة لا تستدعيه |
| products category query مدعوم | غير موجود في controller الحالي |
| superadmin يتجاوز كل فحص | يتجاوز authorize فقط؛review controller يرفضه403 |
| register-staff للسوبر فقط | route تسمح admin مع superadmin bypass؛allowedRoles تقبل admin/pharmacist/superadmin،ولا تفترض قيوداً أقوى من الكود |
| جدول تجريبي يثبت أمان كل البيانات | spoofed header في monthly لا يثبت أمان تفاصيل المنتجات أوpermissions أوكل المسارات |
| تجميع المنتجات يعني جمع المخزون | كتالوج all-branches stock/loose0؛التقارير تختلف حسب endpoint |

أدلة التصحيحات في §7 و§9؛register-staff: `luluBack/src/routes/authRoutes.js:7` و`luluBack/src/controllers/authController.js:229-348`. إنشاء staff ليس تسجيل دخول جديداً للمنشئ؛الرد {success,user} ولا يضبط session جديدة عبر sendTokenResponse.

### 11.3 أمثلة أخطاء محفوظة

```json
{"message": "Phone number too short"}
```

lookup400 عند طول أقل من3؛وللمفقود404 برسالة Customer not found. توجد رسائل auth401 وصلاحية403 عربية في المصدر القديم. غياب branch helper قد يحمل «يجب ربط المستخدم بفرع أولاً» لكن HTTP النهائي يعتمد على controller. لا تعتمد على نص الرسالة أوهذه الأمثلة كتصنيف موحد لـPOS.

### 11.4 فهرس أمثلة JSON

- [S01 — إغلاق الوردية (Shift Close)](#sample-s01)
- [S02 — تسجيل الدخول `POST /auth/login`](#sample-s02)
- [S03 — تسجيل الدخول `POST /auth/login`](#sample-s03)
- [S04 — جلب بيانات المستخدم الحالي `GET /auth/me`](#sample-s04)
- [S05 — تسجيل عميل جديد `POST /auth/register` (Customer فقط)](#sample-s05)
- [S06 — تسجيل موظف جديد `POST /auth/register-staff` ](#sample-s06)
- [S07 — تسجيل موظف جديد `POST /auth/register-staff` ](#sample-s07)
- [S08 — تحديث صلاحيات الموظف `PUT /users/:id/permissions` ](#sample-s08)
- [S09 — فروع المتجر `GET /store/branches`](#sample-s09)
- [S10 — تصنيفات المتجر `GET /store/categories`](#sample-s10)
- [S11 — منتجات المتجر `GET /store/products?branchId=&page=&limit=&keyword=&category=`](#sample-s11)
- [S12 — تفاصيل منتج متجر `GET /store/products/:id?branchId=`](#sample-s12)
- [S13 — الإعدادات العامة `GET /settings/public`](#sample-s13)
- [S14 — إنشاء طلب أونلاين `POST /store/orders`](#sample-s14)
- [S15 — إنشاء طلب أونلاين `POST /store/orders`](#sample-s15)
- [S16 — قائمة طلباتي للعميل `GET /store/orders/my`](#sample-s16)
- [S17 — رفع صورة روشتة `POST /prescriptions/upload-image`](#sample-s17)
- [S18 — إرسال روشتة جديدة `POST /prescriptions`](#sample-s18)
- [S19 — إرسال روشتة جديدة `POST /prescriptions`](#sample-s19)
- [S20 — الوردية الحالية `GET /shifts/current`](#sample-s20)
- [S21 — إنشاء فاتورة نقطة بيع `POST /orders` (POS)](#sample-s21)
- [S22 — إنشاء فاتورة نقطة بيع `POST /orders` (POS)](#sample-s22)
- [S23 — طلبات الفرع الداخلية `GET /orders`](#sample-s23)
- [S24 — الطلبات الأونلاين للفرع `GET /orders/online`](#sample-s24)
- [S25 — استعراض الروشتات للموظف `GET /prescriptions`](#sample-s25)
- [S26 — قائمة المنتجات الداخلية للموظف `GET /products?limit=`](#sample-s26)
- [S27 — التقرير اليومي `GET /reports/daily`](#sample-s27)
- [S28 — التقرير الشهري `GET /reports/monthly`](#sample-s28)
- [S29 — المنتجات الأكثر مبيعاً `GET /reports/top-products`](#sample-s29)
- [S30 — تنبيهات الصلاحية `GET /reports/expiry-alerts`](#sample-s30)
- [S31 — البحث عن عميل في الـ POS برقم الهاتف `GET /customers/lookup`](#sample-s31)
- [S32 — التقرير الشهري `GET /api/reports/monthly?year=2026&month=10`](#sample-s32)
- [S33 — التقرير الشهري `GET /api/reports/monthly?year=2026&month=10`](#sample-s33)
- [S34 — الأكثر مبيعاً `GET /api/reports/top-products?days=30&limit=10`](#sample-s34)
- [S35 — الأكثر مبيعاً `GET /api/reports/top-products?days=30&limit=10`](#sample-s35)
- [S36 — تنبيهات الصلاحية `GET /api/reports/expiry-alerts?days=90`](#sample-s36)
- [S37 — تنبيهات المخزون المنخفض `GET /api/reports/low-stock`](#sample-s37)

<a id="sample-s01"></a>

### S01 — إغلاق الوردية (Shift Close)

نوع: Request مشتق/موثق للإغلاق،لا capture ناجح مثبت. المصدر القديم سطر153؛التقاط/commit العينة غير موثقين.

```json
{
  "endingCash": 250,
  "endingVisa": 50,
  "notes": "ملاحظات الإغلاق إن وجدت"
}
```

<a id="sample-s02"></a>

### S02 — تسجيل الدخول `POST /auth/login`

نوع: Request. المصدر القديم سطر185؛التقاط/commit العينة غير موثقين.

```json
{
  "email": "pharmacist@test.com",
  "password": "[REDACTED]"
}
```

<a id="sample-s03"></a>

### S03 — تسجيل الدخول `POST /auth/login`

نوع: Response. المصدر القديم سطر193؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "user": {
    "id": "cbf82a14-8742-4f11-9a7c-179326d91012",
    "name": "Test Pharmacist",
    "email": "pharmacist@test.com",
    "role": "pharmacist",
    "phone": null,
    "address": null,
    "permissions": null,
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901"
  }
}
```

<a id="sample-s04"></a>

### S04 — جلب بيانات المستخدم الحالي `GET /auth/me`

نوع: Response. المصدر القديم سطر216؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "e98df12a-3312-40bb-97dc-712891bcfa10",
    "name": "Ahmed Mostafa",
    "email": "customer@test.com",
    "phone": "01012345678",
    "address": null,
    "role": "customer",
    "isActive": true,
    "permissions": null,
    "monthlyTarget": 0,
    "branchId": null,
    "createdAt": "2026-10-10T12:00:00.000Z"
  }
}
```

<a id="sample-s05"></a>

### S05 — تسجيل عميل جديد `POST /auth/register` (Customer فقط)

نوع: Request. المصدر القديم سطر239؛التقاط/commit العينة غير موثقين.

```json
{
  "name": "Customer Name",
  "email": "customer@test.com",
  "password": "[REDACTED]",
  "phone": "01000000000",
  "address": "Cairo, Egypt"
}
```

<a id="sample-s06"></a>

### S06 — تسجيل موظف جديد `POST /auth/register-staff`

نوع: Request. المصدر القديم سطر254؛التقاط/commit العينة غير موثقين.

```json
{
  "name": "Staff Name",
  "email": "staff@test.com",
  "password": "[REDACTED]",
  "role": "pharmacist",
  "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
  "phone": "01011111111",
  "monthlyTarget": 50000
}
```

<a id="sample-s07"></a>

### S07 — تسجيل موظف جديد `POST /auth/register-staff`

نوع: Response. المصدر القديم سطر268؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "user": {
    "id": "d09f7a11-8843-4a11-9a7c-229326d91012",
    "name": "Staff Name",
    "email": "staff@test.com",
    "phone": "01011111111",
    "role": "pharmacist",
    "monthlyTarget": 50000,
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
    "isActive": true
  }
}
```

<a id="sample-s08"></a>

### S08 — تحديث صلاحيات الموظف `PUT /users/:id/permissions`

نوع: Request. المصدر القديم سطر288؛التقاط/commit العينة غير موثقين.

```json
{
  "permissions": {
    "editPrice": false,
    "manageTransfers": true,
    "viewPrescriptions": true,
    "viewReports": true,
    "viewReturns": true
  }
}
```

<a id="sample-s09"></a>

### S09 — فروع المتجر `GET /store/branches`

نوع: Response. المصدر القديم سطر314؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": "b18f3a22-3118-4089-9e8c-529a6e118901",
      "name": "Main Branch",
      "address": "Cairo",
      "phone": "01012345678"
    }
  ]
}
```

<a id="sample-s10"></a>

### S10 — تصنيفات المتجر `GET /store/categories`

نوع: Response. المصدر القديم سطر333؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "c10f8a91-4418-4089-9e8c-779a6e118902",
      "name": "Skincare"
    }
  ]
}
```

<a id="sample-s11"></a>

### S11 — منتجات المتجر `GET /store/products?branchId=&page=&limit=&keyword=&category=`

نوع: Response. المصدر القديم سطر353؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 3,
  "total": 3,
  "page": 1,
  "limit": 5,
  "totalPages": 1,
  "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
  "data": [
    {
      "id": "p01f8a22-1118-4089-9e8c-669a6e118999",
      "name": "Hydrating Cream 50ml",
      "scientificName": "Hyaluronic Acid",
      "barcode": "6221000000028",
      "description": "Daily moisturizing cream for dry and sensitive skin",
      "image": null,
      "sellingPrice": 130,
      "stockQuantity": 30,
      "expiryDate": "2028-06-30T00:00:00.000Z",
      "requiresPrescription": false,
      "unit": "قطعة",
      "category": {
        "id": "c10f8a91-4418-4089-9e8c-779a6e118902",
        "name": "Skincare"
      },
      "looseQuantity": 0,
      "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901"
    }
  ]
}
```

<a id="sample-s12"></a>

### S12 — تفاصيل منتج متجر `GET /store/products/:id?branchId=`

نوع: Response. المصدر القديم سطر390؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "p01f8a22-1118-4089-9e8c-669a6e118999",
    "name": "Hydrating Cream 50ml",
    "scientificName": "Hyaluronic Acid",
    "barcode": "6221000000028",
    "description": "Daily moisturizing cream for dry and sensitive skin",
    "image": null,
    "sellingPrice": 130,
    "stockQuantity": 30,
    "expiryDate": "2028-06-30T00:00:00.000Z",
    "requiresPrescription": false,
    "unit": "قطعة",
    "category": {
      "id": "c10f8a91-4418-4089-9e8c-779a6e118902",
      "name": "Skincare"
    },
    "looseQuantity": 0,
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901"
  }
}
```

<a id="sample-s13"></a>

### S13 — الإعدادات العامة `GET /settings/public`

نوع: Response. المصدر القديم سطر420؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {}
}
```

<a id="sample-s14"></a>

### S14 — إنشاء طلب أونلاين `POST /store/orders`

نوع: Request. المصدر القديم سطر437؛التقاط/commit العينة غير موثقين.

```json
{
  "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
  "orderItems": [
    {
      "productId": "p02f8a22-2228-4089-9e8c-669a6e118988",
      "quantity": 2
    }
  ],
  "deliveryAddress": "Nasr City, Cairo, Building 4",
  "customerPhone": "01012345678",
  "notes": "يرجى الاتصال قبل الوصول"
}
```

<a id="sample-s15"></a>

### S15 — إنشاء طلب أونلاين `POST /store/orders`

نوع: Response. المصدر القديم سطر453؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "ord-887123aa-9912-4f81-81b3-4412398fa101",
    "orderNumber": "ONL-20261018-001",
    "customerId": "e98df12a-3312-40bb-97dc-712891bcfa10",
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
    "subtotal": 170,
    "totalAmount": 170,
    "paidAmount": 0,
    "dueAmount": 170,
    "changeAmount": 0,
    "orderType": "ONLINE",
    "status": "pending",
    "paymentMethod": "cash",
    "deliveryAddress": "Nasr City, Cairo, Building 4",
    "customerPhone": "01012345678",
    "notes": "يرجى الاتصال قبل الوصول",
    "createdAt": "2026-10-18T12:30:00.000Z",
    "items": [
      {
        "id": "item-01",
        "orderId": "ord-887123aa-9912-4f81-81b3-4412398fa101",
        "productId": "p02f8a22-2228-4089-9e8c-669a6e118988",
        "productName": "Vitamin C 1000mg",
        "quantity": 2,
        "priceAtPurchase": 85,
        "costAtSale": 60,
        "isUnit": false,
        "isSecondaryUnit": false
      }
    ]
  }
}
```

<a id="sample-s16"></a>

### S16 — قائمة طلباتي للعميل `GET /store/orders/my`

نوع: Response. المصدر القديم سطر498؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 1,
  "total": 1,
  "page": 1,
  "limit": 3,
  "totalPages": 1,
  "data": [
    {
      "id": "ord-887123aa-9912-4f81-81b3-4412398fa101",
      "orderNumber": "ONL-20261018-001",
      "subtotal": 170,
      "discountType": "fixed",
      "discountValue": 0,
      "totalAmount": 170,
      "paidAmount": 0,
      "dueAmount": 170,
      "changeAmount": 0,
      "orderType": "ONLINE",
      "status": "pending",
      "paymentMethod": "cash",
      "deliveryAddress": "Nasr City, Cairo, Building 4",
      "customerPhone": "01012345678",
      "notes": "يرجى الاتصال قبل الوصول",
      "createdAt": "2026-10-18T12:30:00.000Z",
      "updatedAt": "2026-10-18T12:30:00.000Z",
      "items": [
        {
          "id": "item-01",
          "productId": "p02f8a22-2228-4089-9e8c-669a6e118988",
          "productName": "Vitamin C 1000mg",
          "quantity": 2,
          "priceAtPurchase": 85,
          "isUnit": false
        }
      ]
    }
  ]
}
```

<a id="sample-s17"></a>

### S17 — رفع صورة روشتة `POST /prescriptions/upload-image`

نوع: Response. المصدر القديم سطر546؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "image": "/uploads/prescriptions/rx-1729251845123-981241.png",
    "filename": "rx-1729251845123-981241.png",
    "mimeType": "image/png",
    "size": 70142,
    "extension": ".png"
  }
}
```

<a id="sample-s18"></a>

### S18 — إرسال روشتة جديدة `POST /prescriptions`

نوع: Request. المصدر القديم سطر563؛التقاط/commit العينة غير موثقين.

```json
{
  "imageUrl": "/uploads/prescriptions/rx-1729251845123-981241.png",
  "notes": "يرجى توفير البديل إذا كان الصنف ناقصاً"
}
```

<a id="sample-s19"></a>

### S19 — إرسال روشتة جديدة `POST /prescriptions`

نوع: Response. المصدر القديم سطر571؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "rx-771239aa-0012-4f81-99b3-1112398fa202",
    "prescriptionNumber": "RX-20261018-005",
    "customerId": "e98df12a-3312-40bb-97dc-712891bcfa10",
    "imageUrl": "/uploads/prescriptions/rx-1729251845123-981241.png",
    "notes": "يرجى توفير البديل إذا كان الصنف ناقصاً",
    "status": "pending",
    "pharmacistId": null,
    "pharmacistNotes": null,
    "quotedPrice": null,
    "customerResponse": null,
    "rejectionReason": null,
    "createdAt": "2026-10-18T13:00:00.000Z",
    "updatedAt": "2026-10-18T13:00:00.000Z",
    "customer": {
      "name": "Ahmed Mostafa",
      "phone": "01012345678",
      "email": "customer@test.com"
    }
  }
}
```

<a id="sample-s20"></a>

### S20 — الوردية الحالية `GET /shifts/current`

نوع: Response. المصدر القديم سطر605؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "shf-110293aa-5512-4f81-81b3-9912398fa999",
    "pharmacistId": "cbf82a14-8742-4f11-9a7c-179326d91012",
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
    "startTime": "2026-10-18T08:00:00.000Z",
    "endTime": null,
    "startingCash": 100,
    "endingCash": null,
    "expectedCash": 230,
    "endingVisa": null,
    "expectedVisa": 0,
    "totalSales": 130,
    "totalOrders": 1,
    "totalReturns": 0,
    "status": "open",
    "notes": null,
    "pharmacist": {
      "name": "Test Pharmacist"
    },
    "grossSales": 130,
    "netSales": 130,
    "cashSales": 130,
    "cashReturns": 0,
    "netCashSales": 130,
    "visaSales": 0,
    "digitalSales": 0
  }
}
```

<a id="sample-s21"></a>

### S21 — إنشاء فاتورة نقطة بيع `POST /orders` (POS)

نوع: Request. المصدر القديم سطر648؛التقاط/commit العينة غير موثقين.

```json
{
  "orderItems": [
    {
      "productId": "p01f8a22-1118-4089-9e8c-669a6e118999",
      "quantity": 1,
      "isUnit": false,
      "isSecondaryUnit": false
    }
  ],
  "orderType": "POS",
  "paymentMethod": "cash",
  "discountType": "fixed",
  "discountValue": 0,
  "paidAmount": 130,
  "customerPhone": null,
  "customerId": null,
  "splitCash": 0,
  "splitCard": 0,
  "splitInstapay": 0,
  "splitVodafoneCash": 0
}
```

<a id="sample-s22"></a>

### S22 — إنشاء فاتورة نقطة بيع `POST /orders` (POS)

نوع: Response. المصدر القديم سطر673؛التقاط/commit العينة غير موثقين.

```json
{
  "message": "Order created successfully",
  "success": true,
  "data": {
    "id": "ord-pos-998811-aa",
    "orderNumber": "ORD-20261018-010",
    "pharmacistId": "cbf82a14-8742-4f11-9a7c-179326d91012",
    "customerId": null,
    "shiftId": "shf-110293aa-5512-4f81-81b3-9912398fa999",
    "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
    "subtotal": 130,
    "discountType": "fixed",
    "discountValue": 0,
    "totalAmount": 130,
    "paidAmount": 130,
    "dueAmount": 0,
    "changeAmount": 0,
    "orderType": "POS",
    "status": "completed",
    "paymentMethod": "cash",
    "splitCash": 0,
    "splitCard": 0,
    "splitInstapay": 0,
    "splitVodafoneCash": 0,
    "customerPhone": null,
    "deliveryAddress": null,
    "notes": null,
    "createdAt": "2026-10-18T14:15:00.000Z",
    "items": [
      {
        "productName": "Hydrating Cream 50ml",
        "quantity": 1,
        "priceAtPurchase": 130,
        "costAtSale": 90,
        "isUnit": false,
        "isSecondaryUnit": false
      }
    ],
    "branch": {
      "id": "b18f3a22-3118-4089-9e8c-529a6e118901",
      "name": "Main Branch"
    }
  },
  "order": {
    "id": "ord-pos-998811-aa",
    "orderNumber": "ORD-20261018-010"
  }
}
```

<a id="sample-s23"></a>

### S23 — طلبات الفرع الداخلية `GET /orders`

نوع: Response. المصدر القديم سطر732؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 2,
  "data": [
    {
      "id": "ord-pos-998811-aa",
      "orderNumber": "ORD-20261018-010",
      "pharmacistId": "cbf82a14-8742-4f11-9a7c-179326d91012",
      "customerId": null,
      "shiftId": "shf-110293aa-5512-4f81-81b3-9912398fa999",
      "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
      "subtotal": 130,
      "totalAmount": 130,
      "paidAmount": 130,
      "dueAmount": 0,
      "orderType": "POS",
      "status": "completed",
      "paymentMethod": "cash",
      "createdAt": "2026-10-18T14:15:00.000Z",
      "items": [
        {
          "id": "it-1",
          "quantity": 1,
          "priceAtPurchase": 130,
          "product": {
            "id": "p01f8a22-1118-4089-9e8c-669a6e118999",
            "name": "Hydrating Cream 50ml",
            "barcode": "6221000000028"
          }
        }
      ],
      "pharmacist": {
        "id": "cbf82a14-8742-4f11-9a7c-179326d91012",
        "name": "Test Pharmacist"
      },
      "customer": null,
      "shift": {
        "id": "shf-110293aa-5512-4f81-81b3-9912398fa999",
        "status": "open"
      },
      "branch": {
        "id": "b18f3a22-3118-4089-9e8c-529a6e118901",
        "name": "Main Branch"
      }
    }
  ],
  "orders": [
    {
      "id": "ord-pos-998811-aa",
      "orderNumber": "ORD-20261018-010"
    }
  ]
}
```

<a id="sample-s24"></a>

### S24 — الطلبات الأونلاين للفرع `GET /orders/online`

نوع: Response. المصدر القديم سطر792؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 1,
  "activeShift": null,
  "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
  "data": [
    {
      "id": "ord-887123aa-9912-4f81-81b3-4412398fa101",
      "orderNumber": "ONL-20261018-001",
      "pharmacist": null,
      "orderType": "ONLINE",
      "status": "pending",
      "totalAmount": 170
    }
  ],
  "orders": [
    {
      "id": "ord-887123aa-9912-4f81-81b3-4412398fa101"
    }
  ]
}
```

<a id="sample-s25"></a>

### S25 — استعراض الروشتات للموظف `GET /prescriptions`

نوع: Response. المصدر القديم سطر821؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": "rx-771239aa-0012-4f81-99b3-1112398fa202",
      "prescriptionNumber": "RX-20261018-005",
      "customerId": "e98df12a-3312-40bb-97dc-712891bcfa10",
      "imageUrl": "/uploads/prescriptions/rx-1729251845123-981241.png",
      "notes": "يرجى توفير البديل إذا كان الصنف ناقصاً",
      "status": "pending",
      "pharmacistId": null,
      "pharmacistNotes": null,
      "quotedPrice": null,
      "customerResponse": null,
      "rejectionReason": null,
      "createdAt": "2026-10-18T13:00:00.000Z",
      "updatedAt": "2026-10-18T13:00:00.000Z",
      "customer": {
        "name": "Ahmed Mostafa",
        "email": "customer@test.com",
        "phone": "01012345678"
      },
      "pharmacist": null,
      "items": []
    }
  ]
}
```

<a id="sample-s26"></a>

### S26 — قائمة المنتجات الداخلية للموظف `GET /products?limit=`

نوع: Response. المصدر القديم سطر859؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "count": 3,
  "totalCount": 3,
  "page": 1,
  "limit": 3,
  "hasMore": false,
  "data": [
    {
      "id": "p01f8a22-1118-4089-9e8c-669a6e118999",
      "name": "Hydrating Cream 50ml",
      "scientificName": "Hyaluronic Acid",
      "barcode": "6221000000028",
      "description": "Daily moisturizing cream",
      "image": null,
      "categoryId": "c10f8a91-4418-4089-9e8c-779a6e118902",
      "purchasingPrice": 90,
      "sellingPrice": 130,
      "expiryDate": "2028-06-30T00:00:00.000Z",
      "requiresPrescription": false,
      "isAvailableOnline": true,
      "unit": "قطعة",
      "isSplittable": false,
      "unitsPerBox": 1,
      "unitName": "علبة",
      "unitPrice": 130,
      "hasSecondaryUnit": false,
      "secondaryUnitsPerUnit": 0,
      "secondaryUnitName": null,
      "secondaryUnitPrice": 0,
      "supplierId": "sup-01",
      "stockQuantity": 30,
      "minStockAlert": 5,
      "looseQuantity": 0,
      "createdAt": "2026-10-01T10:00:00.000Z",
      "updatedAt": "2026-10-18T11:00:00.000Z",
      "category": {
        "id": "c10f8a91-4418-4089-9e8c-779a6e118902",
        "name": "Skincare"
      },
      "supplier": {
        "id": "sup-01",
        "name": "United Pharma"
      },
      "branchStocks": [
        {
          "id": "bs-01",
          "productId": "p01f8a22-1118-4089-9e8c-669a6e118999",
          "branchId": "b18f3a22-3118-4089-9e8c-529a6e118901",
          "stockQuantity": 30,
          "looseQuantity": 0,
          "averageCost": 90,
          "inTransitQuantity": 0,
          "minStockAlert": 5
        }
      ]
    }
  ]
}
```

<a id="sample-s27"></a>

### S27 — التقرير اليومي `GET /reports/daily`

نوع: Response. المصدر القديم سطر925؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "date": "2026-10-15T21:00:00.000Z",
    "totalSales": 130,
    "grossSales": 130,
    "totalReturns": 0,
    "netSales": 130,
    "cashSales": 130,
    "cardSales": 0,
    "creditSales": 0,
    "totalOrders": 1,
    "posOrders": 1,
    "onlineOrders": 0,
    "salesCOGS": 90,
    "returnsCOGS": 0,
    "cogs": 90,
    "totalExpenses": 0,
    "grossProfit": 40,
    "operatingProfit": 40,
    "netProfit": 40,
    "netRevenue": 130
  }
}
```

<a id="sample-s28"></a>

### S28 — التقرير الشهري `GET /reports/monthly`

نوع: Response. المصدر القديم سطر960؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "year": 2026,
    "month": 10,
    "totalSales": 130,
    "grossSales": 130,
    "totalReturns": 0,
    "netSales": 130,
    "totalOrders": 1,
    "salesCOGS": 90,
    "returnsCOGS": 0,
    "cogs": 90,
    "totalExpenses": 0,
    "grossProfit": 40,
    "operatingProfit": 40,
    "netProfit": 40,
    "netRevenue": 130,
    "dailyBreakdown": [
      {
        "_id": 16,
        "totalSales": 130,
        "grossSales": 130,
        "totalReturns": 0,
        "netSales": 130,
        "orderCount": 1
      }
    ],
    "expenseBreakdown": []
  }
}
```

<a id="sample-s29"></a>

### S29 — المنتجات الأكثر مبيعاً `GET /reports/top-products`

نوع: Response. المصدر القديم سطر1002؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": [
    {
      "_id": "cmv9mnyoi0006wqgoyfa9mv60",
      "productName": "Hydrating Cream 50ml",
      "quantityUnit": "base",
      "grossQuantity": 1,
      "returnedQuantity": 0,
      "totalQuantity": 1,
      "grossRevenue": 130,
      "returnedRevenue": 0,
      "totalRevenue": 130
    }
  ]
}
```

<a id="sample-s30"></a>

### S30 — تنبيهات الصلاحية `GET /reports/expiry-alerts`

نوع: Response. المصدر القديم سطر1030؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "expired": [
      {
        "id": "cmv9mnym50004wqgopr2luret",
        "name": "Vitamin C 1000mg",
        "scientificName": "Ascorbic Acid",
        "barcode": "6221000000011",
        "description": "Vitamin C effervescent tablets",
        "image": null,
        "categoryId": "cmv9bxrw70002wqgo7j1crx4h",
        "purchasingPrice": 60,
        "sellingPrice": 85,
        "expiryDate": "2026-10-01T00:00:00.000Z",
        "requiresPrescription": false,
        "isAvailableOnline": true,
        "unit": "قطعة",
        "isSplittable": false,
        "unitsPerBox": null,
        "unitName": null,
        "unitPrice": null,
        "hasSecondaryUnit": false,
        "secondaryUnitsPerUnit": null,
        "secondaryUnitName": null,
        "secondaryUnitPrice": null,
        "supplierId": null,
        "stockQuantity": 48,
        "minStockAlert": 10,
        "looseQuantity": 0,
        "createdAt": "2026-10-15T14:22:07.613Z",
        "updatedAt": "2026-10-15T14:22:07.613Z",
        "branchStocks": [
          {
            "id": "cmv9mnyna0005wqgo0um6qez2",
            "productId": "cmv9mnym50004wqgopr2luret",
            "branchId": "cmv9bxrvj0001wqgov68wj0wb",
            "stockQuantity": 48,
            "looseQuantity": 0,
            "averageCost": 60,
            "inTransitQuantity": 0,
            "minStockAlert": 10,
            "createdAt": "2026-10-15T14:22:07.654Z",
            "updatedAt": "2026-10-16T09:34:59.926Z"
          }
        ],
        "category": {
          "name": "Vitamins"
        }
      }
    ],
    "expiringSoon": [
      {
        "id": "cmv9mnyp80008wqgoepyhqdof",
        "name": "Amoxicillin 500mg",
        "scientificName": "Amoxicillin",
        "barcode": "6221000000035",
        "description": "Antibiotic capsules, prescription only",
        "image": null,
        "categoryId": null,
        "purchasingPrice": 40,
        "sellingPrice": 60,
        "expiryDate": "2026-11-20T00:00:00.000Z",
        "requiresPrescription": true,
        "isAvailableOnline": true,
        "unit": "قطعة",
        "isSplittable": true,
        "unitsPerBox": 10,
        "unitName": null,
        "unitPrice": 6,
        "hasSecondaryUnit": false,
        "secondaryUnitsPerUnit": null,
        "secondaryUnitName": null,
        "secondaryUnitPrice": null,
        "supplierId": null,
        "stockQuantity": 20,
        "minStockAlert": 5,
        "looseQuantity": 0,
        "createdAt": "2026-10-15T14:22:07.724Z",
        "updatedAt": "2026-10-15T14:22:07.724Z",
        "branchStocks": [
          {
            "id": "cmv9mnyp90009wqgoc9jbowcs",
            "productId": "cmv9mnyp80008wqgoepyhqdof",
            "branchId": "cmv9bxrvj0001wqgov68wj0wb",
            "stockQuantity": 20,
            "looseQuantity": 0,
            "averageCost": 40,
            "inTransitQuantity": 0,
            "minStockAlert": 5,
            "createdAt": "2026-10-15T14:22:07.725Z",
            "updatedAt": "2026-10-15T14:22:07.725Z"
          }
        ],
        "category": null
      }
    ],
    "totalAlerts": 2
  }
}
```

<a id="sample-s31"></a>

### S31 — البحث عن عميل في الـ POS برقم الهاتف `GET /customers/lookup`

نوع: Response. المصدر القديم سطر1143؛التقاط/commit العينة غير موثقين.

```json
{
  "success": true,
  "data": {
    "id": "cmvfft5h20000iagq0n4o12gz",
    "name": "Ahmed Mohamed",
    "phone": "<phone>",
    "loyaltyPoints": 0,
    "totalSpent": 0,
    "notes": "Test customer",
    "createdAt": "2026-10-19T15:56:49.526Z",
    "updatedAt": "2026-10-19T15:56:49.526Z"
  }
}
```

<a id="sample-s32"></a>

### S32 — التقرير الشهري `GET /api/reports/monthly?year=2026&month=10`

نوع: Response. المصدر القديم سطر1210؛التقاط/commit العينة غير موثقين. سياق: فرع A عبر الهيدر (`X-Branch-Id: cmvfhrdeq0001iagqkxwt9vpg`):

```json
{
  "success": true,
  "data": {
    "year": 2026,
    "month": 10,
    "totalSales": 165,
    "grossSales": 165,
    "totalReturns": 0,
    "netSales": 165,
    "totalOrders": 2,
    "salesCOGS": 120,
    "returnsCOGS": 0,
    "cogs": 120,
    "totalExpenses": 0,
    "grossProfit": 45,
    "operatingProfit": 45,
    "netProfit": 45,
    "netRevenue": 165,
    "dailyBreakdown": [
      {
        "_id": 17,
        "totalSales": 70,
        "grossSales": 70,
        "totalReturns": 0,
        "netSales": 70,
        "orderCount": 1
      },
      {
        "_id": 18,
        "totalSales": 95,
        "grossSales": 95,
        "totalReturns": 0,
        "netSales": 95,
        "orderCount": 1
      }
    ],
    "expenseBreakdown": []
  }
}
```

<a id="sample-s33"></a>

### S33 — التقرير الشهري `GET /api/reports/monthly?year=2026&month=10`

نوع: Response. المصدر القديم سطر1253؛التقاط/commit العينة غير موثقين. سياق: الإجمالي المجمع لكافة الفروع (بدون هيدر `X-Branch-Id`):

```json
{
  "success": true,
  "data": {
    "year": 2026,
    "month": 10,
    "totalSales": 605,
    "grossSales": 605,
    "totalReturns": 0,
    "netSales": 605,
    "totalOrders": 8,
    "salesCOGS": 421,
    "returnsCOGS": 0,
    "cogs": 421,
    "totalExpenses": 0,
    "grossProfit": 184,
    "operatingProfit": 184,
    "netProfit": 184,
    "netRevenue": 605,
    "dailyBreakdown": [
      {
        "_id": 16,
        "totalSales": 130,
        "grossSales": 130,
        "totalReturns": 0,
        "netSales": 130,
        "orderCount": 1
      },
      {
        "_id": 17,
        "totalSales": 166,
        "grossSales": 166,
        "totalReturns": 0,
        "netSales": 166,
        "orderCount": 2
      },
      "... 2 more items"
    ],
    "expenseBreakdown": []
  }
}
```

<a id="sample-s34"></a>

### S34 — الأكثر مبيعاً `GET /api/reports/top-products?days=30&limit=10`

نوع: Response. المصدر القديم سطر1301؛التقاط/commit العينة غير موثقين. سياق: فرع A:

```json
{
  "success": true,
  "data": [
    {
      "_id": "cmvfhucqd0003pggq9a2hn6c0",
      "productName": "Panadol Extra 500mg",
      "quantityUnit": "base",
      "grossQuantity": 2,
      "returnedQuantity": 0,
      "totalQuantity": 2,
      "grossRevenue": 70,
      "returnedRevenue": 0,
      "totalRevenue": 70
    },
    {
      "_id": "cmvfhucr00005pggq6asx3pen",
      "productName": "Augmentin 1g Tablets",
      "quantityUnit": "base",
      "grossQuantity": 1,
      "returnedQuantity": 0,
      "totalQuantity": 1,
      "grossRevenue": 95,
      "returnedRevenue": 0,
      "totalRevenue": 95
    }
  ]
}
```

<a id="sample-s35"></a>

### S35 — الأكثر مبيعاً `GET /api/reports/top-products?days=30&limit=10`

نوع: Response. المصدر القديم سطر1332؛التقاط/commit العينة غير موثقين. سياق: الإجمالي المجمع لكافة الفروع:

```json
{
  "success": true,
  "data": [
    {
      "_id": "cmvfhucri000npggqkhi33uel",
      "productName": "Congestal Tablets",
      "quantityUnit": "base",
      "grossQuantity": 3,
      "returnedQuantity": 0,
      "totalQuantity": 3,
      "grossRevenue": 96,
      "returnedRevenue": 0,
      "totalRevenue": 96
    },
    {
      "_id": "cmvfhucqd0003pggq9a2hn6c0",
      "productName": "Panadol Extra 500mg",
      "quantityUnit": "base",
      "grossQuantity": 2,
      "returnedQuantity": 0,
      "totalQuantity": 2,
      "grossRevenue": 70,
      "returnedRevenue": 0,
      "totalRevenue": 70
    },
    "... 6 more items"
  ]
}
```

<a id="sample-s36"></a>

### S36 — تنبيهات الصلاحية `GET /api/reports/expiry-alerts?days=90`

نوع: Response. المصدر القديم سطر1368؛التقاط/commit العينة غير موثقين. سياق: فرع A (`totalAlerts = 3`):

```json
{
  "success": true,
  "data": {
    "expired": [
      {
        "id": "cmvfhucrg000lpggqb4crb4go",
        "name": "Gaviscon Liquid 200ml",
        "barcode": "TEST-A10",
        "expiryDate": "2026-09-01T00:00:00.000Z",
        "stockQuantity": 15,
        "branchStocks": [
          {
            "branchId": "cmvfhrdeq0001iagqkxwt9vpg",
            "stockQuantity": 15
          }
        ]
      }
    ],
    "expiringSoon": [
      {
        "id": "cmvfhucrf000jpggq5n3o34u8",
        "name": "Paracetamol Suspension 120mg",
        "barcode": "TEST-A09",
        "expiryDate": "2026-11-15T00:00:00.000Z",
        "stockQuantity": 25,
        "branchStocks": [
          {
            "branchId": "cmvfhrdeq0001iagqkxwt9vpg",
            "stockQuantity": 25
          }
        ]
      },
      {
        "id": "cmvfhucr50009pggq2934lq5a",
        "name": "Cetirizine 10mg",
        "barcode": "TEST-A06",
        "expiryDate": "2026-12-05T00:00:00.000Z",
        "stockQuantity": 40,
        "branchStocks": [
          {
            "branchId": "cmvfhrdeq0001iagqkxwt9vpg",
            "stockQuantity": 40
          }
        ]
      }
    ],
    "totalAlerts": 3
  }
}
```

<a id="sample-s37"></a>

### S37 — تنبيهات المخزون المنخفض `GET /api/reports/low-stock`

نوع: Response. المصدر القديم سطر1430؛التقاط/commit العينة غير موثقين. سياق: فرع A (`count = 2`, `branchId = cmvfhrdeq0001iagqkxwt9vpg`):

```json
{
  "success": true,
  "count": 2,
  "branchId": "cmvfhrdeq0001iagqkxwt9vpg",
  "data": [
    {
      "id": "cmvfhucrb000fpggqm9yop0ts",
      "name": "Otrivin Adult Nasal Spray",
      "barcode": "TEST-A07",
      "stockQuantity": 3,
      "minStockAlert": 10,
      "branch": {
        "id": "cmvfhrdeq0001iagqkxwt9vpg",
        "name": "Test Branch A"
      }
    },
    {
      "id": "cmvfhucrd000hpggqy9b434o3",
      "name": "Strepsils Honey & Lemon",
      "barcode": "TEST-A08",
      "stockQuantity": 4,
      "minStockAlert": 10,
      "branch": {
        "id": "cmvfhrdeq0001iagqkxwt9vpg",
        "name": "Test Branch A"
      }
    }
  ]
}
```

### 11.5 ملاحظات تجربة تعدد الفروع السابقة

المصدر القديم وصف بيانات اختبار محلية: Main وثلاثة فروع Test Branch A/B/C،مع30 صنفاً تجريبياً تبدأ أكوادها TEST-،و33 صنفاً في الكتالوج وقتها. أمثلة الفرع A ومقابل all-branches أعلاه تحفظ أشكال التقارير والنتائج القديمة،ولا تثبت وجود هذه البيانات أوحالها اليوم.

الوصف السابق لتقرير monthly مع header مزور للصيدلي قال إن الهيدر تجاهل وفرع الصيدلي بقي ثابتاً؛هذا يتفق مع resolver الحالي لكنه ليس اختبار أمان شامل. low-stock aggregate كان count7،والسيرفر الحالي يعيد أول15 صفاً؛عدد الصفوف ليس قاعدة schema. inStockOnly بدون فرع للسوبر يرفض400؛لا تستخدم أرقام الاختبار كتوقعات ثابتة في UI/tests.
