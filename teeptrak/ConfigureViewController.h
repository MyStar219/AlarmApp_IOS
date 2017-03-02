//
//  ConfigureViewController.h
//  teeptrak
//
//  Created by jackson on 1/30/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CHINESE @"zh-Hans"
#define ENGLISH @"en"
#define FRENCH @"fr"
#define AppLanguage @"appLanguage"

#define CustomLocalizedString(key, comment) \
[[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appLanguage"]] ofType:@"lproj"]] localizedStringForKey:(key) value:@"" table:nil]

typedef enum
{
    PICK_PRIORITY = 10,
    PICK_LANGUAGE
} PICKER_TYPE;

@interface ConfigureViewController : UIViewController{
    
    PICKER_TYPE eSelectedPickerType;
    int nSelPriorityIdx, nSelLangIdx;
    
    NSArray *arrayPriorityHourItems;
    NSArray *arrayLanguageItems;
    __weak IBOutlet UILabel *overLab;
    __weak IBOutlet UILabel *langSelectLab;
    __weak IBOutlet UIButton *languageLab;
}

@property (strong, nonatomic) IBOutlet UIButton *m_btnAlarmLevel1;
@property (strong, nonatomic) IBOutlet UIButton *m_btnAlarmLevel2;
@property (strong, nonatomic) IBOutlet UIButton *m_btnPrioritySchedule;
@property (strong, nonatomic) IBOutlet UIButton *m_btnMultiLang;
@property (strong, nonatomic) IBOutlet UIButton *m_btnCancel;

@property (nonatomic) int m_SelPeriodIdx;

- (IBAction)actionBackMain:(id)sender;
- (IBAction)actionCancel:(id)sender;

@end
