#  Metereader Flutter App

[![Flutter Version](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A sleek, modern, and cross-platform mobile application built with Flutter. Metereader allows users to capture photos of their Piped Natural Gas (PNG) meters, automatically extract the reading using an advanced ML Microservice, confirm the reading, and securely submit it to generate dynamic PDF bills.

> **Note:** This is the frontend client application. It works in tandem with the [Metereader Backend API](https://github.com/ElfNoona/metereader-backend), which acts as the source of truth for the database and billing engine.

---

##  Key Features

- **Smart Camera Integration:** Natively captures high-resolution meter images with flash control.
- **Image Cropping:** Built-in UI to crop and focus strictly on the meter digits before processing.
- **Edge-to-Cloud ML:** Synchronously sends the cropped image to a dedicated Python ML Microserver for optical character recognition (OCR) and auto-fills the reading field.
- **Secure Sessions:** Manages JWT Access and Refresh tokens using encrypted local storage. 
- **One-Tap Billing:** Chained API logic that instantly generates an IGL tariff bill right after the user confirms their reading.
- **PDF Viewer:** Securely downloads and triggers the native PDF viewer for generated invoices.

---

##  Technology Stack

- **Framework:** Flutter (Dart)
- **Networking:** `dio` (with custom JWT interceptors)
- **Environment Variables:** `flutter_dotenv`
- **Camera & Media:** `camera`, `image_cropper`
- **Local Storage:** `shared_preferences`

---

##  Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- An Android Emulator, iOS Simulator, or a physical device connected via USB/Wi-Fi.
- The [Metereader Backend](https://github.com/ElfNoona/metereader-backend) running locally or deployed.

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/metereader.git
   cd metereader
   ```

2. **Install Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Configure Environment Variables:**
   Create a `.env` file in the root directory (at the same level as `pubspec.yaml`):
   ```env
   # The URL of your Node.js Backend
   API_BASE_URL=http://10.0.2.2:5000/api

   # The IP of your Python ML Microserver
   ML_SERVER_URL=http://<YOUR_MANAGER_ML_SERVER_IP>:8000/predict
   ```
   *(Note: `10.0.2.2` is the special alias for your host loopback interface from an Android emulator).*

4. **Run the App:**
   ```bash
   flutter run
   ```

---

##  Architecture & Flow

The app follows a clean, feature-driven folder structure:

```text
lib/
├── core/                  # App-wide themes, colors, and input validators
├── data/
│   ├── local/             # StorageService (JWT persistence)
│   └── remote/            # ApiService (Dio singleton, interceptors, error handling)
├── features/
│   ├── auth/              # Login, Signup, AuthController
│   ├── dashboard/         # Dashboard UI, Billing History, PDF Downloads
│   └── scanner/           # Camera logic, Image Cropper, ML API calls, Confirmation
├── main.dart              # App entry point & DotEnv initialization
└── routes.dart            # Centralized named route management
```

### The ML Submission Flow:
1. **Capture:** User takes a picture of the PNG meter.
2. **Crop:** User crops the image to isolate the digits.
3. **Inference:** The Flutter app sends a `multipart/form-data` request directly to the external `ML_SERVER_URL`.
4. **Confirmation:** The ML server returns a number, which auto-fills the text field. The user taps **"Confirm"**.
5. **Database & Billing:** Flutter fires two chained requests to the Node.js backend:
   - `POST /reading/submit` -> Secures the reading in MongoDB.
   - `POST /billing/generate` -> Immediately generates the bill for that reading.

---

##  Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

##  License

Distributed under the MIT License. See `LICENSE` for more information.
