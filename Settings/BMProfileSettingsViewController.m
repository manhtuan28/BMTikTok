//
//  BMProfileSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMProfileSettingsViewController.h"

@implementation BMProfileSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Hồ Sơ & Số Liệu Ảo";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"SỐ LIỆU ẢO (TỰ SƯỚNG / SỐNG ẢO)";
        case 1: return @"TIỆN ÍCH HỒ SƠ & TẢI AVATAR";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 4;
        case 1: return 4;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Tích xanh xác minh ảo" Detail:@"Hiển thị huy hiệu tích xanh chính chủ bên cạnh tên tài khoản của bạn" Key:@"fake_verified"];
            case 1: {
                static NSString *cellId = @"FakeFollowerCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                cell.textLabel.text = @"Số người theo dõi ảo";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                NSString *count = [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_follower_count"];
                cell.detailTextLabel.text = count.length ? [NSString stringWithFormat:@"Đang đặt: %@ người theo dõi", count] : @"Bấm để chỉnh số Follower ảo";
                cell.detailTextLabel.textColor = [UIColor systemPinkColor];
                return cell;
            }
            case 2: {
                static NSString *cellId = @"FakeFollowingCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                cell.textLabel.text = @"Số đang theo dõi ảo";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                NSString *count = [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_following_count"];
                cell.detailTextLabel.text = count.length ? [NSString stringWithFormat:@"Đang đặt: %@ người", count] : @"Bấm để chỉnh số Đang theo dõi ảo";
                cell.detailTextLabel.textColor = [UIColor systemPinkColor];
                return cell;
            }
            case 3: {
                static NSString *cellId = @"FakeLikesCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                cell.textLabel.text = @"Tổng số lượt Thích ảo";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                NSString *count = [[NSUserDefaults standardUserDefaults] stringForKey:@"fake_likes_count"];
                cell.detailTextLabel.text = count.length ? [NSString stringWithFormat:@"Đang đặt: %@ lượt thích", count] : @"Bấm để chỉnh tổng số Thích ảo";
                cell.detailTextLabel.textColor = [UIColor systemPinkColor];
                return cell;
            }
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Sao chép tiểu sử hồ sơ" Detail:@"Chạm giữ vào phần giới thiệu tiểu sử (Bio) để sao chép" Key:@"copy_profile_bio"];
            case 1: return [self createSwitchCellWithTitle:@"Sao chép ID & Tên người dùng" Detail:@"Chạm giữ vào @username hoặc ID người dùng để sao chép" Key:@"copy_profile_id"];
            case 2: return [self createSwitchCellWithTitle:@"Tải ảnh đại diện HD khi giữ lâu" Detail:@"Chạm giữ vào avatar của bất kỳ ai để xem ảnh phóng to và tải về" Key:@"download_profile_avatar"];
            case 3: return [self createSwitchCellWithTitle:@"Ẩn tab bài viết đã thích" Detail:@"Ẩn tab chứa các video bạn đã thả tim trên trang cá nhân" Key:@"hide_liked_tab"];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self promptInputForTitle:@"Số người theo dõi ảo (Follower)" Key:@"fake_follower_count" EnableKey:@"enable_fake_follower"];
        } else if (indexPath.row == 2) {
            [self promptInputForTitle:@"Số đang theo dõi ảo (Following)" Key:@"fake_following_count" EnableKey:@"enable_fake_following"];
        } else if (indexPath.row == 3) {
            [self promptInputForTitle:@"Tổng lượt thích ảo (Likes)" Key:@"fake_likes_count" EnableKey:@"enable_fake_likes"];
        }
    }
}

- (void)promptInputForTitle:(NSString *)title Key:(NSString *)key EnableKey:(NSString *)enableKey {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:@"Nhập số lượng bạn muốn hiển thị (Ví dụ: 1.5M, 800K, 999999)"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Ví dụ: 1.2M";
        textField.text = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    }];
    
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Lưu" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *text = alert.textFields.firstObject.text;
        if (text.length) {
            [[NSUserDefaults standardUserDefaults] setObject:text forKey:key];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:enableKey];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:enableKey];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:saveAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
