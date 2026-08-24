//
//  PlaybackSpeed.m
//  BMTikTok Settings
//
//  Tác giả & Phát triển: Tuancute28
//

#import "PlaybackSpeed.h"

@interface PlaybackSpeed () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *staticTable;
@property (nonatomic, strong) NSArray <NSNumber *> *speeds;
@end

@implementation PlaybackSpeed

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    self.title = @"Chọn tốc độ phát";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Đóng" style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.speeds = @[@0.5, @0.75, @1.0, @1.25, @1.5, @1.75, @2.0, @2.5, @3.0];
    
    self.staticTable = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleInsetGrouped];
    self.staticTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.staticTable.dataSource = self;
    self.staticTable.delegate = self;
    [self.view addSubview:self.staticTable];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speeds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"SpeedCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    NSNumber *speed = self.speeds[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Tốc độ %@x", speed];
    if ([speed isEqualToNumber:@1.0]) {
        cell.detailTextLabel.text = @"(Tốc độ chuẩn)";
    } else if ([speed floatValue] > 1.0) {
        cell.detailTextLabel.text = @"(Nhanh hơn)";
    } else {
        cell.detailTextLabel.text = @"(Chậm hơn)";
    }
    
    NSNumber *currentSpeed = [[NSUserDefaults standardUserDefaults] objectForKey:@"playback_speed"];
    if ((!currentSpeed && [speed isEqualToNumber:@1.0]) || [currentSpeed isEqualToNumber:speed]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber *selectedSpeed = self.speeds[indexPath.row];
    [[NSUserDefaults standardUserDefaults] setValue:selectedSpeed forKey:@"playback_speed"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"playback_en"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.staticTable reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RegionSelectedNotification" object:nil];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tốc độ phát" message:[NSString stringWithFormat:@"Đã cố định tốc độ phát: %@x", selectedSpeed] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self dismissVC];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
