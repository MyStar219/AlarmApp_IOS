//
//  Configuration.h
//  teeptrak
//
//  Created by jackson on 2/10/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    MONDAY  = 0,
    TUESDAY,
    WEDNESDAY,
    THURSDAY,
    FRIDAY,
    SATURDAY,
    SUNDAY
}DAYS;

//login information interface
@interface LoginInfo : NSObject

@property (nonatomic, strong) NSString *m_username;
@property (nonatomic, strong) NSString *m_password;
@property (nonatomic) BOOL              m_bAutoLogin;

@end

//time zone schedule interface
@interface AlarmSchedule : NSObject

@property (nonatomic) BOOL m_bActivity;
@property (nonatomic) DAYS m_day;
@property (nonatomic, strong) NSString * m_from;
@property (nonatomic, strong) NSString * m_to;
@property (nonatomic, assign) NSDate * d_from;
@property (nonatomic, assign) NSDate * d_to;
@property (nonatomic) NSInteger m_level;
@property (nonatomic) BOOL m_allDay;

@end

//system notification interface
@interface AlarmConfig : NSObject

@property (nonatomic) BOOL  m_bSoundAlways;
@property (nonatomic) BOOL  m_bVibration;
@property (nonatomic) BOOL  m_bSystemNotification;

@end
