//
//  LiveActions.m
//  BMTikTok Settings
//
//  Tác giả & Phát triển: Tuancute28
//

#import "LiveActions.h"

@interface LiveActions () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *liveFuncValues;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *liveFuncTitles;
@property (nonatomic, strong) NSArray *liveFuncDescriptions;
@end

@implementation LiveActions

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tùy biến hành động nút Live";
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Đóng" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.liveFuncTitles = @[@"Mặc định của TikTok", @"Mở Cài đặt BMTikTok", @"Mở bảng Tốc độ phát"];
    self.liveFuncDescriptions = @[@"Mở trang danh sách các phòng Live như bình thường", @"Bấm vào nút Live để mở nhanh bảng cài đặt BMTikTok", @"Bấm vào nút Live để đổi nhanh tốc độ phát video"];
    self.liveFuncValues = @[@0, @1, @2];
    
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
    return self.liveFuncValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LiveActionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = self.liveFuncTitles[indexPath.row];
    cell.detailTextLabel.text = self.liveFuncDescriptions[indexPath.row];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    
    NSNumber *currentAction = [[NSUserDefaults standardUserDefaults] objectForKey:@"live_action"];
    if ((!currentAction && [self.liveFuncValues[indexPath.row] isEqualToNumber:@0]) || [currentAction isEqualToNumber:self.liveFuncValues[indexPath.row]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *selectedValue = self.liveFuncValues[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:selectedValue forKey:@"live_action"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"en_livefunc"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.tableView reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nút Live" message:[NSString stringWithFormat:@"Đã thiết lập: %@", self.liveFuncTitles[indexPath.row]] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Hoàn tất" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissVC];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
