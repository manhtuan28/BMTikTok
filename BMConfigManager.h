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

/// Sửa lỗi đăng nhập "Bạn đã truy cập dịch vụ của chúng tôi quá thường xuyên" bằng cách làm mới Device ID & Install ID
+ (BOOL)fixLoginRateLimitAndResetDeviceID;

/// Lấy hoặc sinh mới Device ID hợp lệ (19 chữ số)
+ (NSString *)persistentDeviceID;

/// Lấy hoặc sinh mới Install ID hợp lệ (19 chữ số)
+ (NSString *)persistentInstallID;

@end
