//
//  MainViewController.m
//  teeptrak
//
//  Created by jackson on 1/29/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <AudioToolbox/AudioServices.h>
#import <AVFoundation/AVAudioSession.h>

#import <MediaPlayer/MediaPlayer.h>

#import "MainViewController.h"
#import "AlarmStatusCell.h"

#import "Constant.h"
#import "ConfigureViewController.h"
#import "AlarmDB.h"

@interface MainViewController ()
@end

@implementation MainViewController
@synthesize m_alarmMsgList = _m_alarmMsgList;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.m_notificationTblView.delegate = self;
    self.m_notificationTblView.dataSource = self;
    
    m_bClose = FALSE;
    self.m_lblDisableTime.text = @"";
    
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"alert" ofType:@"mp3"]];
    self.m_player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //initialize alarm msg list
    self.m_alarmMsgList = [[NSMutableArray alloc] init];
    
    //load all configuration information.
    [[AlarmDB dbInstance] getAlarmSchedule:ALARM_LEVEL1
                                            Results:^(NSArray *lstConfigs){
                                                [self initSchedules:ALARM_LEVEL1 inAlarmSchedules:lstConfigs outAlarmSchedules:[GlobalPool sharedObject].m_alarmSchedules1];
                                            }];
    
    [[AlarmDB dbInstance] getAlarmSchedule:ALARM_LEVEL2
                                             Results:^(NSArray *lstConfigs){
                                                 [self initSchedules:ALARM_LEVEL2 inAlarmSchedules:lstConfigs outAlarmSchedules:[GlobalPool sharedObject].m_alarmSchedules2];
                                             }];
    
    [[AlarmDB dbInstance] getAlarmConfig:ALARM_LEVEL1 block:^(AlarmConfig *config) {
        [GlobalPool sharedObject].m_alarmCfg1 = config;
    }];

    [[AlarmDB dbInstance] getAlarmConfig:ALARM_LEVEL2 block:^(AlarmConfig *config) {
        [GlobalPool sharedObject].m_alarmCfg2 = config;
    }];
    
    [[AlarmDB dbInstance] getAllNotifications:^(NSArray *lstAlarms) {
        for (int iAlarm = 0; iAlarm < [lstAlarms count]; iAlarm++)
        {
            [self.m_alarmMsgList addObject:[lstAlarms objectAtIndex:iAlarm]];
        }
        
//        NSString *sOutput = @"";
//        for (Notification *alarm in self.m_alarmMsgList) {
//            NSString *dateString = [NSDateFormatter localizedStringFromDate:alarm.m_date
//                                                                  dateStyle:NSDateFormatterShortStyle
//                                                                  timeStyle:NSDateFormatterFullStyle];
//            sOutput = [NSString stringWithFormat:@"%@%@", sOutput, dateString];
//        }
//        self.lblLog.text = sOutput;
    }];
    
    //put test data to alarm msg list
//    Notification *alarm = [[Notification alloc] init];
//    alarm.m_machine = @"Machine 1";
//    alarm.m_alarmName = @"Alarm 1";
//    alarm.m_date = [NSDate date];
//    alarm.m_alarmLevel = 0;
//    
//    [self.m_alarmMsgList addObject:alarm];
    
    /*Make sure our table view resizes correctly*/
    self.m_notificationTblView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.m_notificationTblView];
  
    NSLog(@"register notification center");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveAlarmNotification:)
                                                 name:@"AlarmNotification"
                                               object:nil];
    
    [self startBackgroundTask];
}

- (void)startBackgroundTask{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) { //Check if our iOS version supports multitasking I.E iOS 4
        if ([[UIDevice currentDevice] isMultitaskingSupported]) { //Check if device supports mulitasking
            UIApplication *application = [UIApplication sharedApplication]; //Get the shared application instance
            
            background_task = [application beginBackgroundTaskWithExpirationHandler: ^ {
                [application endBackgroundTask: background_task]; //Tell the system that we are done with the tasks
                background_task = UIBackgroundTaskInvalid; //Set the task to be invalid
                
                //System will be shutting down the app at any point in time now
            }];
            
            //Background tasks require you to use asyncrous tasks
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                //Perform your tasks that your application requires
                
                NSLog(@"\n\nRunning in the background!\n\n");
                
                [GlobalPool sharedObject].m_bStartTimer = TRUE;
                
                while (true) {
                    [self backgroundWorkThread];
                    [NSThread sleepForTimeInterval:1.0];
                }

            });
        }
    }
    
}

- (void)startTimer{
    [GlobalPool sharedObject].m_workTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self  selector:@selector(backgroundWorkThread)  userInfo:nil repeats:YES];
    [GlobalPool sharedObject].m_bStartTimer = TRUE;
}

- (void)viewWillAppear:(BOOL)animated{
}

- (void) viewWillDisappear:(BOOL)animated{
    
    if (m_bClose){
        
        UIApplication  *app = [UIApplication sharedApplication];
        [app endBackgroundTask: [GlobalPool sharedObject].m_backgroundTask];
        [GlobalPool sharedObject].m_backgroundTask = UIBackgroundTaskInvalid;
        
        [[GlobalPool sharedObject].m_workTimer invalidate];
        m_bClose = FALSE;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void) initSchedules:(ALARM_LEVEL) level inAlarmSchedules:(NSArray *) inSchedules outAlarmSchedules:(NSMutableArray *) outSchedules;
{
    //initialize configuration for each day by default parameters
    for (int iDay = MONDAY; iDay <= SUNDAY; iDay++)
    {
        AlarmSchedule *schedule = [[AlarmSchedule alloc] init];
        
        schedule.m_bActivity = TRUE;
        schedule.m_allDay = FALSE;
        schedule.m_level = level;
        schedule.m_day = iDay;
        schedule.m_from = @"09:00";
        schedule.m_to = @"21:00";
        
        if (iDay == SATURDAY || iDay == SUNDAY)
        {
            schedule.m_bActivity = FALSE;
        }
        
        [outSchedules addObject:schedule];
    }
    
    for (AlarmSchedule *obj in inSchedules)
    {
        [outSchedules setObject:obj atIndexedSubscript:obj.m_day];
    }
}

//
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat result = 20.0f;
    if ([tableView isEqual:self.m_notificationTblView]){
        result = 40.0f;
    }
    return result;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{

    return [self.m_alarmMsgList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlarmStatusCell *cell = nil;
    
    if ([tableView isEqual:self.m_notificationTblView]){
        
        //static NSString *MyCellIdentifier = @"SimpleCell";
        static NSString *MyCellIdentifier = @"AlarmStatusCell";
        /*We will try to retrieve on existing cell with the given indentifier*/
        cell = (AlarmStatusCell *)[tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
        
        if (cell == nil){
            /*If a cell with the given identifier does not exist, we will create the cell with the identifier
             and hand it to the table view*/
            cell = [[AlarmStatusCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:MyCellIdentifier];
        }
       
        NSInteger iAlarm = [self.m_alarmMsgList count] - indexPath.row - 1;
        Notification *alarm = [self.m_alarmMsgList objectAtIndex:iAlarm];
        
        if (alarm.m_readStatus == ALARM_ARRIVAL)
            cell.m_imgStatus.image = [UIImage imageNamed:@"orange.png"];
        else if (alarm.m_readStatus == ALARM_SCHEDULE)
            cell.m_imgStatus.image = [UIImage imageNamed:@"red.png"];
        else
            cell.m_imgStatus.image = [UIImage imageNamed:@"grey.png"];
        
        cell.m_lblMachine.text = alarm.m_machine;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        cell.m_lblDate.text = [dateFormatter stringFromDate:alarm.m_date];
        
        if (alarm.m_alarmLevel == 0)
            cell.m_lblLevel.text = @"P";
        else if (alarm.m_alarmLevel == 1)
            cell.m_lblLevel.text = @"1";
        else
            cell.m_lblLevel.text = @"2";
        
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView isEqual:self.m_notificationTblView]){
        NSLog(@"%@",
              [NSString stringWithFormat:@"Cell %ld in Section %ld is selected",
               (long)indexPath.row, (long)indexPath.section]);

        //update alarm status to grey.
        NSInteger iAlarm = [self.m_alarmMsgList count] - indexPath.row - 1;
        Notification *curAlarm = [self.m_alarmMsgList objectAtIndex:iAlarm];
        curAlarm.m_readStatus = ALARM_READ;
        //[self.m_alarmMsgList setObject:curAlarm atIndexedSubscript:indexPath.row]
        
        //reflect this status to database.
        [[AlarmDB dbInstance] updateNotification:curAlarm];
        [GlobalPool sharedObject].m_selAlarm = curAlarm;
        
        [self performSegueWithIdentifier:@"goDetail" sender:self];
        [self.m_notificationTblView beginUpdates];
        [self.m_notificationTblView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
        [self.m_notificationTblView endUpdates];
    }

}


// background work thread
- (void) backgroundWorkThread{
//    NSLog(@"Background process is Start(EnterBackground)!");
    
    if ([GlobalPool sharedObject].m_bEnalbeDisableTime){
        [self updateDisableTime];
    } else {
        [self clearDisableTimeLabel];
        [self checkAlarmSchedule];
    }
}

//do alarm schedule in background
- (void) performBackgroundSchedule{
    
}
//checking alarm schedule time zone
- (void) checkAlarmSchedule{
    NSLog(@"checking alarm schedule");
    

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekDay = (int)[comps weekday];
    
    weekDay = (weekDay + 7 - 2) % 7;

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    NSString *curDate = [dateFormatter stringFromDate:[NSDate date]];
    
    for (Notification *obj in self.m_alarmMsgList)
    {
        BOOL bMust = FALSE;
        AlarmSchedule *schedule = nil;
        AlarmConfig *config = nil;
        
        if (obj.m_readStatus != ALARM_ARRIVAL) continue;
        
        if (obj.m_alarmLevel == 0)//Priority
        {
            obj.m_readStatus = ALARM_SCHEDULE;
            [[AlarmDB dbInstance] updateNotification:obj];
            [self.m_notificationTblView clearsContextBeforeDrawing];
            [self.m_notificationTblView reloadData];
            [self playSound];

        }
        else
        {
            if (obj.m_alarmLevel == 1)
            {
                schedule = [[GlobalPool sharedObject].m_alarmSchedules1 objectAtIndex:weekDay];
                config = [GlobalPool sharedObject].m_alarmCfg1;
            }
            else
            {
                schedule = [[GlobalPool sharedObject].m_alarmSchedules2 objectAtIndex:weekDay];
                config = [GlobalPool sharedObject].m_alarmCfg2;
            }
        
            // check activity
            if (!schedule.m_bActivity) continue;
        
            //check all day
            if (schedule.m_allDay)
            {
                bMust =TRUE;
                obj.m_readStatus = ALARM_SCHEDULE;
            }
            else
            {
                NSComparisonResult result1, result2;
                
                result1 = [curDate compare:schedule.m_from];
                result2 = [curDate compare:schedule.m_to];
                
                if((result1 == NSOrderedSame || result1 == NSOrderedDescending) && (result2 == NSOrderedSame || result2 == NSOrderedAscending)){
                    bMust =TRUE;
                    obj.m_readStatus = ALARM_SCHEDULE;
                }
            }
            
            if (obj.m_readStatus == ALARM_ARRIVAL) continue;
            
            [[AlarmDB dbInstance] updateNotification:obj];
            [self.m_notificationTblView clearsContextBeforeDrawing];
            [self.m_notificationTblView reloadData];
            if (bMust)
            {
                if (config.m_bSoundAlways)
                {
                    [self playSound];
                }
                
                if (config.m_bVibration)
                    [self vibrateDevice];
                
                if (config.m_bSystemNotification)
                {
                    [self showNotificatoin];
                }
                
            }
            
        }
    }

}

- (void)playSound{
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    float vol = [musicPlayer volume];
    if (vol == 0.0f)
        [musicPlayer setVolume:1.0f];
    
    [self.m_player prepareToPlay];
    [self.m_player play];
    
    [musicPlayer setVolume:vol];
}

- (void)vibrateDevice{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)showNotificatoin {

}

//update disabled time
- (void) updateDisableTime{
    /*
    if (![GlobalPool sharedObject].m_bEnalbeDisableTime)
    {
        if ([self.m_lblDisableTime.text compare:@""] != NSOrderedSame)
            self.m_lblDisableTime.text = @"";
        return;
    }
    */
    UIViewController* curViewCon = self.navigationController.visibleViewController;
    
    NSTimeInterval disabledTime = [[NSDate date] timeIntervalSince1970] - [GlobalPool sharedObject].m_beatingStartTime;
    if ((int)disabledTime < [GlobalPool sharedObject].m_disablePeriod)
    {
        disabledTime = [GlobalPool sharedObject].m_disablePeriod - disabledTime;
       
        if ([curViewCon isKindOfClass:[MainViewController class]]){
            NSString *strTime = [NSString stringWithFormat:@"All alarms disabled for %02i:%02i:%02i", ((int)disabledTime)/(60*60), (((int)disabledTime)/60)%60, ((int)disabledTime)%60];

            self.m_lblDisableTime.text = strTime;
        }
        else if ([curViewCon isKindOfClass:[ConfigureViewController class]]){
            NSString *strTime = [NSString stringWithFormat:@"%02i:%02i:%02i", ((int)disabledTime)/(60*60), (((int)disabledTime)/60)%60, ((int)disabledTime)%60];

            [((ConfigureViewController *)curViewCon).m_btnPrioritySchedule setTitle:strTime
                                                                           forState:UIControlStateNormal];
        }
        
    }
    else
    {
        /*
        if ([GlobalPool sharedObject].m_bEnalbeDisableTime)
        {
            //reset label tesxt
            self.m_lblDisableTime.text = @"";
            [((ConfigureViewController *)curViewCon).m_btnPrioritySchedule setTitle:CustomLocalizedString(@"Disable all alarms", nil)
                                                                           forState:UIControlStateNormal];
        }
        [GlobalPool sharedObject].m_bEnalbeDisableTime = FALSE;
         */
        [self disableTimeIntervalReachEndInterval];
    }
}

- (void) disableTimeIntervalReachEndInterval {
    UIViewController* curViewCon = self.navigationController.visibleViewController;
    
    if ([GlobalPool sharedObject].m_bEnalbeDisableTime)
    {
        //reset label tesxt
        self.m_lblDisableTime.text = @"";
        [((ConfigureViewController *)curViewCon).m_btnPrioritySchedule setTitle:CustomLocalizedString(@"Disable all alarms", nil)
                                                                       forState:UIControlStateNormal];
    }
    [GlobalPool sharedObject].m_bEnalbeDisableTime = FALSE;
}

- (void) clearDisableTimeLabel {
    if ([self.m_lblDisableTime.text compare:@""] != NSOrderedSame){
        self.m_lblDisableTime.text = @"";
    }
}

- (void) receiveAlarmNotification:(NSNotification *)notification{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString:@"AlarmNotification"]){
        NSLog (@"Successfully received the alarm notification!");
        
        [self.m_alarmMsgList addObject:notification.object];
        
        [self.m_notificationTblView reloadData];
        [self.m_notificationTblView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
         atScrollPosition:UITableViewScrollPositionTop
         animated:YES
         ];
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

- (IBAction)actionBackLogin:(id)sender {
    m_bClose = TRUE;
    [self.navigationController popViewControllerAnimated:YES];
}
@end
