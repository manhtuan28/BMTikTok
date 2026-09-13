//
//  BMConfigManager.m
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMConfigManager.h"
#import "BMLogger.h"
#import <Security/Security.h>
#import <objc/runtime.h>

static NSString *const kBMKeychainService = @"com.tuancute28.bmtiktok.config";
static NSString *const kBMKeychainAccount = @"user_settings_backup";

@implementation BMConfigManager

+ (NSArray<NSString *> *)allConfigKeys {
    return @[
        // Bảng tin & Quảng cáo
        @"hide_ads", @"hide_commission_posts", @"remove_pendant", @"remove_tiktok_ai_button",
        @"block_ai_generated", @"block_movie_tok", @"block_poi", @"disable_unsensitive",
        @"disable_warnings", @"remove_elements_button", @"disable_live", @"hide_play_pause",
        @"hide_top_items", @"start_fyp_in_following", @"disable_swipe_in_fyp", @"pull_to_refresh",
        @"auto_scroll_feed",
        
        // Tải xuống & Media
        @"download_button", @"remove_watermark", @"remove_photo_watermark", @"download_music",
        @"share_sheet", @"save_dm_media", @"double_tap_download_sticker", @"highest_video_quality",
        @"upload_hd",
        
        // Quyền riêng tư & Ẩn danh
        @"anonymous_seen", @"mark_seen_on_reply", @"disable_typing", @"view_profiles_anonymous",
        @"disable_screenshot_detection", @"disable_screenrecording_detection", @"hide_activity_status",
        @"padlock",
        
        // Bình luận & Tương tác
        @"transparent_commnet", @"hide_emoji_bar", @"colorize_comment_usernames",
        @"copy_comment_text", @"enable_comment_flags", @"auto_translate_comments",
        @"disable_safari_redirect", @"extendedComment",
        
        // Phát lại video
        @"auto_play_next_video", @"stop_looping_video", @"progress_bar", @"keep_audio_unmuted",
        @"playback_en", @"playback_speed", @"force_highest_bitrate",
        
        // Khu vực & Quốc gia
        @"en_region", @"region", @"russian_fix", @"upload_region",
        
        // Hồ sơ & Số liệu ảo
        @"fake_verified", @"enable_fake_follower", @"fake_follower_count",
        @"enable_fake_following", @"fake_following_count", @"enable_fake_likes", @"fake_likes_count",
        @"copy_profile_bio", @"copy_profile_id", @"download_profile_avatar", @"hide_liked_tab",
        @"extended_bio", @"show_username",
        
        // Xác nhận thao tác
        @"like_confirmation", @"follow_confirmation", @"comment_like_confirmation",
        @"comment_dislike_confirmation", @"publish_confirmation", @"download_confirmation",
        @"bookmark_confirmation",
        
        // Giao diện & Tùy biến
        @"oled_keyboard", @"hide_tab_bar_labels", @"hide_badge_counter",
        @"transparent_status_bar", @"show_exact_date", @"en_livefunc", @"live_action",
        @"video_like_count", @"uploaded_videos", @"en_fake", @"flex_enebaled"
    ];
}

+ (void)resetAllSettingsToDefault {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [self allConfigKeys]) {
        [defaults setBool:NO forKey:key];
    }
    // Xóa các key dạng chuỗi/dict/số
    [defaults removeObjectForKey:@"fake_follower_count"];
    [defaults removeObjectForKey:@"fake_following_count"];
    [defaults removeObjectForKey:@"fake_likes_count"];
    [defaults removeObjectForKey:@"region"];
    [defaults removeObjectForKey:@"playback_speed"];
    [defaults removeObjectForKey:@"live_action"];
    [defaults removeObjectForKey:@"upload_region"];
    [defaults removeObjectForKey:@"en_fake"];
    [defaults removeObjectForKey:@"flex_enebaled"];
    [defaults synchronize];
    
    [self saveSettingsToKeychain];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
}

+ (NSDictionary *)exportSettingsDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [self allConfigKeys]) {
        id val = [defaults objectForKey:key];
        if (val) {
            dict[key] = val;
        }
    }
    dict[@"_meta_app"] = @"BMTikTok";
    dict[@"_meta_author"] = @"Tuancute28 (Bùi Mạnh Tuấn)";
    dict[@"_meta_version"] = @"46.8.0";
    dict[@"_meta_timestamp"] = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    return [dict copy];
}

+ (BOOL)importSettingsFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]]) return NO;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *key in [self allConfigKeys]) {
        id val = dict[key];
        if (val) {
            [defaults setObject:val forKey:key];
        }
    }
    [defaults synchronize];
    [self saveSettingsToKeychain];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    return YES;
}

+ (NSString *)exportSettingsToJSONString {
    NSDictionary *dict = [self exportSettingsDictionary];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData && !error) {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+ (BOOL)importSettingsFromJSONString:(NSString *)jsonString {
    if (!jsonString || !jsonString.length) return NO;
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) return NO;
    
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if ([obj isKindOfClass:[NSDictionary class]] && !error) {
        return [self importSettingsFromDictionary:(NSDictionary *)obj];
    }
    return NO;
}

+ (NSURL *)createExportConfigFileURL {
    NSString *jsonStr = [self exportSettingsToJSONString];
    if (!jsonStr) return nil;
    
    NSString *tempDir = NSTemporaryDirectory();
    NSString *filePath = [tempDir stringByAppendingPathComponent:@"BMTikTok_Config.json"];
    NSError *error = nil;
    [jsonStr writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        return [NSURL fileURLWithPath:filePath];
    }
    return nil;
}

#pragma mark - Keychain & Persistent Services

static NSString *settingsBackupFilePath() {
    NSString *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    return [docs stringByAppendingPathComponent:@".bmtiktok_settings_backup.json"];
}

+ (BOOL)saveSettingsToKeychain {
    NSDictionary *settings = [self exportSettingsDictionary];
    if (!settings || settings.count == 0) return NO;
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:settings options:0 error:&error];
    if (!data || error) return NO;
    
    // 1. Lưu bản ghi NSUserDefaults Master Record
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"BMTikTok_Master_Settings_Backup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 2. Luôn sao lưu vào file dự phòng trong Documents
    [data writeToFile:settingsBackupFilePath() atomically:YES];
    
    // 3. Lưu vào Keychain (Query tìm kiếm cơ bản, không chứa kSecAttrAccessible)
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kBMKeychainService,
        (__bridge id)kSecAttrAccount: kBMKeychainAccount
    };
    
    NSDictionary *attributesToUpdate = @{
        (__bridge id)kSecValueData: data
    };
    
    OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attributesToUpdate);
    if (status != errSecSuccess) {
        // Xóa trước để tránh lỗi trùng lặp -25299
        SecItemDelete((__bridge CFDictionaryRef)query);
        
        NSMutableDictionary *newAttributes = [query mutableCopy];
        newAttributes[(__bridge id)kSecValueData] = data;
        newAttributes[(__bridge id)kSecAttrAccessible] = (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
        status = SecItemAdd((__bridge CFDictionaryRef)newAttributes, NULL);
    }
    
    return YES;
}

+ (BOOL)restoreSettingsFromKeychain {
    // 1. Thử lấy từ Keychain
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kBMKeychainService,
        (__bridge id)kSecAttrAccount: kBMKeychainAccount,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData *)result;
        NSError *error = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if ([obj isKindOfClass:[NSDictionary class]] && !error) {
            return [self importSettingsFromDictionary:(NSDictionary *)obj];
        }
    }
    
    // 2. Fallback: Khôi phục từ file backup nếu Keychain chưa có hoặc bị hạn chế trên thiết bị
    NSString *backupPath = settingsBackupFilePath();
    if ([[NSFileManager defaultManager] fileExistsAtPath:backupPath]) {
        NSData *backupData = [NSData dataWithContentsOfFile:backupPath];
        if (backupData) {
            NSError *error = nil;
            id obj = [NSJSONSerialization JSONObjectWithData:backupData options:0 error:&error];
            if ([obj isKindOfClass:[NSDictionary class]] && !error) {
                return [self importSettingsFromDictionary:(NSDictionary *)obj];
            }
        }
    }
    
    // 3. Fallback: Khôi phục từ NSUserDefaults Master Record
    NSData *masterData = [[NSUserDefaults standardUserDefaults] objectForKey:@"BMTikTok_Master_Settings_Backup"];
    if (masterData) {
        NSError *error = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:masterData options:0 error:&error];
        if ([obj isKindOfClass:[NSDictionary class]] && !error) {
            return [self importSettingsFromDictionary:(NSDictionary *)obj];
        }
    }
    
    return NO;
}

#pragma mark - Login Fix & Device ID Reset

+ (void)cleanOldFakeDeviceIDIfNeeded {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    // Loại bỏ triệt để các cờ reset độc hại khiến ByteDance SDK chặn cấp phát ID
    [defaults removeObjectForKey:@"kAutoResetKey"];
    [defaults removeObjectForKey:@"kTTResetedDeviceID"];
    [defaults removeObjectForKey:@"kTTResetedInstallID"];
    [defaults removeObjectForKey:@"kTTResetNewUser"];
    
    NSString *did = [defaults stringForKey:@"bmtiktok_persistent_device_id"];
    BOOL isFake = (did && ([did hasPrefix:@"741000"] || [did isEqualToString:@"7471290553514378232"]));
    if (isFake) {
        [defaults removeObjectForKey:@"bmtiktok_persistent_device_id"];
        [defaults removeObjectForKey:@"bmtiktok_persistent_install_id"];
        [defaults removeObjectForKey:@"bmtiktok_device_id_confirmed"];
        [BMLogger log:@"[DEVICE-CLEAN] Đã gỡ bỏ Device ID giả mạo cũ: %@", did];
    }
    [defaults synchronize];
}

+ (NSString *)persistentDeviceID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *did = [defaults stringForKey:@"tt_device_id"];
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) {
        did = [defaults stringForKey:@"kDeviceIDStorageKey"];
    }
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) {
        did = [defaults stringForKey:@"did"];
    }
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) {
        did = [defaults stringForKey:@"bmtiktok_persistent_device_id"];
    }
    
    // Thử đọc từ ttinstall_ids.plist nếu TikTok đã lưu trước đó
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) {
        NSArray *searchPaths = @[
            NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject,
            [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Preferences"],
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
        ];
        for (NSString *dir in searchPaths) {
            if (!dir) continue;
            NSString *plistPath = [dir stringByAppendingPathComponent:@"ttinstall_ids.plist"];
            NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            if (plist && plist[@"device_id"]) {
                NSString *fileDid = [NSString stringWithFormat:@"%@", plist[@"device_id"]];
                if (fileDid && fileDid.length >= 5 && ![fileDid isEqualToString:@"0"]) {
                    did = fileDid;
                    break;
                }
            }
        }
    }
    
    // Thử đọc từ Keychain nếu có
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) {
        NSArray *kcServices = @[@"com.ss.iphone.ugc.Awe.device_id", @"com.bytedance.ttinstallservice", @"kBDInstallOldDidKeychainService"];
        for (NSString *svc in kcServices) {
            NSDictionary *query = @{
                (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                (__bridge id)kSecAttrService: svc,
                (__bridge id)kSecReturnData: (__bridge id)kCFBooleanTrue
            };
            CFTypeRef result = NULL;
            if (SecItemCopyMatching((__bridge CFDictionaryRef)query, &result) == errSecSuccess && result) {
                NSData *data = (__bridge_transfer NSData *)result;
                NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                if (str && str.length >= 5 && ![str isEqualToString:@"0"]) {
                    did = str;
                    break;
                }
            }
        }
    }
    
    if (did && ([did hasPrefix:@"741000"] || [did isEqualToString:@"7471290553514378232"])) {
        return nil;
    }
    return (did && did.length >= 5 && ![did isEqualToString:@"0"]) ? did : nil;
}

+ (NSString *)persistentInstallID {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *iid = [defaults stringForKey:@"tt_install_id"];
    if (!iid || iid.length < 5 || [iid isEqualToString:@"0"]) {
        iid = [defaults stringForKey:@"kInstallIDStorageKey"];
    }
    if (!iid || iid.length < 5 || [iid isEqualToString:@"0"]) {
        iid = [defaults stringForKey:@"iid"];
    }
    if (!iid || iid.length < 5 || [iid isEqualToString:@"0"]) {
        iid = [defaults stringForKey:@"bmtiktok_persistent_install_id"];
    }
    
    // Thử đọc từ ttinstall_ids.plist
    if (!iid || iid.length < 5 || [iid isEqualToString:@"0"]) {
        NSArray *searchPaths = @[
            NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject,
            [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"Preferences"],
            NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject
        ];
        for (NSString *dir in searchPaths) {
            if (!dir) continue;
            NSString *plistPath = [dir stringByAppendingPathComponent:@"ttinstall_ids.plist"];
            NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:plistPath];
            if (plist && plist[@"install_id"]) {
                NSString *fileIid = [NSString stringWithFormat:@"%@", plist[@"install_id"]];
                if (fileIid && fileIid.length >= 5 && ![fileIid isEqualToString:@"0"]) {
                    iid = fileIid;
                    break;
                }
            }
        }
    }
    
    if (iid && ([iid hasPrefix:@"741000"] || [iid isEqualToString:@"7465653952132769861"])) {
        return nil;
    }
    return (iid && iid.length >= 5 && ![iid isEqualToString:@"0"]) ? iid : nil;
}

+ (BOOL)isDeviceIDConfirmed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bmtiktok_device_id_confirmed"];
}

+ (void)setConfirmedDeviceID:(NSString *)did installID:(NSString *)iid {
    if (!did || did.length < 5 || [did isEqualToString:@"0"]) return;
    if ([did hasPrefix:@"741000"] || [did isEqualToString:@"7471290553514378232"]) return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:did forKey:@"bmtiktok_persistent_device_id"];
    [defaults setObject:did forKey:@"kDeviceIDStorageKey"];
    [defaults setObject:did forKey:@"tt_device_id"];
    [defaults setObject:did forKey:@"did"];
    [defaults setObject:did forKey:@"com.ss.iphone.ugc.Awe.device_id"];
    
    if (iid && iid.length >= 5 && ![iid isEqualToString:@"0"] && ![iid hasPrefix:@"741000"]) {
        [defaults setObject:iid forKey:@"bmtiktok_persistent_install_id"];
        [defaults setObject:iid forKey:@"kInstallIDStorageKey"];
        [defaults setObject:iid forKey:@"tt_install_id"];
        [defaults setObject:iid forKey:@"iid"];
        [defaults setObject:iid forKey:@"com.ss.iphone.ugc.Awe.install_id"];
    }
    [defaults setBool:YES forKey:@"bmtiktok_device_id_confirmed"];
    [defaults synchronize];
    [BMLogger log:@"[DEVICE-ID] Đã lưu Device ID chính thức từ máy chủ: DID=%@ | IID=%@", did, iid ?: @"none"];
}

+ (BOOL)fixLoginRateLimitAndResetDeviceID {
    [BMLogger log:@"[DEVICE-RESET] Bắt đầu quá trình làm sạch phiên đăng nhập & cookie bị chặn..."];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // 1. Dọn dẹp cờ reset & ID giả nếu có
    NSArray *keysToRemove = @[
        @"bmtiktok_persistent_device_id",
        @"bmtiktok_persistent_install_id",
        @"bmtiktok_device_id_confirmed",
        @"kAutoResetKey",
        @"kTTResetedDeviceID",
        @"kTTResetedInstallID",
        @"kTTResetNewUser"
    ];
    for (NSString *key in keysToRemove) {
        [defaults removeObjectForKey:key];
    }
    [defaults synchronize];
    
    // 2. Xóa sạch HTTP Cookies bị ByteDance gắn cờ giới hạn (odin_tt, msToken...)
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage.cookies copy];
    for (NSHTTPCookie *cookie in cookies) {
        NSString *name = [cookie.name lowercaseString];
        NSString *dom = [cookie.domain lowercaseString];
        if ([dom containsString:@"tiktok"] || [dom containsString:@"bytedance"] || [dom containsString:@"musical"] || [name isEqualToString:@"odin_tt"] || [name isEqualToString:@"mstoken"]) {
            [cookieStorage deleteCookie:cookie];
        }
    }
    [BMLogger log:@"[DEVICE-RESET] Đã xóa toàn bộ cookie theo dõi odin_tt & msToken."];
    
    // 3. Kích hoạt TTInstallIDManager reRegisterDevice sạch (không truyền custom trigger để tránh bị PumbaaPro gắn cờ non-native)
    Class installManagerClass = objc_getClass("TTInstallIDManager");
    if (installManagerClass) {
        id manager = nil;
        if ([(id)installManagerClass respondsToSelector:@selector(sharedManager)]) {
            manager = [(id)installManagerClass performSelector:@selector(sharedManager)];
        } else if ([(id)installManagerClass respondsToSelector:@selector(defaultManager)]) {
            manager = [(id)installManagerClass performSelector:@selector(defaultManager)];
        }
        if (manager) {
            SEL reRegisterSel = NSSelectorFromString(@"reRegisterDeviceWithSceneStatus:triggerFrom:registerSuccessObserver:completion:");
            if ([manager respondsToSelector:reRegisterSel]) {
                typedef void (*ReRegisterFunc)(id, SEL, id, id, id, id);
                ReRegisterFunc func = (ReRegisterFunc)[manager methodForSelector:reRegisterSel];
                if (func) {
                    func(manager, reRegisterSel, nil, nil, nil, nil);
                }
            }
        }
    }
    
    [BMLogger log:@"[DEVICE-RESET] Đã hoàn tất làm sạch cookie & kích hoạt reRegisterDevice sạch lên máy chủ."];
    return YES;
}

@end
