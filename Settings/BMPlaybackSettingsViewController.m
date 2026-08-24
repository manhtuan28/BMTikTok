//
//  BMPlaybackSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMPlaybackSettingsViewController.h"
#import "PlaybackSpeed.h"

@implementation BMPlaybackSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Điều Khiển Phát Lại Video";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"TỰ ĐỘNG PHÁT & TIẾP DIỄN";
        case 1: return @"TỐC ĐỘ PHÁT & CHẤT LƯỢNG";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 4;
        case 1: return 3;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Tự động chuyển video tiếp theo" Detail:@"Tự động lướt sang video mới sau khi video hiện tại phát xong" Key:@"auto_play_next_video"];
            case 1: return [self createSwitchCellWithTitle:@"Tắt lặp lại video (Không Loop)" Detail:@"Dừng phát khi hết video thay vì phát đi phát lại liên tục" Key:@"stop_looping_video"];
            case 2: return [self createSwitchCellWithTitle:@"Bật thanh tua video nhanh" Detail:@"Luôn hiển thị thanh kéo tua thời lượng video ở dưới cùng màn hình" Key:@"progress_bar"];
            case 3: return [self createSwitchCellWithTitle:@"Luôn bật âm thanh khi mở app" Detail:@"Tự động bật tiếng video ngay khi khởi động TikTok" Key:@"keep_audio_unmuted"];
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Bật lưu tốc độ phát video" Detail:@"Giữ nguyên tốc độ phát bạn đã chọn cho tất cả các video kế tiếp" Key:@"playback_en"];
            case 1: {
                static NSString *cellId = @"SpeedPickerNavCell";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                cell.textLabel.text = @"Tốc độ phát mặc định";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                
                NSNumber *speed = [[NSUserDefaults standardUserDefaults] objectForKey:@"playback_speed"];
                cell.detailTextLabel.text = speed ? [NSString stringWithFormat:@"%@x", speed] : @"1.0x (Chuẩn)";
                cell.detailTextLabel.textColor = [UIColor systemPinkColor];
                return cell;
            }
            case 2: return [self createSwitchCellWithTitle:@"Ép chất lượng video cao nhất" Detail:@"Luôn tải luồng video có độ nét và bitrate cao nhất (1080p/60fps)" Key:@"force_highest_bitrate"];
        }
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1 && indexPath.row == 1) {
        PlaybackSpeed *speedVC = [[PlaybackSpeed alloc] init];
        [self.navigationController pushViewController:speedVC animated:YES];
    }
}

@end
