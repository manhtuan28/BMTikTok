//
//  BMIManager.m
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMIManager.h"
#import "TikTokHeaders.h"

@implementation BMIManager

// Helper: lấy boolean từ key chính, nếu chưa có thì thử key cũ (hỗ trợ nâng cấp không mất cấu hình)
static BOOL boolForKeys(NSString *primaryKey, NSString *fallbackKey) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:primaryKey] != nil) {
        return [defaults boolForKey:primaryKey];
    }
    if (fallbackKey && [defaults objectForKey:fallbackKey] != nil) {
        return [defaults boolForKey:fallbackKey];
    }
    return NO;
}

// MARK: - 1. Feed & Ads
+ (BOOL)hideAds {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_ads"];
}
+ (BOOL)hideCommissionPosts {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_commission_posts"];
}
+ (BOOL)removePendant {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_pendant"];
}
+ (BOOL)removeTikTokAIButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_tiktok_ai_button"];
}
+ (BOOL)hidePlayPause {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_play_pause"];
}
+ (BOOL)hideTopItems {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_top_items"];
}
+ (BOOL)startFYPInFollowing {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"start_fyp_in_following"];
}
+ (BOOL)disableSwipeInFYP {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_swipe_in_fyp"];
}
+ (BOOL)disablePullToRefresh {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"pull_to_refresh"];
}
+ (BOOL)autoScrollFeed {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_scroll_feed"];
}
+ (BOOL)disableUnsensitive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_unsensitive"];
}
+ (BOOL)disableWarnings {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_warnings"];
}
+ (BOOL)disableLive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_live"];
}
+ (BOOL)blockMovieTok {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_movie_tok"];
}
+ (BOOL)blockPOI {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_poi"];
}
+ (BOOL)blockAIGenerated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_ai_generated"];
}
+ (BOOL)skipRecommendations {
    return boolForKeys(@"skip_recommendations", @"skip_recommnedations");
}

// MARK: - 2. Download & Media
+ (BOOL)downloadButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_button"];
}
+ (BOOL)removeWatermark {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_watermark"];
}
+ (BOOL)removeDraftWatermark {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_photo_watermark"];
}
+ (BOOL)downloadMusic {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_music"];
}
+ (BOOL)shareSheet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"share_sheet"];
}
+ (BOOL)saveDMMedia {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"save_dm_media"];
}
+ (BOOL)enableStickerDownload {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"double_tap_download_sticker"];
}
+ (BOOL)highestVideoQuality {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"highest_video_quality"];
}
+ (BOOL)uploadHD {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upload_hd"];
}

// MARK: - 3. Playback Controls
+ (BOOL)autoPlay {
    return boolForKeys(@"auto_play_next_video", @"auto_play");
}
+ (BOOL)stopPlay {
    return boolForKeys(@"stop_looping_video", @"stop_play");
}
+ (BOOL)progressBar {
    return boolForKeys(@"progress_bar", @"show_porgress_bar");
}
+ (BOOL)keepAudioUnmuted {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"keep_audio_unmuted"];
}
+ (BOOL)speedEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"playback_en"];
}
+ (NSNumber *)selectedSpeed {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"playback_speed"];
}
+ (BOOL)forceHighestBitrate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"force_highest_bitrate"];
}

// MARK: - 4. Region & Location
+ (BOOL)regionChangingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_region"];
}
+ (NSDictionary *)selectedRegion {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
}
+ (BOOL)russianFix {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"russian_fix"];
}
+ (BOOL)uploadRegion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upload_region"];
}

// MARK: - 5. Privacy & Ghost Mode
+ (BOOL)anonymousSeen {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"anonymous_seen"];
}
+ (BOOL)markSeenOnReply {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"mark_seen_on_reply"];
}
+ (BOOL)disableTyping {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_typing"];
}
+ (BOOL)viewProfilesAnonymous {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"view_profiles_anonymous"];
}
+ (BOOL)disableScreenshotDetection {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_screenshot_detection"];
}
+ (BOOL)disableScreenrecordingDetection {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_screenrecording_detection"];
}
+ (BOOL)hideActivityStatus {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_activity_status"];
}
+ (BOOL)appLock {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"padlock"];
}

// MARK: - 6. Comments & Interaction
+ (BOOL)transparentCommnet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"transparent_commnet"];
}
+ (BOOL)hideEmojiBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_emoji_bar"];
}
+ (BOOL)colorizeCommentUsernames {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"colorize_comment_usernames"];
}
+ (BOOL)copyCommentText {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_comment_text"];
}
+ (BOOL)enableCommentFlags {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_comment_flags"];
}
+ (BOOL)autoTranslateComments {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_translate_comments"];
}
+ (BOOL)disableSafariRedirect {
    return boolForKeys(@"disable_safari_redirect", @"openInBrowser");
}
+ (BOOL)extendedComment {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extendedComment"];
}

// MARK: - 7. Profile & Fake Stats
+ (BOOL)fakeVerified {
    return boolForKeys(@"fake_verified", @"fake_verify");
}
+ (BOOL)fakeChangesEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"enable_fake_follower"] ||
           [defaults boolForKey:@"enable_fake_following"] ||
           [defaults boolForKey:@"enable_fake_likes"] ||
           [defaults boolForKey:@"en_fake"];
}
+ (NSString *)fakeFollowerCount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_follower_count"] ?: @"";
}
+ (NSString *)fakeFollowingCount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_following_count"] ?: @"";
}
+ (NSString *)fakeLikesCount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_likes_count"] ?: @"";
}
+ (BOOL)profileCopy {
    return boolForKeys(@"copy_profile_bio", @"copy_profile_information");
}
+ (BOOL)profileIdCopy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_profile_id"];
}
+ (BOOL)profileSave {
    return boolForKeys(@"download_profile_avatar", @"save_profile");
}
+ (BOOL)hideLikedTab {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_liked_tab"];
}
+ (BOOL)extendedBio {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extended_bio"];
}
+ (BOOL)showUsername {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_username"];
}
+ (BOOL)videoLikeCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_like_count"];
}
+ (BOOL)videoUploadDate {
    return boolForKeys(@"show_exact_date", @"video_upload_date");
}
+ (BOOL)profileVideoCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"uploaded_videos"];
}

// MARK: - 8. Confirmations
+ (BOOL)likeConfirmation {
    return boolForKeys(@"like_confirmation", @"like_confirm");
}
+ (BOOL)followConfirmation {
    return boolForKeys(@"follow_confirmation", @"follow_confirm");
}
+ (BOOL)likeCommentConfirmation {
    return boolForKeys(@"comment_like_confirmation", @"like_comment_confirm");
}
+ (BOOL)dislikeCommentConfirmation {
    return boolForKeys(@"comment_dislike_confirmation", @"dislike_comment_confirm");
}
+ (BOOL)publishConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"publish_confirmation"];
}
+ (BOOL)downloadConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_confirmation"];
}
+ (BOOL)bookmarkConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bookmark_confirmation"];
}

// MARK: - 9. Theme & UI
+ (BOOL)hideElementButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_elements_button"];
}
+ (BOOL)oledKeyboard {
    return boolForKeys(@"oled_keyboard", @"en_oled");
}
+ (BOOL)hideTabBarLabels {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_tab_bar_labels"];
}
+ (BOOL)hideBadgeCounter {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_badge_counter"];
}
+ (BOOL)transparentStatusBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"transparent_status_bar"];
}
+ (BOOL)showExactDate {
    return boolForKeys(@"show_exact_date", @"video_upload_date");
}
+ (BOOL)liveActionEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_livefunc"];
}
+ (NSNumber *)selectedLiveAction {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"live_action"];
}

// MARK: - 10. Helpers & Utilities
+ (void)cleanCache {
    NSArray <NSURL *> *documentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in documentFiles) {
        NSString *ext = file.pathExtension.lowercaseString;
        if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"mp3"] || [ext isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
    }
    
    NSArray <NSURL *> *tempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in tempFiles) {
        NSString *ext = file.pathExtension.lowercaseString;
        if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"mov"] || [ext isEqualToString:@"tmp"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"mp3"] || [ext isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
        if ([file hasDirectoryPath]) {
            if ([BMIManager isEmpty:file]) {
                [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
            }
        }
    }
}

+ (void)eraseAllData {
    [BMIManager cleanCache];
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isEmpty:(NSURL *)url {
    NSArray *folderFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    return (folderFiles.count == 0);
}

+ (void)showSaveVC:(id)item {
    UIActivityViewController *acVC = [[UIActivityViewController alloc] initWithActivityItems:item applicationActivities:nil];
    if (is_iPad()) {
        acVC.popoverPresentationController.sourceView = topMostController().view;
        acVC.popoverPresentationController.sourceRect = CGRectMake(topMostController().view.bounds.size.width / 2.0, topMostController().view.bounds.size.height / 2.0, 1.0, 1.0);
    }
    [topMostController() presentViewController:acVC animated:YES completion:nil];
}

+ (void)saveMedia:(id)newFilePath fileExtension:(id)fileextension {
    NSArray *imageExtensions = @[@"png", @"jpg", @"jpeg", @"gif", @"tiff", @"bmp", @"heif", @"heic", @"svg"];
    NSArray *videoExtensions = @[@"mp4", @"mov", @"avi", @"mkv", @"wmv", @"flv", @"webm"];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
        if ([videoExtensions containsObject:fileextension]) {
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypeVideo fileURL:newFilePath options:options];
        } else if ([imageExtensions containsObject:fileextension]) {
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto fileURL:newFilePath options:options];
        } else {
            NSLog(@"Unsupported file type: %@", fileextension);
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            NSLog(@"Media saved to Camera Roll successfully.");
        } else {
            NSLog(@"Error saving media to Camera Roll: %@", error);
        }
    }];
}

+ (void)saveAudioFromURL:(NSURL *)audioURL completion:(void (^)(BOOL success, NSError *error))completion {
    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:audioURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            if (completion) completion(NO, error);
            return;
        }
        NSString *docsDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSString *fileName = [NSString stringWithFormat:@"TikTok_Audio_%ld.m4a", (long)[[NSDate date] timeIntervalSince1970]];
        NSURL *destinationURL = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:fileName]];
        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationURL error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [BMIManager showSaveVC:@[destinationURL]];
            if (completion) completion(YES, nil);
        });
    }];
    [task resume];
}

+ (NSString *)getDownloadingPersent:(float)per {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterPercentStyle];
    NSNumber *number = [NSNumber numberWithFloat:per];
    return [numberFormatter stringFromNumber:number];
}

@end