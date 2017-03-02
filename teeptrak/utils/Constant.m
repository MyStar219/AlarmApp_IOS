//
//  Constant.m
//  teeptrak
//
//  Created by jackson on 2/3/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIDevice.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#import "Constant.h"
#import "FCUUID.h"

@implementation Constant

@synthesize m_userApiToken = _m_userApiToken;
@synthesize m_deviceToken = _m_deviceToken;
@synthesize m_gcmSenderId = _m_gcmSenderId;


- (NSString *) getBluetoothName{
    return nil;
}

- (NSString *) getDeviceName{
    // Gets a string with the device model

    return [UIDevice currentDevice].name;
}

- (NSString *) generateDeviceId{
    
    return [FCUUID uuidForVendor];
}

- (NSString *) captialize:(NSString *)str{
    return nil;
}

@end

@implementation GlobalPool

@synthesize m_constant = _m_constant;
@synthesize m_bLoginSuccess = _m_bLoginSuccess;
@synthesize m_bStartTimer = _m_bStartTimer;
@synthesize m_workTimer = _m_workTimer;
@synthesize m_backgroundTask = _m_backgroundTask;
@synthesize m_beatingStartTime = _m_beatingStartTime;
@synthesize m_bEnalbeDisableTime = _m_bEnalbeDisableTime;
@synthesize m_disablePeriod = _m_disablePeriod;

@synthesize m_alarmSchedules1 = _m_alarmSchedules1;
@synthesize m_alarmCfg1 = _m_alarmCfg1;
@synthesize m_alarmSchedules2 = _m_alarmSchedules2;
@synthesize m_alarmCfg2 = _m_alarmCfg2;

@synthesize m_selAlarm = _m_selAlarm;

-(id) init
{
    if((self = [super init]))
    {
        self.m_constant = [[Constant alloc] init];
        self.m_bLoginSuccess = FALSE;
        self.m_bStartTimer = FALSE;
        self.m_bEnalbeDisableTime = FALSE;
        self.m_beatingStartTime = 0;
        self.m_disablePeriod = 24 * 60 * 60;
        self.m_workTimer = nil;
        self.m_backgroundTask = UIBackgroundTaskInvalid;
        
        self.m_alarmSchedules1 = [[NSMutableArray alloc] init];
        self.m_alarmSchedules2 = [[NSMutableArray alloc] init];
        
        self.m_alarmCfg1 = [[AlarmConfig alloc] init];
        self.m_alarmCfg2 = [[AlarmConfig alloc] init];
    }
    
    return self;
}

+ (GlobalPool *)sharedObject
{
    static GlobalPool *objUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        objUtility = [[GlobalPool alloc] init];
    });
    return objUtility;
}

@end