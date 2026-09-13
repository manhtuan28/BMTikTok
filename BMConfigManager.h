//
//  BMConfigManager.h
//  BMTikTok
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BMConfigManager : NSObject

/// Danh sách toàn bộ các key cấu hình của BMTikTok
+ (NSArray<NSString *> *)allConfigKeys;

/// Lưu toàn bộ cài đặt hiện tại vào Keychain
+ (BOOL)saveSettingsToKeychain;

/// Khôi phục toàn bộ cài đặt từ Keychain
+ (BOOL)restoreSettingsFromKeychain;

/// Đặt lại toàn bộ cài đặt về mặc định (TẮT hết toàn bộ chức năng)
+ (void)resetAllSettingsToDefault;

/// Xuất toàn bộ cài đặt ra dạng Dictionary
+ (NSDictionary *)exportSettingsDictionary;

/// Nhập cài đặt từ Dictionary
+ (BOOL)importSettingsFromDictionary:(NSDictionary *)dict;

/// Xuất toàn bộ cấu hình ra chuỗi JSON
+ (NSString *)exportSettingsToJSONString;

/// Nhập cấu hình từ chuỗi JSON
+ (BOOL)importSettingsFromJSONString:(NSString *)jsonString;

/// Tạo file cấu hình JSON tạm thời để chia sẻ (Share Sheet)
+ (NSURL *)createExportConfigFileURL;

/// Tự động dọn dẹp các Device ID giả mạo cũ trên thiết bị nếu phát hiện
+ (void)cleanOldFakeDeviceIDIfNeeded;

/// Sửa lỗi đăng nhập "Bạn đã truy cập dịch vụ của chúng tôi quá thường xuyên" bằng cách kích hoạt cấp lại Device ID sạch
+ (BOOL)fixLoginRateLimitAndResetDeviceID;

/// Lấy Device ID hợp lệ đã được máy chủ TikTok cấp phát
+ (NSString *)persistentDeviceID;

/// Lấy hoặc sinh mới Install ID hợp lệ (19 chữ số)
+ (NSString *)persistentInstallID;

/// Kiểm tra xem Device ID đã được máy chủ ByteDance xác nhận đăng ký hay chưa
+ (BOOL)isDeviceIDConfirmed;

/// Cập nhật Device ID và Install ID chính thức từ máy chủ TikTok
+ (void)setConfirmedDeviceID:(NSString *)did installID:(NSString *)iid;

@end
