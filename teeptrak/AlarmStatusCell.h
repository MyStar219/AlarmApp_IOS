//
//  AlarmStatusCell.h
//  teeptrak
//
//  Created by jackson on 2/21/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmStatusCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *m_imgStatus;
@property (strong, nonatomic) IBOutlet UILabel *m_lblMachine;
@property (strong, nonatomic) IBOutlet UILabel *m_lblDate;
@property (strong, nonatomic) IBOutlet UILabel *m_lblLevel;

@end
