#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <SafariServices/SafariServices.h>
#import "BMIManager.h"
#import "SecurityViewController.h"
#import "BMDownload.h"
#import "BMMultipleDownload.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import <Photos/Photos.h>
#import "Settings/ViewController.h"
#import "Settings/PlaybackSpeed.h"

@interface AppDelegate : NSObject <UIApplicationDelegate>
@end

@interface TTKCommentPanelViewController: UIViewController
@end 

@interface AWEUserNameLabel: UILabel
-(void)addVerifiedIcon:(BOOL)arg1;
@end

@interface TTKProfileRootView: UIView
@end

@interface TTKProfileHeaderView : UIView
- (void)addHandleLongPress;
@end

@interface TTKAdsTimerPendantAdapter : UIViewController
@end

@interface AWEMainFeedAnchorView : UIView
@end

@interface AWEPlayInteractionTakoElement : NSObject
- (UIView *)view;
@end

@interface AWETakoEntranceView : UIView
@end

@interface AWEPlayVideoPauseView : UIView
@end

@interface AWECommentPanelView : UIView
@end

@interface AWECommentInputView : UIView
@end

@interface UIKeyboard : UIView
- (void)setKeyboardAppearance:(UIKeyboardAppearance)appearance;
@end

@interface AWETabBar : UIView
@end

@interface AWEScreenShotTracker : NSObject
- (void)trackScreenShotWithParam:(id)arg1;
@end

@interface TIMMessageService : NSObject
- (void)markMessageAsRead:(id)arg1 conversationId:(id)arg2;
@end

@interface AWEIMMessage : NSObject
- (void)markAsRead;
@end

@interface AWEIMTypingStatusSender : NSObject
- (void)sendTypingStatus:(id)arg1;
@end

@interface AWEProfileVisitorRecordService : NSObject
- (void)reportVisitWithSecUid:(id)arg1;
@end

@interface AWEProfileTracker : NSObject
- (void)trackProfileVisitWithSecUid:(id)arg1;
@end

@interface INSPrivacyManager : NSObject
- (void)userDidTakeScreenshot:(id)arg1;
- (void)userDidScreenRecord:(id)arg1;
@end

@interface TTNetworkManager : NSObject
- (id)commonParams;
@end

@interface BDImageView: UIImageView
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)addHandleLongPress;
- (id)bd_baseImage;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
@end

@interface TTTAttributedLabel: UILabel 
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)addHandleLongPress;
@end

@interface AWEPlayInteractionAuthorView: UIView
- (void)addSubview:(id)arg1;
- (NSString *)emojiForCountryCode:(NSString *)countryCode;
@end

@interface SparkViewController: UIViewController
@property(nonatomic, strong, readwrite) NSURL *originURL;
- (void)didTapCloseButton;
@end

@interface AWEAwemeACLItem: NSObject
- (void)setWatermarkType:(NSUInteger)arg1;
- (NSUInteger)watermarkType;
@end

@interface ACCCreationPublishAction: NSObject
- (BOOL)is_open_hd;
- (void)setIs_open_hd:(BOOL)arg1;
- (BOOL)is_have_hd;
- (void)setIs_have_hd:(BOOL)arg1;
@end

@interface AWEMaskInfoModel : NSObject
- (BOOL)showMask;
- (void)setShowMask:(BOOL)arg1;
@end

@interface UIView (RCTViewUnmounting)
@property(retain, nonatomic) id viewController;
@property(retain, nonatomic) UIViewController *yy_viewController;
@end

@interface AWECommentPanelCell: UITableView
- (void)onLikeAction:(id)arg1;
- (void)onDislikeAction:(id)arg1;
@end

@interface TikTokFeedTabControl: UIView
@end

@interface AWEFeedVideoButton: UIButton
@property(copy, nonatomic, readwrite) NSString *imageNameString;
@end

@interface AWEURLModel : NSObject
@property(retain, nonatomic) NSArray* originURLList;
- (NSURL *)recommendUrl;
- (NSURL *)bestURLtoDownload;
- (NSString *)bestURLtoDownloadFormat;
@end

@interface AWEVideoModel : NSObject
@property(readonly, nonatomic) AWEURLModel *playURL;
@property(readonly, nonatomic) AWEURLModel *downloadURL;
@property(readonly, nonatomic) NSNumber *duration;
@end

@interface AWEMusicModel : NSObject
@property(readonly, nonatomic) AWEURLModel *playURL;
@end

@interface AWEPhotoAlbumPhoto: NSObject
@property(readonly, nonatomic) AWEURLModel *originPhotoURL;
@end

@interface AWEPhotoAlbumModel: NSObject
@property(readonly, nonatomic) NSArray <AWEPhotoAlbumPhoto *> *photos;
@end

@interface AWEUserModel: NSObject
@property(retain, nonatomic) NSNumber *visibleVideosCount;
@property(retain, nonatomic) NSNumber *followerCount;
@property(retain, nonatomic) NSNumber *followingCount;
@property(nonatomic, copy) NSString *nickname;
@property(nonatomic, copy) NSString *socialName;
@end

@interface AWEAwemeModel : NSObject
@property(readonly, nonatomic) AWEVideoModel *video;
@property(readonly, nonatomic) AWEMusicModel *music;
@property(readonly, nonatomic) NSString *itemID;
@property(readonly, nonatomic) AWEPhotoAlbumModel *photoAlbum;
@property(readonly, nonatomic) NSString *music_songName;
@property(retain, nonatomic) NSNumber *createTime;
@property(retain, nonatomic) AWEUserModel *author;
@property(nonatomic, copy) NSString *region;
- (BOOL)isUserRecommendBigCard;
- (BOOL)isAds;
- (BOOL)isAd;
- (BOOL)isCommerce;
- (BOOL)isCommerceAd;
@property(retain, nonatomic) id statistics;
@end

@interface AWEAwemeStatisticsModel : NSObject
@property(retain, nonatomic) NSNumber *diggCount;
@end

@interface AWEPlayInteractionWarningElementView: UIView
@property(retain, nonatomic) NSString *warningText;
- (id)warningImage;
@end

@interface TUXLabel: UILabel
@end

@interface AWENewFeedTableViewController: UIViewController
@property (nonatomic, assign) NSInteger defaultIndex;
@property (nonatomic, retain) UIGestureRecognizer *swipeGesture;
@property (nonatomic, retain) UIView *feedHeaderView;
- (void)scrollToNextVideo;
- (AWEAwemeModel *)currentAweme;
@end

@interface AWEFeedCellViewController: UIViewController
@property (nonatomic, strong) AWEAwemeModel *model;
@end

@interface AWEPlayVideoPlayerController: NSObject
@property (nonatomic, assign) BOOL isLoop;
@property (nonatomic, strong) UIViewController *container;
- (UIViewController *)container;
@end

@interface TTKProfileBaseComponentModel: NSObject
@property (nonatomic, copy, readwrite) NSDictionary *bizData;
@property (nonatomic, copy, readwrite) NSString *componentID;
@property (nonatomic, copy, readwrite) NSString *name;
- (NSString *)formattedStringFromNumber:(NSNumber *)number;
- (NSNumber *)numberFromUserDefaultsForKey:(NSString *)key;
@end

@interface AWEPlayInteractionUserAvatarElement: NSObject
@property (nonatomic, strong, readwrite) UIView *view;
- (void)onFollowViewClicked:(id)sender;
@end

@interface AWETextInputController: UIViewController
@property(nonatomic, assign) NSInteger maxTextLength;
@end

@interface AWEProfileEditTextViewController: UIViewController
@property(nonatomic, assign) NSInteger maxTextLength;
@end

@interface TIKTOKProfileHeaderView: UIView
- (void)addHandleLongPress;
@end

@interface AWELiveFeedEntranceView: UIView
@end

@interface AWEFeedViewTemplateCell: UIView <BMMultipleDownloadDelegate>
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, readonly) UIViewController *viewController;
- (UIViewController *)viewController;
- (void)addDownloadButton;
- (void)addHideElementButton;
- (void)downloadVideo:(id)sender;
- (void)downloadHDVideo:(id)sender;
- (void)downloadMusic:(id)sender;
- (void)copyMusic:(id)sender;
- (void)copyVideo:(id)sender;
- (void)copyDecription:(id)sender;
- (void)downloadPhotos:(id)sender photoIndex:(NSInteger)index;
- (void)downloadPhotos:(id)sender;
@end

@interface AWEAwemeBaseViewController: UIViewController
@property(readonly, nonatomic) AWEAwemeModel *model;
@end

@interface TTKPhotoAlbumDetailCellController: UIViewController
@property(readonly, nonatomic) AWEAwemeModel *model;
@end

@interface AWEPlayPhotoAlbumViewController: UIViewController
@end

@interface AWESettingItemModel: NSObject
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSString *detail;
@property (nonatomic, strong, readwrite) UIImage *iconImage;
@property (nonatomic, assign, readwrite) NSInteger type;
- (instancetype)initWithIdentifier:(NSString *)identifier;
@end

@interface TTKSettingsBaseCellPlugin: NSObject
@property (nonatomic, strong, readwrite) AWESettingItemModel *itemModel;
- (instancetype)initWithPluginContext:(id)context;
@end

@interface AWESettingsNormalSectionViewModel: NSObject
@property (nonatomic, copy, readwrite) NSString *sectionIdentifier;
@property (nonatomic, strong, readwrite) id context;
- (void)insertModel:(id)model atIndex:(NSInteger)index animated:(BOOL)animated;
@end

@interface TTKProfileOtherViewController: UIViewController
@property(readonly, nonatomic) AWEUserModel *user;
@end

@interface TTKProfileHomeViewController: UIViewController
@end

@interface AWEUIAlertView: NSObject
+ (void)showAlertWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image actionButtonTitle:(NSString *)actionTitle cancelButtonTitle:(NSString *)cancelTitle actionBlock:(void (^)(void))actionBlock cancelBlock:(void (^)(void))cancelBlock;
@end

@interface FLEXManager: NSObject
+ (instancetype)sharedManager;
- (void)showExplorer;
@end

@interface AWEUserWorkCollectionViewCell: UICollectionViewCell
@property (nonatomic, strong, readwrite) AWEAwemeModel *model;
- (NSString *)formattedNumber:(NSInteger)number;
- (NSString *)formattedDateStringFromTimestamp:(NSTimeInterval)timestamp;
@end

@interface TTKMediaSpeedControlService: NSObject
- (void)setPlaybackRate:(CGFloat)rate;
@end

@interface TTKStoreRegionModel: NSObject
@property (nonatomic, copy, readwrite) NSString *currentRegion;
@end

@interface TTKStoreRegionService: NSObject
@property (nonatomic, strong, readwrite) TTKStoreRegionModel *storeRegionModel;
@end

@interface TIKTOKRegionManager: NSObject
+ (instancetype)sharedInstance;
- (NSString *)getRegion;
- (NSString *)getCarrierRegion;
- (NSString *)getSysRegion;
- (NSString *)getAppLanguage;
@end

@interface TTKPassportAppStoreRegionModel: NSObject
@property (nonatomic, copy, readwrite) NSString *currentRegion;
@end

@interface ATSRegionCacheManager: NSObject
+ (instancetype)sharedInstance;
- (NSString *)getRegion;
@end

@interface TTInstallIDManager: NSObject
+ (instancetype)sharedInstance;
- (NSString *)getRegion;
@end

@interface BDInstallGlobalConfig: NSObject
+ (instancetype)sharedInstance;
@property (nonatomic, copy, readwrite) NSString *appRegion;
@end

@interface BDInstallNetworkUtility: NSObject
+ (NSString *)carrierRegion;
@end

@interface TTAdSplashDeviceHelper: NSObject
+ (NSString *)carrierRegion;
@end

@interface AppsFlyerUtils: NSObject
+ (NSString *)carrierRegion;
@end

@interface PIPOIAPStoreManager: NSObject
+ (NSString *)carrierRegion;
@end

@interface IESLiveDeviceInfo: NSObject
+ (NSString *)carrierRegion;
@end

@interface GULAppEnvironmentUtil: NSObject
+ (BOOL)isFromAppStore;
+ (BOOL)isAppStoreReceiptSandbox;
+ (BOOL)isAppExtension;
@end

@interface FBSDKAppEventsUtility: NSObject
+ (BOOL)isDebugBuild;
@end

@interface AWEAPMManager: NSObject
+ (id)signInfo;
@end

@interface AWESecurity: NSObject
- (void)resetCollectMode;
@end

@interface MSManagerOV: NSObject
- (id)setMode;
@end

@interface MSConfigOV: NSObject
- (id)setMode;
@end

@interface PIPOStoreKitHelper: NSObject
+ (NSString *)carrierRegion;
@end

@interface BDADeviceHelper: NSObject
+ (NSString *)carrierRegion;
@end

@interface TTInstallUtil: NSObject
+ (NSString *)carrierRegion;
@end

@interface AWEAwemeDetailTableViewCell: UIView
- (void)addDownloadButton;
- (void)addHideElementButton;
@end

@interface TTKStoryDetailTableViewCell: UIView
- (void)addDownloadButton;
- (void)addHideElementButton;
@end

static inline BOOL is_iPad() {
    if ([(NSString *)[UIDevice currentDevice].model hasPrefix:@"iPad"]) {
        return YES;
    }
    return NO;
}

static inline UIViewController * _Nullable _topMostController(UIViewController * _Nonnull cont) {
    UIViewController *topController = cont;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    if ([topController isKindOfClass:[UINavigationController class]]) {
        UIViewController *visible = ((UINavigationController *)topController).visibleViewController;
        if (visible) {
            topController = visible;
        }
    }
    return (topController != cont ? topController : nil);
}

static inline UIViewController * _Nonnull topMostController() {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *next = nil;
    while ((next = _topMostController(topController)) != nil) {
        topController = next;
    }
    return topController;
}
