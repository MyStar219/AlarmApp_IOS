//
//  ViewController.h
//  teeptrak
//
//  Created by jackson on 1/25/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WsApiUser.h"
#import "AlarmSchedule.h"
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"

#define CustomLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

@interface LoginViewController : UIViewController{
    LoginInfo *m_logInfo;
    IBOutlet UILabel *logInLab;
    IBOutlet UILabel *passwordLab;
    IBOutlet UIButton *goBtn;
}
@property (strong, nonatomic) IBOutlet UITextField *m_txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *m_txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *m_btnAutoLogin;
@property (strong, nonatomic) IBOutlet UIButton *ActionLogin;

@property (strong, nonatomic) WsApiUser *m_wsUser;
@end

