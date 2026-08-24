#import "TikTokHeaders.h"

NSArray *jailbreakPaths;

static void showConfirmation(void (^okHandler)(void)) {
  [%c(AWEUIAlertView) showAlertWithTitle:@"Xác nhận BMTikTok" description:@"Bạn có chắc chắn muốn thực hiện thao tác này không?" image:nil actionButtonTitle:@"Đồng ý" cancelButtonTitle:@"Hủy" actionBlock:^{
    okHandler();
  } cancelBlock:nil];
}

%hook AppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"flex_enebaled"]) {
        [[%c(FLEXManager) performSelector:@selector(sharedManager)] performSelector:@selector(showExplorer)];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BMTikTokFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"BMTikTokFirstRun" forKey:@"BMTikTokFirstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"download_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"remove_elements_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"show_porgress_bar"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_profile_information"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extended_bio"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extendedComment"];
    }
    [BMIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 { // old app lock TODO: add face-id
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

%hook AWEUserWorkCollectionViewCell
- (void)configWithModel:(id)arg1 isMine:(BOOL)arg2 { // Video like count & upload date lables
    %orig;
    if ([BMIManager videoLikeCount] || [BMIManager videoUploadDate]) {
        for (int i = 0; i < [[self.contentView subviews] count]; i ++) {
            UIView *j = [[self.contentView subviews] objectAtIndex:i];
            if (j.tag == 1001) {
                [j removeFromSuperview];
            } 
            else if (j.tag == 1002) {
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
        

        for (int i = 0; i < [[self.contentView subviews] count]; i ++) {
            UIView *j = [[self.contentView subviews] objectAtIndex:i];
            if (j.tag == 1001) {
                [j removeFromSuperview];
            } 
            else if (j.tag == 1002) {
                [j removeFromSuperview];
            }
        }
        if ([BMIManager videoLikeCount]) {
        [self.contentView addSubview:heartImage];
        [NSLayoutConstraint activateConstraints:@[
                [heartImage.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:110],
                [heartImage.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:4],
                [heartImage.widthAnchor constraintEqualToConstant:16],
                [heartImage.heightAnchor constraintEqualToConstant:16],
            ]];
        [self.contentView addSubview:likeCountLabel];
        [NSLayoutConstraint activateConstraints:@[
                [likeCountLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:109],
                [likeCountLabel.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:23],
                [likeCountLabel.widthAnchor constraintEqualToConstant:200],
                [likeCountLabel.heightAnchor constraintEqualToConstant:16],
            ]];
        }
        if ([BMIManager videoUploadDate]) {
        [self.contentView addSubview:clockImage];
        [NSLayoutConstraint activateConstraints:@[
                [clockImage.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:128],
                [clockImage.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:4],
                [clockImage.widthAnchor constraintEqualToConstant:16],
                [clockImage.heightAnchor constraintEqualToConstant:16],
            ]];
        [self.contentView addSubview:uploadDateLabel];
        [NSLayoutConstraint activateConstraints:@[
                [uploadDateLabel.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:127],
                [uploadDateLabel.leadingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.leadingAnchor constant:23],
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
    dateFormatter.dateFormat = @"dd.MM.yy"; 
    return [dateFormatter stringFromDate:date];

}
%end

%hook TTKProfileRootView
- (void)layoutSubviews { // Video count
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
- (void)layoutSubviews { // Profile save
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
        NSLog(@"Error saving image: %@", error.localizedDescription);
    } else {
        NSLog(@"Image successfully saved to Photos app");
    }
}
%end

%hook AWEUserNameLabel // fake verification
- (void)layoutSubviews {
    %orig;
    if ([self.yy_viewController isKindOfClass:(%c(TTKProfileHomeViewController))] && [BMIManager fakeVerified]) {
        [self addVerifiedIcon:true];
    }
}
%end

%hook TTTAttributedLabel // copy profile decription
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

%hook TTKSettingsBaseCellPlugin
- (void)didSelectItemAtIndex:(NSInteger)index {
    if ([self.itemModel.identifier isEqualToString:@"bmtiktok_settings"]) {
        UINavigationController *BMTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
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
        [BMTikTokSettingsItemModel setTitle:@"BMTikTok++ settings"];
        [BMTikTokSettingsItemModel setDetail:@"BMTikTok++ settings"];
        [BMTikTokSettingsItemModel setIconImage:[UIImage systemImageNamed:@"gear"]];
        [BMTikTokSettingsItemModel setType:99];

        [BMTikTokSettingsPluginCell setItemModel:BMTikTokSettingsItemModel];

        [self insertModel:BMTikTokSettingsPluginCell atIndex:0 animated:true];
    }
}
%end

%hook SparkViewController // alwaysOpenSafari
- (void)viewWillAppear:(BOOL)animated {
    if (![BMIManager alwaysOpenSafari]) {
        return %orig;
    }
    
    // NSURL *url = self.originURL;
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *searchParameter = @"url";
    NSString *searchValue = nil;
    
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:searchParameter]) {
            searchValue = queryItem.value;
            break;
        }
    }
    
    // In-app browser is used for two-factor authentication with security key,
    // login will not complete successfully if it's redirected to Safari
    // if ([urlStr containsString:@"twitter.com/account/"] || [urlStr containsString:@"twitter.com/i/flow/"]) {
    //     return %orig;
    // }

    if (searchValue) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchValue] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        return %orig;
    }
}
%end

%hook CTCarrier // changes country 
- (NSString *)mobileCountryCode {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"mcc"];
        }
        return %orig;
    }
    return %orig;
}

- (void)setIsoCountryCode:(NSString *)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}

- (NSString *)isoCountryCode {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}

- (NSString *)mobileNetworkCode {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"mnc"];
        }
        return %orig;
    }
    return %orig;
}
%end
%hook TTKStoreRegionService
- (id)storeRegion {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)getStoreRegion {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end
%hook TIKTOKRegionManager
+ (NSString *)systemRegion {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)region {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)mccmnc {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [NSString stringWithFormat:@"%@%@", selectedRegion[@"mcc"], selectedRegion[@"mnc"]];
        }
        return %orig;
    }
    return %orig;
}
+ (id)storeRegion {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)currentRegionV2 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
+ (id)localRegion {
        if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}

%end

%hook TTKPassportAppStoreRegionModel
- (id)storeRegion {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (void)setLocalizedCountryName:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig(selectedRegion[@"name"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)localizedCountryName {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"name"];
        }
        return %orig;
    }
    return %orig;
}
%end

%hook ATSRegionCacheManager
- (id)getRegion {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)storeRegionFromCache {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (id)storeRegionFromTTNetNotification:(id)arg1 {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
- (void)setRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig([selectedRegion[@"code"] lowercaseString]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
- (id)region {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return [selectedRegion[@"code"] lowercaseString];
        }
        return %orig;
    }
    return %orig;
}
%end

%hook TTKStoreRegionModel
- (id)storeRegion {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setStoreRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook TTInstallIDManager
- (id)currentAppRegion {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setCurrentAppRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook BDInstallGlobalConfig
- (id)currentAppRegion {
 if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return selectedRegion[@"code"];
        }
        return %orig;
    }
    return %orig;
}
- (void)setCurrentAppRegion:(id)arg1 {
    if ([BMIManager regionChangingEnabled]) {
        if ([BMIManager selectedRegion]) {
            NSDictionary *selectedRegion = [BMIManager selectedRegion];
            return %orig(selectedRegion[@"code"]);
        }
        return %orig(arg1);
    }
    return %orig(arg1);
}
%end

%hook ACCCreationPublishAction
- (BOOL)is_open_hd {
    if ([BMIManager uploadHD]) {
        return 1;
    }
    return %orig;
}
- (void)setIs_open_hd:(BOOL)arg1 {
    if ([BMIManager uploadHD]) {
        %orig(1);
    }
    else {
        return %orig;
    }
}
- (BOOL)is_have_hd {
    if ([BMIManager uploadHD]) {
        return 1;
    }
    return %orig;
}
- (void)setIs_have_hd:(BOOL)arg1 {
    if ([BMIManager uploadHD]) {
        %orig(1);
    }
    else {
        return %orig;
    }
}

%end

%hook TTKCommentPanelViewController
- (void)viewDidLoad {
    %orig;
    if ([BMIManager transparentCommnet]){
        UIView *commnetView = [self view];
        [commnetView setAlpha:0.90];
    }
}
%end

%hook AWEAwemeModel // no ads, block AI videos, show progress bar
- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
    id orig = %orig;
    if ([BMIManager hideAds] && self.isAds) {
        return nil;
    }
    if ([BMIManager blockAIGenerated]) {
        if ([self respondsToSelector:@selector(aigcInfoModel)] && [self aigcInfoModel]) {
            return nil;
        }
        if ([self respondsToSelector:@selector(isAIGC)] && [self isAIGC]) {
            return nil;
        }
        if ([self respondsToSelector:@selector(isAIGCSuggested)] && [self isAIGCSuggested]) {
            return nil;
        }
    }
    return orig;
}
- (id)init {
    id orig = %orig;
    if ([BMIManager hideAds] && self.isAds) {
        return nil;
    }
    if ([BMIManager blockAIGenerated]) {
        if ([self respondsToSelector:@selector(aigcInfoModel)] && [self aigcInfoModel]) {
            return nil;
        }
        if ([self respondsToSelector:@selector(isAIGC)] && [self isAIGC]) {
            return nil;
        }
        if ([self respondsToSelector:@selector(isAIGCSuggested)] && [self isAIGCSuggested]) {
            return nil;
        }
    }
    return orig;
}

- (BOOL)progressBarDraggable {
    return [BMIManager progressBar] || %orig;
}
- (BOOL)progressBarVisible {
    return [BMIManager progressBar] || %orig;
}
- (void)live_callInitWithDictyCategoryMethod:(id)arg1 {
    if (![BMIManager disableLive]) {
        %orig;
    }
}
+ (id)liveStreamURLJSONTransformer {
    if ([BMIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)relatedLiveJSONTransformer {
    if ([BMIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)rawModelFromLiveRoomModel:(id)arg1 {
    if ([BMIManager disableLive]) {
        return nil;
    }
    return %orig;
}
+ (id)aweLiveRoom_subModelPropertyKey {
    if ([BMIManager disableLive]) {
        return nil;
    }
    return %orig;
}
%end

%hook AWEPlayInteractionWarningElementView
- (id)warningImage {
    if ([BMIManager disableWarnings]) {
        return nil;
    }
    return %orig;
}
- (id)warningLabel {
    if ([BMIManager disableWarnings]) {
        return nil;
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
            NSString *nickname = authorModel.nickname;
            NSString *username = authorModel.socialName;
            %orig(username);
        }else {
            %orig;
        }
    }else {
        %orig;
    }
}
%end

%hook AWENewFeedTableViewController
- (BOOL)disablePullToRefreshGestureRecognizer {
    if ([BMIManager disablePullToRefresh]){
        return 1;
    }
    return %orig;
}

%end

%hook AWEPlayVideoPlayerController // auto play next video and stop looping video
- (void)playerWillLoopPlaying:(id)arg1 {
    if ([BMIManager autoPlay]) {
        if ([self.container.parentViewController isKindOfClass:%c(AWENewFeedTableViewController)]) {
            [((AWENewFeedTableViewController *)self.container.parentViewController) scrollToNextVideo];
            return;
        }
    }
    %orig;
}
- (BOOL)loop {
    if ([BMIManager stopPlay]) {
        return 0;
    }
    return %orig; 
}
- (void)setLoop:(BOOL)arg1 {
    if ([BMIManager stopPlay]) {
        %orig(0);
    }else {
        %orig;
    }
}
%end

%hook AWEMaskInfoModel // Disable Unsensitive Content
- (BOOL)showMask {
    if ([BMIManager disableUnsensitive]) {
        return 0;
    }
    return %orig;
}
- (void)setShowMask:(BOOL)arg1 {
    if ([BMIManager disableUnsensitive]) {
        %orig(0);
    }
    else {
        %orig;
    }
}
%end

%hook AWEAwemeACLItem // remove default watermark
- (void)setWatermarkType:(NSUInteger)arg1 {
    if ([BMIManager removeWatermark]){
        %orig(1);
    }
    else { 
        %orig;
    }
    
}
- (NSUInteger)watermarkType {
    if ([BMIManager removeWatermark]){
        return 1;
    }
    return %orig;
}
%end

%hook UIButton // follow confirmation
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

%hook TTKProfileBaseComponentModel // Fake Followers, Fake Following and FakeVerified.

- (NSDictionary *)bizData {
	if ([BMIManager fakeChangesEnabled]) {
		NSDictionary *originalData = %orig;
		NSMutableDictionary *modifiedData = [originalData mutableCopy];
		
		NSNumber *fakeFollowingCount = [self numberFromUserDefaultsForKey:@"following_count"];
		NSNumber *fakeFollowersCount = [self numberFromUserDefaultsForKey:@"follower_count"];
		
		if ([self.componentID isEqualToString:@"relation_info_follower"]) {
			modifiedData[@"follower_count"] = fakeFollowersCount ?: @0; 
		} else if ([self.componentID isEqualToString:@"relation_info_following"]) {
			modifiedData[@"following_count"] = fakeFollowingCount ?: @0; 
			modifiedData[@"formatted_number"] = [self formattedStringFromNumber:fakeFollowingCount ?: @0];
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

%hook AWEFeedVideoButton // like feed confirmation
- (void)_onTouchUpInside {
    if ([BMIManager likeConfirmation] && [self.imageNameString isEqualToString:@"ic_like_fill_1_new"]) {
        void (^actionBlock)(void) = ^{
            %orig;
        };
        showConfirmation(actionBlock);
    } else {
        %orig;
    }
}
%end
%hook AWECommentPanelCell // like/dislike comment confirmation
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

%hook AWEUserModel // follower, following Count fake  
- (NSNumber *)followerCount {
    if ([BMIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"follower_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
- (NSNumber *)followingCount {
    if ([BMIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"following_count"];
        if (!(fakeCountString.length == 0)) {
            NSInteger fakeCount = [fakeCountString integerValue];
            return [NSNumber numberWithInt:fakeCount];
        }

        return %orig;
    }

    return %orig;
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    if ([BMIManager extendedComment]) {
        return 500;
    }

    return %orig;
}
%end
%hook AWEPlayVideoPlayerController
- (void)containerDidFullyDisplayWithReason:(NSInteger)arg1 {
    if ([[[self container] parentViewController] isKindOfClass:%c(AWENewFeedTableViewController)] && [BMIManager skipRecommendations]) {
        AWENewFeedTableViewController *rootVC = [[self container] parentViewController];
        AWEAwemeModel *currentModel = [rootVC currentAweme];
        if ([currentModel isUserRecommendBigCard]) {
            [rootVC scrollToNextVideo];
        }
    }else {
        %orig;
    }
}
%end
%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    if ([BMIManager extendedBio]) {
        return 222;
    }

    return %orig;
}
%end
%hook AWEPlayInteractionAuthorView
%new - (NSString *)emojiForCountryCode:(NSString *)countryCode {
    // Convert the country code to uppercase
    NSString *uppercaseCountryCode = [countryCode uppercaseString];
    
    // Ensure the country code has exactly two characters
    if (uppercaseCountryCode.length != 2) {
        return nil;
    }
    
    // Convert the country code to the regional indicator symbols
    uint32_t firstLetter = [uppercaseCountryCode characterAtIndex:0] + 0x1F1E6 - 'A';
    uint32_t secondLetter = [uppercaseCountryCode characterAtIndex:1] + 0x1F1E6 - 'A';
    
    // Create the emoji using the regional indicator symbols
    NSString *flagEmoji = [[NSString alloc] initWithBytes:&firstLetter length:4 encoding:NSUTF32LittleEndianStringEncoding];
    flagEmoji = [flagEmoji stringByAppendingString:[[NSString alloc] initWithBytes:&secondLetter length:4 encoding:NSUTF32LittleEndianStringEncoding]];
    
    return flagEmoji;
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
            }else {
                [[self viewWithTag:666] removeFromSuperview];
            }
        }
        [[self viewWithTag:666] removeFromSuperview];
        AWEFeedCellViewController* rootVC = self.yy_viewController;
        AWEAwemeModel *model = rootVC.model;
        NSString *countryID = model.region;
        UILabel *uploadLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,2,39.5,20.5)];
        NSString *countryEmoji = [self emojiForCountryCode:countryID];
        uploadLabel.text = [NSString stringWithFormat:@"%@ •",countryEmoji];
        uploadLabel.tag = 666;
        [uploadLabel setTextColor: [UIColor whiteColor]];
        [uploadLabel sizeToFit];
        [self addSubview:uploadLabel];
    }
}
%end

// Modern TikTok 46.5.0 hooks
%hook TTKProfileHeaderView
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BMIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
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

%hook AWEScreenShotTracker
- (void)trackScreenShotWithParam:(id)arg1 {
    if ([BMIManager disableScreenshotDetection]) {
        return;
    }
    %orig(arg1);
}
%end

%hook TIKTOKProfileHeaderView // copy profile information
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BMIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%end

%hook AWELiveFeedEntranceView
- (void)switchStateWithTapped:(BOOL)arg1 {
    if (![BMIManager liveActionEnabled] || [BMIManager selectedLiveAction] == 0) {
        %orig;
    } else if ([BMIManager liveActionEnabled] && [[BMIManager selectedLiveAction] intValue] == 1) {
        UINavigationController *BMTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
        [topMostController() presentViewController:BMTikTokSettings animated:true completion:nil];
    } 
    else {
        %orig;
    }

}
%end


%hook AWEFeedViewTemplateCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, retain) UIProgressView *progressView;
- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(downloadButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down"] forState:UIControlStateNormal];
    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];

        [NSLayoutConstraint activateConstraints:@[
            [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:90],
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [downloadButton.widthAnchor constraintEqualToConstant:30],
            [downloadButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tikwm.com/video/media/hdplay/%@.mp4", as]];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC photoIndex:(unsigned long)index {
    AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];
            NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
            AWEPhotoAlbumPhoto *currentPhoto = [photos objectAtIndex:index];

                NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BMDownload *dwManager = [[BMDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                     [self.hud showInView:topMostController().view];
                }
            
    }

%new - (void)downloadPhotos:(TTKPhotoAlbumDetailCellController *)rootVC {
    NSString *video_description = rootVC.model.music_songName;
    AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];

            NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
            NSMutableArray<NSURL *> *fileURLs = [NSMutableArray array];

            for (AWEPhotoAlbumPhoto *currentPhoto in photos) {
                NSURL *downloadableURL = [currentPhoto.originPhotoURL bestURLtoDownload];
                self.fileextension = [currentPhoto.originPhotoURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    [fileURLs addObject:downloadableURL];
                }
            }

            BMMultipleDownload *dwManager = [[BMMultipleDownload alloc] init];
            [dwManager setDelegate:self];
            [dwManager downloadFiles:fileURLs];
            self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
            self.hud.textLabel.text = @"Downloading";
            [self.hud showInView:topMostController().view];

}
%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = @"mp3";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Không thể sao chép liên kết âm thanh." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Video này không có tệp âm thanh phù hợp để tải xuống." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = rootVC.model.music_songName;
    if (video_description) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Video này không có tệp âm thanh phù hợp để tải xuống." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void) downloadButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC isKindOfClass:%c(AWEFeedCellViewController)]) {

         UIAction *action1 = [UIAction actionWithTitle:@"Download Video"
                                            image:[UIImage systemImageNamed:@"film"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadVideo:rootVC];
    }];
        UIAction *action0 = [UIAction actionWithTitle:@"Download HD Video"
                                            image:[UIImage systemImageNamed:@"film"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadHDVideo:rootVC];
    }];
    UIAction *action2 = [UIAction actionWithTitle:@"Download Music"
                                            image:[UIImage systemImageNamed:@"music.note"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadMusic:rootVC];
    }];
    UIAction *action3 = [UIAction actionWithTitle:@"Copy Music link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyMusic:rootVC];
    }];
    UIAction *action4 = [UIAction actionWithTitle:@"Copy Video link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyVideo:rootVC];
    }];
    UIAction *action5 = [UIAction actionWithTitle:@"Copy Decription"
                                            image:[UIImage systemImageNamed:@"note.text"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyDecription:rootVC];
    }];
    UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Downloads Menu"
                                        children:@[action1, action0,action2]];
    UIMenu *copyMenu = [UIMenu menuWithTitle:@"Copy Menu"
                                        children:@[action3, action4, action5]];
    UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[downloadMenu, copyMenu]];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
    } else if ([self.viewController isKindOfClass:%c(TTKPhotoAlbumDetailCellController)]) {
        TTKPhotoAlbumDetailCellController *rootVC = self.viewController;
        AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];
        NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        NSMutableArray <UIAction *> *photosActions = [NSMutableArray array];
            for (int i = 0; i < photosCount; i++) {
        NSString *title = [NSString stringWithFormat:@"Download Photo %d", i+1];
        UIAction *action = [UIAction actionWithTitle:title
                                               image:[UIImage systemImageNamed:@"photo.fill"]
                                          identifier:nil
                                             handler:^(__kindof UIAction * _Nonnull action) {
                                                [self downloadPhotos:rootVC photoIndex:i];
        }];
        [photosActions addObject:action];

    }
    UIAction *allPhotosAction = [UIAction actionWithTitle:@"Download All Photos"
                                            image:[UIImage systemImageNamed:@"photo.fill"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadPhotos:rootVC];
    }];
    [photosActions addObject:allPhotosAction];
    UIAction *action2 = [UIAction actionWithTitle:@"Download Music"
                                            image:[UIImage systemImageNamed:@"music.note"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadMusic:rootVC];
    }];
    UIAction *action3 = [UIAction actionWithTitle:@"Copy Music link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyMusic:rootVC];
    }];
    UIAction *action4 = [UIAction actionWithTitle:@"Copy Video link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyVideo:rootVC];
    }];
    UIAction *action5 = [UIAction actionWithTitle:@"Copy Decription"
                                            image:[UIImage systemImageNamed:@"note.text"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyDecription:rootVC];
    }];
    UIMenu *PhotosMenu = [UIMenu menuWithTitle:@"Download Photos Menu"
                                        children:photosActions];
    UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Downloads Menu"
                                        children:@[action2]];
    UIMenu *copyMenu = [UIMenu menuWithTitle:@"Copy Menu"
                                        children:@[action3, action4, action5]];
    UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[PhotosMenu, downloadMenu, copyMenu]];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
    }else if ([self.viewController isKindOfClass:%c(TTKPhotoAlbumFeedCellController)]) {
        TTKPhotoAlbumFeedCellController *rootVC = self.viewController;
        AWEPlayPhotoAlbumViewController *photoAlbumController = [rootVC valueForKey:@"_photoAlbumController"];
        NSArray <AWEPhotoAlbumPhoto *> *photos = rootVC.model.photoAlbum.photos;
        unsigned long photosCount = [photos count];
        NSMutableArray <UIAction *> *photosActions = [NSMutableArray array];
            for (int i = 0; i < photosCount; i++) {
        NSString *title = [NSString stringWithFormat:@"Download Photo %d", i+1];
        UIAction *action = [UIAction actionWithTitle:title
                                               image:[UIImage systemImageNamed:@"photo.fill"]
                                          identifier:nil
                                             handler:^(__kindof UIAction * _Nonnull action) {
                                                [self downloadPhotos:rootVC photoIndex:i];
        }];
        [photosActions addObject:action];

    }
        UIAction *allPhotosAction = [UIAction actionWithTitle:@"Download Photos"
                                            image:[UIImage systemImageNamed:@"photo.fill"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadPhotos:rootVC];
    }];
    [photosActions addObject:allPhotosAction];
    UIAction *action2 = [UIAction actionWithTitle:@"Download Music"
                                            image:[UIImage systemImageNamed:@"music.note"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadMusic:rootVC];
    }];
    UIAction *action3 = [UIAction actionWithTitle:@"Copy Music link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyMusic:rootVC];
    }];
    UIAction *action4 = [UIAction actionWithTitle:@"Copy Video link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyVideo:rootVC];
    }];
    UIAction *action5 = [UIAction actionWithTitle:@"Copy Decription"
                                            image:[UIImage systemImageNamed:@"note.text"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyDecription:rootVC];
    }];
    UIMenu *PhotosMenu = [UIMenu menuWithTitle:@"Download Photos Menu"
                                        children:photosActions];
    UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Downloads Menu"
                                        children:@[action2]];
    UIMenu *copyMenu = [UIMenu menuWithTitle:@"Copy Menu"
                                        children:@[action3, action4, action5]];
    UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[PhotosMenu, downloadMenu, copyMenu]];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
    }
}
%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.elementsHidden) {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
    } else {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateNormal];
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
        }
    }
}

%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BMIManager getDownloadingPersent:progress];
}
%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    if ([BMIManager shareSheet]) {
        [BMIManager showSaveVC:downloadedFilePaths];
    }
    else {
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
        self.hud.textLabel.text = @"Backgrounding ✌️";
        [self.hud dismissAfterDelay:0.4];
    };
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BMIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BMIManager showSaveVC:@[newFilePath]];
    }
    else {
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
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) UIProgressView *progressView;
%property (nonatomic, retain) NSString *fileextension;
- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BMIManager downloadButton]){
        [self addDownloadButton];
    }
    if ([BMIManager hideElementButton]) {
        [self addHideElementButton];
    }
}
%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(downloadButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down"] forState:UIControlStateNormal];
    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];

        [NSLayoutConstraint activateConstraints:@[
            [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:90],
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [downloadButton.widthAnchor constraintEqualToConstant:30],
            [downloadButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)downloadHDVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://tikwm.com/video/media/hdplay/%@.mp4", as]];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadVideo:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
        self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)downloadMusic:(AWEAwemeBaseViewController *)rootVC {
    NSString *as = rootVC.model.itemID;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
        self.fileextension = @"mp3";
    if (downloadableURL) {
        BMDownload *dwManager = [[BMDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:topMostController().view];
    }
}
%new - (void)copyMusic:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Video này không có tệp âm thanh phù hợp để tải xuống." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyVideo:(AWEAwemeBaseViewController *)rootVC {
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    if (downloadableURL) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = [downloadableURL absoluteString];
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Video này không có tệp âm thanh phù hợp để tải xuống." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void)copyDecription:(AWEAwemeBaseViewController *)rootVC {
    NSString *video_description = rootVC.model.music_songName;
    if (video_description) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    } else {
        [%c(AWEUIAlertView) showAlertWithTitle:@"BMTikTok, Hi" description:@"Video này không có tệp âm thanh phù hợp để tải xuống." image:nil actionButtonTitle:@"OK" cancelButtonTitle:nil actionBlock:nil cancelBlock:nil];
    }
}
%new - (void) downloadButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {

     UIAction *action1 = [UIAction actionWithTitle:@"Download Video"
                                            image:[UIImage systemImageNamed:@"film"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadVideo:rootVC];
    }];
    UIAction *action0 = [UIAction actionWithTitle:@"Download HD Video"
                                            image:[UIImage systemImageNamed:@"film"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadHDVideo:rootVC];
    }];
    UIAction *action2 = [UIAction actionWithTitle:@"Download Music"
                                            image:[UIImage systemImageNamed:@"music.note"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self downloadMusic:rootVC];
    }];
    UIAction *action3 = [UIAction actionWithTitle:@"Copy Music link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyMusic:rootVC];
    }];
    UIAction *action4 = [UIAction actionWithTitle:@"Copy Video link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyVideo:rootVC];
    }];
    UIAction *action5 = [UIAction actionWithTitle:@"Copy Decription"
                                            image:[UIImage systemImageNamed:@"note.text"]
                                       identifier:nil
                                          handler:^(__kindof UIAction * _Nonnull action) {
                                            [self copyDecription:rootVC];
    }];
    UIMenu *downloadMenu = [UIMenu menuWithTitle:@"Downloads Menu"
                                        children:@[action1, action0,action2]];
    UIMenu *copyMenu = [UIMenu menuWithTitle:@"Copy Menu"
                                        children:@[action3, action4, action5]];
    UIMenu *mainMenu = [UIMenu menuWithTitle:@"" children:@[downloadMenu, copyMenu]];
    [sender setMenu:mainMenu];
    sender.showsMenuAsPrimaryAction = YES;
    }
}
%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    if (self.elementsHidden) {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
    } else {
        [hideElementButton setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateNormal];
    }

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC.interactionController isKindOfClass:%c(TTKFeedInteractionLegacyMainContainerElement)]) {
        TTKFeedInteractionLegacyMainContainerElement *interactionController = rootVC.interactionController;
        if (self.elementsHidden) {
            self.elementsHidden = false;
            [interactionController hideAllElements:false exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye.slash"] forState:UIControlStateNormal];
        } else {
            self.elementsHidden = true;
            [interactionController hideAllElements:true exceptArray:nil];
            [sender setImage:[UIImage systemImageNamed:@"eye"] forState:UIControlStateNormal];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
        self.hud.tapOutsideBlock = ^(JGProgressHUD * _Nonnull HUD) {
        self.hud.textLabel.text = @"Backgrounding ✌️";
        [self.hud dismissAfterDelay:0.4];
    };
    self.progressView.progress = progress;
    self.hud.detailTextLabel.text = [BMIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    NSArray *audioExtensions = @[@"mp3", @"aac", @"wav", @"m4a", @"ogg", @"flac", @"aiff", @"wma"];
    if ([BMIManager shareSheet] || [audioExtensions containsObject:self.fileextension]) {
        [BMIManager showSaveVC:@[newFilePath]];
    }
    else {
        [BMIManager saveMedia:newFilePath fileExtension:self.fileextension];
    }
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) {
        [self.hud dismiss];
    }
}
%end

%hook TTKStoryDetailTableViewCell
    // TODO...
%end

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSURL *bestURLFormat;
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
        bestURLFormat = @"m4a";
    }

    return bestURLFormat;
}
%new - (NSURL *)bestURLtoDownload {
    NSURL *bestURL;
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

%hook PIPOIAPStoreManager
-(bool)_pipo_isJailBrokenDeviceWithProductID:(id)arg2 orderID:(id)arg3 {
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

%hook GULAppEnvironmentUtil
+(bool)isFromAppStore {
	return YES;
}
+(bool)isAppStoreReceiptSandbox {
	return NO;
}
+(bool)isAppExtension {
	return YES;
}
%end

%hook FBSDKAppEventsUtility
+(bool)isDebugBuild {
	return NO;
}
%end

%hook AWEAPMManager
+(id)signInfo {
	return @"AppStore";
}
%end

%hook NSBundle
-(id)pathForResource:(id)arg1 ofType:(id)arg2 {
	if ([arg2 isEqualToString:@"mobileprovision"]) {
		return nil;
	}
	return %orig;
}
%end
%hook AWESecurity
- (void)resetCollectMode {
	return;
}
%end
%hook MSManagerOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end
%hook MSConfigOV
- (id)setMode {
	return (id (^)(id)) ^{
	};
}
%end




// MARK: - [BMTikTok] Extended RX Features by Tuancute28

// 1. Enhanced Adblock & Feed Cleanup
%hook AWEAwemeModel
- (BOOL)isCommerce {
    if ([BMIManager hideCommissionPosts]) {
        return NO;
    }
    return %orig;
}
- (BOOL)isCommerceAd {
    if ([BMIManager hideCommissionPosts] || [BMIManager hideAds]) {
        return NO;
    }
    return %orig;
}
- (BOOL)isAds {
    if ([BMIManager hideAds]) {
        return NO;
    }
    return %orig;
}
- (BOOL)isAd {
    if ([BMIManager hideAds]) {
        return NO;
    }
    return %orig;
}
%end

// 2. Pendant Ads & TikTok AI Button Removal
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

// 3. Play/Pause Overlay & Feed Top Items
%hook AWEPlayVideoPauseView
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager hidePlayPause]) {
        [self setHidden:YES];
    }
}
%end

// 4. Ghost Mode: Anonymous Seen, Anti-Typing, Anti-Screenshot, Anonymous Profile View
%hook TIMMessageService
- (void)markMessageAsRead:(id)arg1 conversationId:(id)arg2 {
    if ([BMIManager anonymousSeen]) {
        return;
    }
    %orig(arg1, arg2);
}
%end

%hook AWEIMMessage
- (void)markAsRead {
    if ([BMIManager anonymousSeen]) {
        return;
    }
    %orig;
}
%end

%hook AWEIMTypingStatusSender
- (void)sendTypingStatus:(id)arg1 {
    if ([BMIManager disableTyping]) {
        return;
    }
    %orig(arg1);
}
%end

%hook AWEProfileVisitorRecordService
- (void)reportVisitWithSecUid:(id)arg1 {
    if ([BMIManager viewProfilesAnonymous]) {
        return;
    }
    %orig(arg1);
}
%end

%hook AWEProfileTracker
- (void)trackProfileVisitWithSecUid:(id)arg1 {
    if ([BMIManager viewProfilesAnonymous]) {
        return;
    }
    %orig(arg1);
}
%end

// 5. Anti Screenshot & Screenrecording Detection in Chats
%hook INSPrivacyManager
- (void)userDidTakeScreenshot:(id)arg1 {
    if ([BMIManager disableScreenshotDetection]) {
        return;
    }
    %orig(arg1);
}
- (void)userDidScreenRecord:(id)arg1 {
    if ([BMIManager disableScreenrecordingDetection]) {
        return;
    }
    %orig(arg1);
}
%end

// 6. Comment Enhancements: Auto Unfold, Transparent Background, Hide Emoji Bar
%hook AWECommentPanelView
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager transparentCommnet]) {
        [self setBackgroundColor:[UIColor clearColor]];
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

// 7. UI & OLED Keyboard Theme
%hook UIKeyboard
- (void)didMoveToSuperview {
    %orig;
    if ([BMIManager oledKeyboard]) {
        [self setKeyboardAppearance:UIKeyboardAppearanceDark];
    }
}
%end

// 8. Tab Bar Customization
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

// 9. Russian Feed Fix
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
    }
    return params;
}
%end


%ctor {
    jailbreakPaths = @[
        @"/Applications/Cydia.app", @"/Applications/blackra1n.app",
        @"/Applications/FakeCarrier.app", @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app", @"/Applications/MxTube.app",
        @"/Applications/RockApp.app", @"/Applications/SBSettings.app", @"/Applications/WinterBoard.app",
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
    %init;
}
