# Al Shihab Local API

NestJS + MySQL backend للتجربة المحلية قبل الاتصال بسيرفر الفريق.

## التشغيل مع XAMPP

```bash
cd backend
copy .env.example .env
npm install
npm run migration:run
npm run start:dev
```

تأكد من تشغيل MySQL قبل `npm run migration:run` و `npm run start:dev`.

### التشغيل السريع الموصى به للعرض

افتح Terminal من جذر المشروع وشغّل قاعدة المشروع المعزولة:

```powershell
C:\xampp\mysql\bin\mysqld.exe --defaults-file=backend\.mysql-data\my.ini --standalone
```

افتح Terminal ثانية وشغّل السيرفر:

```powershell
cd backend
copy .env.example .env
npm install
npm run migration:run
npm run start:dev
```

افتح Terminal ثالثة وشغّل Flutter على Android emulator:

```powershell
flutter run ^
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 ^
  --dart-define=API_APP_KEY=local-app-key ^
  --dart-define=API_APP_SECRET=local-app-secret
```

روابط التحقق السريع:

- API: `http://localhost:3000/api/v1/shop/products`
- Swagger: `http://localhost:3000/docs`
- Admin: `http://localhost:3000/admin/`
- Admin key: `local-admin-key`

> ملاحظة مهمة: إذا كانت قاعدة XAMPP على `3306` لا تعمل أو تظهر أخطاء InnoDB، يمكن استخدام قاعدة معزولة للمشروع على `3307` داخل `backend/.mysql-data` بدون لمس بيانات XAMPP الأصلية.

روابط مهمة:

- API: `http://localhost:3000/api/v1`
- Swagger: `http://localhost:3000/docs`
- phpMyAdmin: `http://localhost/phpmyadmin`

أنشئ قاعدة البيانات من phpMyAdmin أو عبر الطرفية:

```sql
CREATE DATABASE IF NOT EXISTS al_shihab_local
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

إعدادات قاعدة التطوير الحالية في `.env`:

```text
DB_HOST=127.0.0.1
DB_PORT=3307
DB_USERNAME=root
DB_PASSWORD=
DB_DATABASE=al_shihab_local
CORS_ORIGINS=http://localhost:3000,http://localhost:8080
APP_KEY=local-app-key
APP_SECRET=local-app-secret
ADMIN_KEY=local-admin-key
JWT_SECRET=change-this-local-secret-before-sharing
JWT_REFRESH_SECRET=change-this-refresh-secret-before-sharing
JWT_ACCESS_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=30d
```

لتشغيل قاعدة المشروع المعزولة يدوياً:

```powershell
C:\xampp\mysql\bin\mysqld.exe --defaults-file=backend\.mysql-data\my.ini --standalone
```

إذا أردت فتح نفس قاعدة المشروع من phpMyAdmin، اجعل إعداد phpMyAdmin يستخدم المنفذ `3307`:

```php
$cfg['Servers'][$i]['host'] = '127.0.0.1';
$cfg['Servers'][$i]['port'] = '3307';
```

## لوحة التحكم

بعد تشغيل السيرفر افتح:

```text
http://localhost:3000/admin/
```

مفتاح الإدارة المحلي:

```text
local-admin-key
```

اللوحة تدير الإعلانات والعروض عبر مسارات إدارية محمية:

- `GET /api/v1/admin/adverts`
- `POST /api/v1/admin/adverts`
- `PATCH /api/v1/admin/adverts/{id}`
- `DELETE /api/v1/admin/adverts/{id}`
- `GET /api/v1/admin/users`
- `PATCH /api/v1/admin/users/{id}`
- `DELETE /api/v1/admin/users/{id}`

الهيدر المطلوب لهذه المسارات:

```text
X-Admin-Key: local-admin-key
```

تطبيق Flutter يعرض قسم `عروض حصرية` من جدول `adverts` عبر:

```text
GET /api/v1/advert/madverts
```

لذلك أي إعلان نشط بتاريخ صالح في MySQL سيظهر في الصفحة الرئيسية بدون الاعتماد على بيانات وهمية.

وتقرأ الصفحة الرئيسية والتصنيفات بيانات المتجر من MySQL عبر:

```text
GET /api/v1/shop/products
GET /api/v1/blog/categories
```

### خيار Docker

إذا توفر Docker لاحقاً يمكن تشغيل MySQL المعزول:

```bash
docker compose up -d
```
flutter run ^
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 ^
  --dart-define=API_APP_KEY=local-app-key ^
  --dart-define=API_APP_SECRET=local-app-secret

وفي هذه الحالة غيّر `.env` إلى:

```text
DB_USERNAME=al_shihab
DB_PASSWORD=al_shihab_password
```

## الهيدرات

مسارات الإعلانات العامة مثل `GET /api/v1/advert/madverts` يمكن فتحها مباشرة من المتصفح بدون هيدرات.

لبقية الطلبات الحساسة مثل التسجيل، الدخول، بيانات المستخدم، والتحقق، أرسل هذه الهيدرات:

```text
Content-Type: application/json
X-Channel-Id: android
X-API-APP-KEY: local-app-key
X-API-APP-SECRET: local-app-secret
Authorization: Bearer <token>
```

## تجربة سيناريو المصادقة

السيناريو المقصود للتسجيل الآمن:

1. المستخدم يضغط `إنشاء حساب` من تطبيق Flutter.
2. `POST /api/v1/auth/register` ينشئ المستخدم فقط ولا يرجع `access_token` أو `refresh_token`.
3. التطبيق ينتقل تلقائياً إلى شاشة التحقق ويرسل كود عبر `POST /api/v1/auth/verify/send`.
4. في بيئة التطوير فقط يرجع السيرفر `dev_code` لتسهيل العرض، ويظهر في التطبيق لمدة دقيقة.
5. عند إدخال الكود الصحيح، `POST /api/v1/auth/verify/check` يفعّل الحساب ويرجع جلسة الدخول.
6. إذا فشل التحقق أو أُرسلت بيانات غير صحيحة، لا يتم تسجيل الدخول ولا تُحفظ أي جلسة.
7. `POST /api/v1/auth/login` يرفض الحساب غير الموثق برسالة واضحة.

اختبار سريع من PowerShell:

```powershell
$headers = @{
  "X-Channel-Id" = "android"
  "X-API-APP-KEY" = "local-app-key"
  "X-API-APP-SECRET" = "local-app-secret"
}

$phone = "+967777123456"
$password = "Strong123"

Invoke-RestMethod -Method Post `
  -Uri http://localhost:3000/api/v1/auth/register `
  -ContentType "application/json" `
  -Headers $headers `
  -Body (@{
    name = "Demo User"
    phone = $phone
    password = $password
    password_confirmation = $password
  } | ConvertTo-Json)

$send = Invoke-RestMethod -Method Post `
  -Uri http://localhost:3000/api/v1/auth/verify/send `
  -ContentType "application/json" `
  -Headers $headers `
  -Body (@{ phone = $phone; channel = "sms" } | ConvertTo-Json)

$code = $send.data.dev_code

Invoke-RestMethod -Method Post `
  -Uri http://localhost:3000/api/v1/auth/verify/check `
  -ContentType "application/json" `
  -Headers $headers `
  -Body (@{ phone = $phone; channel = "sms"; code = $code; otp = $code } | ConvertTo-Json)
```

## المسارات الجاهزة

- `GET /api/v1/blog/categories`
- `GET /api/v1/blog/categories/{id}`
- `GET /api/v1/location/address/options`
- `GET /api/v1/shop/products`
- `GET /api/v1/shop/products/{id}`
- `GET /api/v1/tags/categories`
- `GET /api/v1/tags/categories/{id}`
- `GET /api/v1/shop/carts`
- `POST /api/v1/shop/carts/add`
- `DELETE /api/v1/shop/carts/delete/{rowId}`
- `DELETE /api/v1/shop/carts/destroy`
- `POST /api/v1/shop/carts/updateqty/{rowId}`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/auth/logout`
- `POST /api/v1/auth/verify/send`
- `POST /api/v1/auth/verify/check`
- `GET /api/v1/me`
- `PUT /api/v1/me`
- `POST /api/v1/me/avatar`
- `DELETE /api/v1/me/avatar`
- `GET /api/v1/user/profile`
- `GET /api/v1/me/preferences`
- `PUT /api/v1/me/preferences`
- `GET /api/v1/advert/madverts`
- `GET /api/v1/advert/madverts/{id}`

## ملاحظات أمان

- كلمات المرور تحفظ باستخدام `bcrypt`.
- يستخدم تسجيل الدخول `access_token` قصير العمر مع `refresh_token` آمن مخزن كـ hash داخل جدول `user_sessions`.
- يتم تدوير `refresh_token` عند `POST /api/v1/auth/refresh`، وتُبطل الجلسة عند تسجيل الخروج.
- مسارات المصادقة والتحقق عليها rate limiting لحماية محاولات الدخول والـ OTP.
- في الإنتاج لا يتم فتح Swagger، ويجب تحديد `CORS_ORIGINS` بقائمة مصادر موثوقة فقط.
- شغّل `npm run migration:run` بعد تحديثات قاعدة البيانات. لا تعتمد على `DB_SYNCHRONIZE=true` خارج التجارب السريعة.
- في بيئة التطوير فقط، `auth/verify/send` يرجع `dev_code` لتسهيل الاختبار.
- غيّر `JWT_SECRET`, `JWT_REFRESH_SECRET`, `APP_KEY`, `APP_SECRET`, و`ADMIN_KEY` قبل مشاركة السيرفر مع أي شخص.

## ربط Flutter محلياً

Android emulator يستخدم `10.0.2.2` بدل `localhost`:

```bash
flutter run ^
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 ^
  --dart-define=API_APP_KEY=local-app-key ^
  --dart-define=API_APP_SECRET=local-app-secret
```

على Windows/Desktop:

```bash
flutter run ^
  --dart-define=API_BASE_URL=http://localhost:3000/api/v1 ^
  --dart-define=API_APP_KEY=local-app-key ^
  --dart-define=API_APP_SECRET=local-app-secret
```
