# ✅ Hướng dẫn khắc phục lỗi Zego Engine null pointer

## 🐛 Lỗi chính đã fix:

### 1. **"This expression has a type of 'void'"**
**Nguyên nhân:** 
- `ZegoExpressEngine.createEngineWithProfile()` trả về `void`, không trả về `ZegoExpressEngine`
- Cố gắng gán vào biến `engine` gây lỗi compile

**Cách fix:**
```dart
// ❌ SAI - Cố gắng gán void vào biến
ZegoExpressEngine? engine = await ZegoExpressEngine.createEngineWithProfile(...);

// ✅ ĐÚNG - Gọi trực tiếp không cần gán
await ZegoExpressEngine.createEngineWithProfile(
  ZegoEngineProfile(appID, ZegoScenario.Default, appSign: appSign),
);
```

### 2. **Loading liên tục sau khi accept call**
**Nguyên nhân:** 
- Proximity sensor kích hoạt liên tục trên mobile
- Log: `proximity cleared, restoring screen brightness` lặp lại ~10 lần/giây

**Cách fix:**
```dart
final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  ..useSpeakerWhenJoining = true  // Force speaker mode
  ..enableAccidentalTouchPrevention = false; // Tắt proximity sensor
```

## 🔧 Các thay đổi đã thực hiện:

### 1. **Cập nhật `video_call_page.dart`**
- ✅ Thêm timeout protection (10 giây) khi tạo engine
- ✅ Cải thiện xử lý lỗi với thông báo chi tiết hơn
- ✅ Thêm delay giữa destroy/create engine (200ms)
- ✅ Xử lý đầy đủ các loại exception: PlatformException, TimeoutException, NullPointerException

### 2. **Cập nhật ProGuard rules** (`android/app/proguard-rules.pro`)
- ✅ Keep tất cả class Zego
- ✅ Bảo vệ native methods
- ✅ Giữ nguyên Parcelable implementations

### 3. **Cập nhật `build.gradle.kts`**
- ✅ Thêm packagingOptions để tránh xung đột native libs
- ✅ Đảm bảo ProGuard rules được áp dụng đúng

### 4. **Sửa file `.env`**
- ✅ Xóa khoảng trắng thừa trong AppSign và AppID

## 🚀 Cách chạy lại ứng dụng:

### Bước 1: Build lại project
```bash
flutter clean
flutter pub get
```

### Bước 2: Chạy trên thiết bị Android
```bash
flutter run
```

### Bước 3: Test cuộc gọi video
1. Đăng nhập vào app
2. Chọn một người dùng để gọi
3. Nhấn nút video call
4. Quan sát logs để xem engine được khởi tạo thành công

## 📋 Logs cần chú ý:

### ✅ Logs thành công:
```
🔍 Validating Zego credentials...
🧹 Old engine destroyed
🔧 Creating engine with AppID: 1657641729, AppSign: da768b23...
✅ Engine created successfully!
✅ Zego SDK Version: 3.22.1
✅ Validation complete - Engine destroyed
```

### ❌ Logs lỗi và cách fix:

#### Lỗi 1: Null pointer reference
```
❌ Create engine error: null object reference
```
**Nguyên nhân:**
- AppSign không đúng
- ProGuard rules chưa áp dụng

**Cách fix:**
1. Kiểm tra AppSign trong file `.env` (phải đúng 32 ký tự hex)
2. Chạy `flutter clean && flutter run`
3. Build ở chế độ debug trước: `flutter run --debug`

#### Lỗi 2: Invalid credentials (1001001)
```
❌ AppID hoặc AppSign KHÔNG HỢP LỆ!
```
**Cách fix:**
1. Đăng nhập [ZegoCloud Console](https://console.zego.im/)
2. Lấy lại AppID và AppSign
3. Cập nhật vào file `.env`

#### Lỗi 3: Timeout
```
❌ Timeout - kiểm tra kết nối mạng
```
**Cách fix:**
1. Kiểm tra internet của thiết bị
2. Thử lại sau vài giây
3. Kiểm tra firewall/VPN

## 🔍 Kiểm tra credentials hiện tại:

AppID: `1657641729`
AppSign: `da768b23960152fd9c95a29a5d3624e3`

### Validate AppSign:
- ✅ Độ dài: 32 ký tự
- ✅ Chỉ chứa hex (0-9, a-f)
- ✅ Không có khoảng trắng

## 🌐 Cross-platform (Flutter ↔ Web):

Để gọi video giữa Flutter mobile và React web:

### 1. Sử dụng cùng credentials trong React:
```javascript
import { ZegoUIKitPrebuilt } from '@zegocloud/zego-uikit-prebuilt';

const appID = 1657641729;
const serverSecret = "YOUR_SERVER_SECRET"; // Lấy từ Zego Console

const kitToken = ZegoUIKitPrebuilt.generateKitTokenForTest(
  appID,
  serverSecret,
  "call_219_6_1", // Cùng callID với Flutter
  "webUserId",
  "Web User"
);

const zp = ZegoUIKitPrebuilt.create(kitToken);
zp.joinRoom({
  container: element,
  scenario: {
    mode: ZegoUIKitPrebuilt.OneONoneCall,
  },
  turnOnCameraWhenJoining: true,
  turnOnMicrophoneWhenJoining: true,
});
```

### 2. Đảm bảo:
- ✅ Cùng AppID
- ✅ Cùng CallID (ví dụ: `call_${userId1}_${userId2}_${timestamp}`)
- ✅ UserID khác nhau giữa 2 thiết bị

## 📱 Fix lỗi loading liên tục trên mobile:

Nếu màn hình cứ quay loading sau khi accept call, thêm config:

```dart
final config = ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
  ..turnOnCameraWhenJoining = true
  ..turnOnMicrophoneWhenJoining = true
  ..useSpeakerWhenJoining = true  // Force speaker mode
  ..enableAccidentalTouchPrevention = false; // Tắt proximity sensor
```

## 🐛 Debug tips:

### 1. Xem logs chi tiết:
```bash
flutter run --verbose
```

### 2. Filter logs của Zego:
```bash
adb logcat | grep -i zego
```

### 3. Kiểm tra ProGuard có áp dụng:
```bash
cd android
./gradlew app:dependencies
```

## ⚠️ Lưu ý quan trọng:

1. **Release build**: ProGuard rules rất quan trọng để tránh obfuscate code Zego
2. **Debug build**: Nên test ở chế độ debug trước khi build release
3. **Web platform**: Không cần validate engine, chỉ mobile mới cần
4. **Permissions**: Camera + Microphone + Bluetooth phải được cấp đủ

## 🔗 Tài liệu tham khảo:

- [Zego Express Documentation](https://docs.zegocloud.com/article/3082)
- [Zego UIKit Prebuilt Call](https://docs.zegocloud.com/article/14826)
- [ProGuard Rules](https://docs.zegocloud.com/faq/express_proguard)

## ✉️ Nếu vẫn gặp lỗi:

1. Gửi logs đầy đủ từ `flutter run --verbose`
2. Screenshot màn hình lỗi
3. Kiểm tra version Zego SDK: `zego_express_engine: 3.22.1`

---

**Cập nhật:** 20/01/2026
**Trạng thái:** ✅ Đã fix và test

