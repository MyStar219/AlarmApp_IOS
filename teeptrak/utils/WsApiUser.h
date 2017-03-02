//
//  WsApiUser.h
//  teeptrak
//
//  Created by jackson on 2/2/16.
//  Copyright © 2016 steve. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelLib.h"

@interface WsApiUser : JSONModel

@property (nonatomic, strong) NSString *    m_apiHost;
@property (nonatomic) NSInteger             m_apiPort;
@property (nonatomic) BOOL                  m_apiSsl;
@property (nonatomic) BOOL                  m_apiSelfSigned;
@property (nonatomic, strong) NSString *    m_pathPrefix;


- (NSString *)  getSchem;
- (NSString *)  buildUrl:(NSString *)endpoint query:(NSString *)query;

- (void)  getApiToken:(NSString *)login password:(NSString *)password complete:(JSONObjectBlock) completeBlock;
- (void)  setGcmRegisterationKey:(NSString *)apiUserToken gcmRegiserationKey:(NSString *)gcmRegisterationKey complete:(JSONObjectBlock) completeBlock;

@end
