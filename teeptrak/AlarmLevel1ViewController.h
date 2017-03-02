//
//  AlarmLevel1ViewController.h
//  teeptrak
//
//  Created by jackson on 1/31/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlarmDB.h"
#import "AlarmSchedule.h"
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"

#define CustomLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

@interface AlarmLevel1ViewController : UIViewController <UIAlertViewDelegate>{
   
    NSMutableArray    *m_daySchedules;
    AlarmConfig      *m_alarmConfig;
    
    BOOL    m_bClose;
    __weak IBOutlet UILabel *fromLab;
    __weak IBOutlet UILabel *toLab;
    __weak IBOutlet UILabel *allDayLab;
    __weak IBOutlet UILabel *overViewLab;
    __weak IBOutlet UILabel *mondayLab;
    __weak IBOutlet UILabel *tuesdayLab;
    __weak IBOutlet UILabel *wednesdayLab;
    __weak IBOutlet UILabel *thursdayLab;
    __weak IBOutlet UILabel *fridayLab;
    __weak IBOutlet UILabel *saturdayLab;
    __weak IBOutlet UILabel *sundayLab;
    __weak IBOutlet UILabel *notificationSettingsLab;
    __weak IBOutlet UILabel *SoundAlwaysActiveLab;
    __weak IBOutlet UILabel *soundDetailLab;
    __weak IBOutlet UILabel *vibrationLab;
    __weak IBOutlet UILabel *vibrationDetailLab;
    __weak IBOutlet UILabel *systemNotificationLab;
    __weak IBOutlet UILabel *systemNotificationDetailLab;
}

@property (strong, nonatomic) IBOutlet UIButton *m_btnSoundAlways;
@property (strong, nonatomic) IBOutlet UIButton *m_btnVibration;
@property (strong, nonatomic) IBOutlet UIButton *m_btnSytemNotification;

//@property (strong, nonatomic) NSArray           *m_daySchedules;
//@property (strong, nonatomic) SettingParam      *m_settingParam;

- (BOOL) isValidTime:(NSInteger)iDay bIsFrom:(BOOL)bIsFrom timeValue:(id) value;

//- (void) alarmScheduleResultsBlock:(NSArray *) schedules;
//- (void) alarmConfigResultsBlock:(AlarmConfig*) config;

- (void) initTimeZoneControls;
- (void) initNotificationControls;

- (void)didTapLabelWithGesture:(UITapGestureRecognizer *)tapGesture;

- (IBAction)actionBackConfiguration:(id)sender;

@end
