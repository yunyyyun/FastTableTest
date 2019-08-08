//
//  BKQError.h
//  BKQ
//
//  Created by 周峻觉 on 2019/6/26.
//  Copyright © 2019 周峻觉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BKQError : NSObject

@property (nonatomic, assign)NSInteger code;
@property (nonatomic, copy)NSString *message;
@property (nonatomic, strong, readonly)NSString *friendlyMessage;
@property (nonatomic, strong)NSError *originError;

+ (instancetype)errorWithCode:(NSInteger)code message:(NSString * _Nullable)message originError:(NSError * _Nullable)originError;
- (instancetype)initWithCode:(NSInteger)code message:(NSString * _Nullable)message originError:(NSError * _Nullable)originError;

@end

NS_ASSUME_NONNULL_END
