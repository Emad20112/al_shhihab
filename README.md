# ✨ ElectroGlass | Futuristic Flutter E-Commerce UI

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![State Management](https://img.shields.io/badge/State-Riverpod-purple?style=for-the-badge)
![Architecture](https://img.shields.io/badge/Architecture-Clean-green?style=for-the-badge)

A high-fidelity **Electronics Store Application** focused on delivering a premium user experience through **Glassmorphism** design principles. The app features advanced micro-interactions, 3D animations, and a fully adaptive UI that switches seamlessly between "Frosted Ice" (Light Mode) and "Smoked Glass" (Dark Mode).

> **Arabic & English Support:** This project fully supports RTL (Arabic) and LTR (English) layouts.

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

_(Place your screenshots here. I recommend creating a grid showing Home, Dark Mode, and Light Mode)_

|                 Home (Dark)                  |                  Home (Light)                  |                 3D Carousel                  |
| :------------------------------------------: | :--------------------------------------------: | :------------------------------------------: |
| ![Dark Home](docs/screenshots/dark_home.png) | ![Light Home](docs/screenshots/light_home.png) | ![3D Effect](docs/screenshots/3d_effect.png) |

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
