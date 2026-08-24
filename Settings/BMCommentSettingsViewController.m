//
//  BMCommentSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMCommentSettingsViewController.h"

@implementation BMCommentSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bình Luận & Tương Tác";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"GIAO DIỆN BÌNH LUẬN";
        case 1: return @"TÍNH NĂNG & TIỆN ÍCH";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        case 1: return 4;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Giao diện bình luận trong suốt" Detail:@"Làm mờ nền khung bình luận để vừa đọc vừa xem video phía sau" Key:@"transparent_commnet"];
            case 1: return [self createSwitchCellWithTitle:@"Ẩn thanh emoji gợi ý" Detail:@"Thu gọn thanh biểu tượng cảm xúc để khung bình luận rộng rãi hơn" Key:@"hide_emoji_bar"];
            case 2: return [self createSwitchCellWithTitle:@"Đổi màu tên người bình luận" Detail:@"Tô màu nổi bật cho username của những người để lại bình luận" Key:@"colorize_comment_usernames"];
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Cho phép sao chép bình luận" Detail:@"Chạm giữ vào bất kỳ bình luận nào để sao chép văn bản" Key:@"copy_comment_text"];
            case 1: return [self createSwitchCellWithTitle:@"Hiển thị cờ quốc gia người bình luận" Detail:@"Gắn cờ quốc gia của tác giả bên cạnh tên người bình luận" Key:@"enable_comment_flags"];
            case 2: return [self createSwitchCellWithTitle:@"Tự động dịch bình luận" Detail:@"Tự động chuyển ngữ các bình luận tiếng nước ngoài sang Tiếng Việt" Key:@"auto_translate_comments"];
            case 3: return [self createSwitchCellWithTitle:@"Không chuyển hướng sang Safari" Detail:@"Mở các liên kết trong bình luận trực tiếp bằng trình duyệt trong app" Key:@"disable_safari_redirect"];
        }
    }
    return [[UITableViewCell alloc] init];
}

@end
