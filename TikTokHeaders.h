//
//  TikTokHeaders.h
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

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
- (void)addVerifiedIcon:(BOOL)arg1;
@end

@interface TTKProfileRootView: UIView
@end

@interface TTKProfileHeaderView : UIView
- (void)addHandleLongPress;
@end

@interface TIKTOKProfileHeaderView : UIView
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

@interface AWEAwemePlayVideoPauseIcon : UIView
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
- (void)userDidTakeScreenshot:(id)arg1;
- (void)trackScreenShotWithParam:(id)arg1;
@end

@interface AWEIMMessage : NSObject
- (void)markAsRead;
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

@interface AWECommentPanelCell: UITableViewCell
- (void)onLikeAction:(id)arg1;
- (void)onDislikeAction:(id)arg1;
@end

@interface AWEFeedVideoButton : UIButton
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

@interface AWEAigcInfoModel : NSObject
@property(nonatomic, assign) BOOL isAIGC;
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
@property(retain, nonatomic) AWEAigcInfoModel *aigcInfoModel;
@property(nonatomic, assign) BOOL isAIGCSuggested;
- (BOOL)isUserRecommendBigCard;
- (BOOL)isAds;
- (BOOL)isAd;
- (BOOL)isCommerce;
- (BOOL)progressBarDraggable;
- (BOOL)progressBarVisible;
- (AWEAwemeStatisticsModel *)statistics;
@end

@interface AWEAwemeStatisticsModel : NSObject
@property(readonly, nonatomic) NSNumber *diggCount;
@end

@interface AWEAwemeBaseViewController : UIViewController
@property (retain, nonatomic) AWEAwemeModel *model;
@end

@interface AWEFeedCellViewController : AWEAwemeBaseViewController
@end

@interface TTKPhotoAlbumDetailCellController : AWEAwemeBaseViewController
@end

@interface TTKPhotoAlbumFeedCellController : AWEAwemeBaseViewController
@end

@interface AWEPlayPhotoAlbumViewController : UIViewController
@end

@interface AWEPlayVideoPlayerController: NSObject
@property(retain, nonatomic) id container;
@property(retain, nonatomic) AWEAwemeModel *model;
@end

@interface AWENewFeedTableViewController: UIViewController
- (void)scrollToNextVideo;
- (AWEAwemeModel *)currentAweme;
@end

@interface TTKProfileOtherViewController: UIViewController
@property(retain, nonatomic) AWEUserModel *user;
@end

@interface TTKProfileBaseComponentModel: NSObject
@property(retain, nonatomic) NSString *componentID;
@property(retain, nonatomic) NSString *name;
@end

@interface AWESettingItemModel: NSObject
@property(retain, nonatomic) NSString *identifier;
@property(retain, nonatomic) NSString *title;
@property(retain, nonatomic) NSString *detail;
@property(retain, nonatomic) UIImage *iconImage;
@property(nonatomic) NSInteger type;
- (instancetype)initWithIdentifier:(NSString *)arg1;
@end

@interface TTKSettingsBaseCellPlugin: NSObject
@property(retain, nonatomic) AWESettingItemModel *itemModel;
- (instancetype)initWithPluginContext:(id)arg1;
@end

@interface AWESettingsNormalSectionViewModel: NSObject
@property(retain, nonatomic) NSString *sectionIdentifier;
@property(retain, nonatomic) id context;
- (void)insertModel:(id)arg1 atIndex:(NSInteger)arg2 animated:(BOOL)arg3;
@end

@interface AWEUIAlertView: NSObject
+ (void)showAlertWithTitle:(NSString *)title description:(NSString *)description image:(UIImage *)image actionButtonTitle:(NSString *)actionTitle cancelButtonTitle:(NSString *)cancelTitle actionBlock:(void (^)(void))actionBlock cancelBlock:(void (^)(void))cancelBlock;
@end

@interface AWEPlayInteractionAuthorUserNameButton: UIButton
@end

@interface TUXLabel: UILabel
@end

@interface AWEFeedViewTemplateCell: UITableViewCell
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, retain) UIProgressView *progressView;
- (void)addDownloadButton;
- (void)addHideElementButton;
- (void)resetPureModeState;
- (void)downloadButtonHandler:(UIButton *)sender;
- (void)hideElementButtonHandler:(UIButton *)sender;
- (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC;
- (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC photoIndex:(unsigned long)index;
- (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC;
- (void)copyMusic:(AWEAwemeBaseViewController *)rootVC;
- (void)copyVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)copyDecription:(AWEAwemeBaseViewController *)rootVC;
@end

@interface AWEAwemeDetailTableViewCell: UITableViewCell
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *fileextension;
- (void)addDownloadButton;
- (void)addHideElementButton;
- (void)resetPureModeState;
- (void)downloadButtonHandler:(UIButton *)sender;
- (void)hideElementButtonHandler:(UIButton *)sender;
- (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC;
- (void)copyMusic:(AWEAwemeBaseViewController *)rootVC;
- (void)copyVideo:(AWEAwemeBaseViewController *)rootVC;
- (void)copyDecription:(AWEAwemeBaseViewController *)rootVC;
@end

@interface CTCarrier: NSObject
@property (nonatomic, strong) NSString *mobileCountryCode;
@property (nonatomic, strong) NSString *isoCountryCode;
@property (nonatomic, strong) NSString *mobileNetworkCode;
@end

@interface TTKStoreRegionService: NSObject
- (id)storeRegion;
- (id)getStoreRegion;
- (void)setStoreRegion:(id)arg1;
@end

@interface TIKTOKRegionManager: NSObject
+ (NSString *)systemRegion;
+ (id)region;
+ (id)mccmnc;
+ (id)storeRegion;
+ (id)currentRegionV2;
+ (id)localRegion;
@end

@interface TTKMediaSpeedControlService: NSObject
- (void)setPlaybackRate:(CGFloat)arg1;
@end

@interface AWEPlayInteractionWarningElementView: UIView
- (id)warningImage;
- (id)warningLabel;
@end

@interface AWEPlayInteractionUserAvatarElement: NSObject
- (void)onFollowViewClicked:(id)sender;
@end

@interface AWETextInputController: NSObject
- (NSUInteger)maxLength;
@end

@interface AWEProfileEditTextViewController: UIViewController
- (NSInteger)maxTextLength;
@end

@interface AWELiveFeedEntranceView: UIView
- (void)switchStateWithTapped:(BOOL)arg1;
@end

@interface BDADeviceHelper: NSObject
+ (bool)isJailBroken;
@end

@interface TTInstallUtil: NSObject
+ (bool)isJailBroken;
@end

@interface AppsFlyerUtils: NSObject
+ (bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2;
@end

@interface IESLiveDeviceInfo: NSObject
+ (bool)isJailBroken;
@end

@interface PIPOStoreKitHelper: NSObject
- (bool)isJailBroken;
@end

@interface BDInstallNetworkUtility: NSObject
+ (bool)isJailBroken;
@end

@interface TTAdSplashDeviceHelper: NSObject
+ (bool)isJailBroken;
@end

@interface FBSDKAppEventsUtility: NSObject
+ (bool)isDebugBuild;
@end

static inline UIViewController * _Nullable topMostController() {
    UIWindow *keyWindow = nil;
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w.isKeyWindow) {
            keyWindow = w;
            break;
        }
    }
    if (!keyWindow) {
        keyWindow = [UIApplication sharedApplication].windows.firstObject;
    }
    UIViewController *topController = [keyWindow rootViewController];
    while ([topController presentedViewController]) {
        topController = [topController presentedViewController];
    }
    return topController;
}

static inline BOOL is_iPad() {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}
