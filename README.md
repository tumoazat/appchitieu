# Smart Expense - Personal Finance Manager with AI 💰

Ứng dụng quản lý tài chính cá nhân thông minh với phân tích AI được xây dựng bằng Flutter.

## ✨ Tính năng chính

### 🔐 Xác thực
- Đăng nhập/Đăng ký bằng Email
- Đăng nhập bằng Google
- Quên mật khẩu
- Quản lý hồ sơ người dùng

### 💸 Quản lý giao dịch
- Thêm thu/chi nhanh chóng
- Phân loại theo danh mục (Ăn uống, Di chuyển, Mua sắm, ...)
- Ghi chú cho mỗi giao dịch
- Xem lịch sử giao dịch theo tháng
- Lọc theo loại giao dịch
- Xóa giao dịch (swipe to delete)

### 📊 Thống kê & Phân tích
- Biểu đồ tròn chi tiêu theo danh mục
- Biểu đồ cột chi tiêu hàng ngày
- Phân tích chi tiết từng danh mục
- Tổng quan thu chi tháng
- Tỷ lệ tiết kiệm

### 🤖 AI Tư vấn Tài chính
- Phân tích ngân sách tháng
- Cảnh báo chi tiêu vượt mức
- Gợi ý tiết kiệm
- So sánh với tháng trước
- Phân tích thói quen chi tiêu

### 👤 Cá nhân
- Quản lý hồ sơ cá nhân
- Cài đặt ngân sách tháng
- Chuyển đổi giao diện sáng/tối
- Thống kê nhanh (giao dịch, streak, tiết kiệm)
- Đăng xuất

## 🚀 Cài đặt

### Yêu cầu
- Flutter SDK ^3.10.7
- Dart SDK ^3.10.7
- Android Studio / Xcode (cho mobile)
- Firebase Project (cho authentication & database)

### Bước 1: Clone repository
```bash
git clone <repository-url>
cd android
```

### Bước 2: Cài đặt dependencies
```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase

#### 3.1 Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com/)
2. Tạo project mới hoặc chọn project có sẵn
3. Thêm Android/iOS app vào project

#### 3.2 Cài đặt Firebase CLI
```bash
# Cài đặt Firebase CLI
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login

# Cài đặt FlutterFire CLI
dart pub global activate flutterfire_cli
```

#### 3.3 Cấu hình Firebase cho Flutter
```bash
# Chạy lệnh cấu hình
flutterfire configure --project=<your-project-id>

# Chọn platforms: Android, iOS, Web (tùy theo nhu cầu)
```

Lệnh này sẽ tự động tạo file `lib/firebase_options.dart` với cấu hình Firebase của bạn.

#### 3.4 Kích hoạt Firebase services
Trong Firebase Console, kích hoạt các services:
- **Authentication**: Email/Password và Google Sign-In
- **Cloud Firestore**: Tạo database ở chế độ test
- **Storage**: (Optional) Cho việc lưu hình ảnh

#### 3.5 Cấu hình Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Transactions subcollection
      match /transactions/{transactionId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Bước 4: Chạy ứng dụng
```bash
# Chạy trên device/emulator
flutter run

# Build APK (Android)
flutter build apk

# Build iOS
flutter build ios
```

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp configuration
├── core/                     # Core utilities
│   ├── theme/               # App themes (light/dark)
│   ├── constants/           # Constants & category data
│   ├── utils/               # Formatters & helpers
│   └── router/              # GoRouter configuration
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── repositories/        # Data repositories
│   └── services/            # Business logic services
├── providers/               # Riverpod providers
└── presentation/            # UI layer
    ├── auth/               # Authentication screens
    ├── navigation/         # Bottom navigation
    ├── home/               # Home screen
    ├── transactions/       # Transactions management
    ├── statistics/         # Statistics & charts
    ├── ai_advice/          # AI financial advice
    ├── profile/            # User profile
    └── shared/             # Shared widgets
```

## 🎨 Design System

### Màu sắc chính
- **Primary**: `#2ECC71` (Fintech Green)
- **Background Light**: `#F8F9FA`
- **Background Dark**: `#121212`
- **Expense**: `#E74C3C` (Red)
- **Income**: `#2ECC71` (Green)

### Typography
- Font chữ: **Inter** (Google Fonts)
- Sizes: 36sp (Display), 28sp (Amount), 24sp (Headline), 16sp (Body), 12sp (Caption)

### Components
- **Border Radius**: 8-24px
- **Spacing**: 4-32px increments
- **Shadows**: Subtle shadows cho depth
- **Animations**: 300ms smooth transitions

## 📦 Dependencies chính

### UI & Design
- `fl_chart` - Biểu đồ
- `google_fonts` - Fonts
- `flutter_animate` - Animations
- `shimmer` - Loading effects

### Navigation & State
- `go_router` - Routing
- `flutter_riverpod` - State management

### Firebase
- `firebase_core` - Firebase core
- `firebase_auth` - Authentication
- `cloud_firestore` - Database
- `google_sign_in` - Google login

### Utility
- `intl` - Internationalization
- `shared_preferences` - Local storage
- `uuid` - ID generation

## 🔧 Troubleshooting

### Firebase initialization error
Nếu gặp lỗi Firebase initialization:
1. Đảm bảo đã chạy `flutterfire configure`
2. Kiểm tra file `firebase_options.dart` đã được tạo
3. Kiểm tra Firebase project ID đúng
4. Xóa `build` folder và chạy lại: `flutter clean && flutter pub get`

### Google Sign-In không hoạt động
1. Kích hoạt Google Sign-In trong Firebase Console
2. Thêm SHA-1 fingerprint (Android):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Cập nhật `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS)

### Lỗi build
```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Rebuild
flutter run
```

## 📝 Lưu ý

- Ứng dụng yêu cầu kết nối internet để đồng bộ dữ liệu với Firebase
- Dữ liệu được lưu trên Cloud Firestore
- AI advice là rule-based, không sử dụng API bên ngoài
- Theme tối/sáng được lưu local và áp dụng tự động

## 🤝 Contributing

Mọi đóng góp đều được chào đón! Vui lòng:
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Dự án được phát hành dưới MIT License.

## 📧 Liên hệ

Nếu có câu hỏi hoặc góp ý, vui lòng tạo issue trên GitHub.

---

Made with ❤️ using Flutter
