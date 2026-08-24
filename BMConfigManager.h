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

@end
