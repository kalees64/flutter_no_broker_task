# 🏢 NoBroker Hub — Property Management Platform

A modern, full-stack proptech management application designed for society administrators, owners, tenants, and vendors. Built with a high-performance **Flutter** mobile frontend and a secure, scalable **Express + TypeScript + PostgreSQL** backend.

---

## 🏗️ Architecture & Technology Stack

| Layer                     | Technologies                                                                                                                                                          |
| ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Mobile App (Frontend)** | Flutter 3.x, Dart, Riverpod 2.x (State Management), GoRouter (Declarative Routing), Dio (Networking & Interceptors), Flutter Dotenv, Lucide Icons, Clean Architecture |
| **Backend API**           | Node.js (ESM), Express 5.x, TypeScript, PostgreSQL (`pg`), Zod (Schema Validation), JWT (Access & Refresh tokens), bcrypt, Helmet, Rate Limiting, Swagger UI          |
| **Database**              | PostgreSQL with relational schemas, connection pooling, and automated migrations                                                                                      |

---

## 📋 Prerequisites

Before running the project, ensure you have the following installed on your development machine:

- **Node.js**: `v18.0.0` or higher ([Download](https://nodejs.org/))
- **PostgreSQL**: `v14.0` or higher running locally or remotely ([Download](https://www.postgresql.org/download/))
- **Flutter SDK**: `v3.19.0` or higher ([Installation Guide](https://docs.flutter.dev/get-started/install))
- **Android SDK / Android Studio** or a connected physical Android device (with Developer Mode & USB/Wireless Debugging enabled)

---

## 🚀 Getting Started

### 1. Database Setup

1. Start your local PostgreSQL server:
   ```bash
   # Windows (PowerShell / Services)
   Start-Service postgresql-x64-16  # (or your installed version)
   ```
2. Create a database named `nobroker_db`:
   ```sql
   CREATE DATABASE nobroker_db;
   ```

---

### 2. Backend Setup & Execution

1. Navigate to the `backend` directory:

   ```bash
   cd backend
   ```

2. Install Node dependencies:

   ```bash
   npm install
   ```

3. Configure environment variables:
   Copy `.env.example` to `.env`:

   ```bash
   copy .env.example .env
   ```

   Edit `.env` with your PostgreSQL credentials:

   ```env
   PORT=5000
   NODE_ENV=development

   DB_HOST=localhost
   DB_PORT=5432
   DB_USER=postgres
   DB_PASSWORD=your_postgres_password
   DB_NAME=nobroker_db

   JWT_ACCESS_SECRET=your_super_secret_access_jwt_key
   JWT_ACCESS_EXPIRES_IN=15m
   JWT_REFRESH_SECRET=your_super_secret_refresh_jwt_key
   JWT_REFRESH_EXPIRES_IN=7d

   CORS_ORIGIN=*
   ```

4. Run database migrations to create all required tables:

   ```bash
   npm run migrate
   ```

5. (Optional) Seed the database with initial admin and demo residents:

   ```bash
   npm run seed
   ```

6. Start the backend development server:

   ```bash
   npm run dev
   ```

   **API Endpoints & Documentation:**
   - 📡 **Base API URL**: `http://localhost:5000/api/v1`
   - 📄 **Interactive Swagger Docs**: `http://localhost:5000/api/v1/docs`
   - 🩺 **Health Check**: `http://localhost:5000/health`

---

### 3. Frontend (Flutter App) Setup & Execution

1. Navigate to the `frontend` directory:

   ```bash
   cd frontend
   ```

2. Install Flutter packages:

   ```bash
   flutter pub get
   ```

3. Configure mobile environment variables:
   Create or edit `frontend/.env`:

   ```env
   # Choose the appropriate URL based on your target environment:

   # Option A: Physical Android Device connected on local Wi-Fi:
   API_BASE_URL=http://<YOUR_HOST_PC_IP>:5000/api/v1
   # (e.g. API_BASE_URL=http://192.168.29.213:5000/api/v1)

   # Option B: Android Studio Emulator (uses virtual host loopback):
   # API_BASE_URL=http://10.0.2.2:5000/api/v1

   # Option C: Chrome Web or Windows Desktop:
   # API_BASE_URL=http://localhost:5000/api/v1
   ```

   > 💡 **Tip for Physical Android Devices**:
   > Run `ipconfig` (Windows) to check your computer's Wi-Fi IP address and ensure both your computer and phone are on the same Wi-Fi network.

4. Verify code quality & tests:

   ```bash
   flutter analyze lib/
   flutter test
   ```

5. Run the Flutter app:

   ```bash
   flutter run
   ```

6. Build Release APK (for installation or distribution):
   ```bash
   flutter build apk --release
   ```
   The generated APK will be at:
   `frontend/build/app/outputs/flutter-apk/app-release.apk`

---

## 📱 Connecting a Physical Android Device via ADB

1. **Enable Developer Options & USB / Wireless Debugging** on your Android device.
2. Connect via Wi-Fi:
   ```bash
   adb connect <DEVICE_IP>:<PORT>
   # e.g.: adb connect 192.168.29.17:42743
   ```
3. Check connected devices:
   ```bash
   flutter devices
   ```
4. Run on the selected device:
   ```bash
   flutter run -d <DEVICE_ID>
   ```

---

## 🔐 Default Demo Credentials

If you ran `npm run seed` in the backend, you can sign in with:

| Role                | Email                | Password         |
| ------------------- | -------------------- | ---------------- |
| **Cluster Admin**   | `admin@nobroker.in`  | `AdminPass123!`  |
| **Resident Tenant** | `tenant@nobroker.in` | `TenantPass123!` |

---

## 📁 Repository Structure

```text
├── backend/
│   ├── src/
│   │   ├── common/         # Middlewares, auth guards, error handlers
│   │   ├── database/       # Pool configuration, SQL migrations & seeds
│   │   ├── modules/
│   │   │   ├── auth/       # Auth controller, service, repository, validators
│   │   │   └── users/      # Users directory CRUD, pagination & aggregate metrics
│   │   └── server.ts       # Express server initialization
│   ├── .env.example
│   └── package.json
│
├── frontend/
│   ├── assets/
│   │   ├── icons/          # Launcher icons & foreground assets
│   │   └── images/         # App logos and illustrations
│   ├── lib/
│   │   ├── core/           # Router (GoRouter), Theme, API constants, Storage
│   │   ├── features/
│   │   │   ├── auth/       # Login & Registration screens, controllers, models
│   │   │   ├── dashboard/  # Health card, stats grid, operations launchpad, activity feed
│   │   │   ├── users/      # User list, filter chips, detail view, add/edit form
│   │   │   └── profile/    # Profile view, edit profile dialog, logout
│   │   └── shared/         # Reusable buttons, cards, text fields, avatars, skeletons
│   ├── test/               # Unit and widget test suite
│   ├── .env.example
│   └── pubspec.yaml
│
├── .gitignore              # Unified root ignore for Node & Flutter
└── README.md               # Project documentation
```

---

## 🧪 Running Tests

### Backend Unit & Integration Tests

```bash
cd backend
npm run test
```

### Frontend Widget & Unit Tests

```bash
cd frontend
flutter test
```
