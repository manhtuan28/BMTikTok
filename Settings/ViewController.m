//
//  ViewController.m
//  BMTikTok Settings
//
//  Tác giả & Phát triển: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "ViewController.h"
#import "CountryTable.h"
#import "LiveActions.h"
#import "PlaybackSpeed.h"
#import "BMIManager.h"

@interface ViewController ()
@property (nonatomic, strong) UITableView *staticTable;
@property (nonatomic, strong) UIImage *devAvatar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Cài đặt BMTikTok";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Xong" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    // Tải ảnh đại diện tác giả từ bundle hoặc root
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
    
    self.staticTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.staticTable.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.staticTable];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.staticTable.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.staticTable.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.staticTable.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.staticTable.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
    
    self.staticTable.dataSource = self;
    self.staticTable.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(regionSelected:)
                                                 name:@"RegionSelectedNotification"
                                               object:nil];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)regionSelected:(NSNotification *)notification {
    [self.staticTable reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"BẢNG TIN & CHẶN QUẢNG CÁO";
        case 1: return @"TẢI XUỐNG & ĐA PHƯƠNG TIỆN";
        case 2: return @"QUYỀN RIÊNG TƯ & CHẾ ĐỘ ẨN DANH";
        case 3: return @"BÌNH LUẬN & THẢO LUẬN";
        case 4: return @"ĐIỀU KHIỂN PHÁT LẠI VIDEO";
        case 5: return @"KHU VỰC & ĐỔI VÙNG QUỐC GIA";
        case 6: return @"HỒ SƠ & TÙY BIẾN SỐ LIỆU ẢO";
        case 7: return @"XÁC NHẬN THAO TÁC (CHỐNG BẤM NHẦM)";
        case 8: return @"GIAO DIỆN & BÀN PHÍM";
        case 9: return @"TÁC GIẢ & HỆ THỐNG";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 18; // Bảng tin & Quảng cáo
        case 1: return 8;  // Tải xuống
        case 2: return 8;  // Ẩn danh & Quyền riêng tư
        case 3: return 7;  // Bình luận
        case 4: return 8;  // Phát lại video
        case 5: return 6;  // Đổi vùng
        case 6: return 11; // Hồ sơ & Tùy biến
        case 7: return 9;  // Xác nhận
        case 8: return 8;  // Giao diện & Bàn phím
        case 9: return 10; // Tác giả & Hệ thống
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // MARK: - Mục 0: Bảng tin & Chặn quảng cáo
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Ẩn toàn bộ quảng cáo" Detail:@"Loại bỏ tất cả các video quảng cáo tài trợ trên bảng tin" Key:@"hide_ads"];
            case 1: return [self createSwitchCellWithTitle:@"Ẩn bài đăng hoa hồng / giỏ hàng" Detail:@"Lọc bỏ các video gắn link tiếp thị liên kết và giỏ hàng TikTok Shop" Key:@"hide_commission_posts"];
            case 2: return [self createSwitchCellWithTitle:@"Ẩn quảng cáo nổi góc màn hình" Detail:@"Xóa các banner và biểu tượng quảng cáo ở góc trên bên trái" Key:@"remove_pendant"];
            case 3: return [self createSwitchCellWithTitle:@"Ẩn nút trợ lý AI Tako" Detail:@"Ẩn nút trợ lý TikTok AI (Tako) trên giao diện xem video" Key:@"remove_tiktok_ai_button"];
            case 4: return [self createSwitchCellWithTitle:@"Ẩn biểu tượng Phát/Tạm dừng" Detail:@"Ẩn icon hiệu ứng phát và tạm dừng che giữa màn hình" Key:@"hide_play_pause"];
            case 5: return [self createSwitchCellWithTitle:@"Ẩn thanh điều hướng trên cùng" Detail:@"Ẩn các tab Dành cho bạn, Đang theo dõi, Cửa hàng ở đầu bảng tin" Key:@"hide_top_items"];
            case 6: return [self createSwitchCellWithTitle:@"Mở app vào Đang theo dõi" Detail:@"Tự động chuyển sang tab Đang theo dõi khi vừa mở ứng dụng" Key:@"start_fyp_in_following"];
            case 7: return [self createSwitchCellWithTitle:@"Khóa thao tác vuốt ngang" Detail:@"Chặn vuốt trái/phải để tránh nhảy nhầm sang camera hoặc trang cá nhân" Key:@"disable_swipe_in_fyp"];
            case 8: return [self createSwitchCellWithTitle:@"Tắt kéo để làm mới" Detail:@"Vô hiệu hóa cử chỉ kéo xuống đầu trang để làm mới bảng tin" Key:@"pull_to_refresh"];
            case 9: return [self createSwitchCellWithTitle:@"Tắt cảnh báo nội dung nhạy cảm" Detail:@"Bỏ qua màn hình che cảnh báo nội dung không phù hợp" Key:@"disable_unsensitive"];
            case 10: return [self createSwitchCellWithTitle:@"Tắt các cảnh báo của TikTok" Detail:@"Ẩn các cảnh báo hệ thống và thông báo nhắc nhở phiền phức" Key:@"disable_warnings"];
            case 11: return [self createSwitchCellWithTitle:@"Ẩn livestream trên bảng tin" Detail:@"Loại bỏ các luồng phát trực tiếp xuất hiện xen kẽ trên bảng tin" Key:@"disable_live"];
            case 12: return [self createSwitchCellWithTitle:@"Bỏ qua đề xuất bạn bè" Detail:@"Tự động ẩn các khung gợi ý kết bạn và tài khoản liên quan" Key:@"skip_recommnedations"];
            case 13: return [self createSwitchCellWithTitle:@"Tắt khảo sát người dùng" Detail:@"Chặn các bảng câu hỏi khảo sát bật lên trên bảng tin" Key:@"disable_survey"];
            case 14: return [self createSwitchCellWithTitle:@"Ẩn cảnh báo thể thao / nguy hiểm" Detail:@"Ẩn thông báo hành vi nguy hiểm trên video thể thao, võ thuật (UFC...)" Key:@"ufc_warnings"];
            case 15: return [self createSwitchCellWithTitle:@"Chặn video quảng cáo phim" Detail:@"Lọc bỏ các video quảng cáo trailer phim có trả phí" Key:@"block_movie_tok"];
            case 16: return [self createSwitchCellWithTitle:@"Chặn video quảng cáo ứng dụng" Detail:@"Lọc bỏ các video quảng cáo tiếp thị cài đặt ứng dụng" Key:@"block_tcm"];
            case 17: return [self createSwitchCellWithTitle:@"Chặn video do AI tạo" Detail:@"Ẩn các video có gắn nhãn nội dung tạo bởi trí tuệ nhân tạo" Key:@"block_ai_generated"];
        }
    }
    // MARK: - Mục 1: Tải xuống & Đa phương tiện
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Nút tải video không logo (HD/4K)" Detail:@"Thêm nút tải trực tiếp video gốc không có watermark về Album ảnh" Key:@"download_button"];
            case 1: return [self createSwitchCellWithTitle:@"Tải file âm thanh / nhạc nền" Detail:@"Tải tệp nhạc gốc (.m4a) của video về thư viện máy" Key:@"download_music"];
            case 2: return [self createSwitchCellWithTitle:@"Tự động xóa hình mờ video" Detail:@"Gỡ bỏ hoàn toàn logo TikTok và ID người dùng khi tải xuống" Key:@"remove_watermark"];
            case 3: return [self createSwitchCellWithTitle:@"Xóa hình mờ ảnh & bản nháp" Detail:@"Lưu bài đăng dạng ảnh và bản nháp mà không bị dính logo" Key:@"remove_photo_watermark"];
            case 4: return [self createSwitchCellWithTitle:@"Tải phương tiện trong tin nhắn riêng" Detail:@"Thêm nút tải ảnh, video, GIF và sticker được gửi trong tin nhắn" Key:@"save_dm_media"];
            case 5: return [self createSwitchCellWithTitle:@"Tải nhãn dán trong bình luận" Detail:@"Chạm 2 lần vào nhãn dán ở phần bình luận để lưu về máy" Key:@"double_tap_download_sticker"];
            case 6: return [self createSwitchCellWithTitle:@"Mở bảng chia sẻ sau khi tải" Detail:@"Tự động hiển thị bảng chia sẻ iOS (Share Sheet) sau khi tải xong" Key:@"share_sheet"];
            case 7: return [self createSwitchCellWithTitle:@"Luôn tải lên chất lượng HD" Detail:@"Ép TikTok luôn xử lý và đăng tải video ở độ phân giải cao nhất" Key:@"upload_hd"];
        }
    }
    // MARK: - Mục 2: Quyền riêng tư & Ẩn danh
    else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Đọc tin nhắn ẩn danh" Detail:@"Đọc tin nhắn trong hộp thư mà đối phương không thấy trạng thái Đã xem" Key:@"anonymous_seen"];
            case 1: return [self createSwitchCellWithTitle:@"Chỉ hiện Đã xem khi trả lời" Detail:@"Chỉ gửi tín hiệu Đã xem khi bạn chủ động gửi tin nhắn phản hồi" Key:@"mark_seen_on_reply"];
            case 2: return [self createSwitchCellWithTitle:@"Tắt chỉ báo đang soạn tin" Detail:@"Ẩn biểu tượng đang nhập tin nhắn đối với người nhận" Key:@"disable_typing"];
            case 3: return [self createSwitchCellWithTitle:@"Xem hồ sơ người khác ẩn danh" Detail:@"Xem trang cá nhân người khác mà không xuất hiện trong Lượt xem hồ sơ" Key:@"view_profiles_anonymous"];
            case 4: return [self createSwitchCellWithTitle:@"Chống phát hiện chụp màn hình" Detail:@"Chặn TikTok gửi thông báo khi bạn chụp màn hình trong tin nhắn riêng" Key:@"disable_screenshot_detection"];
            case 5: return [self createSwitchCellWithTitle:@"Chống phát hiện quay màn hình" Detail:@"Chặn TikTok phát hiện khi bạn đang ghi video màn hình" Key:@"disable_screenrecording_detection"];
            case 6: return [self createSwitchCellWithTitle:@"Ẩn trạng thái hoạt động online" Detail:@"Tắt chấm xanh trực tuyến và thời gian hoạt động gần nhất của bạn" Key:@"hide_activity_status"];
            case 7: return [self createSwitchCellWithTitle:@"Khóa ứng dụng (FaceID / Mật mã)" Detail:@"Yêu cầu xác thực sinh trắc học hoặc mật mã mỗi khi mở app" Key:@"padlock"];
        }
    }
    // MARK: - Mục 3: Bình luận & Thảo luận
    else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Nền bình luận trong suốt" Detail:@"Hiệu ứng nền khung bình luận trong suốt hiện đại và sang trọng" Key:@"transparent_commnet"];
            case 1: return [self createSwitchCellWithTitle:@"Sao chép không dính tên người dùng" Detail:@"Chỉ sao chép văn bản bình luận thuần túy, không kèm @username" Key:@"copy_without_username"];
            case 2: return [self createSwitchCellWithTitle:@"Tự động mở rộng bình luận dài" Detail:@"Tự động mở bung toàn bộ nội dung mà không cần bấm 'Xem thêm'" Key:@"auto_unfold"];
            case 3: return [self createSwitchCellWithTitle:@"Mở hàng loạt câu trả lời" Detail:@"Tự động mở tất cả các phản hồi của bình luận một chạm" Key:@"mass_unfold"];
            case 4: return [self createSwitchCellWithTitle:@"Tắt tooltip và gợi ý bình luận" Detail:@"Ẩn các bong bóng hướng dẫn và gợi ý thao tác trong bình luận" Key:@"disable_tooltip"];
            case 5: return [self createSwitchCellWithTitle:@"Ẩn thanh biểu tượng cảm xúc" Detail:@"Ẩn thanh emoji nhanh để giao diện nhập bình luận gọn gàng hơn" Key:@"hide_emoji_bar"];
            case 6: return [self createSwitchCellWithTitle:@"Tăng giới hạn ký tự bình luận" Detail:@"Cho phép viết bình luận dài hơn giới hạn mặc định của TikTok" Key:@"extendedComment"];
        }
    }
    // MARK: - Mục 4: Điều khiển phát lại video
    else if (indexPath.section == 4) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Tự động cuộn sang video tiếp theo" Detail:@"Tự động lướt xuống video kế tiếp ngay khi video hiện tại phát xong" Key:@"auto_play"];
            case 1: return [self createSwitchCellWithTitle:@"Dừng phát khi hết video" Detail:@"Không lặp lại mà dừng video ở khung hình cuối cùng khi phát hết" Key:@"stop_play"];
            case 2: return [self createSwitchCellWithTitle:@"Luôn hiện thanh thời lượng" Detail:@"Hiển thị thanh tiến trình video dưới mọi bài đăng để dễ dàng tua" Key:@"show_porgress_bar"];
            case 3: return [self createSwitchCellWithTitle:@"Lặp lại video trong Story" Detail:@"Tự động phát lại video Story thay vì tự chuyển sang bài tiếp theo" Key:@"loop_story_videos"];
            case 4: return [self createSwitchCellWithTitle:@"Ngăn ảnh Story tự chuyển tiếp" Detail:@"Giữ nguyên ảnh Story đang xem, không tự động đếm giây chuyển ảnh" Key:@"stop_story_photo_advance"];
            case 5: return [self createSwitchCellWithTitle:@"Phát âm thanh nền khi ẩn app" Detail:@"Tiếp tục phát âm thanh video khi khóa màn hình hoặc chuyển ứng dụng" Key:@"background_play"];
            case 6: return [self createSwitchCellWithTitle:@"Cố định tốc độ phát video" Detail:@"Giữ nguyên tốc độ phát đã chọn (1.25x, 1.5x, 2.0x...) cho mọi video" Key:@"playback_en"];
            case 7: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = @"Tốc độ phát đã chọn";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                NSNumber *speed = [BMIManager selectedSpeed];
                cell.detailTextLabel.text = speed ? [NSString stringWithFormat:@"%@x", speed] : @"1.0x";
                return cell;
            }
        }
    }
    // MARK: - Mục 5: Khu vực & Đổi vùng quốc gia
    else if (indexPath.section == 5) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Bật thay đổi vùng quốc gia" Detail:@"Xem bảng tin quốc tế (Mỹ, Nhật, Hàn, Anh...) không cần tháo SIM hay VPN" Key:@"en_region"];
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = @"Quốc gia đã chọn";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                NSDictionary *region = [BMIManager selectedRegion];
                cell.detailTextLabel.text = region ? [NSString stringWithFormat:@"%@ (%@)", region[@"name"], region[@"code"]] : @"Mặc định";
                return cell;
            }
            case 2: return [self createSwitchCellWithTitle:@"Giả lập vùng toàn diện" Detail:@"Chế độ đổi vùng nâng cao áp dụng cho cả thuật toán tìm kiếm và đề xuất" Key:@"full_region_mode"];
            case 3: return [self createSwitchCellWithTitle:@"Bỏ chặn bảng tin Nga (Bypass Ban)" Detail:@"Khắc phục lỗi không tải được video và mở khóa bảng tin tiếng Nga" Key:@"russian_fix"];
            case 4: return [self createSwitchCellWithTitle:@"Hiện cờ quốc gia tải lên" Detail:@"Hiển thị biểu tượng lá cờ của nước tải lên ngay cạnh tên tác giả" Key:@"upload_region"];
            case 5: return [self createSwitchCellWithTitle:@"Hiện cờ quốc gia trong bình luận" Detail:@"Hiển thị lá cờ quốc gia bên cạnh tên người bình luận" Key:@"enable_comment_flags"];
        }
    }
    // MARK: - Mục 6: Hồ sơ & Tuỳ biến sống ảo
    else if (indexPath.section == 6) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Tải ảnh đại diện kích thước gốc" Detail:@"Nhấn giữ vào ảnh đại diện của bất kỳ ai để tải ảnh HD về máy" Key:@"save_profile"];
            case 1: return [self createSwitchCellWithTitle:@"Sao chép tiểu sử (Bio)" Detail:@"Nhấn giữ phần giới thiệu bản thân để copy nhanh vào bộ nhớ tạm" Key:@"copy_profile_information"];
            case 2: return [self createSwitchCellWithTitle:@"Hiển thị ngày đăng video" Detail:@"Hiện ngày tháng năm video được đăng tải lên TikTok" Key:@"video_upload_date"];
            case 3: return [self createSwitchCellWithTitle:@"Hiện mốc thời gian đăng chi tiết" Detail:@"Hiển thị chính xác giờ, phút đăng bài trên bảng tin Dành cho bạn" Key:@"show_fyp_timestamps"];
            case 4: return [self createSwitchCellWithTitle:@"Hiển thị số lượng lượt thích" Detail:@"Hiển thị số lượt thả tim cụ thể trên từng video" Key:@"video_like_count"];
            case 5: return [self createSwitchCellWithTitle:@"Hiện tổng số video đã đăng" Detail:@"Hiển thị tổng số lượng video của tài khoản trên trang cá nhân" Key:@"uploaded_videos"];
            case 6: return [self createSwitchCellWithTitle:@"Hiển thị @username trên feed" Detail:@"Luôn hiển thị tên người dùng chính xác trên video bảng tin" Key:@"show_username"];
            case 7: return [self createSwitchCellWithTitle:@"Tăng giới hạn ký tự tiểu sử" Detail:@"Cho phép viết tiểu sử dài hơn khi chỉnh sửa trang cá nhân" Key:@"extended_bio"];
            case 8: return [self createSwitchCellWithTitle:@"Luôn mở link ngoài bằng Safari" Detail:@"Mở trực tiếp link web ra Safari ngoài thay vì trình duyệt in-app" Key:@"openInBrowser"];
            case 9: return [self createSwitchCellWithTitle:@"Tìm kiếm follow không giới hạn" Detail:@"Bỏ qua giới hạn 5.000 người theo dõi khi tìm kiếm danh sách follow" Key:@"bypass_follow_list_search"];
            case 10: return [self createSwitchCellWithTitle:@"Tích xanh xác minh giả lập" Detail:@"Gắn huy hiệu tích xanh chính chủ trên trang cá nhân của bạn" Key:@"fake_verify"];
        }
    }
    // MARK: - Mục 7: Xác nhận thao tác (Chống bấm nhầm)
    else if (indexPath.section == 7) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Xác nhận khi thả tim video" Detail:@"Hỏi xác nhận trước khi thích video để tránh lỡ tay bấm nhầm" Key:@"like_confirm"];
            case 1: return [self createSwitchCellWithTitle:@"Xác nhận khi thích bình luận" Detail:@"Hỏi xác nhận trước khi bấm thích một bình luận" Key:@"like_comment_confirm"];
            case 2: return [self createSwitchCellWithTitle:@"Xác nhận khi không thích bình luận" Detail:@"Hỏi xác nhận trước khi bấm không thích bình luận" Key:@"dislike_comment_confirm"];
            case 3: return [self createSwitchCellWithTitle:@"Xác nhận khi nhấn theo dõi" Detail:@"Hỏi xác nhận trước khi nhấn Theo dõi bất kỳ tài khoản nào" Key:@"follow_confirm"];
            case 4: return [self createSwitchCellWithTitle:@"Xác nhận khi thích Story" Detail:@"Hỏi xác nhận trước khi thả tim bài đăng Story" Key:@"story_like_confirmation"];
            case 5: return [self createSwitchCellWithTitle:@"Xác nhận khi chia sẻ nhanh" Detail:@"Hỏi xác nhận trước khi bấm vào nút chia sẻ nhanh" Key:@"quick_share_confirm"];
            case 6: return [self createSwitchCellWithTitle:@"Xác nhận khi chia sẻ lại (Repost)" Detail:@"Hỏi xác nhận trước khi bấm chia sẻ lại video lên trang cá nhân" Key:@"repost_confirm"];
            case 7: return [self createSwitchCellWithTitle:@"Tắt chạm 2 lần thả tim bảng tin" Detail:@"Vô hiệu hóa chạm đúp vào màn hình để thả tim video" Key:@"disable_feed_double_tap"];
            case 8: return [self createSwitchCellWithTitle:@"Tắt chạm 2 lần thả tim Story" Detail:@"Vô hiệu hóa chạm đúp vào màn hình để thả tim Story" Key:@"disable_story_double_tap"];
        }
    }
    // MARK: - Mục 8: Giao diện & Bàn phím
    else if (indexPath.section == 8) {
        switch (indexPath.row) {
            case 0: return [self createSwitchCellWithTitle:@"Nút nổi ẩn toàn bộ giao diện" Detail:@"Hiện nút tròn trong suốt để bật/tắt toàn bộ icon khi xem video" Key:@"remove_elements_button"];
            case 1: return [self createSwitchCellWithTitle:@"Bàn phím đen tuyền OLED" Detail:@"Giao diện bàn phím đen sâu chuẩn OLED giúp dịu mắt và tiết kiệm pin" Key:@"en_oled"];
            case 2: return [self createSwitchCellWithTitle:@"Ẩn nhãn chữ thanh Tab Bar" Detail:@"Ẩn dòng chữ bên dưới các biểu tượng ở thanh điều hướng đáy màn hình" Key:@"hide_tab_bar_labels"];
            case 3: return [self createSwitchCellWithTitle:@"Ẩn nút dấu cộng (+) tạo video" Detail:@"Ẩn nút quay video ở chính giữa thanh Tab Bar" Key:@"hide_plus_button"];
            case 4: return [self createSwitchCellWithTitle:@"Ẩn chấm đỏ thông báo Bạn bè" Detail:@"Tắt chấm đỏ thông báo trên tab Bạn bè" Key:@"hide_friends_badge"];
            case 5: return [self createSwitchCellWithTitle:@"Ẩn chấm đỏ Hộp thư đến" Detail:@"Tắt chấm đỏ thông báo trên tab Hộp thư đến" Key:@"hide_inbox_badge"];
            case 6: return [self createSwitchCellWithTitle:@"Ẩn thú cưng chuỗi tương tác" Detail:@"Ẩn biểu tượng linh vật thú cưng đếm chuỗi nhắn tin" Key:@"hide_streak_pet"];
            case 7: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
                cell.textLabel.text = @"Tùy biến hành động nút Live";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
        }
    }
    // MARK: - Mục 9: Tác giả & Hệ thống
    else if (indexPath.section == 9) {
        switch (indexPath.row) {
            case 0: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Dọn dẹp bộ nhớ đệm video/ảnh";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = @"Xóa sạch các tệp tạm thời để giải phóng dung lượng bộ nhớ máy";
                cell.imageView.image = [UIImage systemImageNamed:@"trash.fill"];
                return cell;
            }
            case 1: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Xóa sạch toàn bộ dữ liệu TikTok";
                cell.textLabel.textColor = [UIColor systemRedColor];
                cell.detailTextLabel.text = @"Xóa sạch bộ nhớ đệm, phiên làm việc và đặt lại cài đặt gốc";
                cell.imageView.image = [UIImage systemImageNamed:@"exclamationmark.triangle.fill"];
                return cell;
            }
            case 2: return [self createSwitchCellWithTitle:@"Công cụ gỡ lỗi FLEX Debugger" Detail:@"Bật thanh công cụ phân tích cấu trúc ứng dụng cho Developer" Key:@"flex_enebaled"];
            case 3: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Tuancute28 (Bùi Mạnh Tuấn)";
                cell.textLabel.textColor = [UIColor labelColor];
                cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
                cell.detailTextLabel.text = @"Tác giả & Nhà phát triển BMTikTok";
                cell.detailTextLabel.textColor = [UIColor systemGrayColor];
                if (self.devAvatar) {
                    cell.imageView.image = self.devAvatar;
                    cell.imageView.layer.cornerRadius = 16.0;
                    cell.imageView.clipsToBounds = YES;
                } else {
                    cell.imageView.image = [UIImage systemImageNamed:@"person.crop.circle.fill"];
                }
                return cell;
            }
            case 4: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"GitHub: manhtuan28";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = @"https://github.com/manhtuan28/BMTikTok";
                cell.imageView.image = [UIImage systemImageNamed:@"link"];
                return cell;
            }
            case 5: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Facebook: Bùi Mạnh Tuấn";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = @"https://www.facebook.com/b.manhtuan.028";
                cell.imageView.image = [UIImage systemImageNamed:@"person.2.fill"];
                return cell;
            }
            case 6: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Instagram: @bmanhtuan282";
                cell.textLabel.textColor = [UIColor systemPurpleColor];
                cell.detailTextLabel.text = @"https://www.instagram.com/bmanhtuan282/";
                cell.imageView.image = [UIImage systemImageNamed:@"camera.fill"];
                return cell;
            }
            case 7: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"TikTok: @capyboiii_28";
                cell.textLabel.textColor = [UIColor systemPinkColor];
                cell.detailTextLabel.text = @"https://www.tiktok.com/@capyboiii_28";
                cell.imageView.image = [UIImage systemImageNamed:@"music.note"];
                return cell;
            }
            case 8: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"X (Twitter): @buituan282";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.detailTextLabel.text = @"https://x.com/buituan282";
                cell.imageView.image = [UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"];
                return cell;
            }
            case 9: {
                UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
                cell.textLabel.text = @"Email: buimanhtuan2k4@gmail.com";
                cell.textLabel.textColor = [UIColor systemOrangeColor];
                cell.detailTextLabel.text = @"Gửi email đóng góp ý kiến & báo lỗi";
                cell.imageView.image = [UIImage systemImageNamed:@"envelope.fill"];
                return cell;
            }
        }
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Chọn tốc độ phát
    if (indexPath.section == 4 && indexPath.row == 7) {
        PlaybackSpeed *speedVC = [[PlaybackSpeed alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:speedVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    // Chọn vùng quốc gia
    else if (indexPath.section == 5 && indexPath.row == 1) {
        CountryTable *countryTable = [[CountryTable alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:countryTable];
        [self presentViewController:navController animated:YES completion:nil];
    }
    // Tùy biến nút Live
    else if (indexPath.section == 8 && indexPath.row == 7) {
        LiveActions *liveVC = [[LiveActions alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:liveVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
    // Dọn dẹp bộ nhớ đệm
    else if (indexPath.section == 9 && indexPath.row == 0) {
        [BMIManager cleanCache];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BMTikTok" message:@"Đã dọn dẹp bộ nhớ đệm và các tệp tạm thành công!" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Đồng ý" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    // Xóa sạch toàn bộ dữ liệu
    else if (indexPath.section == 9 && indexPath.row == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Cảnh báo hệ thống" message:@"Hành động này sẽ xóa toàn bộ dữ liệu tạm thời, lịch sử bộ nhớ đệm và đặt lại các cài đặt về mặc định. Bạn có chắc chắn muốn tiếp tục không?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Xác nhận xóa" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [BMIManager eraseAllData];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Hủy bỏ" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    // Các liên kết tác giả
    else if (indexPath.section == 9 && (indexPath.row == 3 || indexPath.row == 4)) {
        NSURL *url = [NSURL URLWithString:@"https://github.com/manhtuan28/BMTikTok"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 5) {
        NSURL *url = [NSURL URLWithString:@"https://www.facebook.com/b.manhtuan.028"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 6) {
        NSURL *url = [NSURL URLWithString:@"https://www.instagram.com/bmanhtuan282/"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 7) {
        NSURL *url = [NSURL URLWithString:@"https://www.tiktok.com/@capyboiii_28"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 8) {
        NSURL *url = [NSURL URLWithString:@"https://x.com/buituan282"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else if (indexPath.section == 9 && indexPath.row == 9) {
        NSURL *url = [NSURL URLWithString:@"mailto:buimanhtuan2k4@gmail.com"];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
}

- (UITableViewCell *)createSwitchCellWithTitle:(NSString *)title Detail:(NSString*)detail Key:(NSString*)key {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    
    UISwitch *switchView = [[UISwitch alloc] init];
    [cell.contentView addSubview:switchView];
    cell.accessoryView = switchView;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    switchView.on = [defaults boolForKey:key];
    switchView.accessibilityLabel = key;
    [switchView addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0 weight:UIFontWeightMedium];
    
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12.5];
    
    return cell;
}

- (void)switchToggled:(UISwitch *)sender {
    NSString *key = sender.accessibilityLabel;
    if (key.length > 0) {
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
