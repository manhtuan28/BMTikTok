//
//  BMConfirmSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMConfirmSettingsViewController.h"

@implementation BMConfirmSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Xác Nhận Thao Tác (Chống Bấm Nhầm)";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"CHỐNG CHẠM NHẦM THAO TÁC";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: return [self createSwitchCellWithTitle:@"Xác nhận khi Thích video" Detail:@"Hiện hộp thoại xác nhận trước khi thả tim bài viết" Key:@"like_confirmation"];
        case 1: return [self createSwitchCellWithTitle:@"Xác nhận khi Theo dõi" Detail:@"Hiện hộp thoại xác nhận trước khi bấm Follow người khác" Key:@"follow_confirmation"];
        case 2: return [self createSwitchCellWithTitle:@"Xác nhận khi Thích bình luận" Detail:@"Hỏi trước khi bấm thích một bình luận bất kỳ" Key:@"comment_like_confirmation"];
        case 3: return [self createSwitchCellWithTitle:@"Xác nhận khi Không thích bình luận" Detail:@"Hỏi trước khi bấm nút Dislike bình luận" Key:@"comment_dislike_confirmation"];
        case 4: return [self createSwitchCellWithTitle:@"Xác nhận khi Đăng / Xuất bản bài" Detail:@"Hiện cảnh báo trước khi tải video của bạn lên TikTok" Key:@"publish_confirmation"];
        case 5: return [self createSwitchCellWithTitle:@"Xác nhận khi Tải xuống video" Detail:@"Hỏi lại trước khi bắt đầu tải file về album ảnh" Key:@"download_confirmation"];
        case 6: return [self createSwitchCellWithTitle:@"Xác nhận khi Lưu vào Bộ sưu tập" Detail:@"Hỏi lại trước khi đánh dấu Bookmark bài viết" Key:@"bookmark_confirmation"];
        default: return [[UITableViewCell alloc] init];
    }
}

@end
