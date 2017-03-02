//
//  AlarmDB.h
//  teeptrak
//
//  Created by jackson on 2/10/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlarmSchedule.h"
#import "Notification.h"

typedef void(^NotificationResultsBlock)(NSArray* notifications);
typedef void(^AlarmScheduleResultsBlock)(NSArray* configurations);
typedef void(^AlarmConfigResultsBlock)(AlarmConfig* setting);

@interface AlarmDB : NSObject

+ (AlarmDB *) dbInstance;

- (id) initWithFile: (NSString *) filePathName;
- (void) close;

#pragma mark - Notification message

- (LoginInfo *) getLoginInfo;
- (void) saveLoginInfo:(LoginInfo *) logInfo;

- (void) getAllNotifications:(NotificationResultsBlock) notificationBlock;
- (void) getAllNotification:(BOOL) bRead block:(NotificationResultsBlock) notificationBlock;
- (int) saveNotification:(Notification *) newAlarm;
- (void) updateNotification:(Notification *) updateAlarm;

- (void) getAlarmSchedule:(NSInteger) nAlarmLevel Results:(AlarmScheduleResultsBlock) configurationBlock;
- (void) setAlarmSchedule:(AlarmSchedule *) configuration;


- (void) getAlarmConfig:(NSInteger) nLevel block:(AlarmConfigResultsBlock) settingBlock;
- (void) setAlarmConfig:(NSInteger) nLevel config:(AlarmConfig *) alarmCfg;

@end
