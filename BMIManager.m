#import "BMIManager.h"
#import "TikTokHeaders.h"

@implementation BMIManager

// MARK: - Feed & Ads
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
+ (BOOL)disableUnsensitive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_unsensitive"];
}
+ (BOOL)disableWarnings {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_warnings"];
}
+ (BOOL)disableLive {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_live"];
}
+ (BOOL)skipRecommendations {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"skip_recommnedations"];
}
+ (BOOL)disableSurvey {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_survey"];
}
+ (BOOL)hideDangerousAction {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"ufc_warnings"];
}
+ (BOOL)blockMovieTok {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_movie_tok"];
}
+ (BOOL)blockTCM {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_tcm"];
}
+ (BOOL)blockPOI {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_poi"];
}
+ (BOOL)blockAIGenerated {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"block_ai_generated"];
}

// MARK: - Download & Media
+ (BOOL)downloadButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_button"];
}
+ (BOOL)downloadMusic {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"download_music"];
}
+ (BOOL)shareSheet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"share_sheet"];
}
+ (BOOL)removeWatermark {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_watermark"];
}
+ (BOOL)removeDraftWatermark {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_photo_watermark"];
}
+ (BOOL)saveDMMedia {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"save_dm_media"];
}
+ (BOOL)enableStickerDownload {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"double_tap_download_sticker"];
}
+ (BOOL)uploadHD {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upload_hd"];
}

// MARK: - Playback Controls
+ (BOOL)autoPlay {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_play"];
}
+ (BOOL)stopPlay {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"stop_play"];
}
+ (BOOL)progressBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_porgress_bar"];
}
+ (BOOL)loopStoryVideos {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"loop_story_videos"];
}
+ (BOOL)stopStoryPhotoAdvance {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"stop_story_photo_advance"];
}
+ (BOOL)backgroundPlay {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"background_play"];
}
+ (BOOL)speedEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"playback_en"];
}
+ (NSNumber *)selectedSpeed {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"playback_speed"];
}

// MARK: - Region & Location
+ (BOOL)regionChangingEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_region"];
}
+ (BOOL)fullRegionMode {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"full_region_mode"];
}
+ (BOOL)russianFix {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"russian_fix"];
}
+ (NSDictionary *)selectedRegion {
    return [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
}
+ (BOOL)uploadRegion {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"upload_region"];
}
+ (BOOL)enableCommentFlags {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"enable_comment_flags"];
}

// MARK: - Privacy & Ghost Mode
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

// MARK: - Comments
+ (BOOL)transparentCommnet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"transparent_commnet"];
}
+ (BOOL)copyWithoutUsername {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_without_username"];
}
+ (BOOL)autoUnfold {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_unfold"];
}
+ (BOOL)massUnfold {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"mass_unfold"];
}
+ (BOOL)disableCommentTooltip {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_tooltip"];
}
+ (BOOL)hideEmojiBar {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_emoji_bar"];
}
+ (BOOL)extendedComment {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extendedComment"];
}

// MARK: - Profile & Interactions
+ (BOOL)profileSave {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"save_profile"];
}
+ (BOOL)profileCopy {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"copy_profile_information"];
}
+ (BOOL)profileVideoCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"uploaded_videos"];
}
+ (BOOL)videoLikeCount {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_like_count"];
}
+ (BOOL)videoUploadDate {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"video_upload_date"];
}
+ (BOOL)showVideoTimestamp {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_fyp_timestamps"];
}
+ (BOOL)showUsername {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"show_username"];
}
+ (BOOL)extendedBio {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"extended_bio"];
}
+ (BOOL)alwaysOpenSafari {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"openInBrowser"];
}
+ (BOOL)bypassFollowListSearch {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bypass_follow_list_search"];
}
+ (BOOL)bypassMediaLimit {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"bypass_media_limit"];
}
+ (BOOL)fakeChangesEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_fake"];
}
+ (BOOL)fakeVerified {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"fake_verify"];
}
+ (NSString *)fakeFollowerCount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_follower_count"] ?: @"999.9K";
}
+ (NSString *)fakeFollowingCount {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_following_count"] ?: @"1";
}

// MARK: - Confirmations
+ (BOOL)likeConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_confirm"];
}
+ (BOOL)likeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"like_comment_confirm"];
}
+ (BOOL)dislikeCommentConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"dislike_comment_confirm"];
}
+ (BOOL)followConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"follow_confirm"];
}
+ (BOOL)storyLikeConfirmation {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"story_like_confirmation"];
}
+ (BOOL)quickShareConfirm {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"quick_share_confirm"];
}
+ (BOOL)repostConfirm {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"repost_confirm"];
}
+ (BOOL)disableFeedDoubleTap {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_feed_double_tap"];
}
+ (BOOL)disableStoryDoubleTap {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"disable_story_double_tap"];
}

// MARK: - UI & Theme
+ (BOOL)hideElementButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"remove_elements_button"];
}
+ (BOOL)oledKeyboard {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_oled"];
}
+ (BOOL)hideTabBarLabels {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_tab_bar_labels"];
}
+ (BOOL)hidePlusButton {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_plus_button"];
}
+ (BOOL)hideFriendsBadge {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_friends_badge"];
}
+ (BOOL)hideInboxBadge {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_inbox_badge"];
}
+ (BOOL)hideStreakPet {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hide_streak_pet"];
}
+ (BOOL)liveActionEnabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"en_livefunc"];
}
+ (NSNumber *)selectedLiveAction {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"live_action"];
}

// MARK: - Helpers & Utilities
+ (void)cleanCache {
    NSArray <NSURL *> *DocumentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in DocumentFiles) {
        NSString *ext = file.pathExtension.lowercaseString;
        if ([ext isEqualToString:@"mp4"] || [ext isEqualToString:@"png"] || [ext isEqualToString:@"jpeg"] || [ext isEqualToString:@"jpg"] || [ext isEqualToString:@"mp3"] || [ext isEqualToString:@"m4a"]) {
            [[NSFileManager defaultManager] removeItemAtURL:file error:nil];
        }
    }
    
    NSArray <NSURL *> *TempFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()] includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    for (NSURL *file in TempFiles) {
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
    NSArray *FolderFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    return (FolderFiles.count == 0);
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