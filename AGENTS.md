# AGENTS.md — Index Pharma Store · Flutter Agent Rules

> **هذا الملف هو المرجع الإلزامي الأول لأي Agent يعمل على هذا المشروع.**  
> اقرأه بالكامل قبل كتابة أي سطر كود. لا تتجاوز أياً من هذه القواعد.

---

## 1. نظرة عامة على المشروع

| البند                           | التفاصيل                                                |
| ------------------------------- | ------------------------------------------------------- |
| **اسم المشروع**                 | `index_pharma` (Flutter Store App)                      |
| **الهدف**                       | تطبيق عميل (Customer-facing Store) لصيدلية Index Pharma |
| **Backend**                     | Node.js REST API — نسخة `main`                          |
| **Base URL (محلي)**             | `http://localhost:5000/api`                             |
| **Base URL (Android Emulator)** | `http://10.0.2.2:5000/api`                              |
| **Server Origin (للصور)**       | `http://localhost:5000` (بدون `/api`)                   |
| **نظام المصادقة**               | HttpOnly Cookie (`token`) — لا يُعاد الـ JWT داخل JSON  |
| **SDK**                         | Dart `^3.11.4`                                          |

---

## 2. الملفات المرجعية (اقرأها عند الحاجة)

| الملف                                        | الغرض                                                                  |
| -------------------------------------------- | ---------------------------------------------------------------------- |
| `REAL_API_SAMPLES_REFERENCE.md`              | عينات JSON حقيقية ومحققة من السيرفر — **المصدر الأول للنماذج والحقول** |
| `INDEX_PHARMA_API_REFERENCE.md`              | قائمة جميع الـ 108 endpoints + تفاصيل الصلاحيات                        |
| `FLUTTER_STORE_QUICK_GUIDE.md`               | أمثلة Dart جاهزة: إعداد Dio، تسلسل التدفق، mapping الحالات             |
| `Flutter_Rules.md`                           | قواعد المعمارية والأسلوب الإلزامية لصاحب المشروع                       |
| `stitch_designs/docs/DESIGN_SYSTEM.md`       | نظام التصميم (ألوان، خطوط، مسافات) — اقرأه قبل أي شاشة                 |
| `stitch_designs/docs/SCREEN_DIRECTORY.md`    | دليل الشاشات وأسماء ملفات `code/` و`images/` لكل شاشة                  |
| `stitch_designs/docs/COMPONENT_INVENTORY.md` | قائمة المكونات المشتركة في التصميم                                     |

> ترتيب الأولوية عند التعارض: **(1)** عينات الـ API الحقيقية ← **(2)** قرارات صاحب المشروع المسجلة في Notion ← **(3)** التصميم. انظر §17 لسياسة التصميم.

---

## 3. هيكل المشروع الحالي

```
lib/
  main.dart                  ← نقطة الدخول + IndexPharmaApp
  core/
    constants/      ← ثوابت المشروع (app_config)
    di/             ← GetIt (service_locator)
    errors/         ← Failure types + failure_mapper
    localization/   ← مفاتيح الترجمة (app_locale_keys)
    network/        ← ApiClient (Dio + Cookie) + ApiResult + error_mapper
    storage/        ← StorageService (SharedPreferences)
    theme/          ← الألوان والخطوط والمسافات (tokens)
    utils/          ← app_router (GoRouter) + go_router_refresh_stream
    widgets/        ← Shared widgets (badges, buttons, empty/error/loading, guards…)
  features/
    account/        ← حساب العميل وتعديل الملف
    auth/           ← تسجيل الدخول والتسجيل والجلسة
    cart/           ← السلة (محلية)
    categories/     ← التصنيفات
    checkout/       ← إتمام الطلب وتأكيده
    choose_branches/ ← اختيار الفرع
    home/           ← الصفحة الرئيسية
    language/       ← اختيار اللغة
    onboarding/     ← شاشة الترحيب
    orders/         ← طلباتي وتفاصيل الطلب
    prescriptions/  ← رفع الروشتات ومتابعتها
    products/       ← المنتجات وتفاصيل المنتج
    settings/       ← الإعدادات
    splash/         ← Splash screen
stitch_designs/     ← التصميم الرسمي (code/ images/ docs/)
test/               ← مرآة لهيكل lib/
```

> الهيكل أعلاه يعكس المشروع الفعلي بتاريخ آخر تحديث. لو أضفت feature جديدة حدّث هذا القسم.

---

## 4. الحزم المثبتة (pubspec.yaml)

```yaml
dio: ^5.11.1
cookie_jar: ^4.0.9
dio_cookie_manager: ^3.5.0
flutter_bloc: ^9.1.1
go_router: ^18.0.2
get_it: ^9.3.0
easy_localization: ^3.0.8
google_fonts: ^9.0.0
hive: ^2.2.3
hive_flutter: ^1.1.0
image_picker: ^1.2.4
mobile_scanner: ^7.4.2
shared_preferences: ^2.5.6
cached_network_image: ^4.0.4
intl: ^0.20.3
path_provider: ^2.1.6
```

> **لا تضف حزمة جديدة** إلا إذا كانت ضرورية فعلاً وغير مغطاة بالحزم الموجودة.

---

## 5. المعمارية الإلزامية

### 5.1 النمط المتبع

**Clean Architecture + Feature-First** لكل feature:

```
feature_name/
  data/
    datasources/     ← API calls (Dio)
    models/          ← DTOs مع fromJson/toJson
    repositories/    ← impl للـ repository contracts
  domain/
    entities/        ← Business objects نقية
    repositories/    ← Abstract contracts
    usecases/        ← (عند وجود منطق يستحق)
  presentation/
    cubit/           ← State management (Cubit)
    screens/         ← شاشات (المسمى المستخدم فعلياً في المشروع)
    widgets/         ← Widgets خاصة بالـ feature
```

### 5.2 ترتيب التنفيذ الإلزامي

```
Model/Entity → DataSource → Repository → UseCase → Cubit → UI
```

### 5.3 قواعد صارمة

- **UI** لا تستدعي Dio أو DataSource مباشرة.
- **Cubit** لا يستدعي Dio مباشرة — يمر عبر Repository.
- **Domain** لا تستورد Flutter packages ولا تحتوي نصوصاً للعرض (استخدم `translationKey` بدل نص عربي).
- Business logic **لا تُكتب** داخل `build()` أو event handlers.
- `setState` مسموح للحالات المحلية الصغيرة فقط (password visibility، expand).
- لا تستخدم `GetIt` داخل الـ Widgets كـ fallback: مرّر الـ Cubit عبر `BlocProvider` أو الـ constructor.
- لا تبتلع الأخطاء بـ `catch (_)` فارغ.

---

## 6. التقنيات الإلزامية

| الغرض                      | التقنية                                                |
| -------------------------- | ------------------------------------------------------ |
| State Management           | `flutter_bloc` — Cubit بشكل افتراضي                    |
| Routing                    | `go_router`                                            |
| Dependency Injection       | `get_it` — registrations في `core/di/`                 |
| HTTP / API                 | `Dio` + `CookieManager`                                |
| Session / Auth             | `cookie_jar` + `dio_cookie_manager` (PersistCookieJar) |
| Local Storage (Simple)     | `SharedPreferences`                                    |
| Local Storage (Structured) | `Hive`                                                 |
| Localization               | `easy_localization`                                    |
| Image Loading              | `cached_network_image`                                 |
| Image Picking              | `image_picker`                                         |
| Barcode Scanning           | `mobile_scanner`                                       |

---

## 7. المصادقة وإدارة الجلسة

### 7.1 كيفية عمل الـ Auth

```dart
// الإعداد الصحيح لـ Dio مع Cookie
final dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2:5000/api', // Android Emulator
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 60), // أطول لـ file upload
));

final cookieJar = PersistCookieJar();
dio.interceptors.add(CookieManager(cookieJar));
```

### 7.2 قواعد الـ Auth

- الـ JWT يُخزن في HttpOnly Cookie باسم `token` (Max-Age: سنة كاملة).
- **الـ JWT لا يعود داخل JSON أبداً** — استخدم CookieJar دائماً.
- بعد Login/Register، الكوكي تُحفظ تلقائياً ويُرسلها Dio في كل طلب.
- للحصول على `role` المستخدم: استدعِ `GET /auth/me`.
- `GET /auth/me` يرجع المستخدم في مفتاح **`data`** (وليس `user`).
- `POST /auth/login` يرجع المستخدم في مفتاح **`user`**.
- لا تسجّل (log) بيانات الدخول أو الكوكي أو التوكن أبداً.

### 7.3 أنواع المستخدمين وسياق الفرع

| الدور        | تحديد الفرع                                                        |
| ------------ | ------------------------------------------------------------------ |
| `customer`   | يرسل `branchId` في الـ query أو الـ body                           |
| `pharmacist` | يُحدد تلقائياً من `user.branchId` (الهيدر متجاهل)                  |
| `admin`      | يُحدد تلقائياً من `user.branchId` (الهيدر متجاهل)                  |
| `superadmin` | يرسل header: `X-Branch-Id: <branchId>` — بدونه يرى تجميع كل الفروع |

> موظف غير مربوط بفرع يحصل على `403` برسالة «يجب ربط المستخدم بفرع أولاً».

---

## 8. الـ APIs الجوهرية لتطبيق الاستور

### 8.1 تسلسل التدفق الرئيسي

```
GET /store/branches          → اختيار branchId (حفظه محلياً)
GET /store/categories        → التصنيفات
GET /store/products?branchId → قائمة المنتجات
POST /auth/register          → تسجيل عميل جديد
POST /auth/login             → تسجيل الدخول
POST /store/orders           → إنشاء طلب (يتطلب auth)
GET /store/orders/my         → طلباتي
```

### 8.2 تسلسل الروشتة

```
POST /prescriptions/upload-image  → رفع صورة (multipart, field: "image")
  ↓ خذ data.image من الرد
POST /prescriptions { imageUrl, notes }
GET /prescriptions/my
```

### 8.3 نقاط مهمة لكل Endpoint

#### `GET /store/products`

- `branchId` **إجباري** — بدونه يرجع `400`.
- يعرض فقط المنتجات `isAvailableOnline=true` والمتوفرة فعلياً.
- Query: `branchId`, `page`, `limit` (default 20, max 100), `keyword`, `category`.
- Pagination: `total`, `totalPages`, `page`, `limit`.

#### `POST /store/orders`

- لا ترسل `isUnit=true` أو `isSecondaryUnit=true` (علب فقط حالياً).
- السعر يُحسب من الـ Backend — لا ترسل سعراً.
- `paymentMethod` الافتراضي: `cash`.
- الحالة تبدأ: `pending`.

#### `POST /prescriptions/upload-image`

- `multipart/form-data` — field name: **`image`**.
- الحجم الأقصى: **5 MB**.
- timeout >= 60 seconds.

---

## 9. نماذج البيانات (DTOs) الأساسية

### 9.1 User (Login Response — مفتاح `user`)

```dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;        // 'customer' | 'pharmacist' | 'admin' | 'superadmin'
  final String? phone;
  final String? address;
  final Map<String, dynamic>? permissions;
  final String? branchId;
}
```

### 9.2 User (GET /auth/me — مفتاح `data`)

```dart
// نفس الحقول أعلاه + هذه الحقول الإضافية:
final bool isActive;
final int monthlyTarget;
final String createdAt;
```

### 9.3 Branch

```dart
class BranchModel {
  final String id;
  final String name;
  final String? address;
  final String? phone;
}
```

### 9.4 StoreProduct

```dart
class StoreProductModel {
  final String id;
  final String name;
  final String? scientificName;
  final String? barcode;
  final String? description;
  final String? image;           // مسار نسبي → ادمجه مع Server Origin
  final double sellingPrice;
  final int stockQuantity;
  final int looseQuantity;
  final String? expiryDate;
  final bool requiresPrescription;
  final String? unit;
  final CategoryModel? category;
  final String branchId;
}
```

### 9.5 Order Item (في طلب الإنشاء)

```dart
class OrderItemRequest {
  final String productId;
  final int quantity;
  // لا ترسل isUnit / isSecondaryUnit في طلبات الاستور
}
```

### 9.6 Prescription

```dart
class PrescriptionModel {
  final String id;
  final String prescriptionNumber;
  final String imageUrl;         // مسار نسبي
  final String? notes;
  final String status;           // pending|reviewed|quoted|preparing|ready|completed|rejected
  final String? pharmacistNotes;
  final double? quotedPrice;
  final String? rejectionReason;
  final String createdAt;
}
```

---

## 10. Pagination — فروقات مهمة

> **تحذير:** الـ Pagination غير موحد في الـ API — ابنِ DTOs منفصلة.

| الـ Endpoint                  | حقول الـ Pagination                      |
| ----------------------------- | ---------------------------------------- |
| `/store/products`             | `total`, `totalPages`, `page`, `limit`   |
| `/store/orders/my`            | `total`, `totalPages`, `page`, `limit`   |
| المنتجات الداخلية `/products` | `totalCount`, `hasMore`, `page`, `limit` |
| `/orders` (داخلي)             | **لا يوجد Pagination**                   |
| `/orders/online`              | **لا يوجد Pagination**                   |
| `/prescriptions`              | **لا يوجد Pagination**                   |

---

## 11. Error Handling

### 11.1 شكل رسائل الخطأ

```dart
// الشكل الرئيسي (معظم الـ endpoints)
{ "success": false, "message": "رسالة بالعربي" }

// بعض الـ endpoints القديمة (بدون success)
{ "message": "رسالة بالعربي" }
```

> رسائل الخطأ من السيرفر دائماً **بالعربية**، لذلك:
>
> - لا تعرض `Exception.toString()` للمستخدم مباشرة.
> - لا تعرض نص السيرفر الخام في الواجهة الإنجليزية؛ حوّل الخطأ إلى Failure محدد وأظهر رسالة مترجمة من `ar.json`/`en.json`.
> - لا تستخرج أرقاماً من نص الرسالة (مثل الكمية المتاحة)؛ اعتمد على كود الـ HTTP.

### 11.2 جدول أكواد الخطأ

| الكود | الحالة                                 | الإجراء في Flutter                                               |
| ----- | -------------------------------------- | ---------------------------------------------------------------- |
| `400` | Validation / branchId ناقص / سلة فارغة | اعرض رسالة مترجمة مناسبة                                         |
| `401` | غير مسجل دخول / كوكي منتهية            | أعد التوجيه لشاشة Login (ما عدا `/auth/login` و`/auth/register`) |
| `403` | صلاحية غير كافية / حساب معطل           | اعرض رسالة مترجمة مناسبة                                         |
| `404` | مورد غير موجود / منتج غير متاح         | اعرض "غير موجود" / "المنتج غير متاح"                             |
| `409` | تعارض في المخزون / duplicate           | أعد تحميل المنتجات واعرض رسالة للمستخدم                          |
| `429` | Rate limit                             | انتظر وأعد المحاولة                                              |
| `500` | Server error                           | اعرض "خطأ في السيرفر، حاول لاحقاً" (لا تعرض رسالة السيرفر الخام) |

---

## 12. Mapping حالات الطلبات والروشتات

### 12.1 حالات الطلب (Order Status)

```dart
const orderLabels = {
  'pending':    'قيد الانتظار',
  'processing': 'جاري التحضير',
  'completed':  'تم التجهيز',
  'delivered':  'تم التوصيل',
  'cancelled':  'ملغي',
};
```

> هذه التسميات للعميل. في الكود استخدم `translationKey` من ملفات الترجمة وليس النصوص مباشرة.

**دورة الحياة:**

```
pending → processing → completed → delivered (نهائي)
pending / processing → cancelled (نهائي)
```

### 12.2 حالات الروشتة (Prescription Status)

```dart
String prescriptionLabel(String status) {
  switch (status) {
    case 'pending':
    case 'reviewed':
    case 'quoted':
      return 'قيد الانتظار';
    case 'preparing':
    case 'ready':
      return 'جاري التحضير';
    case 'completed':
      return 'تم التوصيل';
    case 'rejected':
      return 'مرفوضة';
    default:
      return status;
  }
}
```

> المثال أعلاه توضيحي للـ mapping فقط. التنفيذ الفعلي يمر عبر `translationKey` (نفس نمط `OrderStatus`).
> **لا تستخدم** `/api/prescriptions/:id/respond` — هذا endpoint Legacy ومهجور في التطبيق الجديد.

---

## 13. معالجة الصور

```dart
/// يحول المسار النسبي إلى URL كامل
String mediaUrl(String path) {
  const origin = 'http://10.0.2.2:5000'; // Android Emulator
  // const origin = 'http://localhost:5000'; // iOS Simulator / Web
  if (path.startsWith('http')) return path;
  return '$origin$path';
}
```

> الصور تكون بمسار نسبي مثل `/uploads/prescriptions/file.jpg`.  
> **لا تضف `/api`** — الصور على Server Origin مباشرة.

---

## 14. تنبيهات وفروق دقيقة حرجة

| التنبيه                    | التفاصيل                                                                                                                           |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| **`user` vs `data`**       | `login`/`register` → مفتاح `user` — `GET /auth/me` → مفتاح `data`                                                                  |
| **تكرار الكائنات**         | ردود POS تكرر البيانات في `data` و `order` — اعتمد `data` دائماً                                                                   |
| **السعر**                  | لا تُرسل السعر من Flutter — Backend يحسبه من DB                                                                                    |
| **رسوم التوصيل**           | لا يوجد `deliveryFee` في الـ API: `totalAmount` = `subtotal`. لا تعرض رسوم توصيل                                                   |
| **branchId**               | احفظه محلياً بعد اختيار الفرع وأرسله في كل طلبات المنتجات والـ checkout                                                            |
| **Cart قبل Checkout**      | أعد تحميل availability قبل إتمام الطلب                                                                                             |
| **409 Stock Conflict**     | عند `409`، أعد تحميل المنتجات واعرض رسالة للمستخدم                                                                                 |
| **تسريب `costAtSale`**     | استجابة `POST /store/orders` تعيد `costAtSale` — لا تعرضه للمستخدم                                                                 |
| **حقول التكلفة والربح**    | `purchasingPrice` و`costAtSale` و`COGS` والأرباح حساسة: لا تُعرض إلا للأدوار/الصلاحيات المؤكدة من صاحب المشروع                     |
| **Reviews**                | `GET/POST /products/:id/reviews` ترجع `404` في الـ `main` حالياً — مؤجلة                                                           |
| **منتجات منتهية الصلاحية** | الـ Backend قد يرجّع منتجاً منتهي الصلاحية في `/store/products` (مهمة D.11). لا تضف منعاً على جهة Flutter دون قرار من صاحب المشروع |

---

## 15. قواعد العمل الإلزامية للـ Agent

### 15.1 قبل الكتابة

1. **افهم** هيكل المشروع، `pubspec.yaml`، الـ routing، وإعداد الـ DI أولاً.
2. **راجع** الملفات المرجعية المذكورة في §2 لأي endpoint جديد.
3. **لا تخترع** endpoints أو حقول JSON — ارجع إلى `REAL_API_SAMPLES_REFERENCE.md`.
4. **قدّم خطة مرحلية** للفيتشرات الكبيرة وانتظر الموافقة قبل التنفيذ.

### 15.2 أثناء الكتابة

- اتبع ترتيب التنفيذ: **Model → DataSource → Repository → UseCase → Cubit → UI**.
- لا تضع business logic داخل Widgets أو Cubit مباشرة.
- أي مسار صورة نسبي → مرره عبر `mediaUrl()`.
- استخدم `const` حيثما أمكن في الـ Widgets.
- لا تكرر إعداد Dio في كل Repository — استخدم الـ instance المركزي.
- ضع كل registrations في `core/di/`.
- كل نص يراه المستخدم يأتي من `ar.json`/`en.json` عبر `easy_localization`؛ لا نصوص ثابتة في الكود. تحقق من RTL للعربي وLTR للإنجليزي.

### 15.3 تغيير الكود الموجود

- افهم الكود الموجود وسياقه قبل تعديله.
- أصغر تغيير ممكن يحقق الهدف.
- لا تعيد هيكلة ملفات غير متعلقة بالمهمة.
- لا تنفذ أوامر حذف أو reset بدون إذن صريح.

### 15.4 التقرير النهائي

وضح دائماً:

1. ما الذي تغير؟
2. أي الملفات أُنشئت أو عُدّلت؟
3. القرارات التقنية المهمة.
4. الأوامر التي نُفّذت فعلاً ونتائجها (لا تقل إن أمراً نجح إلا إذا شغّلته فعلاً).
5. ما يحتاج متابعة أو لم يُختبر.
6. **الاختلافات عن التصميم:** قائمة مختصرة بما غيّرته أو حذفته مقارنة بتصميم Stitch وسبب كل تغيير (انظر §17).

---

## 16. Checklist قبل التسليم

- [ ] المعمارية تتبع Clean Architecture + Feature-First.
- [ ] Cubit يستخدم Repository وليس DataSource مباشرة.
- [ ] لا توجد endpoints أو حقول مخترعة — كل شيء موثق في المراجع.
- [ ] Business logic خارج الـ UI.
- [ ] Loading، Success، Empty، Failure states مُعالجة.
- [ ] الصور تمر عبر `mediaUrl()`.
- [ ] `branchId` يُرسل في كل طلبات المنتجات والـ checkout.
- [ ] لا نصوص عربية ثابتة في الكود (كلها في ملفات الترجمة، والمفاتيح متطابقة في `ar.json` و`en.json`).
- [ ] لا ادعاءات تسويقية أو طبية بدون مصدر (راجع §17).
- [ ] `flutter analyze` يعمل بدون أخطاء و`flutter test` يكمل للآخر.
- [ ] لم تُضف حزمة جديدة دون ضرورة واضحة.
- [ ] الأوامر المُنفّذة موثقة ونتائجها حقيقية.
- [ ] التقرير يحتوي قائمة الاختلافات عن التصميم.

---

## 17. سياسة التصميم (قرار صاحب المشروع — 2026-10-21)

التصميم الرسمي في `stitch_designs/` **دليل وليس مواصفات**. هذه القاعدة تعلو أي عبارة في مهمة أو prompt تقول «اتبع التصميم».

### 17.1 ما يجب تنفيذه

أي عنصر أو حقل أو إجراء أو حالة **تعتمد على الـ Backend** في التصميم: البيانات المعروضة، الطلبات، التحققات، والحالات والأخطاء التي ينتجها الـ API.

### 17.2 ما يملك الـ Agent حرية تغييره

- **النصوص والعبارات:** اكتب نصاً واضحاً ومختصراً عبر ملفات الترجمة.
- **الودجتس المكررة أو الزائدة:** احذف ما لا يضيف قيمة.
- **شكل الـ UI وتجربة المستخدم:** إن لم يكن التصميم أفضل حل، نفّذ الأفضل لواجهة احترافية وتجربة سلسة، باستخدام الـ theme tokens والودجتس المشتركة (`AppPageBar` بعد مهمة 3.18).
- لا تنسخ Tailwind/CSS من ملفات HTML ولا تثبّت ألواناً؛ استخدم `core/theme`.

### 17.3 ما يظل ممنوعاً (قائمة الاستبعاد)

عناصر ظهرت في التصميم لكن لا يدعمها الـ API أو تأجلت. لا تنفذها ولا تضع بدائل وهمية لها:

- وقت التوصيل المتوقع / ETA ورسوم التوصيل و«شحن مبرد» و«فاتورة ضريبية».
- التأمين الطبي بكل أشكاله.
- جرس الإشعارات ووعود «ستتلقى إشعاراً».
- الدعم الفني / الشات.
- الدفع بالبطاقة عند الاستلام (الدفع نقداً فقط).
- المفضلة والتقييمات والعروض والخصومات والطباعة.
- كود الفرع وساعات العمل (الفرع: `id` و`name` و`address` و`phone` فقط).
- مسح الباركود للعميل (مؤجل؛ باركود الموظف ضمن مهام المرحلة 4).
- أي نص إنجليزي ظاهر في الواجهة العربية.
- **أي ادعاء بلا مصدر:** مثل «بإشراف نقابة الصيادلة» أو «مجاني 100%». لا تخترع ادعاءات تسويقية أو طبية أو قانونية؛ اسأل صاحب المشروع.

### 17.4 عند التعارض

ترتيب الأولوية: **(1)** عينات الـ API الحقيقية ← **(2)** قرارات صاحب المشروع في Notion ← **(3)** التصميم. وضّح في التقرير النهائي (§15.4 البند 6) كل اختلاف عن التصميم وسببه.

---

_آخر تحديث: 2026-10-22 — يعكس الهيكل الفعلي للمشروع وقرارات صاحب المشروع حتى هذا التاريخ._
