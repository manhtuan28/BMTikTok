//
//  Tweak.x
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "TikTokHeaders.h"
#import "BMConfigManager.h"
#import <Security/Security.h>
#import <substrate.h>

// ═══════════════════════════════════════════════════════════════
// MARK: - 0. Keychain Sideload Fix (Khắc phục triệt để lỗi Login Loop & OTP Email)
// ═══════════════════════════════════════════════════════════════

static NSMutableDictionary *BMCleanKeychainQuery(CFDictionaryRef dict) {
    if (!dict) return nil;
    NSMutableDictionary *query = [(__bridge NSDictionary *)dict mutableCopy];
    [query removeObjectForKey:(__bridge id)kSecAttrAccessGroup];
    return query;
}

static OSStatus (*orig_SecItemAdd)(CFDictionaryRef attributes, CFTypeRef *result) = NULL;
static OSStatus (*orig_SecItemDelete)(CFDictionaryRef query) = NULL;

static OSStatus hook_SecItemAdd(CFDictionaryRef attributes, CFTypeRef *result) {
    NSMutableDictionary *clean = BMCleanKeychainQuery(attributes);
    OSStatus status = orig_SecItemAdd((__bridge CFDictionaryRef)clean, result);
    // Nếu bị trùng lặp khóa cũ trong keychain cá nhân (errSecDuplicateItem = -25299), xóa key cũ và ghi đè lại
    if (status == errSecDuplicateItem || status == -25299) {
        NSMutableDictionary *deleteQuery = [clean mutableCopy];
        [deleteQuery removeObjectForKey:(__bridge id)kSecValueData];
        [deleteQuery removeObjectForKey:(__bridge id)kSecValueRef];
        [deleteQuery removeObjectForKey:(__bridge id)kSecValuePersistentRef];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrAccessible];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrCreationDate];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrModificationDate];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrDescription];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrComment];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrCreator];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrType];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrLabel];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrIsInvisible];
        [deleteQuery removeObjectForKey:(__bridge id)kSecAttrIsNegative];
        [deleteQuery removeObjectForKey:(__bridge id)kSecReturnData];
        [deleteQuery removeObjectForKey:(__bridge id)kSecReturnAttributes];
        [deleteQuery removeObjectForKey:(__bridge id)kSecReturnRef];
        [deleteQuery removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
        if (orig_SecItemDelete) {
            orig_SecItemDelete((__bridge CFDictionaryRef)deleteQuery);
        }
        status = orig_SecItemAdd((__bridge CFDictionaryRef)clean, result);
    }
    return status;
}

static OSStatus (*orig_SecItemCopyMatching)(CFDictionaryRef query, CFTypeRef *result) = NULL;
static OSStatus hook_SecItemCopyMatching(CFDictionaryRef query, CFTypeRef *result) {
    NSMutableDictionary *clean = BMCleanKeychainQuery(query);
    [clean removeObjectForKey:(__bridge id)kSecAttrAccessible];
    return orig_SecItemCopyMatching((__bridge CFDictionaryRef)clean, result);
}

static OSStatus (*orig_SecItemUpdate)(CFDictionaryRef query, CFDictionaryRef attributesToUpdate) = NULL;
static OSStatus hook_SecItemUpdate(CFDictionaryRef query, CFDictionaryRef attributesToUpdate) {
    NSMutableDictionary *cleanQuery = BMCleanKeychainQuery(query);
    [cleanQuery removeObjectForKey:(__bridge id)kSecAttrAccessible];
    NSMutableDictionary *cleanAttr = BMCleanKeychainQuery(attributesToUpdate);
    return orig_SecItemUpdate((__bridge CFDictionaryRef)cleanQuery, (__bridge CFDictionaryRef)cleanAttr);
}

static OSStatus hook_SecItemDelete(CFDictionaryRef query) {
    NSMutableDictionary *clean = BMCleanKeychainQuery(query);
    [clean removeObjectForKey:(__bridge id)kSecAttrAccessible];
    return orig_SecItemDelete((__bridge CFDictionaryRef)clean);
}

@interface UIViewController (BMPureMode)
- (void)setPureMode:(BOOL)pureMode animated:(BOOL)animated;
- (void)setNeedsSetPureMode:(BOOL)pureMode;
- (id)interactionController;
- (void)hideAllElements:(BOOL)hidden exceptArray:(NSArray *)except;
@end

@interface UIView (BMViewHelpers)
- (UIViewController *)viewController;
- (UIViewController *)parentViewController;
@end

NSArray *jailbreakPaths;
static BOOL gPureModeActive = NO;

static void showConfirmation(void (^okHandler)(void)) {
    [%c(AWEUIAlertView) showAlertWithTitle:@"Xác nhận BMTikTok"
                               description:@"Bạn có chắc chắn muốn thực hiện thao tác này không?"
                                     image:nil
                         actionButtonTitle:@"Đồng ý"
                         cancelButtonTitle:@"Hủy"
                               actionBlock:^{
        okHandler();
    } cancelBlock:nil];
}


// ═══════════════════════════════════════════════════════════════
// MARK: - 1. App Lifecycle & Settings Entry
// ═══════════════════════════════════════════════════════════════

%hook AppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"flex_enebaled"]) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BMTikTok_Initialized_v2"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"BMTikTok_Initialized_v2"];
        
        // Thử khôi phục cài đặt từ Keychain trước (nếu người dùng cài lại IPA hoặc nâng cấp có cấu hình cũ)
        BOOL restored = [BMConfigManager restoreSettingsFromKeychain];
        if (!restored) {
            // Khi vào app lần đầu: TẮT HẾT TOÀN BỘ 100% CÁC CHỨC NĂNG theo yêu cầu người dùng
            [BMConfigManager resetAllSettingsToDefault];
        }
    }
    [BMIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    if ([BMIManager appLock] && !isAuthenticationShowed) {
        UIViewController *rootController = [[self window] rootViewController];
        SecurityViewController *securityViewController = [SecurityViewController new];
        securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootController presentViewController:securityViewController animated:YES completion:nil];
        isAuthenticationShowed = TRUE;
    }
}

- (void)applicationWillEnterForeground:(id)arg1 {
    %orig;
    isAuthenticationShowed = FALSE;
}
%end

%hook TTKSettingsBaseCellPlugin
- (void)didSelectItemAtIndex:(NSInteger)index {
    if ([self.itemModel.identifier isEqualToString:@"bmtiktok_settings"]) {
        UINavigationController *BMTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
        BMTikTokSettings.modalPresentationStyle = UIModalPresentationPageSheet;
        [topMostController() presentViewController:BMTikTokSettings animated:true completion:nil];
    } else {
        return %orig;
    }
}
%end

%hook AWESettingsNormalSectionViewModel
- (void)viewDidLoad {
    %orig;
    if ([self.sectionIdentifier isEqualToString:@"account"]) {
        TTKSettingsBaseCellPlugin *BMTikTokSettingsPluginCell = [[%c(TTKSettingsBaseCellPlugin) alloc] initWithPluginContext:self.context];

        AWESettingItemModel *BMTikTokSettingsItemModel = [[%c(AWESettingItemModel) alloc] initWithIdentifier:@"bmtiktok_settings"];
        [BMTikTokSettingsItemModel setTitle:@"BMTikTok VIP Mod 🇻🇳"];
        [BMTikTokSettingsItemModel setDetail:@"BMTikTok VIP Mod 🇻🇳"];
        [BMTikTokSettingsItemModel setIconImage:[UIImage systemImageNamed:@"gear"]];
        [BMTikTokSettingsItemModel setType:99];

        [BMTikTokSettingsPluginCell setItemModel:BMTikTokSettingsItemModel];
        [self insertModel:BMTikTokSettingsPluginCell atIndex:0 animated:true];
    }
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 2. Feed & Ads
// ═══════════════════════════════════════════════════════════════

%hook AWEAwemeModel
// --- Lọc quảng cáo an toàn ---
- (BOOL)isAds {
    if ([BMIManager hideAds]) return YES;
    return %orig;
}
- (BOOL)isAd {
    if ([BMIManager hideAds]) return YES;
    return %orig;
}
- (BOOL)isCommerce {
    if ([BMIManager hideCommissionPosts]) return YES;
    return %orig;
}

// --- Chặn video AI ---
- (BOOL)isAIGC {
    if ([BMIManager blockAIGenerated]) return YES;
    return %orig;
}

// --- Progress bar ---
- (BOOL)progressBarDraggable {
    return [BMIManager progressBar] || %orig;
}
- (BOOL)progressBarVisible {
    return [BMIManager progressBar] || %orig;
}

// --- Disable live streams ---
- (void)live_callInitWithDictyCategoryMethod:(id)arg1 {
    if (![BMIManager disableLive]) {
        %orig;
    }
}
+ (id)liveStreamURLJSONTransformer {
    if ([BMIManager disableLive]) return nil;
    return %orig;
}
+ (id)relatedLiveJSONTransformer {
    if ([BMIManager disableLive]) return nil;
    return %orig;
}
+ (id)rawModelFromLiveRoomModel:(id)arg1 {
    if ([BMIManager disableLive]) return nil;
    return %orig;
}
+ (id)aweLiveRoom_subModelPropertyKey {
    if ([BMIManager disableLive]) return nil;
    return %orig;
}
%end

%hook AWEPlayInteractionWarningElementView
- (id)warningImage {
    if ([BMIManager disableWarnings]) return nil;
    return %orig;
}
- (id)warningLabel {
    if ([BMIManager disableWarnings]) return nil;
    return %orig;
}
%end

%hook AWENewFeedTableViewController
- (BOOL)disablePullToRefreshGestureRecognizer {
    if ([BMIManager disablePullToRefresh]) return 1;
    return %orig;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    %orig;
    if (gPureModeActive) {
        if ([cell respondsToSelector:@selector(applyPureModeState:animated:)]) {
            [((id)cell) applyPureModeState:YES animated:NO];
        }
        UIButton *btn = (UIButton *)[cell viewWithTag:999];
        if (btn) {
            [btn setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
            [cell bringSubviewToFront:btn];
        }
    }
}
%end

%hook AWEAwemeDetailTableViewController
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    %orig;
    if (gPureModeActive) {
        if ([cell respondsToSelector:@selector(applyPureModeState:animated:)]) {
            [((id)cell) applyPureModeState:YES animated:NO];
        }
        UIButton *btn = (UIButton *)[cell viewWithTag:999];
        if (btn) {
            [btn setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
            [cell bringSubviewToFront:btn];
        }
    }
}
%end

%hook TTKAdsTimerPendantAdapter
- (void)viewDidLoad {
    %orig;
    if ([BMIManager removePendant]) {
        [[self view] setHidden:YES];
    }
}
%end

%group LegacyFeatures
%hook AWEMainFeedAnchorView
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager removePendant]) {
        [self setHidden:YES];
    }
}
%end

%hook AWEPlayInteractionTakoElement
- (void)viewDidLoad {
    %orig;
    if ([BMIManager removeTikTokAIButton]) {
        [[self view] setHidden:YES];
    }
}
%end

%hook AWETakoEntranceView
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager removeTikTokAIButton]) {
        [self setHidden:YES];
    }
}
%end

%hook AWEAwemePlayVideoPauseIcon
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager hidePlayPause]) {
        [self setHidden:YES];
    }
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 3. Video Playback
// ═══════════════════════════════════════════════════════════════

%hook AWEPlayVideoPlayerController
- (void)playerWillLoopPlaying:(id)arg1 {
    if ([BMIManager autoPlay]) {
        UIViewController *parentVC = nil;
        if ([self.container respondsToSelector:@selector(parentViewController)]) {
            parentVC = [self.container parentViewController];
        }
        if ([parentVC isKindOfClass:%c(AWENewFeedTableViewController)]) {
            [((AWENewFeedTableViewController *)parentVC) scrollToNextVideo];
            return;
        }
    }
    %orig;
}
- (BOOL)loop {
    if ([BMIManager stopPlay]) return 0;
    return %orig;
}
- (void)setLoop:(BOOL)arg1 {
    if ([BMIManager stopPlay]) {
        %orig(0);
    } else {
        %orig;
    }
}
- (void)containerDidFullyDisplayWithReason:(NSInteger)arg1 {
    %orig;
    if (gPureModeActive) {
        UIViewController *parentVC = nil;
        if ([self.container respondsToSelector:@selector(parentViewController)]) {
            parentVC = [self.container parentViewController];
        }
        if ([parentVC respondsToSelector:@selector(setPureMode:animated:)]) {
            [((id)parentVC) setPureMode:YES animated:NO];
        }
        id interCtrl = nil;
        if ([parentVC respondsToSelector:@selector(interactionController)]) {
            interCtrl = [((id)parentVC) interactionController];
        }
        if (interCtrl) {
            if ([interCtrl respondsToSelector:@selector(setPureMode:animated:)]) {
                [((id)interCtrl) setPureMode:YES animated:NO];
            }
            if ([interCtrl respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
                [((id)interCtrl) hideAllElements:YES exceptArray:nil];
            }
            if ([interCtrl respondsToSelector:@selector(view)]) {
                UIView *interView = [((id)interCtrl) view];
                interView.alpha = 0.0;
            }
        }
    }
    if ([BMIManager skipRecommendations]) {
        UIViewController *parentVC = nil;
        if ([self.container respondsToSelector:@selector(parentViewController)]) {
            parentVC = [self.container parentViewController];
        }
        if ([parentVC isKindOfClass:%c(AWENewFeedTableViewController)]) {
            AWENewFeedTableViewController *rootVC = (AWENewFeedTableViewController *)parentVC;
            AWEAwemeModel *currentModel = [rootVC currentAweme];
            if ([currentModel isUserRecommendBigCard]) {
                [rootVC scrollToNextVideo];
                return;
            }
        }
    }
}
%end

%hook AWEPlayInteractionViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (gPureModeActive) {
        if ([self respondsToSelector:@selector(setPureMode:animated:)]) {
            [self setPureMode:YES animated:NO];
        }
        if ([self respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
            [self hideAllElements:YES exceptArray:nil];
        }
        self.view.alpha = 0.0;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (gPureModeActive) {
        if ([self respondsToSelector:@selector(setPureMode:animated:)]) {
            [self setPureMode:YES animated:NO];
        }
        if ([self respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
            [self hideAllElements:YES exceptArray:nil];
        }
        self.view.alpha = 0.0;
    }
}

- (void)hideAllElements:(BOOL)arg1 exceptArray:(id)arg2 {
    if (gPureModeActive) {
        %orig(YES, nil);
        return;
    }
    %orig;
}

- (void)hideAllElements:(BOOL)arg1 animate:(BOOL)arg2 exceptArray:(id)3 {
    if (gPureModeActive) {
        %orig(YES, NO, nil);
        return;
    }
    %orig;
}

- (void)hideAllElements:(BOOL)arg1 animate:(BOOL)arg2 duration:(NSTimeInterval)arg3 exceptArray:(id)arg4 {
    if (gPureModeActive) {
        %orig(YES, NO, 0.0, nil);
        return;
    }
    %orig;
}

- (void)showAllElements {
    if (gPureModeActive) {
        return;
    }
    %orig;
}

- (void)showAllComponents {
    if (gPureModeActive) {
        return;
    }
    %orig;
}

- (void)setPureMode:(BOOL)arg1 animated:(BOOL)arg2 {
    if (gPureModeActive) {
        %orig(YES, NO);
        return;
    }
    %orig;
}
%end

%hook AWEAwemeBaseViewController
- (void)setPureMode:(BOOL)arg1 animated:(BOOL)arg2 {
    if (gPureModeActive) {
        %orig(YES, NO);
        return;
    }
    %orig;
}

- (void)setPureMode:(BOOL)arg1 animation:(BOOL)arg2 {
    if (gPureModeActive) {
        %orig(YES, NO);
        return;
    }
    %orig;
}

- (void)setPureMode:(BOOL)arg1 animateDuration:(NSTimeInterval)arg2 {
    if (gPureModeActive) {
        %orig(YES, 0.0);
        return;
    }
    %orig;
}

- (BOOL)pureMode {
    if (gPureModeActive) return YES;
    return %orig;
}

- (BOOL)isInPureMode {
    if (gPureModeActive) return YES;
    return %orig;
}

- (BOOL)isPureMode {
    if (gPureModeActive) return YES;
    return %orig;
}

- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if (gPureModeActive) {
        [self setPureMode:YES animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if (gPureModeActive) {
        [self setPureMode:YES animated:NO];
    }
}
%end

%hook TTKMediaSpeedControlService
- (void)setPlaybackRate:(CGFloat)arg1 {
    NSNumber *speed = [BMIManager selectedSpeed];
    if (![BMIManager speedEnabled] || [speed isEqualToNumber:@1]) {
        return %orig;
    }
    if ([BMIManager speedEnabled]) {
        if ([BMIManager selectedSpeed]) {
            return %orig([speed floatValue]);
        }
    } else {
        return %orig;
    }
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 4. Download & Media Buttons
// ═══════════════════════════════════════════════════════════════

%hook AWEFeedViewTemplateCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property (nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, retain) UIProgressView *progressView;

- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = gPureModeActive;
    [self applyPureModeState:gPureModeActive animated:NO];
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}

- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = gPureModeActive;
    [self applyPureModeState:gPureModeActive animated:NO];
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}

- (void)cellWillDisplay {
    %orig;
    if (gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)cellDidFullyDisplay {
    %orig;
    if (gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)prepareForReuse {
    %orig;
    self.elementsHidden = gPureModeActive;
    if (gPureModeActive) {
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)didMoveToWindow {
    %orig;
    if (self.window && gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(downloadButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];

        [NSLayoutConstraint activateConstraints:@[
            [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:90],
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [downloadButton.widthAnchor constraintEqualToConstant:34],
            [downloadButton.heightAnchor constraintEqualToConstant:34],
        ]];
    }
}

%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *itemID = rootVC.model.itemID;
    self.fileextension = @"mp4";
    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = @"Đang lấy link HD...";
    [self.hud showInView:topMostController().view];

    // Ưu tiên 1: Lấy URL H.264 bitrate cao nhất từ Model gốc
    NSURL *directHDURL = [rootVC.model.video.playAddrH264 bestURLtoDownload];
    if (!directHDURL) {
        directHDURL = [rootVC.model.video.h264URL bestURLtoDownload];
    }

    if (itemID.length > 0) {
        // Thử lấy link từ API TikWM chất lượng HD
        NSString *apiURLStr = [NSString stringWithFormat:@"https://www.tikwm.com/api/?url=https://www.tiktok.com/@i/video/%@", itemID];
        NSURL *apiURL = [NSURL URLWithString:apiURLStr];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:apiURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSURL *finalURL = directHDURL;
            if (!error && data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSDictionary class]] && [json[@"code"] integerValue] == 0) {
                    NSDictionary *dataDict = json[@"data"];
                    NSString *hdURLStr = dataDict[@"hdplay"] ?: dataDict[@"play"];
                    if (hdURLStr.length > 0) {
                        finalURL = [NSURL URLWithString:hdURLStr];
                    }
                }
            }
            if (!finalURL) {
                finalURL = [rootVC.model.video.playURL bestURLtoDownload];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finalURL) {
                    BMDownload *dwManager = [[BMDownload alloc] init];
                    [dwManager downloadFileWithURL:finalURL];
                    [dwManager setDelegate:self];
                    self.hud.textLabel.text = @"Đang tải video HD...";
                } else {
                    [self.hud dismiss];
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể lấy liên kết video HD." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            });
        }];
        [task resume];
    } else if (directHDURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:directHDURL];
        [dwManager setDelegate:self];
        self.hud.textLabel.text = @"Đang tải video HD...";
    } else {
        NSURL *normalURL = [rootVC.model.video.playURL bestURLtoDownload];
        if (normalURL) {
            BMDownload *dwManager = [[BMDownload alloc] init];
            [dwManager downloadFileWithURL:normalURL];
            [dwManager setDelegate:self];
            self.hud.textLabel.text = @"Đang tải video...";
        } else {
            [self.hud dismiss];
            [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không tìm thấy liên kết tải video." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        }
    }
}

%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat] ?: @"mp4";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Đang tải video...";
        [self.hud showInView:topMostController().view];
    }
}

%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC photoIndex:(unsigned long)index {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    if (index < photos.count) {
        AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:index];
        NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
        self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat] ?: @"jpg";
        if (downloadableURL) {
            BMDownload *dwManager = [[BMDownload alloc] init];
            [dwManager downloadFileWithURL:downloadableURL];
            [dwManager setDelegate:self];
            self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            self.hud.textLabel.text = [NSString stringWithFormat:@"Đang tải ảnh %lu...", index + 1];
            [self.hud showInView:topMostController().view];
        }
    }
}

%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC {
    NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
    NSMutableArray<NSURL *> *fileURLs = [NSMutableArray array];

    for (AWEPhotoAlbumPhoto *currentPhoto in photos) {
        NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
        self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat] ?: @"jpg";
        if (downloadableURL) {
            [fileURLs addObject:downloadableURL];
        }
    }

    if (fileURLs.count > 0) {
        BMMultipleDownload *dwManager = [[BMMultipleDownload alloc] init];
        [dwManager setDelegate:self];
        [dwManager downloadFiles:fileURLs];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = [NSString stringWithFormat:@"Đang tải %lu ảnh...", (unsigned long)fileURLs.count];
        [self.hud showInView:topMostController().view];
    }
}

%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = @"mp3";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Đang tải âm thanh...";
        [self.hud showInView:topMostController().view];
    }
}

%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép liên kết âm thanh vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể sao chép liên kết âm thanh." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép liên kết video vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể sao chép liên kết video." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = rootVC.model.music_songName;
    if (video_description.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép nội dung vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không có nội dung mô tả để sao chép." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)downloadButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC isKindOfClass:%c(AWEFeedCellViewController)]) {
        UIAction *action0 = [UIAction actionWithTitle:@"Tải Video HD (Siêu Nét)"
                                                image:[UIImage systemImageNamed:@"sparkles.tv"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadHDVideo:rootVC]; });
            } else {
                [self downloadHDVideo:rootVC];
            }
        }];
        UIAction *action1 = [UIAction actionWithTitle:@"Tải Video (Gốc)"
                                                image:[UIImage systemImageNamed:@"film"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadVideo:rootVC]; });
            } else {
                [self downloadVideo:rootVC];
            }
        }];
        UIAction *action2 = [UIAction actionWithTitle:@"Tải Nhạc Nền / MP3"
                                                image:[UIImage systemImageNamed:@"music.note"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadMusic:rootVC]; });
            } else {
                [self downloadMusic:rootVC];
            }
        }];
        UIAction *action3 = [UIAction actionWithTitle:@"Sao Chép Link Âm Thanh"
                                                image:[UIImage systemImageNamed:@"link"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }];
        UIAction *action4 = [UIAction actionWithTitle:@"Sao Chép Link Video"
                                                image:[UIImage systemImageNamed:@"doc.on.doc"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }];
        UIAction *action5 = [UIAction actionWithTitle:@"Sao Chép Nội Dung Caption"
                                                image:[UIImage systemImageNamed:@"text.bubble"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }];
        UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Menu Tải Xuống" children:@[action0, action1, action2]];
        UIMenu *copyMenu = [UIMenu menuWithTitle:@"Menu Sao Chép" children:@[action3, action4, action5]];
        UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[downloadMenu, copyMenu]];
        [sender setMenu:mainMenu];
        sender.showsMenuAsPrimaryAction = YES;
    } else if ([self.viewController isKindOfClass:%c(TTKPhotoAlbumDetailCellController)] || [self.viewController isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        TTKPhotoAlbumDetailCellController *albumVC = (TTKPhotoAlbumDetailCellController *)self.viewController;
        NSArray <AWEPhotoAlbumPhoto *> *photos = albumVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        NSMutableArray <UIAction *> *photosActions = [NSMutableArray array];
        for (int i = 0; i < photosCount; i++) {
            NSString *title = [NSString stringWithFormat:@"Tải Ảnh %d", i + 1];
            UIAction *action = [UIAction actionWithTitle:title
                                                   image:[UIImage systemImageNamed:@"photo.fill"]
                                              identifier:nil
                                                 handler:^(__kindof UIAction * _Nonnull action) {
                [self downloadPhotos:albumVC photoIndex:i];
            }];
            [photosActions addObject:action];
        }
        UIAction *allPhotosAction = [UIAction actionWithTitle:[NSString stringWithFormat:@"Tải Toàn Bộ Ảnh (%lu)", photosCount]
                                                        image:[UIImage systemImageNamed:@"square.and.arrow.down.on.square.fill"]
                                                   identifier:nil
                                                      handler:^(__kindof UIAction * _Nonnull action) {
            [self downloadPhotos:albumVC];
        }];
        [photosActions addObject:allPhotosAction];
        UIAction *action2 = [UIAction actionWithTitle:@"Tải Nhạc Nền / MP3"
                                                image:[UIImage systemImageNamed:@"music.note"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self downloadMusic:albumVC];
        }];
        UIAction *action3 = [UIAction actionWithTitle:@"Sao Chép Link Âm Thanh"
                                                image:[UIImage systemImageNamed:@"link"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyMusic:albumVC];
        }];
        UIAction *action4 = [UIAction actionWithTitle:@"Sao Chép Link Video"
                                                image:[UIImage systemImageNamed:@"doc.on.doc"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyVideo:albumVC];
        }];
        UIAction *action5 = [UIAction actionWithTitle:@"Sao Chép Nội Dung Caption"
                                                image:[UIImage systemImageNamed:@"text.bubble"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyDecription:albumVC];
        }];
        UIMenu *photosMenu = [UIMenu menuWithTitle:@"Menu Tải Bộ Ảnh" children:photosActions];
        UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Menu Tải Xuống" children:@[action2]];
        UIMenu *copyMenu = [UIMenu menuWithTitle:@"Menu Sao Chép" children:@[action3, action4, action5]];
        UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[photosMenu, downloadMenu, copyMenu]];
        [sender setMenu:mainMenu];
        sender.showsMenuAsPrimaryAction = YES;
    }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = (UIButton *)[self viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hideElementButton setTag:999];
        [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
        [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:34],
            [hideElementButton.heightAnchor constraintEqualToConstant:34],
        ]];
    }
    [hideElementButton setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
}

%new - (void)applyPureModeState:(BOOL)hide animated:(BOOL)animated {
    UIViewController *rootVC = nil;
    if ([self respondsToSelector:@selector(viewController)]) {
        rootVC = [self performSelector:@selector(viewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(cellViewController)]) {
        rootVC = [self performSelector:@selector(cellViewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(btd_viewController)]) {
        rootVC = [self performSelector:@selector(btd_viewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(parentViewController)]) {
        rootVC = [self performSelector:@selector(parentViewController)];
    }
    if (!rootVC) {
        UIResponder *responder = self;
        while (responder) {
            if ([responder isKindOfClass:[UIViewController class]]) {
                rootVC = (UIViewController *)responder;
                break;
            }
            responder = [responder nextResponder];
        }
    }
    
    if (rootVC) {
        if ([rootVC respondsToSelector:@selector(setPureMode:animated:)]) {
            [((id)rootVC) setPureMode:hide animated:animated];
        }
        if ([rootVC respondsToSelector:@selector(setNeedsSetPureMode:)]) {
            [((id)rootVC) setNeedsSetPureMode:hide];
        }
        id interactionController = nil;
        if ([rootVC respondsToSelector:@selector(interactionController)]) {
            interactionController = [((id)rootVC) interactionController];
        }
        if (interactionController) {
            if ([interactionController respondsToSelector:@selector(setPureMode:animated:)]) {
                [((id)interactionController) setPureMode:hide animated:animated];
            }
            if ([interactionController respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
                [((id)interactionController) hideAllElements:hide exceptArray:nil];
            }
            if ([interactionController respondsToSelector:@selector(view)]) {
                UIView *interView = [((id)interactionController) view];
                if (interView) {
                    if (animated) {
                        [UIView animateWithDuration:0.25 animations:^{
                            interView.alpha = hide ? 0.0 : 1.0;
                        }];
                    } else {
                        interView.alpha = hide ? 0.0 : 1.0;
                    }
                }
            }
        }
        
        // Ẩn thanh Tab Bar trên cùng (Following, For You, Live, Search)
        UIViewController *parentContainer = rootVC.parentViewController ?: rootVC;
        if (parentContainer.view) {
            for (UIView *v in parentContainer.view.subviews) {
                if ([v isKindOfClass:%c(TikTokFeedTabControl)]) {
                    if (animated) {
                        [UIView animateWithDuration:0.25 animations:^{
                            v.alpha = hide ? 0.0 : 1.0;
                        }];
                    } else {
                        v.alpha = hide ? 0.0 : 1.0;
                    }
                }
            }
        }
    }
    
    // Duyệt trực tiếp subviews trong cell để ẩn/hiện mọi view tương tác
    void (^processSubviews)(UIView *) = ^(UIView *container) {
        if (!container) return;
        for (UIView *v in container.subviews) {
            if (v.tag == 998 || v.tag == 999) {
                [container bringSubviewToFront:v];
                continue;
            }
            NSString *cls = NSStringFromClass([v class]);
            if ([cls containsString:@"Interaction"] || [cls containsString:@"AWEPlayVideoPauseIcon"] || [cls containsString:@"Pendant"]) {
                if (animated) {
                    [UIView animateWithDuration:0.25 animations:^{
                        v.alpha = hide ? 0.0 : 1.0;
                    }];
                } else {
                    v.alpha = hide ? 0.0 : 1.0;
                }
            }
        }
    };
    processSubviews(self);
    processSubviews(self.contentView);
    
    UIButton *eyeBtn = (UIButton *)[self viewWithTag:999];
    if (eyeBtn) {
        [self bringSubviewToFront:eyeBtn];
    }
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    gPureModeActive = !gPureModeActive;
    self.elementsHidden = gPureModeActive;
    [sender setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
    [self applyPureModeState:gPureModeActive animated:YES];
}

%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BMIManager getDownloadingPersent:progress];
}

%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    if ([BMIManager shareSheet]) {
        [BMIManager showSaveVC:downloadedFilePaths];
    } else {
        for (NSURL *url in downloadedFilePaths) {
            [BMIManager saveMedia:url fileExtension:self.fileextension];
        }
    }
}

%new - (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}

%new - (void)downloadProgress:(float)progress {
    self.progressView.progress = progress;
    self.hud.detailTextLabel.text = [BMIManager getDownloadingPersent:progress];
    self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
        self.hud.textLabel.text = @"Đang chạy nền ✌️";
        [self.hud dismissAfterDelay:0.4];
    };
}

%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:docPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BMIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BMIManager showSaveVC:@[newFilePath]];
    } else {
        [BMIManager saveMedia:newFilePath fileExtension:self.fileextension];
    }
}

%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

%hook AWEAwemeDetailTableViewCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property (nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) UIProgressView *progressView;
%property (nonatomic, retain) NSString *fileextension;

- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = gPureModeActive;
    [self applyPureModeState:gPureModeActive animated:NO];
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}

- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = gPureModeActive;
    [self applyPureModeState:gPureModeActive animated:NO];
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}

- (void)cellWillDisplay {
    %orig;
    if (gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)cellDidFullyDisplay {
    %orig;
    if (gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)prepareForReuse {
    %orig;
    self.elementsHidden = gPureModeActive;
    if (gPureModeActive) {
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

- (void)didMoveToWindow {
    %orig;
    if (self.window && gPureModeActive) {
        self.elementsHidden = YES;
        [self applyPureModeState:YES animated:NO];
    }
    UIButton *btn = (UIButton *)[self viewWithTag:999];
    if (btn) {
        [btn setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
        [self bringSubviewToFront:btn];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(downloadButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];

        [NSLayoutConstraint activateConstraints:@[
            [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:90],
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [downloadButton.widthAnchor constraintEqualToConstant:34],
            [downloadButton.heightAnchor constraintEqualToConstant:34],
        ]];
    }
}

%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *itemID = rootVC.model.itemID;
    self.fileextension = @"mp4";
    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    self.hud.textLabel.text = @"Đang lấy link HD...";
    [self.hud showInView:topMostController().view];

    NSURL *directHDURL = [rootVC.model.video.playAddrH264 bestURLtoDownload];
    if (!directHDURL) {
        directHDURL = [rootVC.model.video.h264URL bestURLtoDownload];
    }

    if (itemID.length > 0) {
        NSString *apiURLStr = [NSString stringWithFormat:@"https://www.tikwm.com/api/?url=https://www.tiktok.com/@i/video/%@", itemID];
        NSURL *apiURL = [NSURL URLWithString:apiURLStr];
        NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:apiURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSURL *finalURL = directHDURL;
            if (!error && data) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if ([json isKindOfClass:[NSDictionary class]] && [json[@"code"] integerValue] == 0) {
                    NSDictionary *dataDict = json[@"data"];
                    NSString *hdURLStr = dataDict[@"hdplay"] ?: dataDict[@"play"];
                    if (hdURLStr.length > 0) {
                        finalURL = [NSURL URLWithString:hdURLStr];
                    }
                }
            }
            if (!finalURL) {
                finalURL = [rootVC.model.video.playURL bestURLtoDownload];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (finalURL) {
                    BMDownload *dwManager = [[BMDownload alloc] init];
                    [dwManager downloadFileWithURL:finalURL];
                    [dwManager setDelegate:self];
                    self.hud.textLabel.text = @"Đang tải video HD...";
                } else {
                    [self.hud dismiss];
                    [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể lấy liên kết video HD." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
                }
            });
        }];
        [task resume];
    } else if (directHDURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:directHDURL];
        [dwManager setDelegate:self];
        self.hud.textLabel.text = @"Đang tải video HD...";
    } else {
        NSURL *normalURL = [rootVC.model.video.playURL bestURLtoDownload];
        if (normalURL) {
            BMDownload *dwManager = [[BMDownload alloc] init];
            [dwManager downloadFileWithURL:normalURL];
            [dwManager setDelegate:self];
            self.hud.textLabel.text = @"Đang tải video...";
        } else {
            [self.hud dismiss];
            [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không tìm thấy liên kết tải video." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
        }
    }
}

%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat] ?: @"mp4";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Đang tải video...";
        [self.hud showInView:topMostController().view];
    }
}

%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = @"mp3";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Đang tải âm thanh...";
        [self.hud showInView:topMostController().view];
    }
}

%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép liên kết âm thanh vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể sao chép liên kết âm thanh." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép liên kết video vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không thể sao chép liên kết video." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = rootVC.model.music_songName;
    if (video_description.length > 0) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Đã sao chép nội dung vào bộ nhớ tạm!" image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok" description:@"Không có nội dung mô tả để sao chép." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}

%new - (void)downloadButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if (rootVC) {
        UIAction *action0 = [UIAction actionWithTitle:@"Tải Video HD (Siêu Nét)"
                                                image:[UIImage systemImageNamed:@"sparkles.tv"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadHDVideo:rootVC]; });
            } else {
                [self downloadHDVideo:rootVC];
            }
        }];
        UIAction *action1 = [UIAction actionWithTitle:@"Tải Video (Gốc)"
                                                image:[UIImage systemImageNamed:@"film"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadVideo:rootVC]; });
            } else {
                [self downloadVideo:rootVC];
            }
        }];
        UIAction *action2 = [UIAction actionWithTitle:@"Tải Nhạc Nền / MP3"
                                                image:[UIImage systemImageNamed:@"music.note"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            if ([BMIManager downloadConfirmation]) {
                showConfirmation(^{ [self downloadMusic:rootVC]; });
            } else {
                [self downloadMusic:rootVC];
            }
        }];
        UIAction *action3 = [UIAction actionWithTitle:@"Sao Chép Link Âm Thanh"
                                                image:[UIImage systemImageNamed:@"link"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyMusic:rootVC];
        }];
        UIAction *action4 = [UIAction actionWithTitle:@"Sao Chép Link Video"
                                                image:[UIImage systemImageNamed:@"doc.on.doc"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyVideo:rootVC];
        }];
        UIAction *action5 = [UIAction actionWithTitle:@"Sao Chép Nội Dung Caption"
                                                image:[UIImage systemImageNamed:@"text.bubble"]
                                           identifier:nil
                                              handler:^(__kindof UIAction * _Nonnull action) {
            [self copyDecription:rootVC];
        }];
        UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Menu Tải Xuống" children:@[action0, action1, action2]];
        UIMenu *copyMenu = [UIMenu menuWithTitle:@"Menu Sao Chép" children:@[action3, action4, action5]];
        UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[downloadMenu, copyMenu]];
        [sender setMenu:mainMenu];
        sender.showsMenuAsPrimaryAction = YES;
    }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = (UIButton *)[self viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hideElementButton setTag:999];
        [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
        [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:34],
            [hideElementButton.heightAnchor constraintEqualToConstant:34],
        ]];
    }
    [hideElementButton setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
}

%new - (void)applyPureModeState:(BOOL)hide animated:(BOOL)animated {
    UIViewController *rootVC = nil;
    if ([self respondsToSelector:@selector(viewController)]) {
        rootVC = [self performSelector:@selector(viewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(cellViewController)]) {
        rootVC = [self performSelector:@selector(cellViewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(btd_viewController)]) {
        rootVC = [self performSelector:@selector(btd_viewController)];
    }
    if (!rootVC && [self respondsToSelector:@selector(parentViewController)]) {
        rootVC = [self performSelector:@selector(parentViewController)];
    }
    if (!rootVC) {
        UIResponder *responder = self;
        while (responder) {
            if ([responder isKindOfClass:[UIViewController class]]) {
                rootVC = (UIViewController *)responder;
                break;
            }
            responder = [responder nextResponder];
        }
    }
    
    if (rootVC) {
        if ([rootVC respondsToSelector:@selector(setPureMode:animated:)]) {
            [((id)rootVC) setPureMode:hide animated:animated];
        }
        if ([rootVC respondsToSelector:@selector(setNeedsSetPureMode:)]) {
            [((id)rootVC) setNeedsSetPureMode:hide];
        }
        id interactionController = nil;
        if ([rootVC respondsToSelector:@selector(interactionController)]) {
            interactionController = [((id)rootVC) interactionController];
        }
        if (interactionController) {
            if ([interactionController respondsToSelector:@selector(setPureMode:animated:)]) {
                [((id)interactionController) setPureMode:hide animated:animated];
            }
            if ([interactionController respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
                [((id)interactionController) hideAllElements:hide exceptArray:nil];
            }
            if ([interactionController respondsToSelector:@selector(view)]) {
                UIView *interView = [((id)interactionController) view];
                if (interView) {
                    if (animated) {
                        [UIView animateWithDuration:0.25 animations:^{
                            interView.alpha = hide ? 0.0 : 1.0;
                        }];
                    } else {
                        interView.alpha = hide ? 0.0 : 1.0;
                    }
                }
            }
        }
    }
    
    // Duyệt trực tiếp subviews trong cell để ẩn/hiện mọi view tương tác
    void (^processSubviews)(UIView *) = ^(UIView *container) {
        if (!container) return;
        for (UIView *v in container.subviews) {
            if (v.tag == 998 || v.tag == 999) {
                [container bringSubviewToFront:v];
                continue;
            }
            NSString *cls = NSStringFromClass([v class]);
            if ([cls containsString:@"Interaction"] || [cls containsString:@"AWEPlayVideoPauseIcon"] || [cls containsString:@"Pendant"]) {
                if (animated) {
                    [UIView animateWithDuration:0.25 animations:^{
                        v.alpha = hide ? 0.0 : 1.0;
                    }];
                } else {
                    v.alpha = hide ? 0.0 : 1.0;
                }
            }
        }
    };
    processSubviews(self);
    processSubviews(self.contentView);
    
    UIButton *eyeBtn = (UIButton *)[self viewWithTag:999];
    if (eyeBtn) {
        [self bringSubviewToFront:eyeBtn];
    }
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    gPureModeActive = !gPureModeActive;
    self.elementsHidden = gPureModeActive;
    [sender setImage:[UIImage systemImageNamed:(gPureModeActive ? @"eye" : @"eye.slash")] forState:UIControlStateNormal];
    [self applyPureModeState:gPureModeActive animated:YES];
}
%end

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSString *bestURLFormat = nil;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"]) {
            bestURLFormat = @"mp4";
        } else if ([url containsString:@".jpeg"]) {
            bestURLFormat = @"jpeg";
        } else if ([url containsString:@".png"]) {
            bestURLFormat = @"png";
        } else if ([url containsString:@".mp3"]) {
            bestURLFormat = @"mp3";
        } else if ([url containsString:@".m4a"]) {
            bestURLFormat = @"m4a";
        }
    }
    if (bestURLFormat == nil) {
        bestURLFormat = @"mp4";
    }
    return bestURLFormat;
}

%new - (NSURL *)bestURLtoDownload {
    NSURL *bestURL = nil;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"] || [url containsString:@".jpeg"] || [url containsString:@".mp3"]) {
            bestURL = [NSURL URLWithString:url];
        }
    }
    if (bestURL == nil) {
        bestURL = [NSURL URLWithString:[self.originURLList firstObject]];
    }
    return bestURL;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 5. Region & Location
// ═══════════════════════════════════════════════════════════════

%hook CTCarrier
- (NSString *)mobileCountryCode {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"mcc"]) {
            return selectedRegion[@"mcc"];
        }
    }
    return %orig;
}

- (NSString *)isoCountryCode {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}

- (NSString *)mobileNetworkCode {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"mnc"]) {
            return selectedRegion[@"mnc"];
        }
    }
    return %orig;
}
%end

%hook TTKStoreRegionService
- (id)storeRegion {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return [selectedRegion[@"code"] lowercaseString];
        }
    }
    return %orig;
}
- (id)getStoreRegion {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return [selectedRegion[@"code"] lowercaseString];
        }
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
    }
    %orig(arg1);
}
%end

%hook TIKTOKRegionManager
+ (NSString *)systemRegion {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}
+ (id)region {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}
+ (id)mccmnc {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"mcc"] && selectedRegion[@"mnc"]) {
            return [NSString stringWithFormat:@"%@%@", selectedRegion[@"mcc"], selectedRegion[@"mnc"]];
        }
    }
    return %orig;
}
+ (id)storeRegion {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}
+ (id)currentRegionV2 {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}
+ (id)localRegion {
    if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            return selectedRegion[@"code"];
        }
    }
    return %orig;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 6. Privacy & Ghost Mode (Chế độ ẩn danh toàn diện)
// ═══════════════════════════════════════════════════════════════

static BOOL bm_isSendingReply = NO;

// 1. Mark Seen on Reply & Anonymous DM Seen
%hook TIMMessageSender
- (void)sendMessage:(id)msg conversationType:(long long)type conversationShortID:(long long)shortID conversationID:(id)cid inInbox:(int)inbox clientExt:(id)ext forceUpdateShortID:(BOOL)force sendMediaList:(id)media bizTransientExtra:(id)extra source:(id)src {
    bm_isSendingReply = YES;
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        bm_isSendingReply = NO;
    });
}
- (void)markConversationAsRead:(id)arg1 {
    if ([BMIManager anonymousSeen]) {
        if ([BMIManager markSeenOnReply] && bm_isSendingReply) {
            %orig;
            return;
        }
        return;
    }
    %orig;
}
- (void)markConversationAsRead:(id)arg1 tillIndex:(long long)arg2 badgeCount:(long long)arg3 {
    if ([BMIManager anonymousSeen]) {
        if ([BMIManager markSeenOnReply] && bm_isSendingReply) {
            %orig;
            return;
        }
        return;
    }
    %orig;
}

// 2. Disable Typing Status in DM (Ẩn biểu tượng đang soạn tin)
- (void)sendInputStatusMessageWithStatus:(long long)arg1 extra:(id)arg2 conversationType:(long long)arg3 conversationShortID:(long long)arg4 conversationID:(id)arg5 inInbox:(int)arg6 {
    if ([BMIManager disableTyping]) return;
    %orig;
}
- (void)sendInputStatusMessageWithInputStatus:(long long)arg1 conversationID:(id)arg2 extra:(id)arg3 completion:(id)arg4 {
    if ([BMIManager disableTyping]) {
        if (arg4) {
            void (^completionBlock)(id, id) = (void (^)(id, id))arg4;
            completionBlock(nil, nil);
        }
        return;
    }
    %orig;
}
%end

%hook AWEIMMessage
- (void)markAsRead {
    if ([BMIManager anonymousSeen]) {
        if ([BMIManager markSeenOnReply] && bm_isSendingReply) {
            %orig;
            return;
        }
        return;
    }
    %orig;
}
%end

%hook AWEIMInputStatusHandler
- (void)sendInputStatusWithConversationID:(id)arg1 inputStatus:(long long)arg2 {
    if ([BMIManager disableTyping]) return;
    %orig;
}
- (void)sendInputStatusWithConversationID:(id)arg1 {
    if ([BMIManager disableTyping]) return;
    %orig;
}
%end

// 3. Anonymous Story Seen (Xem tin & Story ẩn danh)
%hook TTKStoryNetworkService
+ (void)reportStoryViewedWithStoryID:(id)storyID uid:(id)uid unlocked:(BOOL)unlocked completion:(id)completion {
    if ([BMIManager anonymousSeen]) {
        if (completion) {
            void (^completionBlock)(id, id) = (void (^)(id, id))completion;
            completionBlock(nil, nil);
        }
        return;
    }
    %orig;
}
+ (void)reportStoryViewedWithStoryID:(id)storyID uid:(id)uid completion:(id)completion {
    if ([BMIManager anonymousSeen]) {
        if (completion) {
            void (^completionBlock)(id, id) = (void (^)(id, id))completion;
            completionBlock(nil, nil);
        }
        return;
    }
    %orig;
}
+ (void)reportRevealStorySessionWithType:(long long)type reportTime:(id)time completion:(id)completion {
    if ([BMIManager anonymousSeen]) {
        if (completion) {
            void (^completionBlock)(id, id) = (void (^)(id, id))completion;
            completionBlock(nil, nil);
        }
        return;
    }
    %orig;
}
%end

%hook TTKSkylightStoryDataController
- (void)_reportStoryRead:(id)arg1 authorID:(id)arg2 unlocked:(BOOL)arg3 retryCnt:(long long)arg4 {
    if ([BMIManager anonymousSeen]) return;
    %orig;
}
%end

// 4. View Profiles Anonymously (Xem hồ sơ ẩn danh, không gửi view record)
%hook TTKProfileViewsVisitor
- (void)reportProfileView {
    if ([BMIManager viewProfilesAnonymous]) return;
    %orig;
}
%end

// 5. Anti Screenshot & Screen Recording Detection (Chống phát hiện chụp / quay màn hình)
%hook AWEScreenShotTracker
- (void)userDidTakeScreenshot:(id)arg1 {
    if ([BMIManager disableScreenshotDetection]) return;
    %orig(arg1);
}
- (void)userDidTakeScreenShot:(id)arg1 {
    if ([BMIManager disableScreenshotDetection]) return;
    %orig(arg1);
}
%end

%hook UIScreen
- (BOOL)isCaptured {
    if ([BMIManager disableScreenrecordingDetection]) {
        return NO;
    }
    return %orig;
}
%end

// 6. Hide Online Activity Status (Luôn ẩn chấm xanh trực tuyến)
%hook AWEIMActivityStatusSettingManager
- (BOOL)recordUserActivityStatusEnabled {
    if ([BMIManager hideActivityStatus]) {
        return NO;
    }
    return %orig;
}
%end

%hook AWEIMActivityStatusReportManager
- (void)p_reportActivityStatusIfNeededWithParams:(id)arg1 {
    if ([BMIManager hideActivityStatus]) return;
    %orig;
}
- (void)p_reportActivityStatusWithParams:(id)arg1 {
    if ([BMIManager hideActivityStatus]) return;
    %orig;
}
- (void)p_startReportTimerIfNeeded {
    if ([BMIManager hideActivityStatus]) return;
    %orig;
}
- (void)requestReportCurrentUserActivityStatusWithType:(long long)arg1 sceneType:(long long)arg2 onCompletion:(id)arg3 {
    if ([BMIManager hideActivityStatus]) {
        if (arg3) {
            void (^completionBlock)(id, id) = (void (^)(id, id))arg3;
            completionBlock(nil, nil);
        }
        return;
    }
    %orig;
}
- (void)reportActivityStatusForRegularIfNeeded {
    if ([BMIManager hideActivityStatus]) return;
    %orig;
}
- (void)reportActivityStatusForColdLaunchIfNeeded {
    if ([BMIManager hideActivityStatus]) return;
    %orig;
}
%end

%hook AWEIMActivityStatusView
- (void)setHidden:(BOOL)hidden {
    if ([BMIManager hideActivityStatus]) {
        %orig(YES);
        return;
    }
    %orig(hidden);
}
%end

%hook TTKInboxActivityStatusView
- (void)setHidden:(BOOL)hidden {
    if ([BMIManager hideActivityStatus]) {
        %orig(YES);
        return;
    }
    %orig(hidden);
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 7. Profile & User UI
// ═══════════════════════════════════════════════════════════════

%hook AWEUserWorkCollectionViewCell
- (void)configWithModel:(id)arg1 isMine:(BOOL)arg2 {
    %orig;
    if ([BMIManager videoLikeCount] || [BMIManager videoUploadDate]) {
        for (UIView *j in self.contentView.subviews) {
            if (j.tag == 1001 || j.tag == 1002) {
                [j removeFromSuperview];
            }
        }

        AWEAwemeModel *model = [self model];
        AWEAwemeStatisticsModel *statistics = [model statistics];
        NSNumber *createTime = [model createTime];
        NSNumber *likeCount = [statistics diggCount];
        NSString *likeCountFormatted = [self formattedNumber:[likeCount integerValue]];
        NSString *formattedDate = [self formattedDateStringFromTimestamp:[createTime doubleValue]];

        UILabel *likeCountLabel = [UILabel new];
        likeCountLabel.text = likeCountFormatted;
        likeCountLabel.textColor = [UIColor whiteColor];
        likeCountLabel.font = [UIFont boldSystemFontOfSize:13.0];
        likeCountLabel.tag = 1001;
        [likeCountLabel setTranslatesAutoresizingMaskIntoConstraints:false];
        
        UIImageView *heartImage = [UIImageView new];
        heartImage.image = [UIImage systemImageNamed:@"heart"];
        heartImage.tintColor = [UIColor whiteColor];
        [heartImage setTranslatesAutoresizingMaskIntoConstraints:false];

        UILabel *uploadDateLabel = [UILabel new];
        uploadDateLabel.text = formattedDate;
        uploadDateLabel.textColor = [UIColor whiteColor];
        uploadDateLabel.font = [UIFont boldSystemFontOfSize:13.0];
        uploadDateLabel.tag = 1002;
        [uploadDateLabel setTranslatesAutoresizingMaskIntoConstraints:false];

        UIImageView *clockImage = [UIImageView new];
        clockImage.image = [UIImage systemImageNamed:@"clock"];
        clockImage.tintColor = [UIColor whiteColor];
        [clockImage setTranslatesAutoresizingMaskIntoConstraints:false];

        if ([BMIManager videoLikeCount]) {
            [self.contentView addSubview:heartImage];
            [NSLayoutConstraint activateConstraints:@[
                [heartImage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:110],
                [heartImage.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:4],
                [heartImage.widthAnchor constraintEqualToConstant:16],
                [heartImage.heightAnchor constraintEqualToConstant:16],
            ]];
            [self.contentView addSubview:likeCountLabel];
            [NSLayoutConstraint activateConstraints:@[
                [likeCountLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:109],
                [likeCountLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:23],
                [likeCountLabel.widthAnchor constraintEqualToConstant:200],
                [likeCountLabel.heightAnchor constraintEqualToConstant:16],
            ]];
        }
        if ([BMIManager videoUploadDate]) {
            [self.contentView addSubview:clockImage];
            [NSLayoutConstraint activateConstraints:@[
                [clockImage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:128],
                [clockImage.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:4],
                [clockImage.widthAnchor constraintEqualToConstant:16],
                [clockImage.heightAnchor constraintEqualToConstant:16],
            ]];
            [self.contentView addSubview:uploadDateLabel];
            [NSLayoutConstraint activateConstraints:@[
                [uploadDateLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:127],
                [uploadDateLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:23],
                [uploadDateLabel.widthAnchor constraintEqualToConstant:200],
                [uploadDateLabel.heightAnchor constraintEqualToConstant:16],
            ]];
        }
    }
}

%new - (NSString *)formattedNumber:(NSInteger)number {
    if (number >= 1000000) {
        return [NSString stringWithFormat:@"%.1fm", number / 1000000.0];
    } else if (number >= 1000) {
        return [NSString stringWithFormat:@"%.1fk", number / 1000.0];
    } else {
        return [NSString stringWithFormat:@"%ld", (long)number];
    }
}

%new - (NSString *)formattedDateStringFromTimestamp:(NSTimeInterval)timestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if ([BMIManager showExactDate]) {
        dateFormatter.dateFormat = @"dd.MM.yyyy HH:mm";
    } else {
        dateFormatter.dateFormat = @"dd.MM.yy";
    }
    return [dateFormatter stringFromDate:date];
}
%end

%hook TTKProfileRootView
- (void)layoutSubviews {
    %orig;
    if ([BMIManager profileVideoCount]){
        TTKProfileOtherViewController *rootVC = [self yy_viewController];
        AWEUserModel *user = [rootVC user];
        NSNumber *userVideoCount = [user visibleVideosCount];
        if (userVideoCount){
            UILabel *userVideoCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,2,100,20.5)];
            userVideoCountLabel.text = [NSString stringWithFormat:@"Video Count: %@", userVideoCount];
            userVideoCountLabel.font = [UIFont systemFontOfSize:9.0];
            [self addSubview:userVideoCountLabel];
        }
    }
}
%end

%hook BDImageView
- (void)layoutSubviews {
    %orig;
    if ([BMIManager profileSave]) {
        [self addHandleLongPress];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [%c(AWEUIAlertView) showAlertWithTitle:@"Tải ảnh đại diện" description:@"Bạn có muốn lưu ảnh đại diện gốc này về máy không?" image:nil actionButtonTitle:@"Lưu ảnh" cancelButtonTitle:@"Hủy" actionBlock:^{
            UIImageWriteToSavedPhotosAlbum([self bd_baseImage], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } cancelBlock:nil];
    }
}
%new - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"[BMTikTok] Error saving image: %@", error.localizedDescription);
    } else {
        NSLog(@"[BMTikTok] Image successfully saved to Photos app");
    }
}
%end

%hook AWEUserNameLabel
- (void)layoutSubviews {
    %orig;
    if ([self.yy_viewController isKindOfClass:(%c(TTKProfileHomeViewController))] && [BMIManager fakeVerified]) {
        [self addVerifiedIcon:true];
    }
}
%end

%hook TTTAttributedLabel
- (void)layoutSubviews {
    %orig;
    if ([BMIManager profileCopy]){
        [self addHandleLongPress];
    }
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSString *profileDescription = [self text];
        [%c(AWEUIAlertView) showAlertWithTitle:@"Sao chép tiểu sử" description:@"Bạn có muốn sao chép tiểu sử này vào bộ nhớ tạm không?" image:nil actionButtonTitle:@"Sao chép" cancelButtonTitle:@"Hủy" actionBlock:^{
            if (profileDescription) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = profileDescription;
            }
        } cancelBlock:nil];
    }
}
%end

%hook TTKProfileBaseComponentModel
- (NSDictionary *)bizData {
    if ([BMIManager fakeChangesEnabled]) {
        NSDictionary *originalData = %orig;
        NSMutableDictionary *modifiedData = [originalData mutableCopy];
        
        NSNumber *fakeFollowingCount = [self numberFromUserDefaultsForKey:@"fake_following_count"];
        NSNumber *fakeFollowersCount = [self numberFromUserDefaultsForKey:@"fake_follower_count"];
        
        if ([self.componentID isEqualToString:@"relation_info_follower"]) {
            if (fakeFollowersCount && [fakeFollowersCount doubleValue] > 0) {
                modifiedData[@"follower_count"] = fakeFollowersCount;
            }
        } else if ([self.componentID isEqualToString:@"relation_info_following"]) {
            if (fakeFollowingCount && [fakeFollowingCount doubleValue] > 0) {
                modifiedData[@"following_count"] = fakeFollowingCount;
                modifiedData[@"formatted_number"] = [self formattedStringFromNumber:fakeFollowingCount];
            }
        } 
        return [modifiedData copy];
    }
    return %orig;
}

- (NSArray *)components {
    if ([BMIManager fakeVerified]) {
        NSArray *originalComponents = %orig;
        if ([self.componentID isEqualToString:@"user_account_base_info"] && originalComponents.count == 1) {
            NSMutableArray *modifiedComponents = [originalComponents mutableCopy];
            TTKProfileBaseComponentModel *fakeVerify = [%c(TTKProfileBaseComponentModel) new];
            fakeVerify.componentID = @"user_account_verify";
            fakeVerify.name = @"user_account_verify";
            [modifiedComponents addObject:fakeVerify];
            return [modifiedComponents copy];
        }
    }
    return %orig;
}

%new - (NSNumber *)numberFromUserDefaultsForKey:(NSString *)key {
    NSString *stringValue = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    return (stringValue.length > 0) ? @([stringValue doubleValue]) : @0; 
}

%new - (NSString *)formattedStringFromNumber:(NSNumber *)number {
    if (!number) return @"0"; 
    double value = [number doubleValue];
    if (value == 0) return @"0"; 

    NSString *formattedString;
    if (value >= 1e9) {
        formattedString = [NSString stringWithFormat:@"%.1fB", value / 1e9];
    } else if (value >= 1e6) {
        formattedString = [NSString stringWithFormat:@"%.1fM", value / 1e6];
    } else if (value >= 1e3) {
        formattedString = [NSString stringWithFormat:@"%.1fk", value / 1e3];
    } else {
        formattedString = [NSString stringWithFormat:@"%.0f", value];
    }
    return formattedString;
}
%end

%hook AWEUserModel
- (NSNumber *)followerCount {
    if ([BMIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_follower_count"];
        if (fakeCountString.length > 0) {
            return @([fakeCountString integerValue]);
        }
    }
    return %orig;
}
- (NSNumber *)followingCount {
    if ([BMIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_following_count"];
        if (fakeCountString.length > 0) {
            return @([fakeCountString integerValue]);
        }
    }
    return %orig;
}
%end

%hook TUXLabel
- (void)setText:(NSString*)arg1 {
    if ([BMIManager showUsername]) {
        if ([[[self superview] superview] isKindOfClass:%c(AWEPlayInteractionAuthorUserNameButton)]){
            AWEFeedCellViewController *rootVC = [[[self superview] superview] yy_viewController];
            AWEAwemeModel *model = rootVC.model;
            AWEUserModel *authorModel = model.author;
            NSString *username = authorModel.socialName;
            if (username.length > 0) {
                %orig(username);
                return;
            }
        }
    }
    %orig;
}
%end

static NSString *bm_emojiForCountryCode(NSString *countryCode) {
    if (!countryCode || countryCode.length != 2) {
        return nil;
    }
    NSString *uppercaseCountryCode = [countryCode uppercaseString];
    uint32_t firstLetter = [uppercaseCountryCode characterAtIndex:0] + 0x1F1E6 - 'A';
    uint32_t secondLetter = [uppercaseCountryCode characterAtIndex:1] + 0x1F1E6 - 'A';
    NSString *flagEmoji = [[NSString alloc] initWithBytes:&firstLetter length:4 encoding:NSUTF32LittleEndianStringEncoding];
    flagEmoji = [flagEmoji stringByAppendingString:[[NSString alloc] initWithBytes:&secondLetter length:4 encoding:NSUTF32LittleEndianStringEncoding]];
    return flagEmoji;
}

%hook AWEPlayInteractionAuthorView
%new - (NSString *)emojiForCountryCode:(NSString *)countryCode {
    return bm_emojiForCountryCode(countryCode);
}

- (void)layoutSubviews {
    %orig;
    if ([BMIManager uploadRegion]){
        for (int i = 0; i < [[self subviews] count]; i ++){
            id j = [[self subviews] objectAtIndex:i];
            if ([j isKindOfClass:%c(UIStackView)]){
                CGRect frame = [j frame];
                frame.origin.x = 39.5; 
                [j setFrame:frame];
            } else {
                [[self viewWithTag:666] removeFromSuperview];
            }
        }
        [[self viewWithTag:666] removeFromSuperview];
        AWEFeedCellViewController* rootVC = self.yy_viewController;
        AWEAwemeModel *model = rootVC.model;
        NSString *countryID = model.region;
        UILabel *uploadLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,2,39.5,20.5)];
        NSString *countryEmoji = [self emojiForCountryCode:countryID];
        uploadLabel.text = [NSString stringWithFormat:@"%@ •", countryEmoji ?: @""];
        uploadLabel.tag = 666;
        [uploadLabel setTextColor: [UIColor whiteColor]];
        [uploadLabel sizeToFit];
        [self addSubview:uploadLabel];
    }
}
%end

%hook TTKProfileHeaderView
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BMIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 8. Comments & Input
// ═══════════════════════════════════════════════════════════════

%hook TTKCommentPanelViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([BMIManager transparentCommnet]){
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
        for (UIView *sub in self.view.subviews) {
            if ([sub isKindOfClass:[UIVisualEffectView class]]) {
                sub.alpha = 0.5;
            }
        }
    }
}
- (void)viewDidLayoutSubviews {
    %orig;
    if ([BMIManager transparentCommnet]) {
        self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.35];
    }
}
%end

%hook AWECommentListViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    if ([BMIManager transparentCommnet]) {
        self.view.backgroundColor = [UIColor clearColor];
    }
}
%end

%hook AWECommentPanelCell
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager transparentCommnet]) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    if ([BMIManager copyCommentText]) {
        BOOL hasGesture = NO;
        for (UIGestureRecognizer *g in self.gestureRecognizers) {
            if ([g.name isEqualToString:@"bm_copy_comment"]) {
                hasGesture = YES;
                break;
            }
        }
        if (!hasGesture) {
            UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bm_copyCommentAction:)];
            lp.name = @"bm_copy_comment";
            lp.minimumPressDuration = 0.5;
            [self addGestureRecognizer:lp];
        }
    }
}
- (void)layoutSubviews {
    %orig;
    if ([BMIManager colorizeCommentUsernames]) {
        UILabel *authorLbl = nil;
        @try {
            authorLbl = [self valueForKey:@"authorLabel"] ?: [self valueForKey:@"userNameLabel"] ?: [self valueForKey:@"nameLabel"];
        } @catch (id ex) {}
        if (authorLbl && [authorLbl isKindOfClass:[UILabel class]]) {
            authorLbl.textColor = [UIColor colorWithRed:254/255.0 green:44/255.0 blue:85/255.0 alpha:1.0];
        }
    }
    if ([BMIManager enableCommentFlags]) {
        AWECommentModel *commentModel = nil;
        @try {
            commentModel = [self valueForKey:@"commentModel"] ?: [self valueForKey:@"model"];
        } @catch (id ex) {}
        if (commentModel) {
            NSString *region = nil;
            @try {
                region = [commentModel valueForKeyPath:@"author.region"] ?: [commentModel valueForKeyPath:@"author.countryCode"] ?: [commentModel valueForKey:@"region"];
            } @catch (id ex) {}
            if (region.length == 2) {
                NSString *flag = bm_emojiForCountryCode(region);
                UILabel *authorLbl = nil;
                @try {
                    authorLbl = [self valueForKey:@"authorLabel"] ?: [self valueForKey:@"userNameLabel"] ?: [self valueForKey:@"nameLabel"];
                } @catch (id ex) {}
                if (authorLbl && [authorLbl isKindOfClass:[UILabel class]] && flag.length > 0) {
                    if (![authorLbl.text containsString:flag]) {
                        authorLbl.text = [NSString stringWithFormat:@"%@ %@", flag, authorLbl.text ?: @""];
                    }
                }
            }
        }
    }
}
%new - (void)bm_copyCommentAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AWECommentModel *commentModel = nil;
        @try {
            commentModel = [self valueForKey:@"commentModel"] ?: [self valueForKey:@"model"];
        } @catch (id ex) {}
        NSString *text = nil;
        @try {
            text = [commentModel valueForKey:@"content"] ?: [commentModel valueForKey:@"text"];
        } @catch (id ex) {}
        if (text.length > 0) {
            [[UIPasteboard generalPasteboard] setString:text];
            UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [feedback impactOccurred];
        }
    }
}
- (void)onLikeAction:(id)arg1 {
    if ([BMIManager likeCommentConfirmation]) {
        void (^actionBlock)(void) = ^{
            %orig(arg1);
        };
        showConfirmation(actionBlock);
    } else {
        %orig(arg1);
    }
}
- (void)onDislikeAction:(id)arg1 {
    if ([BMIManager dislikeCommentConfirmation]) {
        void (^actionBlock)(void) = ^{
            %orig(arg1);
        };
        showConfirmation(actionBlock);
    } else {
        %orig(arg1);
    }
}
%end

%hook AWECommentInputView
- (void)layoutSubviews {
    %orig;
    if ([BMIManager hideEmojiBar]) {
        UIView *emojiBar = [self valueForKey:@"emojiBarView"];
        if (emojiBar) [emojiBar setHidden:YES];
    }
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    if ([BMIManager extendedComment]) return 500;
    return %orig;
}
%end

%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    if ([BMIManager extendedBio]) return 222;
    return %orig;
}
%end


// ═══════════════════════════════════════════════════════════════
// Live Stream Comments Stability (Khắc phục bình luận lúc hiện lúc không)
// ═══════════════════════════════════════════════════════════════

%hook GBLCommentViewContainerConfig
- (BOOL)banDismissAnimation {
    return YES;
}
- (BOOL)unlimitedDuration {
    return YES;
}
%end

%hook GBLCommentViewContainer
- (BOOL)banDismissAnimation {
    return YES;
}
- (void)setHidden:(BOOL)hidden {
    %orig(NO);
}
- (void)setAlpha:(CGFloat)alpha {
    if (alpha < 0.8) {
        alpha = 1.0;
    }
    %orig(alpha);
}
%end

%hook IESLiveMTCleanScreenFragment
- (void)switchToCleanModeWithType:(unsigned long long)arg1 {
    // Ngăn chặn chế độ tự động dọn màn hình (ẩn bình luận khi vuốt nhầm)
    return;
}
- (id)cleanScreenCountDownTimer {
    return nil;
}
- (void)setCleanScreenCountDownTimer:(id)arg1 {
    // Vô hiệu hóa bộ đếm thời gian tự ẩn bình luận
}
%end

%hook IESLiveCommentContainerFragment
- (void)removeCommentContainerPortrait {
    // Giữ khung bình luận luôn hiển thị ổn định trên màn hình dọc
    return;
}
- (void)commentViewCancel {
    // Ngăn chặn việc hủy / tắt khung bình luận
    return;
}
%end


// ═══════════════════════════════════════════════════════════════
// Comment Translation to Vietnamese (Dịch toàn bộ bình luận sang Tiếng Việt)
// ═══════════════════════════════════════════════════════════════

%hook TTKCommentTranslationConfig
- (id)initWithIsCommentAutoTranslationEnabled:(BOOL)enabled targetLanguageCode:(id)targetLang doNotTranslateLanguageCodes:(id)dntCodes {
    if ([BMIManager autoTranslateComments]) {
        enabled = YES;
        targetLang = @"vi";
        dntCodes = [NSSet set];
    }
    return %orig(enabled, targetLang, dntCodes);
}
- (BOOL)isCommentAutoTranslationEnabled {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
- (NSString *)targetLanguageCode {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSSet *)doNotTranslateLanguageCodes {
    if ([BMIManager autoTranslateComments]) return [NSSet set];
    return %orig;
}
- (NSArray *)sortedDoNotTranslateLanguageCodes {
    if ([BMIManager autoTranslateComments]) return @[];
    return %orig;
}
%end

%hook AWECommentsTranslationController
- (BOOL)isCommentEligibleForAutomaticTranslation:(id)comment {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig(comment);
}
- (BOOL)isTranslationButtonDisplayEnabled {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
- (BOOL)isCommentInDoNotTranslateCodes:(id)comment {
    if ([BMIManager autoTranslateComments]) return NO;
    return %orig(comment);
}
- (BOOL)isCommentTranslatable:(id)comment {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig(comment);
}
- (BOOL)shouldTranslateComment:(id)comment {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig(comment);
}
- (BOOL)_shouldTranslateCommentUsingSessionSnapshot:(id)arg1 {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig(arg1);
}
- (BOOL)isEligibleForAutomaticTranslationWithComment:(id)comment config:(id)config {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig(comment, config);
}
- (BOOL)shouldShowCommentTranslationLabel {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
%end

%hook TTKTranslationSettingsManager
- (NSString *)selectedTranslationLanguage {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSString *)p_selectedTranslationLanguage {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSString *)p_refactoredSelectedTranslationLanguage {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSArray *)doNotTranslateList {
    if ([BMIManager autoTranslateComments]) return @[];
    return %orig;
}
- (NSArray *)p_refactoredSelectedDoNotTranslateLanguages {
    if ([BMIManager autoTranslateComments]) return @[];
    return %orig;
}
- (NSSet *)selectedDoNotTranslateLanguages {
    if ([BMIManager autoTranslateComments]) return [NSSet set];
    return %orig;
}
%end

%hook AWEGlobalTranslationManager
- (void)_fetchTranslationForOriginalContents:(id)contents targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(contents, targetLang, params, completion);
}
- (void)_fetchTranslationForOriginalContent:(id)content targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(content, targetLang, params, completion);
}
- (void)submitOriginalContentsForTranslation:(id)contents requestingStatus:(long long)status targetLanguageCode:(id)targetLang enableTempCache:(BOOL)cache additionalParams:(id)params {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(contents, status, targetLang, cache, params);
}
- (void)submitOriginalContentForTranslation:(id)content requestingStatus:(long long)status targetLanguageCode:(id)targetLang additionalParams:(id)params {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(content, status, targetLang, params);
}
- (void)fetchTranslationForOriginalContent:(id)content targetLanguageCode:(id)targetLang additionalParams:(id)params timeout:(double)timeout completion:(id)completion {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(content, targetLang, params, timeout, completion);
}
- (void)fetchTranslationForContentsWithTranslationInfo:(id)info targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion {
    if ([BMIManager autoTranslateComments]) {
        targetLang = @"vi";
    }
    %orig(info, targetLang, params, completion);
}
%end

%hook C24yGlobalTranslationSettingModel
- (BOOL)autoTranslationEnabled {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
- (NSString *)targetLanguageCode {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSSet *)doNotTranslateLanguages {
    if ([BMIManager autoTranslateComments]) return [NSSet set];
    return %orig;
}
%end

%hook TTKCLAAlwaysTranslateCommentSettingItemViewModel
- (BOOL)isSwitchOn {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
- (BOOL)isOn {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
%end

%hook TTKCLAAutoTranslationSettingItemViewModel
- (BOOL)isSwitchOn {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
- (BOOL)isOn {
    if ([BMIManager autoTranslateComments]) return YES;
    return %orig;
}
%end

%hook TTKCLATranslationTargetLanguageSettingItemViewModel
- (NSString *)selectedLanguageCode {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
- (NSString *)currentLanguageCode {
    if ([BMIManager autoTranslateComments]) return @"vi";
    return %orig;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 9. UI Tweaks & Misc
// ═══════════════════════════════════════════════════════════════

%hook UIButton
- (void)_onTouchUpInside {
    if ([BMIManager followConfirmation] && [self.currentTitle isEqualToString:@"Follow"]) {
        void (^actionBlock)(void) = ^{
            %orig;
        };
        showConfirmation(actionBlock);
    } else {
        %orig;
    }
}
%end

%hook AWEPlayInteractionUserAvatarElement
- (void)onFollowViewClicked:(id)sender {
    if ([BMIManager followConfirmation]) {
        void (^actionBlock)(void) = ^{
            %orig(sender);
        };
        showConfirmation(actionBlock);
    } else {
        %orig(sender);
    }
}
%end

%hook AWEFeedVideoButton
- (void)_onTouchUpInside {
    if ([BMIManager likeConfirmation] && [self.imageNameString isEqualToString:@"ic_like_fill_1_new"]) {
        void (^actionBlock)(void) = ^{
            %orig;
        };
        showConfirmation(actionBlock);
    } else if ([BMIManager bookmarkConfirmation] && ([self.imageNameString containsString:@"collect"] || [self.imageNameString containsString:@"fav"] || [self.imageNameString containsString:@"bookmark"])) {
        void (^actionBlock)(void) = ^{
            %orig;
        };
        showConfirmation(actionBlock);
    } else {
        %orig;
    }
}
%end

%hook SparkViewController
- (void)viewWillAppear:(BOOL)animated {
    if (![BMIManager disableSafariRedirect]) {
        return %orig;
    }
    
    if (!self.originURL) {
        return %orig;
    }

    NSString *urlString = [self.originURL absoluteString].lowercaseString;
    // Tuyệt đối KHÔNG can thiệp vào các luồng xác minh danh tính, captcha, bảo mật, passport, đăng nhập OTP
    if ([urlString containsString:@"verify"] ||
        [urlString containsString:@"captcha"] ||
        [urlString containsString:@"passport"] ||
        [urlString containsString:@"security"] ||
        [urlString containsString:@"sec_sdk"] ||
        [urlString containsString:@"challenge"] ||
        [urlString containsString:@"two_step"] ||
        [urlString containsString:@"account"] ||
        [urlString containsString:@"oauth"] ||
        [urlString containsString:@"login"]) {
        return %orig;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *searchParameter = @"url";
    NSString *searchValue = nil;
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:searchParameter]) {
            searchValue = queryItem.value;
            break;
        }
    }

    if (searchValue && ([searchValue hasPrefix:@"http://"] || [searchValue hasPrefix:@"https://"])) {
        NSString *searchValLower = searchValue.lowercaseString;
        if ([searchValLower containsString:@"verify"] ||
            [searchValLower containsString:@"captcha"] ||
            [searchValLower containsString:@"passport"] ||
            [searchValLower containsString:@"security"] ||
            [searchValLower containsString:@"challenge"]) {
            return %orig;
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchValue] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        return %orig;
    }
}
%end

%hook AWELiveFeedEntranceView
- (void)switchStateWithTapped:(BOOL)arg1 {
    if (![BMIManager liveActionEnabled] || [BMIManager selectedLiveAction] == 0) {
        %orig;
    } else if ([BMIManager liveActionEnabled] && [[BMIManager selectedLiveAction] intValue] == 1) {
        UINavigationController *BMTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
        BMTikTokSettings.modalPresentationStyle = UIModalPresentationPageSheet;
        [topMostController() presentViewController:BMTikTokSettings animated:true completion:nil];
    } else {
        %orig;
    }
}
%end

%hook UIKeyboard
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager oledKeyboard]) {
        [self setKeyboardAppearance:UIKeyboardAppearanceDark];
    }
}
%end

%hook AWETabBar
- (void)layoutSubviews {
    %orig;
    if ([BMIManager hideTabBarLabels]) {
        for (UIView *sub in self.subviews) {
            if ([sub isKindOfClass:[UILabel class]]) {
                sub.hidden = YES;
            }
        }
    }
}
%end

%hook AWEBadgeView
- (void)setHidden:(BOOL)hidden {
    if ([BMIManager hideBadgeCounter]) {
        %orig(YES);
        return;
    }
    %orig(hidden);
}
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager hideBadgeCounter]) {
        [self setHidden:YES];
    }
}
%end

%hook TTKUserEffectTabDataManager
- (BOOL)p_shouldShowLikeTab {
    if ([BMIManager hideLikedTab]) return NO;
    return %orig;
}
%end

%hook AWEFeedContainerViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static BOOL bm_switchedToFollowing = NO;
    if (!bm_switchedToFollowing && [BMIManager startFYPInFollowing]) {
        bm_switchedToFollowing = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if ([self respondsToSelector:@selector(switchToFollowingTab)]) {
                [self performSelector:@selector(switchToFollowingTab)];
            }
        });
    }
}
%end

%hook AWEAwemeBaseViewController
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4 {
    if ([BMIManager disableSwipeInFYP]) return;
    %orig;
}
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4 logExtraDict:(id)arg5 {
    if ([BMIManager disableSwipeInFYP]) return;
    %orig;
}
%end

%hook AWEFeedTableViewController
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4 {
    if ([BMIManager disableSwipeInFYP]) return;
    %orig;
}
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4 logExtraDict:(id)arg5 {
    if ([BMIManager disableSwipeInFYP]) return;
    %orig;
}
%end

%hook TTKFeedInteractionTopView
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager hideTopItems]) {
        [self setHidden:YES];
    }
}
- (void)setHidden:(BOOL)hidden {
    if ([BMIManager hideTopItems]) {
        %orig(YES);
        return;
    }
    %orig(hidden);
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 10. Upload & Publishing
// ═══════════════════════════════════════════════════════════════

%hook ACCCreationPublishAction
- (BOOL)is_open_hd {
    if ([BMIManager uploadHD]) return 1;
    return %orig;
}
- (void)setIs_open_hd:(BOOL)arg1 {
    if ([BMIManager uploadHD]) {
        %orig(1);
    } else {
        return %orig;
    }
}
- (BOOL)is_have_hd {
    if ([BMIManager uploadHD]) return 1;
    return %orig;
}
- (void)setIs_have_hd:(BOOL)arg1 {
    if ([BMIManager uploadHD]) {
        %orig(1);
    } else {
        return %orig;
    }
}
%end

%hook AWEAwemeACLItem
- (void)setWatermarkType:(NSUInteger)arg1 {
    if ([BMIManager removeWatermark]){
        %orig(1);
    } else { 
        %orig;
    }
}
- (NSUInteger)watermarkType {
    if ([BMIManager removeWatermark]) return 1;
    return %orig;
}
%end

%hook AWEMaskInfoModel
- (BOOL)showMask {
    if ([BMIManager disableUnsensitive]) return 0;
    return %orig;
}
- (void)setShowMask:(BOOL)arg1 {
    if ([BMIManager disableUnsensitive]) {
        %orig(0);
    } else {
        %orig;
    }
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 11. Anti-Jailbreak Detection
// ═══════════════════════════════════════════════════════════════

%hook NSFileManager
-(BOOL)fileExistsAtPath:(id)arg1 {
    for (NSString *file in jailbreakPaths) {
        if ([arg1 isEqualToString:file]) {
            return NO;
        }
    }
    return %orig;
}
-(BOOL)fileExistsAtPath:(id)arg1 isDirectory:(BOOL*)arg2 {
    for (NSString *file in jailbreakPaths) {
        if ([arg1 isEqualToString:file]) {
            return NO;
        }
    }
    return %orig;
}
%end

%hook BDADeviceHelper
+(bool)isJailBroken {
    return NO;
}
%end

%hook UIDevice
+(bool)btd_isJailBroken {
    return NO;
}
%end

%hook TTInstallUtil
+(bool)isJailBroken {
    return NO;
}
%end

%hook AppsFlyerUtils
+(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 {
    return NO;
}
%end

%hook IESLiveDeviceInfo
+(bool)isJailBroken {
    return NO;
}
%end

%hook PIPOStoreKitHelper
-(bool)isJailBroken {
    return NO;
}
%end

%hook BDInstallNetworkUtility
+(bool)isJailBroken {
    return NO;
}
%end

%hook TTAdSplashDeviceHelper
+(bool)isJailBroken {
    return NO;
}
%end

%hook FBSDKAppEventsUtility
+(bool)isDebugBuild {
    return NO;
}
%end

%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url {
    if (!url) return %orig;
    NSString *scheme = [[url scheme] lowercaseString];
    if ([scheme isEqualToString:@"cydia"] || 
        [scheme isEqualToString:@"sileo"] || 
        [scheme isEqualToString:@"zbra"] || 
        [scheme isEqualToString:@"filza"] || 
        [scheme isEqualToString:@"undecimus"] ||
        [scheme isEqualToString:@"santander"]) {
        return NO;
    }
    return %orig;
}
%end

%hook MPKitUtilityService
- (BOOL)deviceIsJailbroken {
    return NO;
}
%end

%hook UIDevice
- (BOOL)tspk_device_info_btd_isJailBroken {
    return NO;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 12. Network
// ═══════════════════════════════════════════════════════════════

%hook TTNetworkManager
- (id)commonParams {
    id params = %orig;
    if ([BMIManager russianFix]) {
        if ([params isKindOfClass:[NSMutableDictionary class]]) {
            NSMutableDictionary *mut = (NSMutableDictionary *)params;
            mut[@"carrier_region"] = @"RU";
            mut[@"sys_region"] = @"RU";
            mut[@"region"] = @"RU";
            mut[@"app_language"] = @"ru";
            return mut;
        }
    } else if ([BMIManager regionChangingEnabled]) {
        NSDictionary *selectedRegion = [BMIManager selectedRegion];
        if (selectedRegion && selectedRegion[@"code"]) {
            NSString *code = [selectedRegion[@"code"] uppercaseString];
            NSMutableDictionary *mut = [params isKindOfClass:[NSMutableDictionary class]] ? (NSMutableDictionary *)params : [params mutableCopy];
            if (mut) {
                mut[@"carrier_region"] = code;
                mut[@"sys_region"] = code;
                mut[@"region"] = code;
                return mut;
            }
        }
    }
    return params;
}
%end


// ═══════════════════════════════════════════════════════════════
// MARK: - 13. Constructor
// ═══════════════════════════════════════════════════════════════

%ctor {
    jailbreakPaths = @[
        @"/Applications/Cydia.app", @"/Applications/blackra1n.app",
        @"/Applications/FakeCarrier.app", @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app", @"/Applications/MxTube.app",
        @"/Applications/RockApp.app", @"/Applications/SBSettings.app", @"/Applications/WinterBoard.app",
        @"/Applications/Sileo.app", @"/Applications/Zebra.app", @"/Applications/Filza.app",
        @"/Applications/Dopamine.app",
        @"/.cydia_no_stash", @"/.installed_unc0ver", @"/.bootstrapped_electra",
        @"/usr/libexec/cydia/firmware.sh", @"/usr/libexec/ssh-keysign", @"/usr/libexec/sftp-server",
        @"/usr/bin/ssh", @"/usr/bin/sshd", @"/usr/sbin/sshd",
        @"/var/lib/cydia", @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
        @"/var/log/apt", @"/usr/share/jailbreak/injectme.plist", @"/usr/sbin/frida-server",
        @"/Library/MobileSubstrate/CydiaSubstrate.dylib", @"/Library/TweakInject",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib", @"Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist", @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist", @"/System/Library/CoreServices/SystemVersion.plist",
        @"/private/var/mobile/Library/SBSettings/Themes", @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log", @"/private/var/log/syslog",
        @"/private/var/cache/apt/", @"/private/var/lib/apt",
        @"/private/var/Users/", @"/private/var/stash",
        @"/var/jb", @"/var/jb/usr/bin", @"/var/jb/usr/lib", @"/var/jb/usr/libexec",
        @"/var/jb/Library", @"/var/jb/Library/MobileSubstrate", @"/var/jb/etc/apt",
        @"/var/jb/etc/ssh", @"/var/jb/bin/sh", @"/var/jb/bin/bash", @"/var/binpack",
        @"/usr/lib/libjailbreak.dylib", @"/usr/lib/libz.dylib",
        @"/usr/lib/system/introspectionNSZombieEnabled",
        @"/usr/lib/dyld",
        @"/jb/amfid_payload.dylib", @"/jb/libjailbreak.dylib",
        @"/jb/jailbreakd.plist", @"/jb/offsets.plist",
        @"/jb/lzma",
        @"/hmd_tmp_file",
        @"/etc/ssh/sshd_config", @"/etc/apt/undecimus/undecimus.list",
        @"/etc/apt/sources.list.d/sileo.sources", @"/etc/apt/sources.list.d/electra.list",
        @"/etc/apt", @"/etc/ssl/certs", @"/etc/ssl/cert.pem",
        @"/bin/sh", @"/bin/bash",
    ];

    // Khắc phục triệt để lỗi Keychain Sideload (-34018 & errSecDuplicateItem) gây lặp Email Login
    MSHookFunction(SecItemAdd, hook_SecItemAdd, (void **)&orig_SecItemAdd);
    MSHookFunction(SecItemCopyMatching, hook_SecItemCopyMatching, (void **)&orig_SecItemCopyMatching);
    MSHookFunction(SecItemUpdate, hook_SecItemUpdate, (void **)&orig_SecItemUpdate);
    MSHookFunction(SecItemDelete, hook_SecItemDelete, (void **)&orig_SecItemDelete);

    %init;

    if (%c(AWEMainFeedAnchorView) || %c(AWEPlayInteractionTakoElement) || %c(AWETakoEntranceView)) {
        %init(LegacyFeatures);
    }
}
