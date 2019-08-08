//
//  BKQError.m
//  BKQ
//
//  Created by 周峻觉 on 2019/6/26.
//  Copyright © 2019 周峻觉. All rights reserved.
//

#import "BKQError.h"
#import "BKQErrorCode.h"

@implementation BKQError

+ (instancetype)errorWithCode:(NSInteger)code message:(NSString *)message originError:(NSError *)originError {
    return [[BKQError alloc] initWithCode:code message:message originError:originError];
}

- (instancetype)initWithCode:(NSInteger)code message:(NSString *)message originError:(NSError *)originError {
    self = [super init];
    if (self) {
        _code = code;
        _message = [message copy];
        _originError = originError;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<BKQError:%p code:%ld message:%@ friendlyMessage:%@ originError:%@>", self, (long)_code, _message, self.friendlyMessage, _originError];
}

- (NSString *)friendlyMessage {
    if (_code == BKQSuccessCode) {
        return @"成功";
    } else if (_code == BKQUnauthorizedCode) {
        return @"账号已在别处登录";
    } else if (_code == BKQAccountFrozenCode) {
        return @"此账号已被冻结，请联系客服解除";
    } else if (_code < 1000) {
        return @"网络错误";
    } else {
        return _message;
    }
}

@end
