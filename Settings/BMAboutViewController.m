//
//  BMAboutViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMAboutViewController.h"

@implementation BMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Thông Tin Tác Giả & Hỗ Trợ";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"TÁC GIẢ & LIÊN KẾT XÃ HỘI";
        case 1: return @"HỖ TRỢ & HƯỚNG DẪN";
        case 2: return @"QUẢN TRỊ HỆ THỐNG";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 6;
        case 1: return 2;
        case 2: return 1;
        default: return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *socialCellId = @"SocialLinkCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:socialCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:socialCellId];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"GitHub";
                cell.detailTextLabel.text = @"@manhtuan28";
                cell.imageView.image = [UIImage systemImageNamed:@"chevron.left.forwardslash.chevron.right"];
                break;
            case 1:
                cell.textLabel.text = @"Facebook";
                cell.detailTextLabel.text = @"b.manhtuan.028";
                cell.imageView.image = [UIImage systemImageNamed:@"person.2.fill"];
                break;
            case 2:
                cell.textLabel.text = @"TikTok Chính Chủ";
                cell.detailTextLabel.text = @"@capyboiii_28";
                cell.imageView.image = [UIImage systemImageNamed:@"play.tv.fill"];
                break;
            case 3:
                cell.textLabel.text = @"Instagram";
                cell.detailTextLabel.text = @"@bmanhtuan282";
                cell.imageView.image = [UIImage systemImageNamed:@"camera.fill"];
                break;
            case 4:
                cell.textLabel.text = @"X (Twitter)";
                cell.detailTextLabel.text = @"@buituan282";
                cell.imageView.image = [UIImage systemImageNamed:@"bubble.left.and.bubble.right.fill"];
                break;
            case 5:
                cell.textLabel.text = @"Email Liên Hệ";
                cell.detailTextLabel.text = @"buimanhtuan2k4@gmail.com";
                cell.imageView.image = [UIImage systemImageNamed:@"envelope.fill"];
                break;
        }
        return cell;
    } else if (indexPath.section == 1) {
        static NSString *guideCellId = @"GuideCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:guideCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:guideCellId];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Sửa lỗi Đăng nhập / SMS OTP";
            cell.detailTextLabel.text = @"Xem các mẹo đăng nhập khi bị báo 'gửi quá nhiều lần'";
            cell.imageView.image = [UIImage systemImageNamed:@"questionmark.circle.fill"];
        } else {
            cell.textLabel.text = @"Kho Lưu Trữ Dự Án BMTikTok";
            cell.detailTextLabel.text = @"Mã nguồn mở và các bản phát hành mới nhất";
            cell.imageView.image = [UIImage systemImageNamed:@"folder.fill"];
        }
        return cell;
    } else if (indexPath.section == 2) {
        static NSString *resetCellId = @"ResetCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resetCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resetCellId];
        }
        cell.textLabel.text = @"Khôi phục tất cả cài đặt BMTikTok";
        cell.textLabel.textColor = [UIColor systemRedColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        return cell;
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        NSString *urlString = nil;
        switch (indexPath.row) {
            case 0: urlString = @"https://github.com/manhtuan28/BMTikTok"; break;
            case 1: urlString = @"https://www.facebook.com/b.manhtuan.028"; break;
            case 2: urlString = @"https://www.tiktok.com/@capyboiii_28"; break;
            case 3: urlString = @"https://www.instagram.com/bmanhtuan282/"; break;
            case 4: urlString = @"https://x.com/buituan282"; break;
            case 5: urlString = @"mailto:buimanhtuan2k4@gmail.com"; break;
        }
        if (urlString) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:nil];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mẹo Đăng Nhập Tài Khoản"
                                                                           message:@"Nếu gặp lỗi 'Gửi quá nhiều lần' khi nhận mã SMS:\n\n1. Sử dụng Tên người dùng / Email & Mật khẩu để vào thẳng.\n\n2. Hoặc đăng nhập trên máy tính / Safari rồi dùng app quét mã QR.\n\n3. Tạm thời tắt 'Đổi quốc gia' trong menu BMTikTok trước khi gửi mã SMS."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Đã hiểu" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/manhtuan28/BMTikTok"] options:@{} completionHandler:nil];
        }
    } else if (indexPath.section == 2) {
        UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Khôi phục cài đặt gốc"
                                                                         message:@"Bạn có chắc chắn muốn đặt lại tất cả các tùy chọn BMTikTok về mặc định?"
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
        [confirm addAction:[UIAlertAction actionWithTitle:@"Đặt lại ngay" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSArray *keys = @[
                @"hide_ads", @"hide_commission_posts", @"remove_pendant", @"remove_tiktok_ai_button",
                @"block_ai_generated", @"block_movie_tok", @"block_poi", @"disable_unsensitive",
                @"disable_warnings", @"disable_live", @"hide_play_pause", @"hide_top_items",
                @"start_fyp_in_following", @"disable_swipe_in_fyp", @"pull_to_refresh", @"auto_scroll_feed",
                @"download_button", @"remove_watermark", @"remove_photo_watermark", @"download_music",
                @"share_sheet", @"save_dm_media", @"double_tap_download_sticker", @"highest_video_quality",
                @"anonymous_seen", @"mark_seen_on_reply", @"disable_typing", @"view_profiles_anonymous",
                @"disable_screenshot_detection", @"disable_screenrecording_detection", @"hide_activity_status",
                @"padlock", @"transparent_commnet", @"hide_emoji_bar", @"colorize_comment_usernames",
                @"copy_comment_text", @"enable_comment_flags", @"auto_translate_comments", @"disable_safari_redirect",
                @"auto_play_next_video", @"stop_looping_video", @"progress_bar", @"keep_audio_unmuted",
                @"playback_en", @"force_highest_bitrate", @"fake_verified", @"enable_fake_follower",
                @"enable_fake_following", @"enable_fake_likes", @"copy_profile_bio", @"copy_profile_id",
                @"download_profile_avatar", @"hide_liked_tab", @"like_confirmation", @"follow_confirmation",
                @"comment_like_confirmation", @"comment_dislike_confirmation", @"publish_confirmation",
                @"download_confirmation", @"bookmark_confirmation", @"oled_keyboard", @"hide_tab_bar_labels",
                @"hide_badge_counter", @"transparent_status_bar", @"show_exact_date", @"en_region"
            ];
            for (NSString *k in keys) {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:k];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            UIAlertController *doneAlert = [UIAlertController alertControllerWithTitle:@"Thành công" message:@"Đã đặt lại toàn bộ cài đặt BMTikTok về mặc định." preferredStyle:UIAlertControllerStyleAlert];
            [doneAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:doneAlert animated:YES completion:nil];
        }]];
        [confirm addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:confirm animated:YES completion:nil];
    }
}

@end
