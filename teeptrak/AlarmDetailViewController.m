//
//  AlarmDetailViewController.m
//  teeptrak
//
//  Created by jackson on 2/1/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import "AlarmDetailViewController.h"
#include "Constant.h"

@interface AlarmDetailViewController ()

@end

@implementation AlarmDetailViewController
-(void)viewWillAppear:(BOOL)animated
{
    [alarmdetailLab setText:CustomLocalizedString(@"ALARM DETAILS", nil)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.m_tblAlarmDetail.delegate = self;
    self.m_tblAlarmDetail.dataSource = self;
    self.m_tblAlarmDetail.rowHeight = 50;
    
    /*Make sure our table view resizes correctly*/
    self.m_tblAlarmDetail.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.m_tblAlarmDetail];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = nil;
    
    if ([tableView isEqual:self.m_tblAlarmDetail]){
        
        static NSString *MyCellIdentifier = @"SimpleCell";
        /*We will try to retrieve on existing cell with the given indentifier*/
        cell = [tableView dequeueReusableCellWithIdentifier:MyCellIdentifier];
        
        if (cell == nil){
            /*If a cell with the given identifier does not exist, we will create the cell with the identifier
             and hand it to the table view*/
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                          reuseIdentifier:MyCellIdentifier];
        }

        if (indexPath.section == 0)
        {
            cell.textLabel.text = CustomLocalizedString(@"Message",nil);
            cell.detailTextLabel.text = [GlobalPool sharedObject].m_selAlarm.m_message;
        }
        else if (indexPath.section == 1)
        {
            cell.textLabel.text = CustomLocalizedString(@"Alarm name", nil);
            cell.detailTextLabel.text = [GlobalPool sharedObject].m_selAlarm.m_alarmName;
        }
        else if (indexPath.section == 2)
        {
            cell.textLabel.text = CustomLocalizedString(@"Machine name", nil);
            cell.detailTextLabel.text = [GlobalPool sharedObject].m_selAlarm.m_machine;
        }
        else if (indexPath.section == 3)
        {
            cell.textLabel.text = CustomLocalizedString(@"Date", nil);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd/MM HH:mm"];
            
            cell.detailTextLabel.text = [dateFormatter stringFromDate:[GlobalPool sharedObject].m_selAlarm.m_date];
        }
        else if (indexPath.section == 4)
        {
            cell.textLabel.text = CustomLocalizedString(@"Alarm type", nil);
            if ([GlobalPool sharedObject].m_selAlarm.m_alarmLevel == ALARM_RPIORITY)
                cell.detailTextLabel.text = @"P";
            else if ([GlobalPool sharedObject].m_selAlarm.m_alarmLevel == ALARM_LEVEL1)
                cell.detailTextLabel.text = @"1";
            else
                cell.detailTextLabel.text = @"2";
        }
      
    }

    return cell;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)actionBackMain:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
