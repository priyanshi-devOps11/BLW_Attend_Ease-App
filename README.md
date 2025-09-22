# 📲 BLW Attend Ease App

A cross-platform Flutter application designed for **BLW Employees attendance management**.  
It provides a smooth way to manage daily attendance, export reports, and handle employee data with an easy-to-use interface.

---

## 🚀 Features

- 🔐 **Authentication** – Secure login for employees/admins  
- 🏠 **Dashboard** – Quick overview of attendance data  
- 📅 **Daily Attendance** – Mark and view daily records  
- 👨‍💼 **Admin Panel** – Manage employees and attendance  
- 📤 **Export Service** – Generate and share reports  
- 🔔 **Notifications** – Stay updated with alerts/reminders  
- 🎨 **Custom UI Components** – Reusable widgets for buttons, cards, and more  

---

## 📂 Project Structure

lib/
│── main.dart # Entry point
│
├── models/ # Data models
│ ├── attendance_model.dart
│ └── user_model.dart
│
├── screens/ # UI screens
│ ├── admin_panel_screen.dart
│ ├── attendance_screen.dart
│ ├── daily_attendance_screen.dart
│ ├── dashboard_screen.dart
│ ├── home_screen.dart
│ └── login_screen.dart
│
├── services/ # Core services
│ ├── auth_service.dart
│ ├── db_helper.dart
│ ├── export_service.dart
│ └── notification_service.dart
│
├── utils/ # Helpers & constants
│ ├── app_colors.dart
│ ├── location_helper.dart
│ └── validators.dart
│
└── widgets/ # Reusable UI widgets
├── attendance_card.dart
├── custom_button.dart
├── export_buttons.dart
└── user_attendance_buttons.dart


---

## 📹 Demo Videos

- 🔗 [Demo Video 1](https://drive.google.com/your-demo1-link)  
- 🔗 [Demo Video 2](https://drive.google.com/your-demo2-link)  

*(Click the links to watch the app in action!)*

---

## 🛠️ Getting Started

### Prerequisites
- Install [Flutter](https://docs.flutter.dev/get-started/install)  
- Install Android Studio or VS Code  
- Setup an emulator or connect a real device  

### Run Locally
# Clone the repository
git clone https://github.com/priyanshi-devOps11/BLW_Attend_Ease-App.git

# Navigate to project directory
cd BLW_Attend_Ease-App

# Get dependencies
flutter pub get

# Run the app
flutter run

📦 Dependencies

Some important packages used:
provider – state management
sqflite / supabase – database
intl – date & formatting
flutter_local_notifications – notifications
(Check pubspec.yaml for full list.)


## 👩‍💻 Author

**Priyanshi Srivastava**  
🎓 BTech CSE | Application Developer  
🔗 [GitHub](https://github.com/priyanshi-devOps11)  

📜 License

This project is licensed under the MIT License.
