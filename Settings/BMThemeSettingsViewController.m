//
//  BMThemeSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMThemeSettingsViewController.h"

@implementation BMThemeSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Giao Diện & Tùy Biến";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"TÙY BIẾN GIAO DIỆN";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: return [self createSwitchCellWithTitle:@"Bàn phím màu tối OLED" Detail:@"Chuyển bàn phím sang tông đen tuyền tiết kiệm pin trên màn OLED" Key:@"oled_keyboard"];
        case 1: return [self createSwitchCellWithTitle:@"Ẩn nhãn chữ thanh Tab Bar" Detail:@"Chỉ hiển thị biểu tượng icon ở thanh điều hướng dưới đáy màn hình" Key:@"hide_tab_bar_labels"];
        case 2: return [self createSwitchCellWithTitle:@"Ẩn số thông báo đỏ (Badges)" Detail:@"Xóa các chấm đỏ thông báo chưa đọc trên các tab" Key:@"hide_badge_counter"];
        case 3: return [self createSwitchCellWithTitle:@"Trong suốt thanh trạng thái" Detail:@"Làm mờ phần tai thỏ / Dynamic Island để xem video trọn vẹn" Key:@"transparent_status_bar"];
        case 4: return [self createSwitchCellWithTitle:@"Hiển thị ngày phát hành bài viết" Detail:@"Hiện ngày giờ cụ thể đăng video thay vì hiện '2 ngày trước'" Key:@"show_exact_date"];
        default: return [[UITableViewCell alloc] init];
    }
}

@end
