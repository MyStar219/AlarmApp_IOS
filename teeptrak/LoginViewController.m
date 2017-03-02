//
//  ViewController.m
//  teeptrak
//
//  Created by jackson on 1/25/16.
//  Copyright © 2016 steve. All rights reserved.
//
#import "global.h"
#import "HUD.h"

#import "LoginViewController.h"
#import "MainViewController.h"
#import "AppDelegate.h"
#import "AlarmDB.h"

#import "CGYAML.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
@synthesize m_txtUsername = _m_txtUsername;
@synthesize m_txtPassword = _m_txtPassword;
@synthesize m_btnAutoLogin = _m_btnAutoLogin;
@synthesize m_wsUser = _m_wsUser;

-(void)viewWillAppear:(BOOL)animated
{
    [logInLab setText:CustomLocalizedString(@"Login", nil)];
    [passwordLab setText:CustomLocalizedString(@"Password", nil)];
    [_m_btnAutoLogin setTitle:CustomLocalizedString(@"Remember me", nil) forState:UIControlStateNormal];
    [goBtn setTitle:CustomLocalizedString(@"Go!", nil) forState:UIControlStateNormal];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_logInfo = [[AlarmDB dbInstance] getLoginInfo];
    if (m_logInfo.m_bAutoLogin)
    {
        [self.m_btnAutoLogin setImage:[UIImage imageNamed:@"check20.png"] forState:UIControlStateNormal];
    }
    else{
        [self.m_btnAutoLogin setImage:[UIImage imageNamed:@"uncheck20.png"] forState:UIControlStateNormal];
    }
 
    
    // read out API properties from settings.yml file
    NSString *fileName = [[NSBundle bundleForClass:[self class]] pathForResource:@"settings" ofType:@"yml"];
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:@"settings" withExtension:@"yml"];
    
    CGYAML * apiYml = [[CGYAML alloc] initWithURL:resourceURL];
    
    NSString *strValue = [apiYml valueForYPath:@"/api/host"];
    
    
    self.m_wsUser = [[WsApiUser alloc] init];
    self.m_wsUser.m_apiHost = [apiYml valueForYPath:@"/api/host"];
    self.m_wsUser.m_apiPort = [[apiYml valueForYPath:@"/api/port"] integerValue];
    if ([[apiYml valueForYPath:@"/api/ssl"] isEqualToString:@"true"])
        self.m_wsUser.m_apiSsl = true;
    else
        self.m_wsUser.m_apiSsl = false;

    if ([[apiYml valueForYPath:@"/api/self_signed"] isEqualToString:@"true"])
        self.m_wsUser.m_apiSelfSigned = true;
    else
        self.m_wsUser.m_apiSelfSigned = false;
    
    [GlobalPool sharedObject].m_constant.m_gcmSenderId = [apiYml valueForYPath:@"/gcm_sender_id"];

    if (m_logInfo.m_bAutoLogin)
        [self actionAutoLogin];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[self view] endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//enable/disable auto login
- (IBAction)clickedAutoLogin:(UIButton *)sender {
    if (m_logInfo.m_bAutoLogin)
    {
        [self.m_btnAutoLogin setImage:[UIImage imageNamed:@"uncheck20.png"] forState:UIControlStateNormal];
        m_logInfo.m_bAutoLogin = FALSE;
    }
    else{
        [self.m_btnAutoLogin setImage:[UIImage imageNamed:@"check20.png"] forState:UIControlStateNormal];
        m_logInfo.m_bAutoLogin = TRUE;
    }
}
- (IBAction)ActionLogin:(id)sender {
    
    if (m_logInfo.m_bAutoLogin)
    {
        m_logInfo.m_username = self.m_txtUsername.text;
        m_logInfo.m_password = self.m_txtPassword.text;
        
        [[AlarmDB dbInstance] saveLoginInfo:m_logInfo];
    }
    
    [self actionAutoLogin];
}

- (void) actionAutoLogin{
    [HUD showUIBlockingIndicatorWithText:@"Login"];
    
    NSString *strLogin = self.m_txtUsername.text;
    NSString *strPassword = self.m_txtPassword.text;
    
    if (m_logInfo.m_bAutoLogin)
    {
        strLogin = m_logInfo.m_username;
        strPassword = m_logInfo.m_password;
    }
    
    strLogin = @"demo1";
    strPassword = @"12345678";
    
    AppDelegate* delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.m_wsUser getApiToken:strLogin
                      password:strPassword
                      complete:^(NSDictionary * json, JSONModelError *err) {
                          [HUD hideUIBlockingIndicator];
                          if ([json valueForKey:@"api_key"]){
                              [GlobalPool sharedObject].m_constant.m_userApiToken = [json valueForKey:@"api_key"];
                              
                              [self.m_wsUser setGcmRegisterationKey:[json valueForKey:@"api_key"]
                                                 gcmRegiserationKey:delegate.m_strDeviceToken
                                                           complete:nil];
                              
                              [self performSegueWithIdentifier:@"gotoMain" sender:nil];
                              [GlobalPool sharedObject].m_bLoginSuccess = TRUE;
                          }
                          else{
                              //show error
                              [[[UIAlertView alloc] initWithTitle:CustomLocalizedString(@"Wrong username and password", nil)
                                                          message:[err localizedDescription]
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil] show];
                              [GlobalPool sharedObject].m_bLoginSuccess = FALSE;
                              
                              //                              //home button press programmatically
                              //                              UIApplication *app = [UIApplication sharedApplication];
                              //                              [app performSelector:@selector(suspend)];
                              //
                              //                              //wait 2 seconds while app is going background
                              //                              [NSThread sleepForTimeInterval:10.0];
                              //
                              //                              //exit app when app is in background
                              //                              exit(0);
                          }
                      }];
}

@end
