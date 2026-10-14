# Flutter Store Integration Quick Guide

## Packages مقترحة

```yaml
dependencies:
  dio: ^5.0.0
  cookie_jar: ^4.0.0
  dio_cookie_manager: ^3.0.0
  flutter_secure_storage: ^9.0.0
  image_picker: ^1.0.0
```

> `flutter_secure_storage` يفيد لو backend تم تعديله لاحقًا لإرجاع Bearer token. مع الوضع الحالي استخدم CookieJar.

## Dio + Cookie

```dart
final dio = Dio(BaseOptions(
  baseUrl: 'http://10.0.2.2:5000/api',
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
));

final cookieJar = PersistCookieJar();
dio.interceptors.add(CookieManager(cookieJar));
```

Android Emulator يستخدم `10.0.2.2` بدل `localhost`.

## Store sequence

```text
GET /store/branches
  ↓
اختيار branchId
  ↓
GET /store/categories
GET /store/products?branchId=...
  ↓
POST /auth/register أو POST /auth/login
  ↓
POST /store/orders
  ↓
GET /store/orders/my
```

## Prescription sequence

```text
POST /prescriptions/upload-image (multipart image)
  ↓
خذ data.image
  ↓
POST /prescriptions { imageUrl, notes }
  ↓
GET /prescriptions/my
```

Status mapping:

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

Order status mapping:

```dart
const orderLabels = {
  'pending': 'قيد الانتظار',
  'processing': 'جاري التحضير',
  'completed': 'تم التجهيز',
  'delivered': 'تم التوصيل',
  'cancelled': 'ملغي',
};
```

## Image helper

لو API رجع:

```text
/uploads/prescriptions/file.jpg
```

اعمل:

```dart
String mediaUrl(String path) {
  const origin = 'http://10.0.2.2:5000';
  if (path.startsWith('http')) return path;
  return '$origin$path';
}
```
