//
//  MainViewController.h
//  teeptrak
//
//  Created by jackson on 1/29/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVAudioPlayer.h>

#import "Notification.h"
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"

#define CustomLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

@interface MainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>{
    BOOL    m_bClose;
    SystemSoundID mySound;
    __block UIBackgroundTaskIdentifier background_task; //Create a task object
}

@property (strong, nonatomic) IBOutlet UITableView *m_notificationTblView;
@property (strong, nonatomic) IBOutlet UIButton *m_btnLogout;
@property (strong, nonatomic) IBOutlet UIButton *m_btnConfig;
@property (strong, nonatomic) IBOutlet UIImageView *m_imgLogo;
@property (strong, nonatomic) IBOutlet UILabel *m_lblDisableTime;
@property (weak, nonatomic) IBOutlet UILabel *lblLog;

- (IBAction)actionBackLogin:(id)sender;

//store notification messages
@property (strong, nonatomic) NSMutableArray *m_alarmMsgList;
@property (nonatomic, strong) AVAudioPlayer *m_player;

//background work thread
- (void) backgroundWorkThread;
- (void) performBackgroundSchedule;

//check alarm schedule time zone and display disabled time on screen.
- (void) checkAlarmSchedule;
- (void) updateDisableTime;

- (void) receiveAlarmNotification:(NSNotification *) notification;
@end
