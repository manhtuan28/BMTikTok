//
//  BMBaseSettingsViewController.m
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import "BMBaseSettingsViewController.h"
#import "BMConfigManager.h"

@implementation BMBaseSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = [UIColor systemGroupedBackgroundColor];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (UITableViewCell *)createSwitchCellWithTitle:(NSString *)title Detail:(NSString *)detail Key:(NSString *)key {
    NSString *cellId = [NSString stringWithFormat:@"SwitchCell_%@", key];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UISwitch *switchView = [[UISwitch alloc] init];
        switchView.onTintColor = [UIColor systemPinkColor];
        switchView.accessibilityIdentifier = key;
        [switchView addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = switchView;
    }
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    UISwitch *switchView = (UISwitch *)cell.accessoryView;
    [switchView setOn:[[NSUserDefaults standardUserDefaults] boolForKey:key] animated:NO];
    
    return cell;
}

- (UITableViewCell *)createNavigationCellWithTitle:(NSString *)title
                                           Detail:(NSString *)detail
                                             Icon:(NSString *)iconName
                                        IconColor:(UIColor *)iconColor {
    static NSString *cellId = @"NavCategoryCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    cell.detailTextLabel.text = detail;
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
    
    // Tạo icon tròn bo góc đẹp mắt kiểu iOS Settings
    UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:17 weight:UIImageSymbolWeightMedium];
    UIImage *symbolImage = [UIImage systemImageNamed:iconName withConfiguration:config];
    
    CGSize iconSize = CGSizeMake(34, 34);
    UIGraphicsBeginImageContextWithOptions(iconSize, NO, 0.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 34, 34) cornerRadius:8];
    [iconColor setFill];
    [path fill];
    
    if (symbolImage) {
        [[UIColor whiteColor] setFill];
        UIImage *tintedSymbol = [symbolImage imageWithTintColor:[UIColor whiteColor] renderingMode:UIImageRenderingModeAlwaysOriginal];
        CGFloat symW = tintedSymbol.size.width;
        CGFloat symH = tintedSymbol.size.height;
        [tintedSymbol drawInRect:CGRectMake((34 - symW) / 2.0, (34 - symH) / 2.0, symW, symH)];
    }
    
    UIImage *finalIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    cell.imageView.image = finalIcon;
    return cell;
}

- (void)switchToggled:(UISwitch *)sender {
    NSString *key = sender.accessibilityIdentifier;
    if (key) {
        [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Đồng bộ vào Keychain để tránh bị reset khi cài lại app
        [BMConfigManager saveSettingsToKeychain];
        
        // Haptic feedback nhẹ nhàng
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
        [feedback impactOccurred];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [[UITableViewCell alloc] init];
}

@end
