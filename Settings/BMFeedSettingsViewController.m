//
//  BMFeedSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMFeedSettingsViewController.h"

@implementation BMFeedSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bảng Tin & Quảng Cáo";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"CHẶN QUẢNG CÁO & SHOP";
        case 1: return @"BỘ LỌC NỘI DUNG & AI";
        case 2: return @"ĐIỀU HƯỚNG & CỬ CHỈ BẢNG TIN";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 3;
        case 1: return 6;
        case 2: return 8;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Ẩn toàn bộ quảng cáo" Detail:@"Loại bỏ tất cả các video quảng cáo tài trợ trên bảng tin" Key:@"hide_ads"];
            case 1: return [self createSwitchCellWithTitle:@"Ẩn bài đăng hoa hồng / giỏ hàng" Detail:@"Lọc bỏ các video gắn link tiếp thị liên kết và giỏ hàng TikTok Shop" Key:@"hide_commission_posts"];
            case 2: return [self createSwitchCellWithTitle:@"Ẩn quảng cáo nổi góc màn hình" Detail:@"Xóa các banner và biểu tượng quảng cáo ở góc trên bên trái" Key:@"remove_pendant"];
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Chặn video do AI tạo" Detail:@"Tự động lọc và bỏ qua các video được gắn nhãn tạo bởi AI (AIGC)" Key:@"block_ai_generated"];
            case 1: return [self createSwitchCellWithTitle:@"Ẩn nút trợ lý AI Tako" Detail:@"Ẩn nút trợ lý TikTok AI (Tako) trên giao diện xem video" Key:@"remove_tiktok_ai_button"];
            case 2: return [self createSwitchCellWithTitle:@"Chặn video MovieTok" Detail:@"Lọc bỏ các video cắt ghép review phim tự động" Key:@"block_movie_tok"];
            case 3: return [self createSwitchCellWithTitle:@"Chặn video gắn địa điểm (POI)" Detail:@"Lọc bỏ các bài đăng gắn thẻ vị trí hoặc quán ăn" Key:@"block_poi"];
            case 4: return [self createSwitchCellWithTitle:@"Tắt cảnh báo nội dung nhạy cảm" Detail:@"Bỏ qua màn hình che cảnh báo nội dung không phù hợp" Key:@"disable_unsensitive"];
            case 5: return [self createSwitchCellWithTitle:@"Tắt các cảnh báo của TikTok" Detail:@"Ẩn các cảnh báo hệ thống và thông báo nhắc nhở phiền phức" Key:@"disable_warnings"];
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Nút ẩn toàn bộ giao diện (Pure Mode)" Detail:@"Thêm nút hình con mắt ở góc trên để ẩn/hiện toàn bộ nút bấm, caption và chỉ xem video tinh khiết" Key:@"remove_elements_button"];
            case 1: return [self createSwitchCellWithTitle:@"Ẩn phát trực tiếp trên bảng tin" Detail:@"Không hiển thị các phòng LIVE khi đang lướt Feed" Key:@"disable_live"];
            case 2: return [self createSwitchCellWithTitle:@"Ẩn biểu tượng Phát/Tạm dừng" Detail:@"Ẩn icon hiệu ứng phát và tạm dừng che giữa màn hình" Key:@"hide_play_pause"];
            case 3: return [self createSwitchCellWithTitle:@"Ẩn thanh điều hướng trên cùng" Detail:@"Ẩn các tab Dành cho bạn, Đang theo dõi, Cửa hàng ở đầu bảng tin" Key:@"hide_top_items"];
            case 4: return [self createSwitchCellWithTitle:@"Mở app vào Đang theo dõi" Detail:@"Tự động chuyển sang tab Đang theo dõi khi vừa mở ứng dụng" Key:@"start_fyp_in_following"];
            case 5: return [self createSwitchCellWithTitle:@"Khóa thao tác vuốt ngang" Detail:@"Chặn vuốt trái/phải để tránh nhảy nhầm sang camera hoặc trang cá nhân" Key:@"disable_swipe_in_fyp"];
            case 6: return [self createSwitchCellWithTitle:@"Tắt kéo để làm mới" Detail:@"Vô hiệu hóa cử chỉ kéo xuống đầu trang để làm mới bảng tin" Key:@"pull_to_refresh"];
            case 7: return [self createSwitchCellWithTitle:@"Tự động cuộn bảng tin" Detail:@"Tự động lướt sang video kế tiếp sau khi phát xong" Key:@"auto_scroll_feed"];
        }
    }
    return [[UITableViewCell alloc] init];
}

@end
