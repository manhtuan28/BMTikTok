//
//  BMConfigManager.m
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMConfigManager.h"

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
        @"auto_scroll_feed", @"skip_recommendations", @"skip_recommnedations",
        
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
        @"disable_safari_redirect", @"openInBrowser", @"extendedComment",
        
        // Phát lại video
        @"auto_play_next_video", @"auto_play", @"stop_looping_video", @"stop_play",
        @"progress_bar", @"show_porgress_bar", @"keep_audio_unmuted",
        @"playback_en", @"playback_speed", @"force_highest_bitrate",
        
        // Khu vực & Quốc gia
        @"en_region", @"region", @"russian_fix", @"upload_region",
        
        // Hồ sơ & Số liệu ảo
        @"fake_verified", @"fake_verify", @"enable_fake_follower", @"fake_follower_count",
        @"enable_fake_following", @"fake_following_count", @"enable_fake_likes", @"fake_likes_count",
        @"copy_profile_bio", @"copy_profile_information", @"copy_profile_id",
        @"download_profile_avatar", @"save_profile", @"hide_liked_tab",
        @"extended_bio", @"show_username",
        
        // Xác nhận thao tác
        @"like_confirmation", @"like_confirm", @"follow_confirmation", @"follow_confirm",
        @"comment_like_confirmation", @"like_comment_confirm",
        @"comment_dislike_confirmation", @"dislike_comment_confirm",
        @"publish_confirmation", @"download_confirmation", @"bookmark_confirmation",
        
        // Giao diện & Tùy biến
        @"oled_keyboard", @"en_oled", @"hide_tab_bar_labels", @"hide_badge_counter",
        @"transparent_status_bar", @"show_exact_date", @"video_upload_date",
        @"en_livefunc", @"live_action", @"video_like_count", @"uploaded_videos",
        @"en_fake", @"flex_enebaled"
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
    dict[@"_meta_version"] = @"46.9.0";
    dict[@"_meta_timestamp"] = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]];
    return [dict copy];
}

+ (BOOL)importSettingsFromDictionary:(NSDictionary *)dict {
    if (![dict isKindOfClass:[NSDictionary class]] || dict.count == 0) return NO;
    
    // Hỗ trợ trường hợp dictionary được bọc trong các root key thông dụng
    if (dict[@"settings"] && [dict[@"settings"] isKindOfClass:[NSDictionary class]]) {
        dict = dict[@"settings"];
    } else if (dict[@"config"] && [dict[@"config"] isKindOfClass:[NSDictionary class]]) {
        dict = dict[@"config"];
    } else if (dict[@"data"] && [dict[@"data"] isKindOfClass:[NSDictionary class]]) {
        dict = dict[@"data"];
    } else if (dict[@"bmtiktok"] && [dict[@"bmtiktok"] isKindOfClass:[NSDictionary class]]) {
        dict = dict[@"bmtiktok"];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL importedAny = NO;
    for (NSString *key in [self allConfigKeys]) {
        id val = dict[key];
        if (val != nil && val != [NSNull null]) {
            if ([val isKindOfClass:[NSString class]]) {
                NSString *strVal = [(NSString *)val lowercaseString];
                if ([strVal isEqualToString:@"true"]) {
                    [defaults setBool:YES forKey:key];
                    importedAny = YES;
                    continue;
                } else if ([strVal isEqualToString:@"false"]) {
                    [defaults setBool:NO forKey:key];
                    importedAny = YES;
                    continue;
                }
            }
            [defaults setObject:val forKey:key];
            importedAny = YES;
        }
    }
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    return importedAny;
}

+ (BOOL)importSettingsFromData:(NSData *)data {
    if (!data || data.length == 0) return NO;
    
    // Tự động loại bỏ UTF-8 BOM nếu có
    if (data.length >= 3) {
        const unsigned char *bytes = (const unsigned char *)data.bytes;
        if (bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
            data = [data subdataWithRange:NSMakeRange(3, data.length - 3)];
        }
    }
    
    NSError *error = nil;
    id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if ([obj isKindOfClass:[NSDictionary class]] && !error) {
        return [self importSettingsFromDictionary:(NSDictionary *)obj];
    }
    
    // Thử giải mã bằng nhiều bảng mã khác nhau phòng trường hợp file lưu từ Windows/web
    NSArray<NSNumber *> *encodings = @[
        @(NSUTF8StringEncoding),
        @(NSISOLatin1StringEncoding),
        @(NSWindowsCP1252StringEncoding),
        @(NSUTF16StringEncoding)
    ];
    for (NSNumber *encNum in encodings) {
        NSString *str = [[NSString alloc] initWithData:data encoding:[encNum unsignedIntegerValue]];
        if (str && str.length > 0) {
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSData *cleanedData = [str dataUsingEncoding:NSUTF8StringEncoding];
            if (cleanedData) {
                id cleanObj = [NSJSONSerialization JSONObjectWithData:cleanedData options:0 error:nil];
                if ([cleanObj isKindOfClass:[NSDictionary class]]) {
                    return [self importSettingsFromDictionary:(NSDictionary *)cleanObj];
                }
            }
        }
    }
    
    return NO;
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
    if (data) {
        return [self importSettingsFromData:data];
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
    
    // 3. Lưu vào Keychain
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
        if ([self importSettingsFromData:data]) {
            return YES;
        }
    }
    
    // 2. Fallback: Khôi phục từ file backup nếu Keychain chưa có hoặc bị hạn chế trên thiết bị
    NSString *backupPath = settingsBackupFilePath();
    if ([[NSFileManager defaultManager] fileExistsAtPath:backupPath]) {
        NSData *backupData = [NSData dataWithContentsOfFile:backupPath];
        if (backupData && [self importSettingsFromData:backupData]) {
            return YES;
        }
    }
    
    // 3. Fallback: Khôi phục từ NSUserDefaults Master Record
    NSData *masterData = [[NSUserDefaults standardUserDefaults] objectForKey:@"BMTikTok_Master_Settings_Backup"];
    if (masterData && [self importSettingsFromData:masterData]) {
        return YES;
    }
    
    return NO;
}

@end
