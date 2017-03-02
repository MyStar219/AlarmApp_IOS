//
//  Notification.h
//  teeptrak
//
//  Created by jackson on 1/30/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ALARM_ARRIVAL = 0,
    ALARM_SCHEDULE,
    ALARM_READ
}ALARM_STATUS;

typedef enum{
    ALARM_RPIORITY = 0,
    ALARM_LEVEL1,
    ALARM_LEVEL2
}ALARM_LEVEL;

@interface Notification : NSObject

//notification message body
@property (nonatomic) NSInteger             m_id;
@property (nonatomic, strong) NSString *    m_machine;
@property (nonatomic) NSInteger             m_performance;
@property (nonatomic) NSInteger             m_speed;
@property (nonatomic) ALARM_STATUS          m_readStatus;
@property (nonatomic, strong) NSDate *      m_date;
@property (nonatomic) NSInteger             m_alarmLevel;
@property (nonatomic, strong) NSString *    m_alarmName;
@property (nonatomic, strong) NSString *    m_message;

//need to schedule.
@property (nonatomic, strong) NSDate*       m_arrivalTime;
//wake up on schedule time
@property (nonatomic) BOOL                  m_wakeUp;

@end
