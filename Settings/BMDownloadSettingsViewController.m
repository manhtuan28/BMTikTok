//
//  BMDownloadSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMDownloadSettingsViewController.h"

@implementation BMDownloadSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tải Xuống & Đa Phương Tiện";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"TẢI VIDEO & MEDIA";
        case 1: return @"TÙY CHỌN BỔ SUNG";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 5;
        case 1: return 3;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Nút tải xuống trực tiếp" Detail:@"Thêm nút tải xuống tiện lợi ngay trên thanh công cụ xem video" Key:@"download_button"];
            case 1: return [self createSwitchCellWithTitle:@"Tải video không logo / watermark" Detail:@"Tự động lấy link gốc và lưu video chất lượng cao không có watermark" Key:@"remove_watermark"];
            case 2: return [self createSwitchCellWithTitle:@"Tải ảnh slide không logo" Detail:@"Xóa watermark khi lưu các bộ ảnh / bài đăng slide nhiều ảnh" Key:@"remove_photo_watermark"];
            case 3: return [self createSwitchCellWithTitle:@"Tải âm thanh & nhạc nền MP3" Detail:@"Cho phép lưu file âm thanh/nhạc nền bài hát trực tiếp về thiết bị" Key:@"download_music"];
            case 4: return [self createSwitchCellWithTitle:@"Mở bảng chia sẻ hệ thống iOS" Detail:@"Mở Share Sheet mặc định của iOS khi bấm nút tải xuống" Key:@"share_sheet"];
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Lưu media trong tin nhắn (DM)" Detail:@"Cho phép lưu ảnh và video được gửi trong cuộc trò chuyện riêng tư" Key:@"save_dm_media"];
            case 1: return [self createSwitchCellWithTitle:@"Tải nhãn dán khi chạm 2 lần" Detail:@"Chạm đúp vào nhãn dán (sticker) để lưu về máy" Key:@"double_tap_download_sticker"];
            case 2: return [self createSwitchCellWithTitle:@"Luôn tải chất lượng cao nhất (HD)" Detail:@"Tự động chọn phiên bản có bitrate và độ phân giải cao nhất" Key:@"highest_video_quality"];
        }
    }
    return [[UITableViewCell alloc] init];
}

@end
