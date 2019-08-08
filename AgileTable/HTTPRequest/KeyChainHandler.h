//
//  KeyChainHandler.h
//  AiQiangGou
//
//  Created by XUEDoweidu on 14/12/30.
//  Copyright (c) 2014年 Doweidu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainHandler : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

+ (void)saveThisDeviceOnly:(NSString *)service data:(id)data;
+ (id)loadThisDeviceOnly:(NSString *)service;
+ (void)deleteThisDeviceOnly:(NSString *)service;

@end
