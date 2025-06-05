# 💇‍♀️ SalonBook - Hair Salon Booking App

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white" alt="Firebase" />
  <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white" alt="Material Design" />
  <img src="https://img.shields.io/badge/License-GPLv3-blue.svg?style=for-the-badge" alt="GPLv3 License" />
</div>

<div align="center">
  <h3>✨ A comprehensive salon management system with dual interfaces for admins and clients ✨</h3>
  <p>Book appointments • Shop products • Manage salon operations</p>
</div>

---

## 🌟 Features

### 👥 **Dual Interface System**
- **Client App**: Beautiful mobile experience for customers
- **Admin Dashboard**: Comprehensive management interface for salon owners

### 📅 **Smart Appointment System**
- Gender-specific service filtering
- Real-time availability checking
- 3-month advance booking with automated time slot generation
- Appointment status tracking (Pending → Confirmed → Completed)
- Smart cancellation with automatic slot liberation

### 🛍️ **E-commerce Store**
- Product catalog with categories and search
- Shopping cart with quantity management
- Secure checkout process with address management
- Order tracking and management
- Featured products and promotional sections

### 🔐 **User Management**
- Firebase Authentication with role-based access
- Profile management with gender-specific services
- Admin/Client role separation
- Comprehensive error handling

### ⚡ **Advanced Features**
- Adaptive dark/light theming
- Real-time data synchronization
- Smart time slot management
- Professional Material Design UI
- Offline-ready architecture

---

## 📱 Screenshots

<div align="center">
  <table>
    <tr>
      <td align="center"><strong>Client Home</strong></td>
      <td align="center"><strong>Booking Flow</strong></td>
      <td align="center"><strong>Admin Dashboard</strong></td>
    </tr>
    <tr>
      <td><img src="screenshots/client_home.png" width="250" alt="Client Home"/></td>
      <td><img src="screenshots/booking_flow.png" width="250" alt="Booking Flow"/></td>
      <td><img src="screenshots/admin_dashboard.png" width="250" alt="Admin Dashboard"/></td>
    </tr>
  </table>
</div>

---

## 🏗️ Tech Stack

| Category | Technology                          |
|----------|-------------------------------------|
| **Framework** | Flutter 3.32.x                      |
| **Language** | Dart                                |
| **Backend** | Firebase (Firestore, Auth, Storage) |
| **State Management** | Provider                            |
| **UI/UX** | Material Design 3                   |
| **Database** | Cloud Firestore                     |
| **Authentication** | Firebase Auth                       |
| **Theming** | Adaptive Theme                      |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.23.0)
- Dart SDK (>=3.8.0)
- Firebase project setup
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/salonbook.git
   cd salonbook
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project
   - Enable Authentication and Firestore
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in respective platform directories

4. **Configure Firebase**
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

---

## 🏢 Project Structure

```
lib/
├── models/              # Data models
│   ├── appointment.dart
│   ├── service.dart
│   ├── product.dart
│   └── model.dart       # Main state management
├── pages/
│   ├── admin/          # Admin dashboard screens
│   ├── auth/           # Authentication screens
│   └── client/         # Client app screens
├── resources/          # Utilities and validators
└── widgets/           # Reusable UI components
```

---

## 🔧 Configuration

### Default Admin Account
Create an admin user by setting `role: "admin"` in Firestore users collection.

### Salon Configuration
Update salon information in Firestore:
```json
{
  "name": "Your Salon Name",
  "address": "123 Main St",
  "phone": "+1-234-567-8900",
  "openHours": {
    "monday": {"open": "09:00", "close": "18:00"},
    "tuesday": {"open": "09:00", "close": "18:00"}
  }
}
```

---

## 📈 Key Features Walkthrough

### For Salon Owners (Admin)
1. **Dashboard Analytics** - Revenue, appointments, and store metrics
2. **Appointment Management** - Calendar view with status controls
3. **Service Management** - Add/edit services with pricing and duration
4. **Product Catalog** - Full e-commerce management
5. **Time Slot Generation** - Automated 3-month availability creation

### For Customers (Client)
1. **Service Booking** - Gender-filtered services with real-time availability
2. **Product Shopping** - Browse, search, and purchase salon products
3. **Order Tracking** - Complete order lifecycle management
4. **Profile Management** - Personal information and preferences

---

## 🎨 Customization

### Theming
The app supports adaptive theming. Modify colors in `main.dart`:

```dart
primaryColor: Colors.deepPurple,  // Your brand color
hintColor: Colors.amber,          // Accent color
```

### Business Rules
Adjust salon operations in `model.dart`:
- Operating hours and days
- Appointment duration slots
- Booking advance limit
- Cancellation policies

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'salonbook: Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Note:** By contributing to this project, you agree that your contributions will be licensed under the same GPLv3 license that covers this project.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0** - see the [LICENSE.md](LICENSE.md) file for details.

### What this means:
- ✅ **Free to use** - You can use this software for any purpose
- ✅ **Free to modify** - You can change the code to suit your needs
- ✅ **Free to distribute** - You can share the original or modified versions
- ❗ **Copyleft** - If you distribute modified versions, you must also make your source code available under GPLv3
- ❗ **No warranty** - The software is provided "as is" without any guarantees

### Commercial Use
This software can be used commercially, but any derivative works must also be released under GPLv3. If you need a different license for commercial use, please contact the author.

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend infrastructure
- Material Design for UI guidelines
- Contributors and the Flutter community

---

<div align="center">
  <p>Made with ❤️ and ☕ by <a href="https://github.com/BuhoObservador">Jose Mateo Romero</a> • <a href="mailto:otema28@gmail.com">otema28@gmail.com</a></p>
  <p>⭐ Star this repo if you find it helpful!</p>

  <br>

  <p><strong>📜 Licensed under GPLv3 - Free and Open Source Software</strong></p>
</div>