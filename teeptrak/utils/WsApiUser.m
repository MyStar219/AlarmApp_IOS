//
//  WsApiUser.m
//  teeptrak
//
//  Created by jackson on 2/2/16.
//  Copyright © 2016 steve. All rights reserved.
//

#include "Constant.h"
#import "WsApiUser.h"

#define PATH_PREFIX     @"/api/v1"

@implementation WsApiUser

@synthesize m_apiHost = _m_apiHost;
@synthesize m_apiPort = _m_apiPort;
@synthesize m_apiSsl = _m_apiSsl;
@synthesize m_apiSelfSigned = _m_apiSelfSigned;
@synthesize m_pathPrefix = _m_pathPrefix;


-(id) init
{
    if((self = [super init]))
    {
        
        self.m_apiHost = @"staging.teeptrak.net";
        self.m_apiPort = 443;
        self.m_apiSsl = true;
        self.m_apiSelfSigned = true;
    }
    
    return self;
}

- (NSString *) getSchem{

    return [NSString stringWithFormat:@"http%@", self.m_apiSsl ? @"s" : @""];
}

- (NSString *) buildUrl:(NSString *)endpoint query:(NSString *)query{

    NSString *path = [NSString stringWithFormat:@"%@/%@", PATH_PREFIX, endpoint];
    
    return [NSString stringWithFormat:@"%@://%@:%lu%@", self.getSchem, _m_apiHost, _m_apiPort, path];
}

- (void) getApiToken:(NSString *)login password:(NSString *)password complete:(JSONObjectBlock)completeBlock{

   
    [JSONHTTPClient getJSONFromURLWithString:[self buildUrl:@"users.json" query:@""]
                                      params:@{@"login":login, @"password":password}
                                  completion:completeBlock];
//                                              ]^(NSDictionary *json, JSONModelError *err) {
//                                      
//                                      if ([json valueForKey:@"api_key"])
//                                          self.m_pathPrefix = [json valueForKey:@"api_key"];
//                                      
//                                  }];
     
}

- (void) setGcmRegisterationKey:(NSString *)apiUserToken gcmRegiserationKey:(NSString *)gcmRegisterationKey complete:(JSONObjectBlock)completeBlock{
    
    NSDictionary *queryParams = @{
                                  @"token":apiUserToken,
                                  @"apple_token":gcmRegisterationKey,
                                  @"udid":[GlobalPool sharedObject].m_constant.m_deviceToken,
                                  @"name":[[GlobalPool sharedObject].m_constant getDeviceName]
                                  };
    
    [JSONHTTPClient postJSONFromURLWithString:[self buildUrl:@"users/apple_token.json" query:@""]
                                       params:queryParams
                                   completion:^(NSDictionary *json, JSONModelError *err) {
    
                                          if ([json valueForKey:@"api_key"])
                                              self.m_pathPrefix = [json valueForKey:@"api_key"];
    
                                      }];
}

@end
