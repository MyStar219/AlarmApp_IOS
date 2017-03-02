//
//  AppDelegate.h
//  teeptrak
//
//  Created by jackson on 1/25/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNotificationLanguageChanged @"kNotificationLanguageChanged"
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"
#define LanguageFileName @"Localizable"
//#define LocationLanguage(key) NSLocalizedStringFromTable(str, LanguageFileName, nil)
#define LocationLanguage(key) [[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    BOOL    m_bTapNotification;
}

@property (nonatomic, strong) NSString* m_strDeviceToken;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) bool m_bReceivedNotification;



@end

