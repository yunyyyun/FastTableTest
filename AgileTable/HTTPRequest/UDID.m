//
//  UDID.m
//  EvilDriver
//
//  Created by Andy on 2017/2/25.
//  Copyright © 2017年 EvilDriver. All rights reserved.
//

#import "UDID.h"
#import "KeyChainHandler.h"
#import "OpenUDID.h"
#import "Config.h"

#define kDMUserTokenKey @"kDMUserTokenKey"

@implementation UDID

#pragma mark - 获取UDID

+ (NSString *)udid
{
    NSString *udid = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    udid = [defaults objectForKey:kDMUserTokenKey];
    if (udid) {
        return udid;
    }
    
    udid = [KeyChainHandler load:kDMUserTokenKey];
    if (udid) {
        [defaults setObject:udid forKey:kDMUserTokenKey];

		return udid;
    }
    
    udid = [OpenUDID value];
    if (udid) {
        [defaults setObject:udid forKey:kDMUserTokenKey];
        [KeyChainHandler save:kDMUserTokenKey data:udid];
        
        return udid;
    }
    
    udid = [[NSUUID UUID] UUIDString];
    [defaults setObject:udid forKey:kDMUserTokenKey];
	[KeyChainHandler save:kDMUserTokenKey data:udid];

    return udid;
}

@end
