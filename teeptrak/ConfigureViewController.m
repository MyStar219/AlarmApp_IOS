//
//  ConfigureViewController.m
//  teeptrak
//
//  Created by jackson on 1/30/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import "ConfigureViewController.h"
#import "ActionSheetStringPicker.h"
#import "Constant.h"

@interface ConfigureViewController ()
{
    NSArray *arrayLanguageItems1;
}
@end

@implementation ConfigureViewController
@synthesize m_SelPeriodIdx = _m_SelPeriodIdx;

-(void)viewWillAppear:(BOOL)animated
{
    arrayPriorityHourItems = @[CustomLocalizedString(@"Disable all alarms", nil), CustomLocalizedString(@"1h", nil), CustomLocalizedString(@"2h",nil), CustomLocalizedString(@"4h",nil), CustomLocalizedString(@"24h", nil)];
    arrayLanguageItems = @[CustomLocalizedString(@"English",nil), CustomLocalizedString(@"French", nil), CustomLocalizedString(@"Chinese",nil)];
    arrayLanguageItems1 = @[@"en", @"fr", @"zh-Hans"];
    [_m_btnAlarmLevel1 setTitle:CustomLocalizedString(@"Alarm level 1", nil) forState:UIControlStateNormal];
    [_m_btnAlarmLevel2 setTitle:CustomLocalizedString(@"Alarm level 2", nil) forState:UIControlStateNormal];
    [self.m_btnPrioritySchedule setTitle:[arrayPriorityHourItems objectAtIndex:nSelPriorityIdx] forState:UIControlStateNormal];
    [langSelectLab setText:CustomLocalizedString(@"Language selection", nil)];
    [self.m_btnMultiLang setTitle:[arrayLanguageItems objectAtIndex:nSelLangIdx] forState:UIControlStateNormal];
    [overLab setText:CustomLocalizedString(@"Properties and time zone configuration", nil)];
    [_m_btnCancel setTitle:CustomLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
   
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    nSelLangIdx = [[[NSUserDefaults standardUserDefaults] objectForKey:@"languageIdx"] intValue];
    nSelPriorityIdx = [[[NSUserDefaults standardUserDefaults] objectForKey:@"priorityIndex"] intValue];;
    
//    arrayPriorityHourItems = @[@"Disable all alarms", @"1h", @"2h", @"4h", @"24h"];
//    arrayLanguageItems = @[@"English", @"French", @"Chinese"];
    
    if ([GlobalPool sharedObject].m_bEnalbeDisableTime)
    {
        [self.m_btnPrioritySchedule setTitle:@"" forState:UIControlStateNormal];
    }
    else
    {
        [self.m_btnPrioritySchedule setTitle:CustomLocalizedString(@"Disable all alarms", nil) forState:UIControlStateNormal];
    }
    
    [[self.m_btnAlarmLevel1 layer] setBorderWidth:2.0f];
    [[self.m_btnAlarmLevel1 layer] setBorderColor:[UIColor lightGrayColor].CGColor];

    [[self.m_btnAlarmLevel2 layer] setBorderWidth:2.0f];
    [[self.m_btnAlarmLevel2 layer] setBorderColor:[UIColor lightGrayColor].CGColor];

    //set priority border
    [[self.m_btnPrioritySchedule layer] setBorderWidth:2.0f];
    [[self.m_btnPrioritySchedule layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    
    //set multi-language border
    [[self.m_btnMultiLang layer] setBorderWidth:2.0f];
    [[self.m_btnMultiLang layer] setBorderColor:[UIColor lightGrayColor].CGColor];
    
    if ([GlobalPool sharedObject].m_bEnalbeDisableTime == TRUE){
        [[self.m_btnCancel layer] setBorderWidth:2.0f];
        [[self.m_btnCancel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [[self.m_btnCancel layer] setBackgroundColor:[UIColor darkGrayColor].CGColor];
        [self.m_btnPrioritySchedule setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.m_btnCancel setEnabled:YES];
    }
    else{
        [[self.m_btnCancel layer] setBorderWidth:2.0f];
        [[self.m_btnCancel layer] setBorderColor:[UIColor lightGrayColor].CGColor];
        [[self.m_btnCancel layer] setBackgroundColor:[UIColor lightGrayColor].CGColor];
        [self.m_btnPrioritySchedule setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.m_btnCancel setEnabled:NO];
    }
    


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Priority Alarm period

- (IBAction)changePriorityAlarmHour:(id)sender {
    
    eSelectedPickerType = PICK_PRIORITY;
    nSelPriorityIdx = self.m_SelPeriodIdx;
    
    [ActionSheetStringPicker showPickerWithTitle:CustomLocalizedString(@"Disable all alarm period", nil) rows:arrayPriorityHourItems
                                initialSelection:nSelPriorityIdx > 0 ? nSelPriorityIdx : 0 target:self
                                   successAction:@selector(itemWasSelected:element:)
                                    cancelAction:@selector(actionPickerCancelled:) origin:sender];
}

- (IBAction)changeMultiLanguage:(id)sender {
    
    eSelectedPickerType = PICK_LANGUAGE;
    [ActionSheetStringPicker showPickerWithTitle:CustomLocalizedString(@"Language selection", nil) rows:arrayLanguageItems
                                initialSelection:nSelLangIdx > 0 ? nSelLangIdx : 0 target:self
                                   successAction:@selector(itemWasSelected:element:)
                                    cancelAction:@selector(actionPickerCancelled:) origin:sender];
    
}

- (void)itemWasSelected:(NSNumber *)selectedIndex element:(id)element {
    int nSelectedIdx = (int)[selectedIndex integerValue];
    
    switch (eSelectedPickerType) {
        case PICK_PRIORITY:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nSelectedIdx] forKey:@"priorityIndex"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            nSelPriorityIdx = nSelectedIdx;
            break;
        }
            
        case PICK_LANGUAGE:
        {
            nSelLangIdx = nSelectedIdx;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:nSelLangIdx] forKey:@"languageIdx"];
            [[NSUserDefaults standardUserDefaults] setObject:[arrayLanguageItems1 objectAtIndex:nSelLangIdx] forKey:AppLanguage];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self viewWillAppear:YES];
            break;
        }
            
        default:
            break;
    }
    
    //disable and enable cancel button
    self.m_SelPeriodIdx = nSelPriorityIdx;
    
    if (nSelPriorityIdx == 0){
        [self.m_btnCancel setEnabled:NO];
        [self.m_btnPrioritySchedule setEnabled:YES];
        
        [[self.m_btnCancel layer] setBackgroundColor:[UIColor lightGrayColor].CGColor];
        [self.m_btnPrioritySchedule setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

        [GlobalPool sharedObject].m_bEnalbeDisableTime = FALSE;

        [self.m_btnPrioritySchedule setTitle:[arrayPriorityHourItems objectAtIndex:nSelPriorityIdx] forState:UIControlStateNormal];
    }
    else {
        [self.m_btnCancel setEnabled:YES];
        [self.m_btnPrioritySchedule setEnabled:NO];
        
        [[self.m_btnCancel
          layer] setBackgroundColor:[UIColor darkGrayColor].CGColor];
        [self.m_btnPrioritySchedule setTitleColor:[UIColor redColor] forState:UIControlStateNormal];

        [GlobalPool sharedObject].m_beatingStartTime = [[NSDate date] timeIntervalSince1970];
        [GlobalPool sharedObject].m_bEnalbeDisableTime = TRUE;
        
        if (nSelPriorityIdx == 1)
            [GlobalPool sharedObject].m_disablePeriod = 60 * 60;
        else if (nSelPriorityIdx == 2)
            [GlobalPool sharedObject].m_disablePeriod = 2 * 60 * 60;
        else if (nSelPriorityIdx == 3)
            [GlobalPool sharedObject].m_disablePeriod = 4 * 60 * 60;
        else
            [GlobalPool sharedObject].m_disablePeriod = 24 * 60 * 60;
    }
    
    [self.m_btnMultiLang setTitle:[arrayLanguageItems objectAtIndex:nSelLangIdx] forState:UIControlStateNormal];
   
}

- (void)actionPickerCancelled:(id)sender {
    NSLog(@"Delegate has been informed that ActionSheetPicker was cancelled");
}

- (IBAction)actionCancel:(id)sender {
  
    [GlobalPool sharedObject].m_bEnalbeDisableTime = FALSE;

    [self.m_btnPrioritySchedule setEnabled:YES];
    [self.m_btnPrioritySchedule setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.m_btnPrioritySchedule setTitle:CustomLocalizedString(@"Disable all alarms", nil) forState:UIControlStateNormal];
    
    [self.m_btnCancel setEnabled:NO];
    [[self.m_btnCancel layer] setBackgroundColor:[UIColor lightGrayColor].CGColor];
    
    self.m_SelPeriodIdx = 0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBackMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
