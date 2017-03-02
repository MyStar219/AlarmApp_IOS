//
//  AlarmDB.m
//  teeptrak
//
//  Created by jackson on 2/10/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIAlertView.h>
#import "ABSQLiteDB.h"
#import "ABRecordset.h"
#import "AlarmDB.h"

static AlarmDB * _dbInstance;


@implementation AlarmDB{
    id <ABDatabase> m_db;
}

- (id) init{
    return [self initWithFile: nil];
}

- (id) initWithFile:(NSString *)filePathName{
    if (!(self = [super init])) return nil;
    
    _dbInstance = self;
    
    BOOL myPathIsDir;
    BOOL fileExists = [[NSFileManager defaultManager]
                       fileExistsAtPath: filePathName
                       isDirectory: &myPathIsDir];
    
    // backupDbPath allows for a pre-made database to be in the app. Good for testing
    NSString *backupDbPath = [[NSBundle mainBundle]
                              pathForResource:@"Alarm"
                              ofType:@"db"];
    BOOL copiedBackupDb = NO;
    if (backupDbPath != nil) {
        copiedBackupDb = [[NSFileManager defaultManager]
                          copyItemAtPath:backupDbPath
                          toPath:filePathName
                          error:nil];
    }
    
    // open SQLite db file
    m_db = [[ABSQLiteDB alloc] init];
    
    if(![m_db connect:filePathName]) {
        return nil;
    }
    
    if(!fileExists) {
        if(!backupDbPath || !copiedBackupDb)
            [self makeDB];
    }
    
    return self;
    
}


+ (AlarmDB *) dbInstance {
    if (!_dbInstance) {
        NSString *dbFilePath;
        NSArray *searchPaths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentFolderPath = searchPaths[0];
        dbFilePath = [documentFolderPath stringByAppendingPathComponent: @"AlarmDB.db"];
        
        AlarmDB* alarmDB = [[AlarmDB alloc] initWithFile:dbFilePath];
        if (!alarmDB) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"File Error" message:@"Unable to open database." delegate:nil cancelButtonTitle:@"Darn" otherButtonTitles:nil];
            [alert show];
        }
    }
    
    return _dbInstance;
}


- (void) close {
    [m_db close];
}

//read login information
- (LoginInfo *) getLoginInfo{
    id<ABRecordset> results = [m_db sqlSelect:@"select *from Login"];
    
    LoginInfo* log = [[LoginInfo alloc] init];
    if (![results eof])
    {
        log.m_username = [[results fieldWithName:@"username"] stringValue];
        log.m_password = [[results fieldWithName:@"password"] stringValue];
        log.m_bAutoLogin = [[results fieldWithName:@"autologin"] booleanValue];
    }
    
    return log;
}

//save login information
- (void) saveLoginInfo:(LoginInfo *)logInfo{
    NSString *sql = [NSString stringWithFormat:@"insert into Login(username, password, autologin) values('%@', '%@', %i);", logInfo.m_username, logInfo.m_password, logInfo.m_bAutoLogin];
    [m_db sqlExecute:@"delete from Login"];
    [m_db sqlExecute:sql];
}

//read out all alarm notifications
- (void) getAllNotifications:(NotificationResultsBlock) notificationBlock{
    
    NSMutableArray* reports = [[NSMutableArray alloc] init];
   
    //[m_db sqlExecute:@"delete from Notification"];
    
    id<ABRecordset> results = [m_db sqlSelect:@"select *from Notification order by id"];
    while (![results eof]) {
        Notification* notification = [[Notification alloc] init];
        notification.m_id = [[results fieldWithName:@"id"] intValue];
        notification.m_machine = [[results fieldWithName:@"machine"] stringValue];
        notification.m_performance = [[results fieldWithName:@"performance"] intValue];
        notification.m_speed = [[results fieldWithName:@"speed"] intValue];
        notification.m_readStatus = [[results fieldWithName:@"readStatus"] intValue];
        notification.m_date = [[results fieldWithName:@"date"] dateValue];
        notification.m_alarmLevel = [[results fieldWithName:@"alarmLevel"] intValue];
        notification.m_alarmName = [[results fieldWithName:@"alarmName"] stringValue];
        notification.m_message = [[results fieldWithName:@"message"] stringValue];
        notification.m_arrivalTime = [[results fieldWithName:@"arrivalTime"] dateValue];
        notification.m_wakeUp = [[results fieldWithName:@"wakeup"] booleanValue];
        [reports addObject:notification];
        [results moveNext];
    }
    
    notificationBlock(reports);
}

//read out all alarm notifications by flag.
- (void) getAllNotification:(BOOL) bRead block:(NotificationResultsBlock) notificationBlock{
    
    NSMutableArray* reports = [[NSMutableArray alloc] init];
    NSString* sql;
    
    if (bRead){
        //read out notifications woke up already
        sql = @"select * from Notification where wakeUp=true order by id";
        
    }else{
        //read out notifications don't woke up yet.
        sql = @"select * from Notification where wakeUp=false order by id";
    }
    

    id<ABRecordset> results = [m_db sqlSelect:sql];
    while (![results eof]) {
        Notification* notification = [[Notification alloc] init];
        notification.m_id = [[results fieldWithName:@"id"] intValue];
        notification.m_machine = [[results fieldWithName:@"machine"] stringValue];
        notification.m_performance = [[results fieldWithName:@"performance"] intValue];
        notification.m_speed = [[results fieldWithName:@"speed"] intValue];
        notification.m_readStatus = [[results fieldWithName:@"readStatus"] intValue];
        notification.m_date = [[results fieldWithName:@"date"] dateValue];
        notification.m_alarmLevel = [[results fieldWithName:@"alarmLevel"] intValue];
        notification.m_alarmName = [[results fieldWithName:@"alarmName"] stringValue];
        notification.m_message = [[results fieldWithName:@"message"] stringValue];
        notification.m_arrivalTime = [[results fieldWithName:@"arrivalTime"] dateValue];
        notification.m_wakeUp = [[results fieldWithName:@"wakeup"] booleanValue];
        [reports addObject:notification];
        [results moveNext];
    }
    
    notificationBlock(reports);
}

//add new alarm notification in table.
- (int) saveNotification:(Notification *)newAlarm{
    NSString *sql;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    //convet alarm date to string
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:newAlarm.m_date];
    
    NSString *strArrivalTime = [dateFormatter stringFromDate:[NSDate date]];
    
    sql = [NSString stringWithFormat:@"insert into Notification(machine, performance, speed, readStatus, date, alarmLevel, alarmName, message, arrivalTime, wakeup) values('%@', %i, %i, 0, '%@', %i, '%@', '%@', '%@', 0);", newAlarm.m_machine, (int)newAlarm.m_performance, (int)newAlarm.m_speed, strDate, (int)newAlarm.m_alarmLevel, newAlarm.m_alarmName, newAlarm.m_message, strArrivalTime];
    
    [m_db sqlExecute:sql];
    
    id<ABRecordset> result = [m_db sqlSelect:@"select max(id) as id from Notification;"];
    return [[result fieldAtIndex:0] intValue];
}

- (void) updateNotification:(Notification *)updateAlarm{
    NSString *sql = [NSString stringWithFormat:@"update Notification set readStatus=%i, wakeUp=%i where id=%i;", updateAlarm.m_readStatus, updateAlarm.m_wakeUp,(int)updateAlarm.m_id];
    [m_db sqlExecute:sql];
}


- (void) getAlarmSchedule:(NSInteger)nAlarmLevel Results:(AlarmScheduleResultsBlock)scheduleBlock{
    NSMutableArray* reports = [[NSMutableArray alloc] init];
    NSString* sql = [NSString stringWithFormat:@"select * from Configuration where level=%i order by id, day", (int)nAlarmLevel];

    id<ABRecordset> results = [m_db sqlSelect:sql];
    while (![results eof]) {
        AlarmSchedule* config = [[AlarmSchedule alloc] init];
        config.m_bActivity = [[results fieldWithName:@"activity"] booleanValue];
        config.m_day = [[results fieldWithName:@"day"] intValue];
        config.m_from = [[results fieldWithName:@"fromTime"] stringValue];
        config.m_to = [[results fieldWithName:@"toTime"] stringValue];
        config.m_level = [[results fieldWithName:@"level"] intValue];
        config.m_allDay = [[results fieldWithName:@"allDay"] booleanValue];

        [reports addObject:config];
        [results moveNext];
    }
    
    scheduleBlock(reports);
}

- (void) setAlarmSchedule:(AlarmSchedule *)schedule{
    NSString *sql = [NSString stringWithFormat:@"select * from configuration where (level=%i and day=%i);", (int)schedule.m_level, (int)schedule.m_day];
    
    id <ABRecordset> results;
    
    results = [m_db sqlSelect: sql];
    if ([results eof]) {
        sql = [NSString stringWithFormat:@"insert into Configuration(activity, day, fromTime, toTime, level, allDay) values(%i, %i,'%@', '%@', %i, %i);", schedule.m_bActivity, (int)schedule.m_day, schedule.m_from, schedule.m_to, (int)schedule.m_level, schedule.m_allDay];
    }
    else {
        sql = [NSString stringWithFormat:@"update Configuration set activity=%i, fromTime='%@', toTime='%@', allDay=%i where (level=%i and day=%i);", (int)schedule.m_bActivity,  schedule.m_from, schedule.m_to, (int)schedule.m_allDay, (int)schedule.m_level, (int)schedule.m_day];
    }
    
    [m_db sqlExecute:sql];

}

- (void) getAlarmConfig:(NSInteger)nLevel block:(AlarmConfigResultsBlock)configBlock
{
    AlarmConfig* reports = [[AlarmConfig alloc] init];
    NSString* sql;
    
    //read out setting parameters for a
    sql = [NSString  stringWithFormat:@"select * from Setting where level=%i", (int)nLevel];
    
    id<ABRecordset> results = [m_db sqlSelect:sql];
    
    if (![results eof])
    {
        reports.m_bSoundAlways = [[results fieldWithName:@"soundAlways"] booleanValue];
        reports.m_bVibration = [[results fieldWithName:@"vibration"] booleanValue];
        reports.m_bSystemNotification = [[results fieldWithName:@"systemNotification"] booleanValue];
    }
    else
    {
        reports.m_bSoundAlways = FALSE;
        reports.m_bVibration = FALSE;
        reports.m_bSystemNotification = FALSE;
    }
    
    configBlock(reports);
}

- (void) setAlarmConfig:(NSInteger)nLevel config:(AlarmConfig *)alarmCfg
{
    NSString *sql = [NSString stringWithFormat:@"select * from Setting where level=%i;", (int)nLevel];
    
    id <ABRecordset> results;
    
    results = [m_db sqlSelect: sql];
    if ([results eof]) {
        sql = [NSString stringWithFormat:@"insert into Setting(level, soundAlways, vibration, systemNotification) values(%i, %i, %i, %i);", (int)nLevel, alarmCfg.m_bSoundAlways, alarmCfg.m_bVibration, alarmCfg.m_bSystemNotification];
    }
    else {
        sql = [NSString stringWithFormat:@"update Setting set soundAlways=%i, vibration=%i, systemNotification=%i where level=%i;", alarmCfg.m_bSoundAlways, alarmCfg.m_bVibration, alarmCfg.m_bSystemNotification, (int)nLevel];
    }
    
    [m_db sqlExecute:sql];
}

#pragma mark - Utilities

- (void) makeDB {
    
    //login information table
    [m_db sqlExecute:@"create table Login(username text, password text, autologin boolean);"];
    
    // Notification message table
    [m_db sqlExecute:@"create table Notification(id integer primary key autoincrement, machine text, performance int, speed int, readStatus int, date date, alarmName text, message text, alarmLevel int, arrivalTime date, wakeUp boolean);"];
    
    // Alarm level 1/2
    [m_db sqlExecute:@"create table Configuration(id integer primary key autoincrement, activity boolean, day int, fromTime text, toTime text, level int, allDay boolean);"];

    // Setting parameters
    [m_db sqlExecute:@"create table Setting(id integer primary key autoincrement, level int, soundAlways boolean, vibration boolean, systemNotification boolean);"];

}

- (NSString*)escapeText:(NSString*)text {
    NSString* newValue = [text stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
    return newValue;
}

@end
