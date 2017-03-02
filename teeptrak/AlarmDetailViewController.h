//
//  AlarmDetailViewController.h
//  teeptrak
//
//  Created by jackson on 2/1/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"

#define CustomLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

@interface AlarmDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    
    IBOutlet UILabel *alarmdetailLab;
}
@property (strong, nonatomic) IBOutlet UITableView *m_tblAlarmDetail;

- (IBAction)actionBackMain:(id)sender;

@end
