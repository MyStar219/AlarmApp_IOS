//
//  Constant.h
//  teeptrak
//
//  Created by jackson on 2/3/16.
//  Copyright © 2016 steve. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIApplication.h>
#import "AlarmSchedule.h"
#import "Notification.h"

@interface Constant : NSObject

//shared preference
@property (nonatomic, strong) NSString *m_userApiToken;
@property (nonatomic, strong) NSString *m_deviceToken;

//GCM
@property (nonatomic, strong) NSString *m_gcmSenderId;

- (NSString *) generateDeviceId;
- (NSString *) getDeviceName;
- (NSString *) getBluetoothName;
- (NSString *) captialize:(NSString *) str;

@end

@interface GlobalPool : NSObject
@property (nonatomic, strong) Constant *m_constant;

@property (nonatomic) BOOL  m_bLoginSuccess;

@property (nonatomic) BOOL m_bStartTimer;
@property (nonatomic) NSInteger m_disablePeriod;
@property (nonatomic) BOOL m_bEnalbeDisableTime;

@property (nonatomic) NSTimeInterval m_beatingStartTime;
@property (nonatomic) UIBackgroundTaskIdentifier m_backgroundTask;
@property (strong, nonatomic) NSTimer *m_workTimer;

@property (strong, nonatomic) NSMutableArray *m_alarmSchedules1;
@property (strong, nonatomic) AlarmConfig *m_alarmCfg1;

@property (strong, nonatomic) NSMutableArray *m_alarmSchedules2;
@property (strong, nonatomic) AlarmConfig *m_alarmCfg2;

@property (strong, nonatomic) Notification *m_selAlarm;
-(id) init;
+ (GlobalPool *) sharedObject;

@end

#endif /* Constant_h */

