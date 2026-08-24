//
//  BMConfigManager.m
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMConfigManager.h"
#import <Security/Security.h>

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
        @"transparent_status_bar", @"show_exact_date", @"en_livefunc", @"live_action"
    ];
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
    dict[@"_meta_version"] = @"46.5.0";
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

#pragma mark - Keychain Services

+ (BOOL)saveSettingsToKeychain {
    NSDictionary *settings = [self exportSettingsDictionary];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:settings options:0 error:&error];
    if (!data || error) return NO;
    
    // Xóa item cũ nếu có
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kBMKeychainService,
        (__bridge id)kSecAttrAccount: kBMKeychainAccount
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
    
    // Thêm item mới
    NSDictionary *attributes = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: kBMKeychainService,
        (__bridge id)kSecAttrAccount: kBMKeychainAccount,
        (__bridge id)kSecValueData: data,
        (__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleAfterFirstUnlock
    };
    
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
    return status == errSecSuccess;
}

+ (BOOL)restoreSettingsFromKeychain {
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
    return NO;
}

@end
