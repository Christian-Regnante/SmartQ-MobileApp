# SmartQ Rwanda

SmartQ Rwanda is a real-time queue management system built with **Flutter**, **Clean Architecture**, **BLoC 8+**, and **Firebase** (Auth + Cloud Firestore).

It streamlines queues across institutions in Rwanda (hospitals, banks, government services, and more), with role-based workflows for **Super Admins**, **Organization Admins**, **Staff**, and **Clients**.

---

## Key Features & Roles

```
                     ┌───────────────────────────────────────────────┐
                     │              SMARTQ RWANDA SYSTEM             │
                     └───────────────────────┬───────────────────────┘
                                             │
      ┌──────────────────┬───────────────────┼───────────────────┬──────────────────┐
      ▼                  ▼                   ▼                   ▼                  ▼
┌──────────────┐  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│ SUPER ADMIN  │  │  ORG ADMIN   │   │    STAFF     │   │    CLIENT    │   │ NOTIFICATIONS│
│ - Org CRUD   │  │ - Services   │   │ - Serving Box│   │ - Join Queue │   │ - Unread     │
│ - Admins     │  │ - Staff      │   │ - Call/Skip  │   │ - Live Ticket│   │   badge      │
│ - Live stats │  │ - Analytics  │   │ - Cancel     │   │ - Profile    │   │ - Mark read  │
│ - Dark/Light │  │ - Dark/Light │   │ - Dark/Light │   │ - Google/Email│  │ - Real-time  │
└──────────────┘  └──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
```

### Super Admin
- Register and manage institutions (name, location, email, **sector**, active/inactive).
- Provision Organization Admins and assign them to institutions.
- Live **Overview** stats driven by active organizations and today's tickets.
- **National Analytics**: customers today, active counters (staff), average wait, platform SLA, sector distribution.
- Audit logs and profile settings (including dark mode).

### Organization Admin
- Create and manage **service desks** (name, counter, average wait time).
- Provision and assign **staff** to service desks.
- Form validation on create/edit with clear required-field messages.

### Staff Service Desk
- Live currently-serving box and waiting queue.
- Call next / call specific ticket, complete, skip, or cancel.
- Counter **OPEN / CLOSED** toggle.
- Single-serving protection while a customer is being served.

### Client Portal
- Discover organizations and services; join a queue with contact phone.
- Live active ticket status (`WAITING` → `SERVING` → `DONE`).
- Tickets history including cancelled tickets.
- **Email/password** and **Google Sign-In**.
- Required Rwanda phone (`+2507XXXXXXXX`) on register; editable later in Profile.
- Forgot password via Firebase reset email.
- In-app notifications with unread badge on **Alerts** and mark-as-read on tap.

### Theming
- Light mode and **Aetheric Depth** dark mode (persisted with `SharedPreferences`).
- Bottom navigation shells rebuild immediately on theme toggle.

---

## Architecture & Stack

```
lib/
├── core/
│   ├── constants/          # Firebase & route constants
│   ├── errors/             # Failures / exceptions
│   ├── router/             # go_router configuration
│   ├── services/           # DI, provisioning, admin init
│   ├── theme/              # AppColors, ThemeCubit, typography
│   ├── utils/              # FormValidators, PhoneValidators
│   └── widgets/            # Neumorphic UI + state widgets
├── features/
│   ├── auth/               # Login, register, Google, password reset
│   ├── client/             # Home, orgs, services, join, active ticket
│   ├── notifications/      # Streams, unread count, mark read
│   ├── organization_admin/ # Services, staff, analytics
│   ├── organizations/      # Org entities / repositories
│   ├── profile/            # Profile & settings (all roles)
│   ├── services/           # Service desks domain
│   ├── staff/              # Staff dashboard & queue BLoC
│   ├── super_admin/        # Orgs, admins, analytics, logs
│   └── tickets/            # Tickets & cancelled tickets
└── shared/                 # UserRole, TicketStatus enums
```

### Tech stack
| Layer | Choice |
|---|---|
| Framework | Flutter (SDK ^3.12) |
| State | `flutter_bloc` ^8.1 |
| DI | `get_it` ^7.6 |
| Routing | `go_router` ^13.2 |
| Backend | Firebase Auth, Cloud Firestore |
| Social auth | `google_sign_in` |
| Preferences | `shared_preferences` (theme) |
| UI | Neumorphic design + Google Fonts |

---

## Firestore Schema (summary)

```
smartq-rwanda
├── /users/{userId}
│   ├── fullName, email, phoneNumber, role
│   ├── organizationId, serviceId / serviceIds[], isActive, photoUrl
│
├── /organizations/{orgId}
│   ├── name, description, location, address, email, phoneNumber
│   ├── sector ("Healthcare" | "Banking & Financial" | "Government e-Services" | "Other")
│   ├── isActive, adminId, createdAt
│
├── /services/{serviceId}
│   ├── name, description, organizationId, counterNumber
│   ├── averageServiceTimeMinutes, isActive, currentQueueCount, ...
│
├── /tickets/{ticketId}
│   ├── ticketNumber, userId, organizationId, serviceId, phoneNumber
│   ├── status ("waiting" | "serving" | "done" | "skipped" | "cancelled")
│   ├── position, estimatedWaitMinutes, counterNumber
│   ├── createdAt, calledAt, completedAt
│
├── /cancelledTickets/{id}     # Snapshot archive on cancel
├── /notifications/{id}
│   ├── userId, ticketId, type, title, message, isRead, createdAt
└── /admin_logs/{id}           # Super-admin audit trail
```

Security rules live in `firestore.rules` (authenticated read/write for app collections). Deploy with Firebase CLI or paste into the Firebase Console.

---

## Getting Started

### Prerequisites
- Flutter SDK **3.12+**
- Firebase project (**smartq-rwanda** or your own)
- Chrome (web) and/or Android Studio (Android)

### 1. Clone & install
```bash
git clone https://github.com/Christian-Regnante/SmartQ-MobileApp.git
cd SmartQ-MobileApp
flutter pub get
```

### 2. Firebase config
Ensure these files match your Firebase project:
- `android/app/google-services.json`
- `lib/firebase_options.dart`

**Android Google Sign-In:** add your machine’s **debug SHA-1** (and release SHA-1 when shipping) to the Firebase Android app, then re-download `google-services.json` if needed.

```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Auth:** enable **Email/Password** and **Google** in Firebase Authentication. Confirm the **Password reset** email template is enabled.

### 3. Analyze & run
```bash
flutter analyze
flutter run -d chrome      # web
flutter run -d android     # device / emulator
```

### 4. Tests
```bash
flutter test
```

---

## Notable Product Rules
- Client registration requires a Rwanda mobile number: **`+2507XXXXXXXX`**.
- Google users can add/edit phone from **Profile**.
- Inactive organizations show as **INACTIVE** on Overview; Overview stats count **active** orgs/admins.
- CRUD dialogs for orgs, admins, staff, and services validate required fields before saving.

---

## License
Distributed under the **MIT License** (see repository license terms if present).
