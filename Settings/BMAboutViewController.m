//
//  BMAboutViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMAboutViewController.h"
#import "BMConfigManager.h"

#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

@interface BMAboutViewController () <UIDocumentPickerDelegate>
@end

@implementation BMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Thông Tin Tác Giả";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return @"TÁC GIẢ & LIÊN KẾT XÃ HỘI";
        case 1: return @"SAO LƯU & XUẤT/NHẬP CẤU HÌNH";
        default: return @"";
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 6;
        case 1: return 6; // Xuất JSON, Nhập File, Copy Clipboard, Dán Clipboard, Lưu Keychain, Khôi phục Keychain
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
    }
    return [[UITableViewCell alloc] init];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        NSString *urlString = nil;
        switch (indexPath.row) {
            case 0: urlString = @"https://github.com/manhtuan28"; break;
            case 1: urlString = @"https://www.facebook.com/b.manhtuan.028/"; break;
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
                        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                        act.popoverPresentationController.sourceView = cell ?: self.view;
                        act.popoverPresentationController.sourceRect = cell ? cell.bounds : CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
                    }
                    [self presentViewController:act animated:YES completion:nil];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Không thể tạo tệp cấu hình JSON."];
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
                if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                    picker.popoverPresentationController.sourceView = cell ?: self.view;
                    picker.popoverPresentationController.sourceRect = cell ? cell.bounds : CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2, 0, 0);
                }
                [self presentViewController:picker animated:YES completion:nil];
                break;
            }
            case 2: { // Copy Clipboard
                NSString *json = [BMConfigManager exportSettingsToJSONString];
                if (json && json.length > 0) {
                    [UIPasteboard generalPasteboard].string = json;
                    [self showAlertWithTitle:@"Đã sao chép" message:@"Cấu hình JSON đã được lưu vào bộ nhớ tạm (Clipboard)."];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Không thể tạo chuỗi JSON từ cấu hình hiện tại."];
                }
                break;
            }
            case 3: { // Dán Clipboard
                NSString *clipboard = [UIPasteboard generalPasteboard].string;
                if (clipboard && clipboard.length > 0 && [BMConfigManager importSettingsFromJSONString:clipboard]) {
                    [self showAlertWithTitle:@"Thành công" message:@"Đã nạp và áp dụng cấu hình từ Clipboard thành công!"];
                } else {
                    [self showAlertWithTitle:@"Lỗi" message:@"Nội dung trong Clipboard không phải định dạng JSON cấu hình BMTikTok hợp lệ."];
                }
                break;
            }
            case 4: { // Lưu Keychain
                if ([BMConfigManager saveSettingsToKeychain]) {
                    [self showAlertWithTitle:@"Đã lưu Keychain" message:@"Cấu hình đã được lưu an toàn vào Keychain của iOS. Khi bạn cài lại app hoặc nâng cấp IPA, bạn có thể bấm 'Khôi phục cấu hình từ Keychain' để lấy lại cấu hình."];
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
    }
}

#pragma mark - UIDocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls {
    if (urls.count > 0) {
        NSURL *url = urls.firstObject;
        BOOL accessed = [url startAccessingSecurityScopedResource];
        NSData *data = [NSData dataWithContentsOfURL:url];
        if (accessed) {
            [url stopAccessingSecurityScopedResource];
        }
        
        if (data) {
            NSString *content = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (content && [BMConfigManager importSettingsFromJSONString:content]) {
                [self showAlertWithTitle:@"Thành công" message:@"Đã nhập và áp dụng cấu hình từ tệp JSON thành công!"];
                return;
            }
        }
        [self showAlertWithTitle:@"Lỗi" message:@"Tệp đã chọn không phải file cấu hình BMTikTok hợp lệ."];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    if (url) {
        [self documentPicker:controller didPickDocumentsAtURLs:@[url]];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
