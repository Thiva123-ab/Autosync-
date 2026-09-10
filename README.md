# AutoSync 🚘

**AutoSync** is a modern, premium mobile application designed to streamline vehicle service management. It provides a seamless interface for customers to book and track services, while offering powerful, role-based dashboards for dealership staff (Mechanics, Service Advisors, and Admins) to manage workflows efficiently.

---

## 🌟 Key Features

### 👥 Role-Based Portals
AutoSync automatically routes users to their dedicated workspaces based on their assigned role:
- **Customer Portal**: Book new services, track vehicle status, view upcoming appointments, and get AI chatbot assistance.
- **Service Advisor Portal**: Manage customer bookings, assign repair jobs to mechanics, and oversee the garage's daily operations.
- **Mechanic Dashboard**: View assigned jobs, update repair statuses (e.g., In Progress, Completed), and log notes on specific vehicles.
- **Admin Dashboard**: Oversee system analytics, manage staff members, and control broad operations.

### 🎨 Premium UI/UX Design
The app features a state-of-the-art **Dark Mode Glassmorphism** design. 
- Fluid vehicle background imagery.
- Frosted glass cards with soft shadows and gradients.
- Smooth micro-animations powered by `flutter_animate` for a highly responsive feel.

### 🔐 Built-in Test Accounts
AutoSync includes a smart testing feature for developers. If you try to log into the Staff Portal using specific test emails, the app will auto-generate the accounts and assign the correct roles in Firestore automatically.
- **Admin:** `admin@autosync.com`
- **Advisor:** `advisor@autosync.com`
- **Mechanic:** `mechanic@autosync.com`
*(Default test password: `Password123!`)*

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend & Database**: [Firebase](https://firebase.google.com/) (Authentication & Cloud Firestore)
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Animations**: [Flutter Animate](https://pub.dev/packages/flutter_animate)

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- An IDE such as VS Code or Android Studio.
- Firebase project setup with Firestore and Authentication enabled.

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/autosync.git
   cd autosync
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Configuration**
   This project uses `flutterfire_cli`. Ensure you configure your project with your own Firebase details.
   ```bash
   flutterfire configure
   ```

4. **Run the App**
   ```bash
   flutter run
   ```

---

## 📁 Project Structure

```text
lib/
├── core/                   # Core configurations, constants, models, and routing
│   ├── constants/          # AppRoles, Colors, etc.
│   ├── models/             # Data models (e.g., JobModel)
│   └── routing/            # GoRouter implementation (app_router.dart)
├── features/               # Feature-based architecture
│   ├── auth/               # Customer and Staff login pages & providers
│   ├── customer/           # Customer home, booking, and vehicle management
│   ├── dashboard/          # Staff dashboards (admin, advisor, mechanic)
│   └── chatbot/            # Customer AI assistance
└── main.dart               # App entry point
```

---

## 🤝 Contributing
Contributions, issues, and feature requests are welcome! Feel free to check the issues page if you want to contribute.

## 📝 License
This project is licensed under the MIT License.