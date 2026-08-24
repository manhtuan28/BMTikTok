//
//  BMBaseSettingsViewController.h
//  BMTikTok Settings
//
//  Tác giả: Tuancute28 (Bùi Mạnh Tuấn)
//

#import <UIKit/UIKit.h>
#import "BMIManager.h"

@interface BMBaseSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

- (UITableViewCell *)createSwitchCellWithTitle:(NSString *)title
                                       Detail:(NSString *)detail
                                          Key:(NSString *)key;

- (UITableViewCell *)createNavigationCellWithTitle:(NSString *)title
                                           Detail:(NSString *)detail
                                             Icon:(NSString *)iconName
                                        IconColor:(UIColor *)iconColor;

@end
