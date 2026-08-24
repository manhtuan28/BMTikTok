//
//  BMPrivacySettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMPrivacySettingsViewController.h"

@implementation BMPrivacySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Quyền Riêng Tư & Ẩn Danh";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"CHẾ ĐỘ ẨN DANH (GHOST MODE)";
        case 1: return @"BẢO MẬT ỨNG DỤNG";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 7;
        case 1: return 1;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Xem tin & story ẩn danh" Detail:@"Không gửi thông báo đã xem cho người đăng khi bạn xem Story" Key:@"anonymous_seen"];
            case 1: return [self createSwitchCellWithTitle:@"Đánh dấu đã xem khi trả lời" Detail:@"Chỉ hiển thị trạng thái Đã xem trong DM khi bạn gửi tin nhắn trả lời" Key:@"mark_seen_on_reply"];
            case 2: return [self createSwitchCellWithTitle:@"Ẩn trạng thái đang nhập tin nhắn" Detail:@"Không hiển thị biểu tượng 'đang soạn tin...' cho người bên kia" Key:@"disable_typing"];
            case 3: return [self createSwitchCellWithTitle:@"Xem hồ sơ người khác ẩn danh" Detail:@"Không lưu lại lịch sử ghé thăm trang cá nhân của người khác" Key:@"view_profiles_anonymous"];
            case 4: return [self createSwitchCellWithTitle:@"Chống phát hiện chụp màn hình" Detail:@"Chặn TikTok thông báo cho đối phương khi bạn chụp ảnh màn hình" Key:@"disable_screenshot_detection"];
            case 5: return [self createSwitchCellWithTitle:@"Chống phát hiện quay màn hình" Detail:@"Chặn TikTok thông báo cho đối phương khi bạn quay video màn hình" Key:@"disable_screenrecording_detection"];
            case 6: return [self createSwitchCellWithTitle:@"Ẩn trạng thái hoạt động online" Detail:@"Luôn ẩn chấm xanh trạng thái trực tuyến của bạn trên TikTok" Key:@"hide_activity_status"];
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Khóa ứng dụng (Face ID / Passcode)" Detail:@"Yêu cầu xác thực Face ID / Touch ID mỗi khi mở lại TikTok" Key:@"padlock"];
        }
    }
    return [[UITableViewCell alloc] init];
}

@end
