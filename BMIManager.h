#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BMIManager: NSObject

// MARK: - Feed & Ads
+ (BOOL)hideAds;
+ (BOOL)hideCommissionPosts;
+ (BOOL)removePendant;
+ (BOOL)removeTikTokAIButton;
+ (BOOL)hidePlayPause;
+ (BOOL)hideTopItems;
+ (BOOL)startFYPInFollowing;
+ (BOOL)disableSwipeInFYP;
+ (BOOL)disablePullToRefresh;
+ (BOOL)disableUnsensitive;
+ (BOOL)disableWarnings;
+ (BOOL)disableLive;
+ (BOOL)skipRecommendations;
+ (BOOL)disableSurvey;
+ (BOOL)hideDangerousAction;
+ (BOOL)blockMovieTok;
+ (BOOL)blockTCM;
+ (BOOL)blockPOI;
+ (BOOL)blockAIGenerated;

// MARK: - Download & Media
+ (BOOL)downloadButton;
+ (BOOL)downloadMusic;
+ (BOOL)shareSheet;
+ (BOOL)removeWatermark;
+ (BOOL)removeDraftWatermark;
+ (BOOL)saveDMMedia;
+ (BOOL)enableStickerDownload;
+ (BOOL)uploadHD;

// MARK: - Playback Controls
+ (BOOL)autoPlay;
+ (BOOL)stopPlay;
+ (BOOL)progressBar;
+ (BOOL)loopStoryVideos;
+ (BOOL)stopStoryPhotoAdvance;
+ (BOOL)backgroundPlay;
+ (BOOL)speedEnabled;
+ (NSNumber *)selectedSpeed;

// MARK: - Region & Location
+ (BOOL)regionChangingEnabled;
+ (BOOL)fullRegionMode;
+ (BOOL)russianFix;
+ (NSDictionary *)selectedRegion;
+ (BOOL)uploadRegion;
+ (BOOL)enableCommentFlags;

// MARK: - Privacy & Ghost Mode
+ (BOOL)anonymousSeen;
+ (BOOL)markSeenOnReply;
+ (BOOL)disableTyping;
+ (BOOL)viewProfilesAnonymous;
+ (BOOL)disableScreenshotDetection;
+ (BOOL)disableScreenrecordingDetection;
+ (BOOL)hideActivityStatus;
+ (BOOL)appLock;

// MARK: - Comments
+ (BOOL)transparentCommnet;
+ (BOOL)copyWithoutUsername;
+ (BOOL)autoUnfold;
+ (BOOL)massUnfold;
+ (BOOL)disableCommentTooltip;
+ (BOOL)hideEmojiBar;
+ (BOOL)extendedComment;

// MARK: - Profile & Interactions
+ (BOOL)profileSave;
+ (BOOL)profileCopy;
+ (BOOL)profileVideoCount;
+ (BOOL)videoLikeCount;
+ (BOOL)videoUploadDate;
+ (BOOL)showVideoTimestamp;
+ (BOOL)showUsername;
+ (BOOL)extendedBio;
+ (BOOL)alwaysOpenSafari;
+ (BOOL)bypassFollowListSearch;
+ (BOOL)bypassMediaLimit;
+ (BOOL)fakeChangesEnabled;
+ (BOOL)fakeVerified;
+ (NSString *)fakeFollowerCount;
+ (NSString *)fakeFollowingCount;

// MARK: - Confirmations
+ (BOOL)likeConfirmation;
+ (BOOL)likeCommentConfirmation;
+ (BOOL)dislikeCommentConfirmation;
+ (BOOL)followConfirmation;
+ (BOOL)storyLikeConfirmation;
+ (BOOL)quickShareConfirm;
+ (BOOL)repostConfirm;
+ (BOOL)disableFeedDoubleTap;
+ (BOOL)disableStoryDoubleTap;

// MARK: - UI & Theme
+ (BOOL)hideElementButton;
+ (BOOL)oledKeyboard;
+ (BOOL)hideTabBarLabels;
+ (BOOL)hidePlusButton;
+ (BOOL)hideFriendsBadge;
+ (BOOL)hideInboxBadge;
+ (BOOL)hideStreakPet;
+ (BOOL)liveActionEnabled;
+ (NSNumber *)selectedLiveAction;

// MARK: - Helpers & Utilities
+ (void)showSaveVC:(id)item;
+ (void)cleanCache;
+ (void)eraseAllData;
+ (BOOL)isEmpty:(NSURL *)url;
+ (NSString *)getDownloadingPersent:(float)per;
+ (void)saveMedia:(id)item fileExtension:(id)fileExtension;
+ (void)saveAudioFromURL:(NSURL *)audioURL completion:(void (^)(BOOL success, NSError *error))completion;

@end