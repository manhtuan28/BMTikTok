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

@class AWEAwemeModel;
@class AWEAwemeStatisticsModel;
@class AWEUserModel;
@class AWEVideoModel;
@class AWEMusicModel;
@class AWEPhotoAlbumModel;
@class AWEPhotoAlbumPhoto;
@class AWEURLModel;

@interface AppDelegate : NSObject <UIApplicationDelegate>
@end

@interface FLEXManager : NSObject
+ (instancetype)sharedManager;
- (void)showExplorer;
@end

@interface TTKProfileHomeViewController : UIViewController
@end

@interface TTKCommentPanelViewController: UIViewController
@end 

@interface AWECommentListViewController: UIViewController
@end 

@interface AWEPlayInteractionViewController : UIViewController
- (void)setPureMode:(BOOL)pureMode animated:(BOOL)animated;
- (void)hideAllElements:(BOOL)hidden exceptArray:(NSArray *)except;
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
@property(readonly, nonatomic) AWEURLModel *h264URL;
@property(readonly, nonatomic) AWEURLModel *playAddrH264;
@property(readonly, nonatomic) NSArray *bitrateModels;
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

@interface AWEAwemeStatisticsModel : NSObject
@property(readonly, nonatomic) NSNumber *diggCount;
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
- (NSNumber *)numberFromUserDefaultsForKey:(NSString *)key;
- (NSString *)formattedStringFromNumber:(NSNumber *)number;
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

@interface AWEUserWorkCollectionViewCell : UICollectionViewCell
- (AWEAwemeModel *)model;
- (NSString *)formattedNumber:(NSInteger)number;
- (NSString *)formattedDateStringFromTimestamp:(NSTimeInterval)timestamp;
@end

@interface AWEFeedViewTemplateCell: UITableViewCell <BMDownloadDelegate, BMMultipleDownloadDelegate>
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, retain) UIProgressView *progressView;
- (void)addDownloadButton;
- (void)addHideElementButton;
- (void)applyPureModeState:(BOOL)hide animated:(BOOL)animated;
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

@interface AWEAwemeDetailTableViewCell: UITableViewCell <BMDownloadDelegate, BMMultipleDownloadDelegate>
@property (nonatomic, strong) JGProgressHUD *hud;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) UIProgressView *progressView;
@property (nonatomic, retain) NSString *fileextension;
- (void)addDownloadButton;
- (void)addHideElementButton;
- (void)applyPureModeState:(BOOL)hide animated:(BOOL)animated;
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

@interface MPKitUtilityService: NSObject
- (BOOL)deviceIsJailbroken;
@end

// MARK: - Live Stream Comments Stability
@interface GBLCommentViewContainerConfig : NSObject
- (BOOL)banDismissAnimation;
- (BOOL)unlimitedDuration;
@end

@interface GBLCommentViewContainer : UIView
- (BOOL)banDismissAnimation;
@end

@interface IESLiveMTCleanScreenFragment : NSObject
- (void)switchToCleanModeWithType:(unsigned long long)arg1;
- (id)cleanScreenCountDownTimer;
- (void)setCleanScreenCountDownTimer:(id)arg1;
@end

@interface IESLiveCommentContainerFragment : NSObject
- (void)removeCommentContainerPortrait;
- (void)commentViewCancel;
@end

// MARK: - Ghost Mode & Privacy Interfaces
@interface TTKStoryNetworkService : NSObject
+ (void)reportStoryViewedWithStoryID:(id)storyID uid:(id)uid unlocked:(BOOL)unlocked completion:(id)completion;
+ (void)reportStoryViewedWithStoryID:(id)storyID uid:(id)uid completion:(id)completion;
+ (void)reportRevealStorySessionWithType:(long long)type reportTime:(id)time completion:(id)completion;
@end

@interface TTKSkylightStoryDataController : NSObject
- (void)_reportStoryRead:(id)arg1 authorID:(id)arg2 unlocked:(BOOL)arg3 retryCnt:(long long)arg4;
@end

@interface AWEIMInputStatusHandler : NSObject
- (void)sendInputStatusWithConversationID:(id)arg1 inputStatus:(long long)arg2;
- (void)sendInputStatusWithConversationID:(id)arg1;
@end

@interface TIMMessageSender : NSObject
- (void)sendMessage:(id)msg conversationType:(long long)type conversationShortID:(long long)shortID conversationID:(id)cid inInbox:(int)inbox clientExt:(id)ext forceUpdateShortID:(BOOL)force sendMediaList:(id)media bizTransientExtra:(id)extra source:(id)src;
- (void)sendInputStatusMessageWithStatus:(long long)arg1 extra:(id)arg2 conversationType:(long long)arg3 conversationShortID:(long long)arg4 conversationID:(id)arg5 inInbox:(int)inbox;
- (void)sendInputStatusMessageWithInputStatus:(long long)arg1 conversationID:(id)arg2 extra:(id)arg3 completion:(id)arg4;
- (void)markConversationAsRead:(id)arg1;
- (void)markConversationAsRead:(id)arg1 tillIndex:(long long)arg2 badgeCount:(long long)arg3;
@end

@interface TTKProfileViewsVisitor : NSObject
- (void)reportProfileView;
@end

@interface AWEIMActivityStatusSettingManager : NSObject
- (BOOL)recordUserActivityStatusEnabled;
@end

@interface AWEIMActivityStatusReportManager : NSObject
- (void)p_reportActivityStatusIfNeededWithParams:(id)arg1;
- (void)p_reportActivityStatusWithParams:(id)arg1;
- (void)p_startReportTimerIfNeeded;
- (void)requestReportCurrentUserActivityStatusWithType:(long long)arg1 sceneType:(long long)arg2 onCompletion:(id)arg3;
- (void)reportActivityStatusForRegularIfNeeded;
- (void)reportActivityStatusForColdLaunchIfNeeded;
@end

@interface AWEIMActivityStatusView : UIView
@end

@interface TTKInboxActivityStatusView : UIView
@end

// MARK: - Comment Translation Interfaces
@interface TTKCommentTranslationConfig : NSObject
- (id)initWithIsCommentAutoTranslationEnabled:(BOOL)enabled targetLanguageCode:(id)targetLang doNotTranslateLanguageCodes:(id)dntCodes;
- (BOOL)isCommentAutoTranslationEnabled;
- (NSString *)targetLanguageCode;
- (NSSet *)doNotTranslateLanguageCodes;
- (NSArray *)sortedDoNotTranslateLanguageCodes;
@end

@interface AWECommentsTranslationController : NSObject
- (BOOL)isCommentEligibleForAutomaticTranslation:(id)comment;
- (BOOL)isTranslationButtonDisplayEnabled;
- (BOOL)isCommentInDoNotTranslateCodes:(id)comment;
- (BOOL)isCommentTranslatable:(id)comment;
- (BOOL)shouldTranslateComment:(id)comment;
- (BOOL)_shouldTranslateCommentUsingSessionSnapshot:(id)arg1;
- (BOOL)isEligibleForAutomaticTranslationWithComment:(id)comment config:(id)config;
- (BOOL)shouldShowCommentTranslationLabel;
@end

@interface TTKTranslationSettingsManager : NSObject
- (NSString *)selectedTranslationLanguage;
- (NSString *)p_selectedTranslationLanguage;
- (NSString *)p_refactoredSelectedTranslationLanguage;
- (NSArray *)doNotTranslateList;
- (NSArray *)p_refactoredSelectedDoNotTranslateLanguages;
- (NSSet *)selectedDoNotTranslateLanguages;
@end

@interface TTKCLAAutoTranslationSettingItemViewModel : NSObject
- (BOOL)isSwitchOn;
- (BOOL)isOn;
@end

@interface AWEGlobalTranslationManager : NSObject
- (void)_fetchTranslationForOriginalContents:(id)contents targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion;
- (void)_fetchTranslationForOriginalContent:(id)content targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion;
- (void)submitOriginalContentsForTranslation:(id)contents requestingStatus:(long long)status targetLanguageCode:(id)targetLang enableTempCache:(BOOL)cache additionalParams:(id)params;
- (void)submitOriginalContentForTranslation:(id)content requestingStatus:(long long)status targetLanguageCode:(id)targetLang additionalParams:(id)params;
- (void)fetchTranslationForOriginalContent:(id)content targetLanguageCode:(id)targetLang additionalParams:(id)params timeout:(double)timeout completion:(id)completion;
- (void)fetchTranslationForContentsWithTranslationInfo:(id)info targetLanguageCode:(id)targetLang additionalParams:(id)params completion:(id)completion;
@end

@interface C24yGlobalTranslationSettingModel : NSObject
- (BOOL)autoTranslationEnabled;
- (NSString *)targetLanguageCode;
- (NSSet *)doNotTranslateLanguages;
@end

@interface TTKCLAAlwaysTranslateCommentSettingItemViewModel : NSObject
- (BOOL)isSwitchOn;
- (BOOL)isOn;
@end

@interface TTKCLATranslationTargetLanguageSettingItemViewModel : NSObject
- (NSString *)selectedLanguageCode;
- (NSString *)currentLanguageCode;
@end

@interface AWEBadgeView : UIView
@end

@interface TTKUserEffectTabDataManager : NSObject
- (BOOL)p_shouldShowLikeTab;
@end

@interface AWEFeedContainerViewController : UIViewController
- (void)switchToFollowingTab;
@end

@interface AWEFeedTableViewController : UIViewController
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4;
- (void)slideToProfileVCWithModel:(id)arg1 referString:(id)arg2 bizScene:(id)arg3 cell:(id)arg4 logExtraDict:(id)arg5;
@end

@interface TTKFeedInteractionTopView : UIView
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
