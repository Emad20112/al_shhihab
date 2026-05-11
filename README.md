
# ✨ ElectroGlass | Futuristic Flutter E-Commerce UI

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State-Riverpod-purple?style=for-the-badge)





A high-fidelity **Electronics Store Application** focused on delivering a premium user experience through **Glassmorphism** design principles. The app features advanced micro-interactions, 3D animations, and a fully adaptive UI that switches seamlessly between "Frosted Ice" (Light Mode) and "Smoked Glass" (Dark Mode).

> **Arabic & English Support:** This project fully supports RTL (Arabic) and LTR (English) layouts.

---

## تشغيل وتجربة النظام محلياً

### 1. تشغيل قاعدة البيانات

المشروع يستخدم MySQL محلياً على المنفذ `3307` داخل مجلد `backend/.mysql-data` حتى لا يلمس قاعدة XAMPP الافتراضية.

```powershell
C:\xampp\mysql\bin\mysqld.exe --defaults-file=backend\.mysql-data\my.ini --standalone
```

للتحقق أن قاعدة البيانات تعمل:

```powershell
C:\xampp\mysql\bin\mysqladmin.exe --protocol=tcp -h 127.0.0.1 -P 3307 -u root ping
```

### 2. تشغيل Backend

```powershell
cd backend
copy .env.example .env
npm install
npm run migration:run
npm run start:dev
```

بعد التشغيل:

- API: `http://localhost:3000/api/v1`
- Swagger: `http://localhost:3000/docs`
- Admin: `http://localhost:3000/admin/`
- Admin key: `local-admin-key`

### 3. تشغيل Flutter على Android Emulator

```powershell
flutter run ^
  --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 ^
  --dart-define=API_APP_KEY=local-app-key ^
  --dart-define=API_APP_SECRET=local-app-secret
```

على Windows/Desktop استخدم `localhost` بدل `10.0.2.2`.

### 4. تجربة المصادقة

1. افتح شاشة تسجيل الدخول.
2. اختر `إنشاء حساب`.
3. أدخل الاسم، رقم الهاتف، وكلمة مرور قوية.
4. اضغط `إنشاء حساب`.
5. التطبيق ينقلك تلقائياً إلى شاشة التحقق ويرسل كود تجريبي.
6. في وضع التطوير يظهر `dev_code` لمدة دقيقة في الرسالة.
7. أدخل الكود واضغط `تأكيد التحقق`.
8. بعد نجاح التحقق فقط يتم تسجيل الدخول وحفظ الجلسة.

مهم: إنشاء الحساب وحده لا يرجع توكن ولا يسجل دخول. الحساب غير الموثق لا يستطيع تسجيل الدخول.

---

## 📱 Visual Concept (The Design System)

The UI is built around a custom **Glass Engine** that adapts to the theme:

| Feature          | ☀️ Light Mode (Frosted Ice)       | 🌙 Dark Mode (Smoked Glass)              |
| :--------------- | :-------------------------------- | :--------------------------------------- |
| **Ambience**     | Soft, airy, pastel gradients      | Deep, mysterious, neon accents           |
| **Glass**        | High blur, white with low opacity | Dark void, smoked edges, glowing borders |
| **Interactions** | Bold primary colors               | Neon glows (Cyan/Magenta)                |

---

## 📸 Screenshots

| ![Screenshot 546](assets/screenshot/Screenshot%20%28546%29.png) | ![Screenshot 547](assets/screenshot/Screenshot%20%28547%29.png) |
| :--------------------------------------------------------------: | :--------------------------------------------------------------: |
| ![Screenshot 552](assets/screenshot/Screenshot%20%28552%29.png) | ![Screenshot 554](assets/screenshot/Screenshot%20%28554%29.png) |
| ![Screenshot 556](assets/screenshot/Screenshot%20%28556%29.png) | ![Screenshot 557](assets/screenshot/Screenshot%20%28557%29.png) |
| ![Screenshot 563](assets/screenshot/Screenshot%20%28563%29.png) | ![Screenshot 564](assets/screenshot/Screenshot%20%28564%29.png) |
| ![Screenshot 565](assets/screenshot/Screenshot%20%28565%29.png) |                                                                |

---

## 🚀 Key Features

- **🎨 Advanced Glassmorphism:** A custom `GlassContainer` widget that handles blur, saturation, and gradient borders automatically.
- **🌗 Dynamic Theming:** Instant toggle between Dark and Light modes using Riverpod.
- **🎢 Animations:**
  - **3D Pop-out Effect:** Products visually break the boundaries of their cards.
  - **Micro-interactions:** Glowing buttons, staggered list entries, and smooth page transitions.
  - **Animated Backgrounds:** Floating orbs that change color based on the theme.
- **🌍 Localization:** Full support for Arabic and English using `easy_localization`.
- **📱 Responsive:** Pixel-perfect layout on all screen sizes using `flutter_screenutil`.

---

## 🛠 Tech Stack

- **Framework:** Flutter & Dart
- **State Management:** [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Architecture:** Feature-based Clean Architecture (Core, Data, Domain, Presentation)
- **Animations:** [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Responsiveness:** [flutter_screenutil](https://pub.dev/packages/flutter_screenutil)
- **Localization:** [easy_localization](https://pub.dev/packages/easy_localization)
- **Fonts:** Google Fonts (Cairo for Arabic, Poppins for English)

---

## 📂 Project Structure

```bash
lib/
├── core/                  # Core logic, constants, and themes
│   ├── theme/             # Glassmorphism theme config
│   └── constants/         # Colors, Dimensions, Assets
├── widgets/               # Reusable UI components
│   ├── glass_container.dart  # The core visual engine
│   ├── glass_app_bar.dart
│   └── ...
├── features/              # Feature-based folders
│   ├── home/              # Home screen & logic
│   └── products/          # Product details & logic
├── data/                  # Dummy data & models
└── main.dart              # Entry point
```
