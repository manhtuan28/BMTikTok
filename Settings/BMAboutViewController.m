//
//  BMAboutViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMAboutViewController.h"
#import "BMConfigManager.h"
#import "BMLogger.h"
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface BMAboutViewController () <UIDocumentPickerDelegate>
@end

@implementation BMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Thông Tin Tác Giả";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"TÁC GIẢ & LIÊN KẾT XÃ HỘI";
        case 1: return @"SAO LƯU & XUẤT/NHẬP CẤU HÌNH";
        case 2: return @"QUẢN TRỊ & GỠ LỖI (DEBUG)";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 6;
        case 1: return 6; // Xuất JSON, Nhập File, Copy Clipboard, Dán Clipboard, Lưu Keychain, Khôi phục Keychain
        case 2: return 5; // Reset DID, Mở FLEX, Xuất Log, Xóa Log, Reset All
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
        static NSString *configCellId = @"ConfigActionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:configCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:configCellId];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Xuất tệp cấu hình (.json)";
                cell.detailTextLabel.text = @"Lưu file cấu hình vào ứng dụng Tệp hoặc AirDrop";
                cell.imageView.image = [UIImage systemImageNamed:@"square.and.arrow.up.fill"];
                break;
            case 1:
                cell.textLabel.text = @"Nhập tệp cấu hình từ máy";
                cell.detailTextLabel.text = @"Khôi phục cài đặt từ file JSON đã lưu";
                cell.imageView.image = [UIImage systemImageNamed:@"square.and.arrow.down.fill"];
                break;
            case 2:
                cell.textLabel.text = @"Sao chép cấu hình vào Clipboard";
                cell.detailTextLabel.text = @"Copy chuỗi JSON cấu hình vào bộ nhớ tạm";
                cell.imageView.image = [UIImage systemImageNamed:@"doc.on.doc.fill"];
                break;
            case 3:
                cell.textLabel.text = @"Dán & Áp dụng từ Clipboard";
                cell.detailTextLabel.text = @"Đọc cấu hình JSON từ bộ nhớ tạm và áp dụng ngay";
                cell.imageView.image = [UIImage systemImageNamed:@"doc.badge.arrow.up.fill"];
                break;
            case 4:
                cell.textLabel.text = @"Lưu cấu hình vào Keychain";
                cell.detailTextLabel.text = @"Lưu an toàn trên máy, không bị mất khi cài lại IPA";
                cell.imageView.image = [UIImage systemImageNamed:@"key.fill"];
                break;
            case 5:
                cell.textLabel.text = @"Khôi phục cấu hình từ Keychain";
                cell.detailTextLabel.text = @"Nạp lại toàn bộ cài đặt đã lưu trong Keychain";
                cell.imageView.image = [UIImage systemImageNamed:@"arrow.counterclockwise.circle.fill"];
                break;
        }
        return cell;
    } else if (indexPath.section == 2) {
        static NSString *debugCellId = @"DebugActionCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:debugCellId];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:debugCellId];
        }
        cell.textLabel.textColor = [UIColor labelColor];
        cell.textLabel.textAlignment = NSTextAlignmentNatural;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
        
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"Sửa lỗi Đăng nhập (Làm mới Device ID)";
                cell.textLabel.textColor = [UIColor systemOrangeColor];
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                cell.detailTextLabel.text = @"Xóa mã máy bị TikTok chặn 'quá thường xuyên', cấp mã mới";
                cell.imageView.image = [UIImage systemImageNamed:@"arrow.triangle.2.circlepath.circle.fill"];
                cell.imageView.tintColor = [UIColor systemOrangeColor];
                break;
            case 1:
                cell.textLabel.text = @"Mở Trình Gỡ Lỗi FLEX Explorer";
                cell.textLabel.textColor = [UIColor systemBlueColor];
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                cell.detailTextLabel.text = @"Mở thanh công cụ soi View, Network, Controller, Database";
                cell.imageView.image = [UIImage systemImageNamed:@"hammer.fill"];
                cell.imageView.tintColor = [UIColor systemBlueColor];
                break;
            case 2:
                cell.textLabel.text = @"Xuất File Log Debug (BMTikTok_Debug_Log.txt)";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                cell.detailTextLabel.text = @"Gửi/Lưu toàn bộ log mạng và lỗi đăng nhập";
                cell.imageView.image = [UIImage systemImageNamed:@"doc.text.magnifyingglass"];
                cell.imageView.tintColor = [UIColor systemTealColor];
                break;
            case 3:
                cell.textLabel.text = @"Xóa Lịch Sử Log Debug";
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
                cell.detailTextLabel.text = @"Làm trống file log hiện tại để ghi phiên mới";
                cell.imageView.image = [UIImage systemImageNamed:@"trash.fill"];
                cell.imageView.tintColor = [UIColor systemGrayColor];
                break;
            case 4:
                cell.textLabel.text = @"Khôi phục tất cả cài đặt BMTikTok";
                cell.textLabel.textColor = [UIColor systemRedColor];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
                cell.detailTextLabel.text = nil;
                cell.imageView.image = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
        }
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
        switch (indexPath.row) {
            case 0: { // Xuất JSON File
                NSURL *fileURL = [BMConfigManager createExportConfigFileURL];
                if (fileURL) {
                    UIActivityViewController *act = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
                    if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                        act.popoverPresentationController.sourceView = self.view;
                        act.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
                    }
                    [self presentViewController:act animated:YES completion:nil];
                }
                break;
            }
            case 1: { // Nhập File JSON
                UIDocumentPickerViewController *picker = nil;
                if (@available(iOS 14.0, *)) {
                    picker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:@[UTTypeJSON, UTTypePlainText]];
                } else {
                    picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.json", @"public.plain-text"] inMode:UIDocumentPickerModeImport];
                }
                picker.delegate = self;
                picker.allowsMultipleSelection = NO;
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            case 2: { // Copy Clipboard
                NSString *json = [BMConfigManager exportSettingsToJSONString];
                if (json) {
                    [UIPasteboard generalPasteboard].string = json;
                    [self showAlertWithTitle:@"Đã sao chép" message:@"Cấu hình JSON đã được lưu vào bộ nhớ tạm."];
                }
                break;
            }
            case 3: { // Dán Clipboard
                NSString *clipboard = [UIPasteboard generalPasteboard].string;
                if (clipboard && [BMConfigManager importSettingsFromJSONString:clipboard]) {
                    [self showAlertWithTitle:@"Thành công" message:@"Đã nạp và áp dụng cấu hình từ Clipboard!"];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Nội dung trong bộ nhớ tạm không phải định dạng JSON cấu hình BMTikTok hợp lệ."];
                }
                break;
            }
            case 4: { // Lưu Keychain
                if ([BMConfigManager saveSettingsToKeychain]) {
                    [self showAlertWithTitle:@"Đã lưu Keychain" message:@"Cấu hình đã được lưu an toàn vào Keychain của iOS. Khi bạn cài lại app hoặc nâng cấp IPA, cài đặt sẽ không bị mất."];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Không thể ghi cấu hình vào Keychain."];
                }
                break;
            }
            case 5: { // Khôi phục Keychain
                if ([BMConfigManager restoreSettingsFromKeychain]) {
                    [self showAlertWithTitle:@"Thành công" message:@"Đã khôi phục toàn bộ cài đặt BMTikTok từ Keychain!"];
                } else {
                    [self showAlertWithTitle:@"Thông báo" message:@"Chưa có bản sao lưu cấu hình nào trong Keychain."];
                }
                break;
            }
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0: { // Sửa lỗi Đăng nhập (Làm mới Device ID)
                UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Làm mới Device ID & Sửa lỗi Đăng nhập"
                                                                                 message:@"Chức năng này sẽ xóa mã máy bị TikTok chặn do 'truy cập quá thường xuyên', cấp phát Device ID mới hoàn toàn để bạn đăng nhập bình thường.\n\nBạn có muốn tiếp tục không?"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [confirm addAction:[UIAlertAction actionWithTitle:@"Làm mới ngay" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [BMConfigManager fixLoginRateLimitAndResetDeviceID];
                    [self showAlertWithTitle:@"Đã làm mới Device ID thành công!" message:@"Mã thiết bị đã được làm mới sạch sẽ. Hãy mở màn hình Đăng nhập để đăng nhập tài khoản ngay bây giờ."];
                }]];
                [confirm addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:confirm animated:YES completion:nil];
                break;
            }
            case 1: { // Mở FLEX Explorer
                Class flexClass = NSClassFromString(@"FLEXManager");
                if (flexClass) {
                    id mgr = [flexClass performSelector:NSSelectorFromString(@"sharedManager")];
                    [mgr performSelector:NSSelectorFromString(@"showExplorer")];
                    [self showAlertWithTitle:@"FLEX Explorer" message:@"Đã kích hoạt thanh công cụ gỡ lỗi FLEX trên màn hình!"];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Không tìm thấy thư viện FLEX trong ứng dụng."];
                }
                break;
            }
            case 2: { // Xuất File Log Debug
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                [BMLogger shareLogFromViewController:self sender:cell ?: self.view];
                break;
            }
            case 3: { // Xóa Lịch Sử Log Debug
                [BMLogger clearLog];
                [self showAlertWithTitle:@"Thành công" message:@"Đã xóa sạch dữ liệu log và khởi tạo phiên log mới."];
                break;
            }
            case 4: { // Khôi phục cài đặt gốc
                UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Khôi phục cài đặt gốc"
                                                                                 message:@"Bạn có chắc chắn muốn đặt lại tất cả các tùy chọn BMTikTok về mặc định (TẮT toàn bộ chức năng)?"
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
                [confirm addAction:[UIAlertAction actionWithTitle:@"Đặt lại ngay" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [BMConfigManager resetAllSettingsToDefault];
                    [self showAlertWithTitle:@"Thành công" message:@"Đã đặt lại toàn bộ cài đặt BMTikTok về mặc định (Toàn bộ tính năng đã được TẮT)."];
                }]];
                [confirm addAction:[UIAlertAction actionWithTitle:@"Hủy" style:UIAlertActionStyleCancel handler:nil]];
                [self presentViewController:confirm animated:YES completion:nil];
                break;
            }
        }
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *url = urls.firstObject;
        [url startAccessingSecurityScopedResource];
        NSError *error = nil;
        NSString *content = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
        [url stopAccessingSecurityScopedResource];
        
        if (content && [BMConfigManager importSettingsFromJSONString:content]) {
            [self showAlertWithTitle:@"Thành công" message:@"Đã nhập và áp dụng cấu hình từ tệp JSON thành công!"];
        } else {
            [self showAlertWithTitle:@"Lỗi" message:@"Tệp đã chọn không phải file cấu hình BMTikTok hợp lệ."];
        }
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
