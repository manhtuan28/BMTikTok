# BMTikTok

<p align="center">
  <img src="avatar.jpg" width="120" height="120" style="border-radius: 50%; box-shadow: 0 4px 15px rgba(0,0,0,0.3);" alt="Tuancute28 Avatar" />
  <br>
  <b>BMTikTok - Tweak TikTok iOS Toàn Diện & Đỉnh Cao</b>
  <br>
  <i>Phát triển & duy trì bởi <b>Tuancute28 (Bùi Mạnh Tuấn)</b></i>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-14.0+-black?style=for-the-badge&logo=apple" alt="iOS Version" />
  <img src="https://img.shields.io/badge/Architecture-ARM64%20%7C%20ARM64e-blue?style=for-the-badge" alt="Architecture" />
  <img src="https://img.shields.io/badge/TikTok-v30.0+-fe2c55?style=for-the-badge&logo=tiktok" alt="TikTok Version" />
  <img src="https://img.shields.io/badge/DRM-Free-success?style=for-the-badge" alt="DRM Free" />
</p>

---

## 🚀 Giới Thiệu

**BMTikTok** là bản tinh chỉnh (Tweak) mã nguồn mở cao cấp dành cho ứng dụng **TikTok iOS**, được tối ưu hóa đặc biệt cho người dùng Việt Nam và quốc tế. Tweak cung cấp các tính năng vượt trội: tải media HD gốc không logo, đổi vùng không cần VPN/SIM, chế độ ẩn danh Ghost Mode toàn diện, sửa lỗi bình luận livestream, chế độ xem video không phân tâm (Pure Mode), cùng cơ chế khắc phục lỗi đăng nhập và bảo lưu cấu hình độc quyền.

Toàn bộ mã nguồn sạch 100%, không sử dụng mã hóa OLLVM, không chứa DRM, không popup quảng cáo hoặc đòi key bản quyền.

---

## ✨ Chi Tiết Các Tính Năng Đột Phá

### 1. 👻 Chế Độ Ẩn Danh & Quyền Riêng Tư (Ghost Mode)
*Hệ thống can thiệp tầng sâu vào luồng API & Socket của TikTok để bảo vệ danh tính tuyệt đối.*

- **Xem Tin & Story Ẩn Danh (`anonymous_seen`)**: Chặn các lệnh báo cáo đã xem (`reportStoryViewedWithStoryID:`, `_reportStoryRead:`, các endpoint `/tiktok/story/view/report/v1`). Bạn có thể thoải mái xem Story mà chủ bài đăng không hề thấy bạn trong danh sách người đã xem.
- **Chỉ Đánh Dấu Đã Xem Khi Trả Lời (`mark_seen_on_reply`)**: Trạng thái "Đã xem" trong tin nhắn trực tiếp (DM) được đóng băng hoàn toàn khi bạn mở đọc. Trạng thái chỉ được gửi đi khi và chỉ khi bạn nhấn nút gửi tin nhắn trả lời đối phương.
- **Ẩn Trạng Thái Đang Soạn Tin (`disable_typing`)**: Vô hiệu hóa việc gửi gói tin typing status (`sendInputStatusWithConversationID:`, `TIMMessageSender`). Người bên kia sẽ không bao giờ thấy biểu tượng ba chấm "đang soạn tin...".
- **Xem Hồ Sơ Ẩn Danh (`view_profiles_anonymous`)**: Ngăn chặn TikTok ghi nhận và gửi báo cáo xem trang cá nhân (`-[TTKProfileViewsVisitor reportProfileView]` & `/tiktok/user/profile/view_record/add/v1`). Lịch sử ghé thăm của chủ tài khoản sẽ không có tên bạn.
- **Chống Phát Hiện Chụp Màn Hình (`disable_screenshot_detection`)**: Vô hiệu hóa bộ lắng nghe chụp màn hình (`AWEScreenShotTracker`) và chặn gửi sự kiện cảnh báo chụp màn hình trong tin nhắn riêng tư.
- **Chống Phát Hiện Quay Màn Hình (`disable_screenrecording_detection`)**: Can thiệp thuộc tính hệ thống `-[UIScreen isCaptured]` luôn trả về `NO`, vô hiệu hóa các listener kiểm tra quay màn hình của TikTok.
- **Ẩn Trạng Thái Hoạt Động Online (`hide_activity_status`)**: Vô hiệu hóa bộ đếm và yêu cầu gửi trạng thái online định kỳ (`AWEIMActivityStatusReportManager`), đồng thời ẩn toàn bộ chấm xanh trực tuyến của bạn trên giao diện TikTok.
- **Khóa Ứng Dụng Sinh Trắc Học (`padlock`)**: Tích hợp bảo vệ bằng Face ID / Touch ID hoặc Passcode ngay khi mở lại ứng dụng.

---

### 2. 💬 Tương Tác Bình Luận & Tự Động Dịch Sang Tiếng Việt
*Tối ưu hóa toàn diện trải nghiệm đọc và tương tác bình luận cho người dùng Việt Nam.*

- **Tự Động Dịch Toàn Bộ Bình Luận Sang Tiếng Việt (`auto_translate_comments`)**:
  - **Dịch từ mọi ngôn ngữ**: Tự động chuyển ngữ mọi bình luận bằng bất kỳ ngôn ngữ nào (Tiếng Anh, Trung, Nhật, Hàn, Nga, Ả Rập, Tây Ban Nha, Pháp, v.v.) sang **Tiếng Việt** chuẩn xác.
  - **Can thiệp sâu tầng API**: Hook trực tiếp vào cấu hình dịch thuật (`TTKCommentTranslationConfig`, `AWECommentsTranslationController`, `TTKTranslationSettingsManager`, `AWEGlobalTranslationManager`).
  - **Xóa bỏ rào cản DNT (Do Not Translate)**: Ép danh sách bỏ qua ngôn ngữ luôn trống (`doNotTranslateLanguageCodes = []`), bảo đảm không một bình luận ngoại ngữ nào bị bỏ sót.
  - **Đồng bộ mã ngôn ngữ đích**: Luôn đặt tham số `trg_lang` = `@"vi"` trên các endpoint dịch thuật ByteDance (`/aweme/v2/comment/translation/`, `/aweme/v1/content/translation/`).
- **Sao Chép Bình Luận Một Chạm (`copy_comment_text`)**:
  - Nhấn giữ (Long Press) vào bất kỳ bình luận nào để sao chép ngay nội dung văn bản vào khay nhớ tạm (Clipboard), đi kèm rung phản hồi xúc giác (Haptic Feedback).
- **Gắn Cờ Quốc Gia Cho Bình Luận (`enable_comment_flags`)**:
  - Tự động nhận diện khu vực của người viết bình luận và gắn biểu tượng cờ quốc gia bên cạnh tên hiển thị.
- **Tô Màu Tên Người Bình Luận (`colorize_comment_usernames`)**:
  - Đổi màu tên tác giả bình luận sang màu sắc nổi bật, giúp dễ phân biệt các phản hồi trong luồng trò chuyện.
- **Khung Bình Luận Trong Suốt (`transparent_commnet`)**:
  - Làm mờ khung bình luận để vừa lướt xem phản hồi của cộng đồng vừa theo dõi trọn vẹn video phía sau.
- **Khắc Phục Bình Luận Livestream Lúc Hiện Lúc Không**:
  - Vô hiệu hóa cơ chế tự làm mờ và ẩn khung chat của IESLive (`banDismissAnimation`, `unlimitedDuration` trên `GBLCommentViewContainerConfig`).
  - Chặn bộ đếm thời gian `cleanScreenCountDownTimer` tự xóa bình luận sau vài giây không có tương tác.
  - Ổn định khung chat dọc phòng LIVE, ngăn chặn hiện tượng chập chờn, giật lag.

---

### 3. 👁️ Chế Độ Xem Thuần Khiết (Pure Mode - Ẩn Giao Diện)
- **Nút Con Mắt Ẩn Toàn Bộ Giao Diện**: Ẩn thanh công cụ bên phải, tên tác giả, mô tả caption, âm thanh để thưởng thức trọn vẹn video full màn hình.
- **Duy Trì Xuyên Suốt Khi Lướt Video**: Đã khắc phục lỗi sang video khác bị mất ẩn giao diện. Trạng thái ẩn UI được ghi nhớ và áp dụng liên tục cho tất cả các video kế tiếp khi vuốt cho đến khi bạn chủ động chạm vào con mắt để hiện lại.

---

### 4. 📥 Tải Xuống Đa Phương Tiện Không Watermark
- **Tải Video Chất Lượng Gốc**: Tải video không logo, không watermark ở độ phân giải cao nhất (HD / 2K / 4K).
- **Tải Nhạc Nền / Âm Thanh (.m4a)**: Lưu trực tiếp tệp âm thanh của bất kỳ video nào về máy.
- **Tải Ảnh & Sticker Trong Tin Nhắn**: Bổ sung menu lưu ảnh, video clip, nhãn dán trong Direct Messages về Camera Roll.
- **Tải Ảnh Story & Bản Nháp**: Lưu giữ hình ảnh và story nguyên bản không dính viền watermark TikTok.
- **Kích Hoạt Tải Lên Chất Lượng Cao**: Mở khóa chế độ upload video chất lượng cao nhất cho tài khoản.

---

### 5. 🌍 Đổi Vùng 38 Quốc Gia Không Cần SIM / VPN
- **Bypass Giới Hạn Khu Vực**: Chuyển vùng sang Mỹ (US), Nhật Bản (JP), Hàn Quốc (KR), Singapore (SG), Vương quốc Anh (GB), Việt Nam (VN)... ngay lập tức mà không cần tháo SIM hoặc cài đặt ứng dụng VPN.
- **Russian Feed Fix**: Vượt qua rào cản cấm vận để mở khóa nguồn cấp dữ liệu video tiếng Nga.
- **Hiển Thị Cờ Quốc Gia**: Hiển thị quốc kỳ của tài khoản đăng tải video cạnh tên người dùng và trong khu vực bình luận.

---

### 6. 🚫 Chặn 100% Quảng Cáo & Tinh Giản Bảng Tin
- **Chặn Video Tài Trợ (Sponsored Ads)**: Loại bỏ sạch sẽ mọi video quảng cáo chèn giữa bảng tin.
- **Lọc Bài Viết Tiếp Thị Liên Kết (Affiliate / Giỏ Hàng)**: Tùy chọn ẩn các video gắn link mua sắm hoa hồng để trải nghiệm xem video giải trí thuần túy.
- **Ẩn Banner Góc & Nút Trợ Lý AI Tako**: Xóa bỏ các biểu tượng quảng cáo nổi góc màn hình và trợ lý ảo Tako che khuất tầm nhìn.
- **Khởi Động Thẳng Vào Tab Đang Theo Dõi (Following)**: Bỏ qua tab "Dành cho bạn" khi mở app nếu muốn cập nhật tin từ bạn bè trước.
- **Khóa Vuốt Ngang (Horizontal Pan Lock)**: Chống vô tình trượt tay chuyển sang camera hoặc trang cá nhân.
- **Tự Động Cuộn Bảng Tin (Auto-Scroll)**: Tự động lướt sang video tiếp theo khi video hiện tại phát xong.

---

### 7. 🛡️ Xác Nhận Thao Tác (Chống Bấm Nhầm)
- **Hộp Thoại Hỏi Lại Thông Minh**: Ngăn chặn tình trạng vô tình chạm tay vào các nút tương tác quan trọng:
  - Xác nhận khi Thích video (Heart / Double tap).
  - Xác nhận khi Theo dõi tài khoản (Follow).
  - Xác nhận khi Thích / Không thích bình luận (Comment Like / Dislike).
  - Xác nhận trước khi Lưu vào Bộ sưu tập (Bookmark / Favorite).
  - Xác nhận trước khi Tải xuống video (Download Confirmation).
  - Xác nhận trước khi Đăng tải bài viết (Publish Confirmation).

---

### 8. 🎮 Điều Khiển Trình Phát Video
- **Ghi Nhớ Tốc Độ Phát**: Cố định tốc độ bạn thích (1.25x, 1.5x, 2.0x, 3.0x...) xuyên suốt phiên xem.
- **Luôn Hiện Thanh Tiến Trình (Progress Bar)**: Hiển thị thanh tua thời lượng dưới chân mọi video kể cả video ngắn.
- **Luôn Bật Âm Thanh Khi Mở App**: Tự động bỏ tắt tiếng (unmute) mỗi khi khởi động TikTok.
- **Ép Chất Lượng Video Cao Nhất**: Luôn ưu tiên phát luồng video có độ nét và bitrate cao nhất.

---

### 9. 👤 Tùy Biến Trang Cá Nhân & Sống Ảo
- **Lưu Ảnh Đại Diện Full Size**: Nhấn giữ avatar của bất kỳ ai để tải ảnh gốc độ phân giải cao.
- **Sao Chép Nhanh**: Nhấn giữ tiểu sử (Bio) hoặc tên người dùng để sao chép nhanh vào clipboard.
- **Ẩn Tab Bài Viết Đã Thích**: Ẩn tab danh sách video đã thích trên trang cá nhân của bạn.
- **Huy Hiệu Tích Xanh Ảo**: Bật tích xanh Verified trên hồ sơ cá nhân để chụp ảnh màn hình sống ảo.
- **Tùy Chỉnh Số Follower / Following / Likes Ảo**: Tự đặt số người theo dõi, đang theo dõi và tổng lượt thích theo ý muốn.

---

### 10. 🎨 Giao Diện & Tùy Biến Hệ Thống
- **Bàn Phím Tối OLED**: Chuyển bàn phím sang nền đen tuyệt đối, dịu mắt và tiết kiệm pin cho màn hình OLED.
- **Ẩn Chấm Đỏ Thông Báo (Badge Counter)**: Xóa bỏ các biểu tượng chấm đỏ chưa đọc gây rối mắt trên thanh Tab Bar.
- **Ẩn Nhãn Chữ Tab Bar**: Tối giản thanh điều hướng chỉ hiển thị icon thanh lịch.
- **Trong Suốt Thanh Trạng Thái**: Làm mờ thanh Status Bar / Dynamic Island khi xem video.
- **Mở Liên Kết Bằng Safari**: Tùy chọn tự động mở các link web ngoài bằng Safari thay vì trình duyệt in-app.

---

### 11. 🔐 Khắc Phục Triệt Để Lỗi Đăng Nhập & Bảo Lưu Cài Đặt
- **Fix Lỗi Sideload Login Loop**: Tích hợp tầng hook C-API Keychain (`SecItemAdd`, `SecItemCopyMatching`, `SecItemUpdate`) tự động loại bỏ thuộc tính `kSecAttrAccessGroup` không hợp lệ khi cài app qua bên thứ ba (Sideloadly, AltStore, Scarlet, TrollStore). Giải quyết triệt để lỗi gửi mã OTP về email nhưng quay trở lại màn hình đăng nhập liên tục.
- **Bảo Lưu Cài Đặt 3 Tầng (Triple-Redundant Persistence)**: Cài đặt được đồng bộ đồng thời tại 3 nơi:
  1. *Keychain iOS* (tồn tại ngay cả khi xóa app cài lại).
  2. *Documents JSON Backup* (`BMTikTokSettings.json`).
  3. *NSUserDefaults Master Record*.
- **Mặc Định Toàn Bộ Tính Năng TẮT (Default OFF)**: Khi mới cài đặt lần đầu, toàn bộ tính năng đều ở trạng thái OFF để đảm bảo ứng dụng hoạt động nguyên bản, người dùng toàn quyền chủ động bật tính năng cần thiết.

---

## 🛠️ Hướng Dẫn Biên Dịch & Đóng Gói

### 1. Biên dịch Tweak với Theos

Yêu cầu môi trường có cài đặt [Theos](https://theos.dev/):

```bash
cd BMTikTok
make clean
make package FINALPACKAGE=1
```

Tệp `.dylib` thành phẩm sẽ nằm trong thư mục `.theos/obj/debug/` hoặc gói `.deb` trong `packages/`.

### 2. Tiêm (Inject) vào TikTok IPA

Sử dụng `Azule`, `Sideloadly` hoặc `PyPatch` để inject tweak vào ứng dụng TikTok:

```bash
# Ví dụ sử dụng Azule:
azule -i TikTok.ipa -o TikTok_BMTikTok.ipa -f .theos/obj/debug/BMTikTok.dylib
```

> [!IMPORTANT]
> - Bundle ID chuẩn của TikTok quốc tế là: `com.zhiliaoapp.musically`.
> - Hãy đảm bảo công cụ ký (signing tool) giữ nguyên hoặc map entitlements Keychain đúng để tính năng đăng nhập hoạt động trơn tru.

---

## 👨‍💻 Thông Tin Tác Giả & Liên Hệ

Dự án được xây dựng và phát triển với tâm huyết của:

- **Tác giả / Lập trình viên**: **Tuancute28 (Bùi Mạnh Tuấn)**
- 🌐 **GitHub**: [https://github.com/manhtuan28](https://github.com/manhtuan28)
- 🐙 **Git Repository**: [https://github.com/manhtuan28/BMTikTok.git](https://github.com/manhtuan28/BMTikTok.git)
- 📘 **Facebook**: [https://www.facebook.com/b.manhtuan.028](https://www.facebook.com/b.manhtuan.028)
- 📸 **Instagram**: [https://www.instagram.com/bmanhtuan282/](https://www.instagram.com/bmanhtuan282/)
- 🎵 **TikTok**: [https://www.tiktok.com/@capyboiii_28](https://www.tiktok.com/@capyboiii_28)
- 🐦 **X (Twitter)**: [https://x.com/buituan282](https://x.com/buituan282)
- ✉️ **Email**: [buimanhtuan2k4@gmail.com](mailto:buimanhtuan2k4@gmail.com)

---

## 📦 Hướng Dẫn Quản Lý Git

```bash
# Khởi tạo và đồng bộ mã nguồn
git init
git remote add origin https://github.com/manhtuan28/BMTikTok.git
git add .
git commit -m "Fix livestream comments flickering, implement full Ghost Mode suite, and update README"
git branch -M main
git push -u origin main
```

---

<p align="center">
  <i>Được tạo với ❤️ bởi Tuancute28 cho cộng đồng iOS Jailbreak & Sideload Việt Nam.</i>
</p>
