# Dự án MBossWater

## 1. Tổng quan

Ứng dụng được xây dựng dựa trên mô hình **Clean Architecture**, kết hợp với **Firebase** làm backend chính. Mục tiêu là đảm bảo mã nguồn dễ bảo trì, mở rộng và đáp ứng tốt các yêu cầu nghiệp vụ.

## 2. Công nghệ sử dụng

- **Ngôn ngữ chính**: Dart (Flutter)
- **Mô hình kiến trúc**: Clean Architecture
- **Quản lý trạng thái**: BLoC (Business Logic Component)
- **Backend**: Firebase (Firestore, Cloud Functions, Cloud Message, ...)
- **Cơ sở dữ liệu thời gian thực**: Firestore
- **Quản lý dependencies**: pubspec.yaml

## 3. Cấu trúc dự án

Ứng dụng được chia thành các tầng như sau:

### a. Presentation Layer (Tầng giao diện)

- Chứa UI và logic liên quan đến giao diện người dùng.
- **Thư mục**: `lib/presentation`
- Các màn hình được tổ chức theo module hoặc chức năng cụ thể.
- Quản lý trạng thái bằng BLoC hoặc Cubit.

### b. Domain Layer (Tầng nghiệp vụ)

- Chứa các logic cốt lõi và các quy tắc kinh doanh.
- **Thư mục**: `lib/domain`
- Các thành phần chính:
  - **Entities**: Các đối tượng thuần liên quan đến nghiệp vụ.
  - **Use Cases**: Chứa các logic xử lý nghiệp vụ (ví dụ: xử lý đăng nhập, tính toán thống kê).
  - **Repositories (Contracts)**: Các interface kết nối tầng Domain và Data.

### c. Data Layer (Tầng dữ liệu)

- Chứa các thành phần liên quan đến xử lý dữ liệu (API, Firebase, Local Storage).
- **Thư mục**: `lib/data`
- Các thành phần chính:
  - **Models**: Các mô hình dữ liệu (DTO) được ánh xạ từ Firestore hoặc API.
  - **Data Sources**:
    - **Remote Data Source**: Giao tiếp với Firebase hoặc API bên ngoài.
    - **Local Data Source**: Lưu trữ dữ liệu cục bộ (Shared Preferences, SQLite).
  - **Repositories (Implementations)**: Hiện thực hóa các repository trong tầng Domain.

## 4. Công cụ Firebase được sử dụng

- **Firestore**: Lưu trữ và đồng bộ dữ liệu thời gian thực.
- **Cloud Functions**: Xử lý logic backend (như gửi thông báo, xử lý sự kiện).
- **Firebase Storage**: Quản lý tệp (ảnh, video).
- **Firebase Analytics**: Theo dõi hành vi người dùng.

## 5. Mã hóa dữ liệu

Ứng dụng sử dụng thuật toán **AES (Advanced Encryption Standard)** với chế độ **CBC (Cipher Block Chaining)** để mã hóa và giải mã dữ liệu nhạy cảm như mật khẩu.

- **Secret Key**: Được yêu cầu có độ dài chính xác 32 ký tự, đảm bảo tính bảo mật và khả năng tương thích với thuật toán AES.
- **IV (Initialization Vector)**: Sử dụng một giá trị ngẫu nhiên cố định với độ dài 16 byte để tăng cường bảo mật khi mã hóa dữ liệu.

Ví dụ mã hóa và giải mã:

```dart
String encryptedData = EncryptionHelper.encryptData("sampleData", "yourSecretKey1234567890123456");
String decryptedData = EncryptionHelper.decryptData(encryptedData, "yourSecretKey1234567890123456");
```

## 6. Quy trình phát triển

- **Tuân thủ Clean Architecture**:
  - Không viết logic nghiệp vụ trong UI.
  - Tách biệt rõ ràng giữa các tầng Presentation, Domain và Data.
- **Quản lý trạng thái**:
  - Sử dụng BLoC để quản lý trạng thái và logic nghiệp vụ.
  - Các màn hình UI chỉ nên chịu trách nhiệm hiển thị thông tin và nhận tương tác từ người dùng.
  
## 7. Hướng dẫn setup

### a. Cài đặt môi trường

- **Flutter SDK**: Yêu cầu phiên bản `>= 3.x`.
  - Hướng dẫn cài đặt Flutter: [Cài đặt Flutter](https://flutter.dev/docs/get-started/install)
  
- **Firebase CLI**:
  - Hướng dẫn cài đặt Firebase CLI: [Cài đặt Firebase CLI](https://firebase.google.com/docs/cli)

### b. Setup dự án

1. **Clone repo**:

    ```bash
    git clone https://github.com/thuanyg/mbosswater
    ```

2. **Cài đặt dependencies**:

    ```bash
    flutter pub get
    ```

3. **Cấu hình Firebase**:
   - Thêm tệp `google-services.json` (Android) hoặc `GoogleService-Info.plist` (iOS) vào thư mục tương ứng.

### c. Chạy ứng dụng

- **Development**:

    ```bash
    flutter run
    ```

- **Production build**:

    ```bash
    flutter build apk
    ```

### d. Thêm module Firebase mới

- Kích hoạt module trong Firebase Console.
- Cập nhật tệp cấu hình Firebase (`google-services.json` hoặc `GoogleService-Info.plist`).
- Sử dụng SDK Firebase tương ứng.

## 8. Liên hệ hỗ trợ
