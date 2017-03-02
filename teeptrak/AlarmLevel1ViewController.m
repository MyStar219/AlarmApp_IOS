//
//  AlarmLevel1ViewController.m
//  teeptrak
//
//  Created by jackson on 1/31/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import "AlarmLevel1ViewController.h"
#import "ActionSheetDatePicker.h"
#import "AlarmDB.h"
#import "Notification.h"
#import "Constant.h"

@interface AlarmLevel1ViewController ()

@end

@implementation AlarmLevel1ViewController

//@synthesize m_daySchedules = _m_daySchedules;
//@synthesize m_settingParam = _m_settingParam;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_bClose = FALSE;
    
    m_daySchedules = [GlobalPool sharedObject].m_alarmSchedules1;
    m_alarmConfig = [GlobalPool sharedObject].m_alarmCfg1;
    
    [self initTimeZoneControls];
    [self initNotificationControls];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [overViewLab setText:CustomLocalizedString(@"Time zone configuration - Alarm level 1", nil)];
    [fromLab setText:CustomLocalizedString(@"From", nil)];
    [toLab setText:CustomLocalizedString(@"To", nil)];
    [allDayLab setText:CustomLocalizedString(@"All day", nil)];
    [mondayLab setText:CustomLocalizedString(@"Monday", nil)];
    [tuesdayLab setText:CustomLocalizedString(@"Tuesday", nil)];
    [wednesdayLab setText:CustomLocalizedString(@"Wednesday", nil)];
    [thursdayLab setText:CustomLocalizedString(@"Thursday", nil)];
    [fridayLab setText:CustomLocalizedString(@"Friday", nil)];
    [saturdayLab setText:CustomLocalizedString(@"Saturday", nil)];
    [sundayLab setText:CustomLocalizedString(@"Sunday", nil)];
    [notificationSettingsLab setText:CustomLocalizedString(@"NOTIFICATION SETTINGS", nil)];
    [SoundAlwaysActiveLab setText:CustomLocalizedString(@"Sound always active", nil)];
    [soundDetailLab setText:CustomLocalizedString(@"Override phone settings. Sound notifications even if phone is on mute", nil)];
    [vibrationLab setText:CustomLocalizedString(@"Vibration", nil)];
    [vibrationDetailLab setText:CustomLocalizedString(@"Vibration on notification reception", nil)];
    [systemNotificationLab setText:CustomLocalizedString(@"System notification", nil)];
    [systemNotificationDetailLab setText:CustomLocalizedString(@"Will display a message above any activities on alert reception", nil)];
    
}

- (void) initTimeZoneControls
{
    //set controls of time zone and all day
    for (int iDay = MONDAY; iDay <= SUNDAY; iDay++)
    {
        AlarmSchedule *config = [m_daySchedules objectAtIndex:iDay];

        UILabel *lblDayName = (UILabel *)[self.view viewWithTag:iDay + 28];
        UILabel *lblFrom = (UILabel *)[self.view viewWithTag:iDay + 7];
        UILabel *lblTo = (UILabel *)[self.view viewWithTag:iDay + 14];
        UIButton *btnAllDay = (UIButton *)[self.view viewWithTag:iDay + 21];
        
        
        if (config.m_bActivity)
        {
            if (config.m_allDay)
            {
                lblFrom.text = @"--:--";
                lblTo.text = @"--:--";
                [btnAllDay setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
            }
            else
            {
                lblFrom.text = config.m_from;
                lblTo.text = config.m_to;
            }
            lblDayName.backgroundColor =[UIColor colorWithRed:226/255.0f green:240/255.0f blue:217/255.0f alpha:1.0];
        }
        else
        {
            lblFrom.text = @"HH:MM";
            lblTo.text = @"HH:MM";
            [btnAllDay setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
            lblDayName.backgroundColor = [UIColor colorWithRed:255/255.0f green:209/255.0f blue:209/255.0f alpha:1.0];
        }
        
        lblDayName.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelWithGesture:)];
        [lblDayName addGestureRecognizer:tapGesture];
        
        lblFrom.userInteractionEnabled = YES;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelWithGesture:)];
        [lblFrom addGestureRecognizer:tapGesture];

        lblTo.userInteractionEnabled = YES;
        tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLabelWithGesture:)];
        [lblTo addGestureRecognizer:tapGesture];
    }
}

- (void) initNotificationControls
{
    if (m_alarmConfig.m_bSoundAlways)
        [self.m_btnSoundAlways setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    else
        [self.m_btnSoundAlways setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];
    
    if (m_alarmConfig.m_bVibration)
        [self.m_btnVibration setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    else
        [self.m_btnVibration setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];

    if (m_alarmConfig.m_bSystemNotification)
        [self.m_btnSytemNotification setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    else
        [self.m_btnSytemNotification setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if (m_bClose){

        m_bClose = FALSE;
        
        //save time zone schedule
        for (int iDay = MONDAY; iDay <= SUNDAY; iDay++)
        {
            UILabel *lblFrom = (UILabel *)[self.view viewWithTag:iDay + 7];
            UILabel *lblTo = (UILabel *)[self.view viewWithTag:iDay + 14];
            AlarmSchedule *dayCfg = [m_daySchedules objectAtIndex:iDay];
            if (dayCfg.m_bActivity && !dayCfg.m_allDay)
            {
                dayCfg.m_from = lblFrom.text;
                dayCfg.m_to = lblTo.text;
            }
            
            [[AlarmDB dbInstance] setAlarmSchedule:dayCfg];
        }
        
        //save notification settings
        [[AlarmDB dbInstance] setAlarmConfig:ALARM_LEVEL1 config:m_alarmConfig];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

//receive all events of labels.
- (void)didTapLabelWithGesture:(UITapGestureRecognizer *)tapGesture {
    
    if (![tapGesture.view isKindOfClass:[UILabel class]]) return;
        
    //select day of the week.
    if (tapGesture.view.tag >= 28 && tapGesture.view.tag <= 34)
    {
        int iDay = (int)tapGesture.view.tag - 28;
        AlarmSchedule *dayCfg = [m_daySchedules objectAtIndex:iDay];
        UILabel *lblDayName = (UILabel *)tapGesture.view;
        UILabel *lblFrom = (UILabel *)[self.view viewWithTag:iDay + 7];
        UILabel *lblTo = (UILabel *)[self.view viewWithTag:iDay + 14];
        UIButton *btnAllDay = (UIButton *)[self.view viewWithTag:iDay + 21];

        if (dayCfg.m_bActivity)
        {
            dayCfg.m_bActivity = FALSE;
            lblFrom.text = @"HH:MM";
            lblTo.text = @"HH:MM";
            lblDayName.backgroundColor = [UIColor colorWithRed:255/255.0f green:209/255.0f blue:209/255.0f alpha:1.0];
            
            if (dayCfg.m_allDay)
                [btnAllDay setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        }
        else
        {
            dayCfg.m_bActivity = TRUE;
            lblDayName.backgroundColor =[UIColor colorWithRed:226/255.0f green:240/255.0f blue:217/255.0f alpha:1.0];

            if (dayCfg.m_allDay)
            {
                lblFrom.text = @"--:--";
                lblTo.text = @"--:--";
                [btnAllDay setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
            }
            else
            {
                lblFrom.text = dayCfg.m_from;
                lblTo.text = dayCfg.m_to;
            }
        }
        
        return;
    }
   
    //select From and To time.
    if (tapGesture.view.tag >= 7 && tapGesture.view.tag <= 23){
        
        NSString *timeString = ((UILabel *)tapGesture.view).text;//@"00:00";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        NSDate *dateFromString = [dateFormatter dateFromString:timeString];
 
        //
        NSString *stringTitle;
        BOOL bFrom = TRUE;
        int iDay = 0;
        if (tapGesture.view.tag >= 7 && tapGesture.view.tag <= 13)
        {
            stringTitle = @"Select Start Time";
            iDay = (int)tapGesture.view.tag - 7;
            bFrom = TRUE;
        }
        else
        {
            stringTitle = @"Select End Time";
            iDay = (int)tapGesture.view.tag - 14;
            bFrom = FALSE;
        }
        
        AlarmSchedule *dayCfg = [m_daySchedules objectAtIndex:iDay];
        if (!dayCfg.m_bActivity)
        {
            UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                            message:@"Activiate day to set time"
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert1 show];
            
            [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
            return;
        }
        
        if (dayCfg.m_allDay)
        {
            UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                            message:@"You have selected all day, Time is from 00:00 to 23:59 at the moment."
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:nil];
            [alert1 show];
            
            [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
            return;
        }
        
        ActionSheetDatePicker *actionSheetPicker = [[ActionSheetDatePicker alloc] initWithTitle:NSLocalizedString(stringTitle, nil)
                                                                                 datePickerMode:UIDatePickerModeTime
                                                                                   selectedDate:dateFromString
                                                                                      doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
                                                                                          
                                                                                          if ([self isValidTime:iDay bIsFrom:bFrom timeValue:selectedDate])
                                                                                          {
                                                                                              NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                                                              [dateFormatter setDateFormat:@"HH:mm"];
                                                                                              ((UILabel *)origin).text = [dateFormatter stringFromDate:selectedDate];
                                                                                          }
                                                                                       } cancelBlock:^(ActionSheetDatePicker *picker) {
                                                                                       } origin:tapGesture.view];
        
        [actionSheetPicker showActionSheetPicker];
        
    }
}

- (IBAction)actionBackConfiguration:(id)sender {
    m_bClose = TRUE;
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL) isValidTime:(NSInteger)iDay bIsFrom:(BOOL)bIsFrom timeValue:(id) value{

    AlarmSchedule *dayCfg = [m_daySchedules objectAtIndex:iDay];
    NSString *strErr;
    if (bIsFrom)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *toDate = [dateFormatter dateFromString:dayCfg.m_to];
        NSComparisonResult ret = [toDate compare:value];
        
        if (ret == NSOrderedDescending)
            return TRUE;
        else if (ret == NSOrderedSame)
            strErr = @"start time can't be equal to end time.";
        else
            strErr = @"start time can't be greater than end time.";

    }
    else
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"HH:mm"];
        
        NSDate *toFrom = [dateFormatter dateFromString:dayCfg.m_from];
        NSComparisonResult ret = [toFrom compare:value];
        
        if (ret == NSOrderedAscending)
            return TRUE;
        else if (ret == NSOrderedSame)
            strErr = @"start time can't be equal to end time.";
        else
            strErr = @"start time can't be greater than end time.";
        
    }

    UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                    message:strErr
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:nil];
    [alert1 show];
    
    [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];

    return FALSE;
}

-(void)dismiss:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:0 animated:YES];
}

/*===========================================================================================*/
//check/uncheck all day on Monday
- (IBAction)ActionAllMonday:(UIButton *)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:MONDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:MONDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:MONDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}


//check/uncheck all day on Tuesday
- (IBAction)ActionAllTuesday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:TUESDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:TUESDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:TUESDAY + 14];

    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//check/uncheck all day on Wednesday
- (IBAction)ActionAllWednesday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:WEDNESDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:WEDNESDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:WEDNESDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//check/uncheck all day on Thursday
- (IBAction)ActionAllThursday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:THURSDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:THURSDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:THURSDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//chech/uncheck all day on Friday
- (IBAction)ActionAllFriday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:FRIDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:FRIDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:FRIDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//check/uncheck all day on Saturday
- (IBAction)ActionAllSaturday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:SATURDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:SATURDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:SATURDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//check/uncheck all day on Sanday
- (IBAction)ActionAllSunday:(id)sender {
    AlarmSchedule *monCfg = [m_daySchedules objectAtIndex:SUNDAY];
    UILabel *lblFrom = (UILabel *)[self.view viewWithTag:SUNDAY + 7];
    UILabel *lblTo = (UILabel *)[self.view viewWithTag:SUNDAY + 14];
    
    if (!monCfg.m_bActivity)
    {
        UIAlertView *alert1 = [[UIAlertView alloc]initWithTitle:@"Timezone Error!"
                                                        message:@"Activiate day to set time"
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:nil];
        [alert1 show];
        
        [self performSelector:@selector(dismiss:) withObject:alert1 afterDelay:3.0];
        return;
    }
    
    if (monCfg.m_allDay){
        monCfg.m_allDay = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = monCfg.m_from;
        lblTo.text = monCfg.m_to;
    }
    else{
        monCfg.m_allDay = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32.png"] forState:UIControlStateNormal];
        
        lblFrom.text = @"--:--";
        lblTo.text = @"--:--";
    }
}

//check/uncheck always sound activity
- (IBAction)ActionAlwaysActivity:(id)sender {
    if (m_alarmConfig.m_bSoundAlways){
        m_alarmConfig.m_bSoundAlways = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];
    }
    else{
        m_alarmConfig.m_bSoundAlways = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    }
}

//check/uncheck vibration
- (IBAction)ActionVibration:(id)sender {
    if (m_alarmConfig.m_bVibration){
        m_alarmConfig.m_bVibration = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];
    }
    else{
        m_alarmConfig.m_bVibration = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    }
}

//check/uncheck system notification
- (IBAction)ActionSystemNotification:(id)sender {
    if (m_alarmConfig.m_bSystemNotification){
        m_alarmConfig.m_bSystemNotification = FALSE;
        [sender setImage:[UIImage imageNamed:@"uncheck32_clr.png"] forState:UIControlStateNormal];
    }
    else{
        m_alarmConfig.m_bSystemNotification = TRUE;
        [sender setImage:[UIImage imageNamed:@"check32_clr.png"] forState:UIControlStateNormal];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
