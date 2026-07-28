# SmartQ Rwanda 🚀

SmartQ Rwanda is an enterprise-grade, real-time Queue Management System built with **Flutter**, **Clean Architecture**, **BLoC 8+**, and **Firebase Cloud Firestore**. 

The application streamlines queue management across institutions (such as hospitals, banks, public utilities, and service centers) in Rwanda, providing role-based workflows for **Super Admins**, **Organization Admins**, **Staff Service Desks**, and **Clients**.

---

## 🌟 Key Features & Role Matrix

```
                     ┌───────────────────────────────────────────────┐
                     │              SMARTQ RWANDA SYSTEM             │
                     └───────────────────────┬───────────────────────┘
                                             │
      ┌──────────────────┬───────────────────┼───────────────────┬──────────────────┐
      ▼                  ▼                   ▼                   ▼                  ▼
┌──────────────┐  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ SUPER ADMIN  │  │  ORG ADMIN   │   │    STAFF     │   │    CLIENT    │   │ NOTIFICATIONS│
│ - Org Setup  │  │ - Service    │   │ - Serving Box│   │ - Join Queue │   │ - Real-Time  │
│ - Admin Assign  │ Desks        │   │ - Single Call│   │ - Live Status│   │ Alerts       │
│ - Analytics  │  │ - Staff Desk │   │ - Skip/Cancel│   │ - Cancelled  │   │ - Status     │
└──────────────┘  └──────────────┘   └──────────────┘   │ Tab          │   │ Changes      │
                                                        └──────────────┘   └──────────────┘
```

### 1. 🛡️ Super Admin Management
- **Organization Provisioning**: Create and manage institutions (e.g., King Faisal Hospital, Bank of Kigali).
- **Admin Assignment**: Assign Organization Admins to manage institution-specific service desks.
- **Global Overview**: System-wide analytics and user monitoring.

### 2. 🏢 Organization Admin
- **Service Desk Setup**: Configure service categories (e.g., Dental, Consultation, Teller, Customer Support), prefix codes, and average service durations.
- **Staff Assignment**: Map service desks to assigned staff members.

### 3. 👨‍💼 Staff Service Desk Dashboard
- **Real-Time Currently Serving Box**: Displays live ticket number (`#A015`), organization name, service desk name, and active status.
- **Dynamic Main Action Button**: Automatically toggles between `[ Call Next Customer 🔔 ]` (when idle) and `[ Complete Service ]` (when serving).
- **Single Serving Ticket Protection**: Enforces atomic single-customer serving per staff member. Disables waiting list call buttons while serving a customer and shows warning guidance.
- **Manual Ticket Selection**: Call specific waiting customers directly from card-level `[ Call ]` buttons.
- **Skip Ticket Workflow**: Moves a non-responsive customer back to the **END** of the waiting line by updating creation and skip timestamps.
- **Cancel Ticket Workflow**: Presents a confirmation modal and archives a snapshot document to `/cancelledTickets` without deleting historical audit logs.
- **Counter Toggle**: Easily switch desk status between `OPEN` and `CLOSED`.

### 4. 📱 Client Portal
- **Organization & Service Discovery**: Search and select institutions and specific service desks.
- **Queue Registration**: Join queue with estimated wait time calculation.
- **Live Active Ticket Screen**: Real-time status updates (`WAITING` → `BEING SERVED` → `COMPLETED`).
- **Dedicated Cancelled Tickets Tab**: Streams historical cancelled tickets directly from `/cancelledTickets` displaying Organization, Service, Ticket Number, Cancelled Date, and Reason.
- **In-App Notifications**: Receive real-time alerts when a ticket is called, completed, skipped, or cancelled.

---

## 🏗️ Architecture & Technology Stack

SmartQ Rwanda adheres strictly to **Clean Architecture** principles and **BLoC 8+** state management:

```
lib/
├── core/                   # Shared theme, constants, widgets, errors, router
│   ├── constants/          # FirebaseConstants, RouteConstants
│   ├── errors/             # Failures and ServerExceptions
│   ├── theme/              # AppColors, Neumorphic themes
│   └── widgets/            # State widgets, Neumorphic buttons/cards
├── features/               # Feature modules
│   ├── auth/               # Firebase Authentication & User State
│   ├── client/             # Client Home, Join Queue, Active Ticket UI
│   ├── notifications/      # Live Firestore Notification Stream
│   ├── organization_admin/ # Org Admin Desks & Analytics
│   ├── staff/              # Staff Dashboard, Queue BLoC, Call/Skip/Cancel
│   ├── super_admin/        # Super Admin Organizations & User Setup
│   └── tickets/            # QueueTicket & CancelledTicket Models, BLoC, Repos
└── shared/                 # Shared Enums (TicketStatus, UserRole)
```

### Tech Stack Specifications
- **Framework**: [Flutter](https://flutter.dev) (SDK ^3.12)
- **Language**: [Dart](https://dart.dev)
- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (^8.1.3)
- **Dependency Injection**: [get_it](https://pub.dev/packages/get_it) (^7.6.0)
- **Routing**: [go_router](https://pub.dev/packages/go_router) (^13.2.0)
- **Backend Services**: Firebase Authentication, Cloud Firestore
- **Design System**: Neumorphic & Modern HSL Tailwind/Google Fonts Styling

---

## 🗄️ Firestore Database Schema

```
smartq-rwanda (Firestore Root)
├── /users/{userId}
│   ├── fullName, email, role ("superAdmin" | "orgAdmin" | "staff" | "client")
│   ├── organizationId, serviceIds []
│
├── /organizations/{orgId}
│   ├── name, code, createdAt
│
├── /services/{serviceId}
│   ├── name, prefix ("A", "T", "D"), organizationId
│   ├── currentQueueCount, lastTicketNumber, averageServiceTimeMinutes
│
├── /tickets/{ticketId}
│   ├── ticketNumber ("A015"), userId, organizationId, serviceId
│   ├── status ("waiting" | "serving" | "done" | "cancelled")
│   ├── counterNumber, staffId, createdAt, calledAt, completedAt
│
├── /cancelledTickets/{cancelledTicketId}   [Dedicated Snapshot Collection]
│   ├── originalTicketId, clientId, organizationId, organizationName
│   ├── serviceId, serviceName, queueNumber, phoneNumber, counterNumber
│   ├── cancellationReason, cancelledBy, cancelledAt, originalStatus
│
└── /notifications/{notificationId}
    ├── userId, ticketId, type ("ticket_called" | "completed" | "cancelled" | "skipped")
    ├── title, message, isRead, createdAt
```

---

## 🔐 Firestore Security Rules

Deploy the following rules in your **Firebase Console -> Firestore Database -> Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Authenticated access to users collection
    match /users/{userId} {
      allow read, write: if request.auth != null;
    }

    // Authenticated access to organizations collection
    match /organizations/{orgId} {
      allow read, write: if request.auth != null;
    }

    // Authenticated access to services collection
    match /services/{serviceId} {
      allow read, write: if request.auth != null;
    }

    // Authenticated access to tickets collection
    match /tickets/{ticketId} {
      allow read, write: if request.auth != null;
    }

    // Authenticated access to notifications collection
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null;
    }

    // Authenticated access to cancelledTickets collection
    match /cancelledTickets/{cancelledTicketId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Getting Started & Setup

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.12.0 or higher)
- [Dart SDK](https://dart.dev/get-dart)
- Chrome Browser (for Flutter Web development) or Android Studio / Xcode (for Mobile)

### 1. Clone the Repository
```bash
git clone https://github.com/Christian-Regnante/SmartQ-MobileApp.git
cd SmartQ-MobileApp
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Static Analysis & Verification
```bash
flutter analyze
```

### 4. Launch Application

#### Flutter Web (Debug Mode):
```bash
flutter run -d chrome
```

#### Android Device / Emulator:
```bash
flutter run -d android
```

---

## 🧪 Testing & Code Quality
Run unit and bloc tests:
```bash
flutter test
```

---

## 📄 License
Distributed under the **MIT License**. See `LICENSE` for more details.
