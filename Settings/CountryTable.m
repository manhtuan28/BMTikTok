#import "CountryTable.h"

@interface CountryTable () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *regionTitles;
@property (nonatomic, strong) NSArray *regionCodes;
@property (nonatomic, strong) UITableView *tableView;
@end

@interface AWEStoreRegionChangeManager: NSObject 
- (void)p_showStoreRegionChangedDialog;
+ (id)sharedInstance;
@end

@implementation CountryTable

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Chọn quốc gia / Khu vực";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Đóng" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
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
        @{@"area": @"South Korea 🇰🇷", @"name": @"South Korea", @"code": @"KR", @"mcc": @"450", @"mnc": @"05"},
        @{@"area": @"United Kingdom 🇬🇧", @"name": @"United Kingdom", @"code": @"GB", @"mcc": @"234", @"mnc": @"30"},
        @{@"area": @"Singapore 🇸🇬", @"name": @"Singapore", @"code": @"SG", @"mcc": @"525", @"mnc": @"01"},
        @{@"area": @"Thailand 🇹🇭", @"name": @"Thailand", @"code": @"TH", @"mcc": @"520", @"mnc": @"18"},
        @{@"area": @"Taiwan 🇹🇼", @"name": @"Taiwan", @"code": @"TW", @"mcc": @"466", @"mnc": @"01"},
        @{@"area": @"Hong Kong 🇭🇰", @"name": @"Hong Kong", @"code": @"HK", @"mcc": @"454", @"mnc": @"00"},
        @{@"area": @"Australia 🇦🇺", @"name": @"Australia", @"code": @"AU", @"mcc": @"505", @"mnc": @"02"},
        @{@"area": @"Canada 🇨🇦", @"name": @"Canada", @"code": @"CA", @"mcc": @"302", @"mnc": @"720"},
        @{@"area": @"France 🇫🇷", @"name": @"France", @"code": @"FR", @"mcc": @"208", @"mnc": @"10"},
        @{@"area": @"Germany 🇩🇪", @"name": @"Germany", @"code": @"DE", @"mcc": @"262", @"mnc": @"01"},
        @{@"area": @"Russia 🇷🇺", @"name": @"Russia", @"code": @"RU", @"mcc": @"250", @"mnc": @"01"},
        @{@"area": @"Italy 🇮🇹", @"name": @"Italy", @"code": @"IT", @"mcc": @"222", @"mnc": @"10"},
        @{@"area": @"Indonesia 🇮🇩", @"name": @"Indonesia", @"code": @"ID", @"mcc": @"510", @"mnc": @"01"},
        @{@"area": @"Malaysia 🇲🇾", @"name": @"Malaysia", @"code": @"MY", @"mcc": @"502", @"mnc": @"13"},
        @{@"area": @"Philippines 🇵🇭", @"name": @"Philippines", @"code": @"PH", @"mcc": @"515", @"mnc": @"02"},
        @{@"area": @"Saudi Arabia 🇸🇦", @"name": @"Saudi Arabia", @"code": @"SA", @"mcc": @"420", @"mnc": @"01"},
        @{@"area": @"United Arab Emirates 🇦🇪", @"name": @"United Arab Emirates", @"code": @"AE", @"mcc": @"424", @"mnc": @"02"},
        @{@"area": @"Brazil 🇧🇷", @"name": @"Brazil", @"code": @"BR", @"mcc": @"724", @"mnc": @"06"},
        @{@"area": @"Turkey 🇹🇷", @"name": @"Turkey", @"code": @"TR", @"mcc": @"286", @"mnc": @"01"},
        @{@"area": @"Macao 🇲🇴", @"name": @"Macao", @"code": @"MO", @"mcc": @"455", @"mnc": @"00"},
        @{@"area": @"Argentina 🇦🇷", @"name": @"Argentina", @"code": @"AR", @"mcc": @"722", @"mnc": @"07"},
        @{@"area": @"Laos 🇱🇦", @"name": @"Laos", @"code": @"LA", @"mcc": @"457", @"mnc": @"01"},
        @{@"area": @"Anguilla 🇦🇮", @"name": @"Anguilla", @"code": @"AI", @"mcc": @"365", @"mnc": @"840"},
        @{@"area": @"Panama 🇵🇦", @"name": @"Panama", @"code": @"PA", @"mcc": @"714", @"mnc": @"04"},
        @{@"area": @"Finland 🇫🇮", @"name": @"Finland", @"code": @"FI", @"mcc": @"244", @"mnc": @"91"},
        @{@"area": @"Pakistan 🇵🇰", @"name": @"Pakistan", @"code": @"PK", @"mcc": @"410", @"mnc": @"01"},
        @{@"area": @"Denmark 🇩🇰", @"name": @"Denmark", @"code": @"DK", @"mcc": @"238", @"mnc": @"01"},
        @{@"area": @"Norway 🇳🇴", @"name": @"Norway", @"code": @"NO", @"mcc": @"242", @"mnc": @"01"},
        @{@"area": @"Sudan 🇸🇩", @"name": @"Sudan", @"code": @"SD", @"mcc": @"634", @"mnc": @"01"},
        @{@"area": @"Romania 🇷🇴", @"name": @"Romania", @"code": @"RO", @"mcc": @"226", @"mnc": @"01"},
        @{@"area": @"Egypt 🇪🇬", @"name": @"Egypt", @"code": @"EG", @"mcc": @"602", @"mnc": @"01"},
        @{@"area": @"Lebanon 🇱🇧", @"name": @"Lebanon", @"code": @"LB", @"mcc": @"415", @"mnc": @"01"},
        @{@"area": @"Mexico 🇲🇽", @"name": @"Mexico", @"code": @"MX", @"mcc": @"334", @"mnc": @"030"},
        @{@"area": @"Kuwait 🇰🇼", @"name": @"Kuwait", @"code": @"KW", @"mcc": @"419", @"mnc": @"02"},
        @{@"area": @"Algeria 🇩🇿", @"name": @"Algeria", @"code": @"DZ", @"mcc": @"603", @"mnc": @"01"}
    ];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.regionTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CountryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *regionDict = self.regionCodes[indexPath.row];
    cell.textLabel.text = self.regionTitles[indexPath.row];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Mã quốc gia: %@ | MCC: %@", regionDict[@"code"], regionDict[@"mcc"]];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    NSDictionary *currentRegion = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"region"];
    if (currentRegion && [currentRegion[@"code"] isEqualToString:regionDict[@"code"]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *selectedRegion = self.regionCodes[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:selectedRegion forKey:@"region"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Đã chuyển vùng" message:[NSString stringWithFormat:@"Đã đổi sang: %@", self.regionTitles[indexPath.row]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Hoàn tất" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissVC];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
