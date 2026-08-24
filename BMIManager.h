//
//  BMIManager.h
//  BMTikTok
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface BMIManager: NSObject

// MARK: - 1. Feed & Ads
+ (BOOL)hideAds;
+ (BOOL)hideCommissionPosts;
+ (BOOL)removePendant;
+ (BOOL)removeTikTokAIButton;
+ (BOOL)hidePlayPause;
+ (BOOL)hideTopItems;
+ (BOOL)startFYPInFollowing;
+ (BOOL)disableSwipeInFYP;
+ (BOOL)disablePullToRefresh;
+ (BOOL)autoScrollFeed;
+ (BOOL)disableUnsensitive;
+ (BOOL)disableWarnings;
+ (BOOL)disableLive;
+ (BOOL)blockMovieTok;
+ (BOOL)blockPOI;
+ (BOOL)blockAIGenerated;
+ (BOOL)skipRecommendations;

// MARK: - 2. Download & Media
+ (BOOL)downloadButton;
+ (BOOL)removeWatermark;
+ (BOOL)removeDraftWatermark;
+ (BOOL)downloadMusic;
+ (BOOL)shareSheet;
+ (BOOL)saveDMMedia;
+ (BOOL)enableStickerDownload;
+ (BOOL)highestVideoQuality;
+ (BOOL)uploadHD;

// MARK: - 3. Playback Controls
+ (BOOL)autoPlay;
+ (BOOL)stopPlay;
+ (BOOL)progressBar;
+ (BOOL)keepAudioUnmuted;
+ (BOOL)speedEnabled;
+ (NSNumber *)selectedSpeed;
+ (BOOL)forceHighestBitrate;

// MARK: - 4. Region & Location
+ (BOOL)regionChangingEnabled;
+ (NSDictionary *)selectedRegion;
+ (BOOL)russianFix;
+ (BOOL)uploadRegion;

// MARK: - 5. Privacy & Ghost Mode
+ (BOOL)anonymousSeen;
+ (BOOL)markSeenOnReply;
+ (BOOL)disableTyping;
+ (BOOL)viewProfilesAnonymous;
+ (BOOL)disableScreenshotDetection;
+ (BOOL)disableScreenrecordingDetection;
+ (BOOL)hideActivityStatus;
+ (BOOL)appLock;

// MARK: - 6. Comments & Interaction
+ (BOOL)transparentCommnet;
+ (BOOL)hideEmojiBar;
+ (BOOL)colorizeCommentUsernames;
+ (BOOL)copyCommentText;
+ (BOOL)enableCommentFlags;
+ (BOOL)autoTranslateComments;
+ (BOOL)disableSafariRedirect;
+ (BOOL)extendedComment;

// MARK: - 7. Profile & Fake Stats
+ (BOOL)fakeVerified;
+ (BOOL)fakeChangesEnabled;
+ (NSString *)fakeFollowerCount;
+ (NSString *)fakeFollowingCount;
+ (NSString *)fakeLikesCount;
+ (BOOL)profileCopy;
+ (BOOL)profileIdCopy;
+ (BOOL)profileSave;
+ (BOOL)hideLikedTab;
+ (BOOL)extendedBio;
+ (BOOL)showUsername;
+ (BOOL)videoLikeCount;
+ (BOOL)videoUploadDate;
+ (BOOL)profileVideoCount;

// MARK: - 8. Confirmations
+ (BOOL)likeConfirmation;
+ (BOOL)followConfirmation;
+ (BOOL)likeCommentConfirmation;
+ (BOOL)dislikeCommentConfirmation;
+ (BOOL)publishConfirmation;
+ (BOOL)downloadConfirmation;
+ (BOOL)bookmarkConfirmation;

// MARK: - 9. Theme & UI
+ (BOOL)hideElementButton;
+ (BOOL)oledKeyboard;
+ (BOOL)hideTabBarLabels;
+ (BOOL)hideBadgeCounter;
+ (BOOL)transparentStatusBar;
+ (BOOL)showExactDate;
+ (BOOL)liveActionEnabled;
+ (NSNumber *)selectedLiveAction;

// MARK: - 10. Helpers & Utilities
+ (void)showSaveVC:(id)item;
+ (void)cleanCache;
+ (void)eraseAllData;
+ (BOOL)isEmpty:(NSURL *)url;
+ (NSString *)getDownloadingPersent:(float)per;
+ (void)saveMedia:(id)item fileExtension:(id)fileExtension;
+ (void)saveAudioFromURL:(NSURL *)audioURL completion:(void (^)(BOOL success, NSError *error))completion;

@end