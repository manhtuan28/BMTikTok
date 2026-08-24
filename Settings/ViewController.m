//
//  ViewController.m
//  BMTikTok Settings
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "ViewController.h"
#import "BMBaseSettingsViewController.h"
#import "BMFeedSettingsViewController.h"
#import "BMDownloadSettingsViewController.h"
#import "BMPrivacySettingsViewController.h"
#import "BMCommentSettingsViewController.h"
#import "BMPlaybackSettingsViewController.h"
#import "CountryTable.h"
#import "BMProfileSettingsViewController.h"
#import "BMConfirmSettingsViewController.h"
#import "BMThemeSettingsViewController.h"
#import "BMAboutViewController.h"
#import "BMIManager.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImage *devAvatar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Cài Đặt BMTikTok";
    
    // Nút Xong đóng modal
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Xong"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(dismissVC)];
    doneButton.tintColor = [UIColor systemPinkColor];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Tải ảnh đại diện tác giả Tuancute28
    NSString *bundleAvatar = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg" inDirectory:@"BMTikTok.bundle"];
    if (bundleAvatar && [[NSFileManager defaultManager] fileExistsAtPath:bundleAvatar]) {
        self.devAvatar = [UIImage imageWithContentsOfFile:bundleAvatar];
    } else {
        NSString *rootAvatar = [[NSBundle mainBundle] pathForResource:@"avatar" ofType:@"jpg"];
        if (rootAvatar && [[NSFileManager defaultManager] fileExistsAtPath:rootAvatar]) {
            self.devAvatar = [UIImage imageWithContentsOfFile:rootAvatar];
        } else {
            self.devAvatar = [UIImage systemImageNamed:@"person.crop.circle.fill"];
        }
    }
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    // Tạo Header View đẹp mắt
    [self setupHeaderView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionSelected:)
                                                 name:@"RegionSelectedNotification"
                                               object:nil];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)regionSelected:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)setupHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 160)];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // Khung Card Avatar & Thông tin
    UIView *cardView = [[UIView alloc] initWithFrame:CGRectMake(16, 10, self.view.bounds.size.width - 32, 140)];
    cardView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    cardView.backgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    cardView.layer.cornerRadius = 16;
    cardView.layer.shadowColor = [UIColor blackColor].CGColor;
    cardView.layer.shadowOpacity = 0.06;
    cardView.layer.shadowOffset = CGSizeMake(0, 4);
    cardView.layer.shadowRadius = 8;
    [headerView addSubview:cardView];
    
    // Avatar
    UIImageView *avatarIV = [[UIImageView alloc] initWithFrame:CGRectMake(16, 18, 64, 64)];
    avatarIV.image = self.devAvatar;
    avatarIV.contentMode = UIViewContentModeScaleAspectFill;
    avatarIV.layer.cornerRadius = 32;
    avatarIV.layer.masksToBounds = YES;
    avatarIV.layer.borderWidth = 2.5;
    avatarIV.layer.borderColor = [UIColor systemPinkColor].CGColor;
    [cardView addSubview:avatarIV];
    
    // Tên & Badge
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 18, cardView.bounds.size.width - 100, 24)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    titleLabel.text = @"BMTikTok VIP Mod 🇻🇳";
    titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    [cardView addSubview:titleLabel];
    
    UILabel *authorLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 42, cardView.bounds.size.width - 100, 18)];
    authorLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    authorLabel.text = @"Phát triển bởi: Tuancute28 (Bùi Mạnh Tuấn)";
    authorLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
    authorLabel.textColor = [UIColor systemPinkColor];
    [cardView addSubview:authorLabel];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(92, 60, cardView.bounds.size.width - 100, 16)];
    descLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    descLabel.text = @"TikTok v46.5.0 • Đầy đủ tính năng cao cấp";
    descLabel.font = [UIFont systemFontOfSize:11];
    descLabel.textColor = [UIColor secondaryLabelColor];
    [cardView addSubview:descLabel];
    
    // Social Buttons Row
    NSArray *socials = @[
        @{@"icon": @"chevron.left.forwardslash.chevron.right", @"url": @"https://github.com/manhtuan28/BMTikTok", @"name": @"GitHub"},
        @{@"icon": @"person.2.fill", @"url": @"https://www.facebook.com/b.manhtuan.028", @"name": @"Facebook"},
        @{@"icon": @"play.tv.fill", @"url": @"https://www.tiktok.com/@capyboiii_28", @"name": @"TikTok"},
        @{@"icon": @"bubble.left.and.bubble.right.fill", @"url": @"https://x.com/buituan282", @"name": @"X (Twitter)"}
    ];
    
    CGFloat btnW = (cardView.bounds.size.width - 32) / 4.0;
    for (int i = 0; i < socials.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.frame = CGRectMake(16 + i * btnW, 94, btnW - 8, 32);
        btn.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        btn.backgroundColor = [UIColor tertiarySystemGroupedBackgroundColor];
        btn.layer.cornerRadius = 8;
        btn.tintColor = [UIColor labelColor];
        
        UIImage *img = [UIImage systemImageNamed:socials[i][@"icon"] withConfiguration:[UIImageSymbolConfiguration configurationWithPointSize:12 weight:UIImageSymbolWeightSemibold]];
        [btn setImage:img forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@" %@", socials[i][@"name"]] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
        btn.accessibilityIdentifier = socials[i][@"url"];
        [btn addTarget:self action:@selector(openSocialLink:) forControlEvents:UIControlEventTouchUpInside];
        [cardView addSubview:btn];
    }
    
    self.tableView.tableHeaderView = headerView;
}

- (void)openSocialLink:(UIButton *)sender {
    NSString *urlString = sender.accessibilityIdentifier;
    if (urlString) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"DANH MỤC CÀI ĐẶT TÍNH NĂNG";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"RootCategoryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *title = @"";
    NSString *detail = @"";
    NSString *iconName = @"";
    UIColor *iconColor = [UIColor systemPinkColor];
    
    switch (indexPath.row) {
        case 0:
            title = @"Bảng Tin & Quảng Cáo";
            detail = @"Chặn quảng cáo, giỏ hàng, video AI, tùy biến cử chỉ Feed";
            iconName = @"play.rectangle.fill";
            iconColor = [UIColor colorWithRed:254/255.0 green:44/255.0 blue:85/255.0 alpha:1.0]; // TikTok Pink
            break;
        case 1:
            title = @"Tải Xuống & Đa Phương Tiện";
            detail = @"Tải video/ảnh không logo, tải nhạc MP3, media tin nhắn";
            iconName = @"arrow.down.circle.fill";
            iconColor = [UIColor colorWithRed:37/255.0 green:244/255.0 blue:238/255.0 alpha:1.0]; // TikTok Cyan
            break;
        case 2:
            title = @"Quyền Riêng Tư & Ẩn Danh";
            detail = @"Xem ẩn danh, ẩn đã xem, ẩn đang nhập, khóa app Face ID";
            iconName = @"eye.slash.fill";
            iconColor = [UIColor systemPurpleColor];
            break;
        case 3:
            title = @"Bình Luận & Tương Tác";
            detail = @"Bình luận trong suốt, sao chép text, gắn cờ quốc gia, dịch";
            iconName = @"bubble.left.and.bubble.right.fill";
            iconColor = [UIColor systemOrangeColor];
            break;
        case 4:
            title = @"Điều Khiển Phát Lại Video";
            detail = @"Tự động chuyển video, thanh tua nhanh, tốc độ phát mặc định";
            iconName = @"speedometer";
            iconColor = [UIColor systemBlueColor];
            break;
        case 5: {
            title = @"Khu Vực & Đổi Vùng Quốc Gia";
            NSDictionary *currentRegion = [BMIManager selectedRegion];
            NSString *area = currentRegion ? currentRegion[@"name"] : @"Chưa chọn";
            BOOL isEn = [BMIManager regionChangingEnabled];
            detail = [NSString stringWithFormat:@"Đổi vị trí Feed quốc tế (Hiện tại: %@ • %@)", area, isEn ? @"Đang bật" : @"Đang tắt"];
            iconName = @"globe.americas.fill";
            iconColor = [UIColor systemGreenColor];
            break;
        }
        case 6:
            title = @"Hồ Sơ & Số Liệu Ảo";
            detail = @"Tích xanh ảo, chỉnh Follower/Like ảo, tải ảnh đại diện HD";
            iconName = @"person.crop.circle.badge.checkmark";
            iconColor = [UIColor systemIndigoColor];
            break;
        case 7:
            title = @"Xác Nhận Thao Tác (Chống Bấm Nhầm)";
            detail = @"Hộp thoại hỏi lại khi bấm Thích, Follow, Đăng bài, Tải về";
            iconName = @"hand.tap.fill";
            iconColor = [UIColor systemRedColor];
            break;
        case 8:
            title = @"Giao Diện & Tùy Biến";
            detail = @"Bàn phím OLED, ẩn nhãn Tab Bar, ẩn số thông báo đỏ";
            iconName = @"paintbrush.fill";
            iconColor = [UIColor systemTealColor];
            break;
        case 9:
            title = @"Thông Tin Tác Giả & Hỗ Trợ";
            detail = @"Tuancute28, liên hệ hỗ trợ, sửa lỗi SMS, khôi phục cài đặt";
            iconName = @"info.circle.fill";
            iconColor = [UIColor systemGrayColor];
            break;
    }
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.5];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    // Bo góc biểu tượng phong cách iOS Settings
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:16 weight:UIImageSymbolWeightMedium];
    UIImage *symbolImage = [UIImage systemImageNamed:iconName withConfiguration:config];
    
    CGSize iconSize = CGSizeMake(34, 34);
    UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 34, 34) cornerRadius:8];
    [iconColor setFill];
    [path fill];
    
    if (symbolImage) {
        UIImage *tintedSymbol = [symbolImage imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
        CGFloat symW = tintedSymbol.size.width;
        CGFloat symH = tintedSymbol.size.height;
        [tintedSymbol drawInRect:CGRectMake((34 - symW) / 2.0, (34 - symH) / 2.0, symW, symH)];
    }
    
    UIImage *finalIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    cell.imageView.image = finalIcon;
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *targetVC = nil;
    switch (indexPath.row) {
        case 0: targetVC = [[BMFeedSettingsViewController alloc] init]; break;
        case 1: targetVC = [[BMDownloadSettingsViewController alloc] init]; break;
        case 2: targetVC = [[BMPrivacySettingsViewController alloc] init]; break;
        case 3: targetVC = [[BMCommentSettingsViewController alloc] init]; break;
        case 4: targetVC = [[BMPlaybackSettingsViewController alloc] init]; break;
        case 5: targetVC = [[CountryTable alloc] init]; break;
        case 6: targetVC = [[BMProfileSettingsViewController alloc] init]; break;
        case 7: targetVC = [[BMConfirmSettingsViewController alloc] init]; break;
        case 8: targetVC = [[BMThemeSettingsViewController alloc] init]; break;
        case 9: targetVC = [[BMAboutViewController alloc] init]; break;
    }
    
    if (targetVC) {
        [self.navigationController pushViewController:targetVC animated:YES];
    }
}

@end
