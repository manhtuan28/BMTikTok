//
//  CountryTable.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "CountryTable.h"

@interface CountryTable () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *regionTitles;
@property (nonatomic, strong) NSArray *regionCodes;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation CountryTable

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Khu Vực & Đổi Quốc Gia";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    self.regionTitles = @[
        @"Việt Nam 🇻🇳", @"Hoa Kỳ (United States) 🇺🇸", @"Nhật Bản (Japan) 🇯🇵", @"Hàn Quốc (South Korea) 🇰🇷",
        @"Vương quốc Anh (UK) 🇬🇧", @"Singapore 🇸🇬", @"Thái Lan (Thailand) 🇹🇭", @"Đài Loan (Taiwan) 🇹🇼",
        @"Hồng Kông (Hong Kong) 🇭🇰", @"Úc (Australia) 🇦🇺", @"Canada 🇨🇦", @"Pháp (France) 🇫🇷",
        @"Đức (Germany) 🇩🇪", @"Nga (Russia) 🇷🇺", @"Ý (Italy) 🇮🇹", @"Indonesia 🇮🇩",
        @"Malaysia 🇲🇾", @"Philippines 🇵🇭", @"Ả Rập Xê Út 🇸🇦", @"Các Tiểu Vương quốc Ả Rập 🇦🇪",
        @"Brazil 🇧🇷", @"Thổ Nhĩ Kỳ 🇹🇷", @"Ma Cao 🇲🇴", @"Argentina 🇦🇷",
        @"Lào 🇱🇦", @"Anguilla 🇦🇮", @"Panama 🇵🇦", @"Phần Lan 🇫🇮",
        @"Pakistan 🇵🇰", @"Đan Mạch 🇩🇰", @"Na Uy 🇳🇴", @"Sudan 🇸🇩",
        @"Romania 🇷🇴", @"Ai Cập 🇪🇬", @"Li-băng 🇱🇧", @"Mexico 🇲🇽",
        @"Kuwait 🇰🇼", @"Algeria 🇩🇿"
    ];
    
    self.regionCodes = @[
        @{@"area": @"Vietnam 🇻🇳", @"name": @"Vietnam", @"code": @"VN", @"mcc": @"452", @"mnc": @"01"},
        @{@"area": @"United States 🇺🇸", @"name": @"United States", @"code": @"US", @"mcc": @"310", @"mnc": @"00"},
        @{@"area": @"Japan 🇯🇵", @"name": @"Japan", @"code": @"JP", @"mcc": @"440", @"mnc": @"00"},
        @{@"area": @"South Korea 🇰🇷", @"name": @"Korea", @"code": @"KR", @"mcc": @"450", @"mnc": @"02"},
        @{@"area": @"United Kingdom 🇬🇧", @"name": @"United Kingdom", @"code": @"GB", @"mcc": @"234", @"mnc": @"10"},
        @{@"area": @"Singapore 🇸🇬", @"name": @"Singapore", @"code": @"SG", @"mcc": @"525", @"mnc": @"01"},
        @{@"area": @"Thailand 🇹🇭", @"name": @"Thailand", @"code": @"TH", @"mcc": @"520", @"mnc": @"18"},
        @{@"area": @"Taiwan 🇹🇼", @"name": @"Taiwan", @"code": @"TW", @"mcc": @"466", @"mnc": @"01"},
        @{@"area": @"Hong Kong 🇭🇰", @"name": @"HongKong", @"code": @"HK", @"mcc": @"454", @"mnc": @"12"},
        @{@"area": @"Australia 🇦🇺", @"name": @"Australia", @"code": @"AU", @"mcc": @"505", @"mnc": @"01"},
        @{@"area": @"Canada 🇨🇦", @"name": @"Canada", @"code": @"CA", @"mcc": @"302", @"mnc": @"220"},
        @{@"area": @"France 🇫🇷", @"name": @"France", @"code": @"FR", @"mcc": @"208", @"mnc": @"10"},
        @{@"area": @"Germany 🇩🇪", @"name": @"Germany", @"code": @"DE", @"mcc": @"262", @"mnc": @"01"},
        @{@"area": @"Russia 🇷🇺", @"name": @"Russia", @"code": @"RU", @"mcc": @"250", @"mnc": @"01"},
        @{@"area": @"Italy 🇮🇹", @"name": @"Italy", @"code": @"IT", @"mcc": @"222", @"mnc": @"01"},
        @{@"area": @"Indonesia 🇮🇩", @"name": @"Indonesia", @"code": @"ID", @"mcc": @"510", @"mnc": @"10"},
        @{@"area": @"Malaysia 🇲🇾", @"name": @"Malaysia", @"code": @"MY", @"mcc": @"502", @"mnc": @"12"},
        @{@"area": @"Philippines 🇵🇭", @"name": @"Philippines", @"code": @"PH", @"mcc": @"515", @"mnc": @"03"},
        @{@"area": @"Saudi Arabia 🇸🇦", @"name": @"Saudi Arabia", @"code": @"SA", @"mcc": @"420", @"mnc": @"01"},
        @{@"area": @"United Arab Emirates 🇦🇪", @"name": @"United Arab Emirates", @"code": @"AE", @"mcc": @"424", @"mnc": @"02"},
        @{@"area": @"Brazil 🇧🇷", @"name": @"Brazil", @"code": @"BR", @"mcc": @"724", @"mnc": @"05"},
        @{@"area": @"Turkey 🇹🇷", @"name": @"Turkey", @"code": @"TR", @"mcc": @"286", @"mnc": @"01"},
        @{@"area": @"Macau 🇲🇴", @"name": @"Macau", @"code": @"MO", @"mcc": @"455", @"mnc": @"01"},
        @{@"area": @"Argentina 🇦🇷", @"name": @"Argentina", @"code": @"AR", @"mcc": @"722", @"mnc": @"310"},
        @{@"area": @"Laos 🇱🇦", @"name": @"Laos", @"code": @"LA", @"mcc": @"457", @"mnc": @"01"},
        @{@"area": @"Anguilla 🇦🇮", @"name": @"Anguilla", @"code": @"AI", @"mcc": @"365", @"mnc": @"840"},
        @{@"area": @"Panama 🇵🇦", @"name": @"Panama", @"code": @"PA", @"mcc": @"714", @"mnc": @"01"},
        @{@"area": @"Finland 🇫🇮", @"name": @"Finland", @"code": @"FI", @"mcc": @"244", @"mnc": @"05"},
        @{@"area": @"Pakistan 🇵🇰", @"name": @"Pakistan", @"code": @"PK", @"mcc": @"410", @"mnc": @"01"},
        @{@"area": @"Denmark 🇩🇰", @"name": @"Denmark", @"code": @"DK", @"mcc": @"238", @"mnc": @"01"},
        @{@"area": @"Norway 🇳🇴", @"name": @"Norway", @"code": @"NO", @"mcc": @"242", @"mnc": @"01"},
        @{@"area": @"Sudan 🇸🇩", @"name": @"Sudan", @"code": @"SD", @"mcc": @"634", @"mnc": @"01"},
        @{@"area": @"Romania 🇷🇴", @"name": @"Romania", @"code": @"RO", @"mcc": @"226", @"mnc": @"01"},
        @{@"area": @"Egypt 🇪🇬", @"name": @"Egypt", @"code": @"EG", @"mcc": @"602", @"mnc": @"01"},
        @{@"area": @"Lebanon 🇱🇧", @"name": @"Lebanon", @"code": @"LB", @"mcc": @"415", @"mnc": @"01"},
        @{@"area": @"Mexico 🇲🇽", @"name": @"Mexico", @"code": @"MX", @"mcc": @"334", @"mnc": @"020"},
        @{@"area": @"Kuwait 🇰🇼", @"name": @"Kuwait", @"code": @"KW", @"mcc": @"419", @"mnc": @"02"},
        @{@"area": @"Algeria 🇩🇿", @"name": @"Algeria", @"code": @"DZ", @"mcc": @"603", @"mnc": @"01"}
    ];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

#pragma mark - UITableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) return @"CẤU HÌNH ĐỔI QUỐC GIA";
    return @"DANH SÁCH QUỐC GIA KHẢ DỤNG";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 2;
    return self.regionTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString *switchCellId = @"RegionSwitchCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:switchCellId];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:switchCellId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *sw = [[UISwitch alloc] init];
                sw.onTintColor = [UIColor systemPinkColor];
                [sw addTarget:self action:@selector(regionSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = sw;
            }
            cell.textLabel.text = @"Bật tính năng Đổi vùng";
            cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            cell.detailTextLabel.text = @"Bắt buộc bật để chuyển nội dung Feed sang nước khác";
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            UISwitch *sw = (UISwitch *)cell.accessoryView;
            [sw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"en_region"] animated:NO];
            return cell;
        } else {
            static NSString *ruSwitchId = @"RuFixSwitchCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ruSwitchId];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ruSwitchId];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UISwitch *sw = [[UISwitch alloc] init];
                sw.onTintColor = [UIColor systemPinkColor];
                [sw addTarget:self action:@selector(russianFixChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = sw;
            }
            cell.textLabel.text = @"Mở khóa Bảng tin Nga (Russian Fix)";
            cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
            cell.detailTextLabel.text = @"Bỏ qua cấm vận và mở khóa xem video vùng Nga";
            cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
            UISwitch *sw = (UISwitch *)cell.accessoryView;
            [sw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"russian_fix"] animated:NO];
            return cell;
        }
    }
    
    static NSString *cellIdentifier = @"CountryItemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *regionDict = self.regionCodes[indexPath.row];
    cell.textLabel.text = self.regionTitles[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Mã: %@ • MCC: %@ • MNC: %@", regionDict[@"code"], regionDict[@"mcc"], regionDict[@"mnc"]];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    NSDictionary *currentRegion = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
    if (currentRegion && [currentRegion[@"code"] isEqualToString:regionDict[@"code"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.tintColor = [UIColor systemPinkColor];
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)regionSwitchChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"en_region"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
}

- (void)russianFixChanged:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"russian_fix"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) return;
    
    NSDictionary *selectedRegion = self.regionCodes[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedRegion forKey:@"region"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"en_region"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [feedback impactOccurred];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đã đổi vùng thành công"
                                                                   message:[NSString stringWithFormat:@"Đã thiết lập vùng xem video sang: %@", self.regionTitles[indexPath.row]]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
