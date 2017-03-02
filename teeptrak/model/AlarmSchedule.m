//
//  Configuration.m
//  teeptrak
//
//  Created by jackson on 2/10/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import "AlarmSchedule.h"

//
@implementation LoginInfo

@synthesize m_username = _m_username;
@synthesize m_password = _m_password;
@synthesize m_bAutoLogin = _m_bAutoLogin;

@end

//
@implementation AlarmSchedule

@synthesize m_bActivity = _m_bActivity;
@synthesize m_day = _m_day;
@synthesize m_from = _m_from;
@synthesize m_to = _m_to;
@synthesize d_from = _d_from;
@synthesize d_to = _d_to;
@synthesize m_level = _m_level;
@synthesize m_allDay = _m_allDay;

@end

//
@implementation AlarmConfig

@synthesize m_bSoundAlways = _m_bSoundAlways;
@synthesize m_bVibration = _m_bVibration;
@synthesize m_bSystemNotification = _m_bSystemNotification;

@end
