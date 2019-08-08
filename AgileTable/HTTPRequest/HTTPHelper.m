//
//  HTTPHelper.m
//  GoIco
//
//  Created by Andy on 2017/8/26.
//  Copyright © 2017年 ico. All rights reserved.
//

#import "HTTPHelper.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
#import "Config.h"
#import <CommonCrypto/CommonCryptor.h>
#import "DES3Util.h"
#import "LXMethod.h"

#define useDes true

static int UserUnLoginCode = 401;

@implementation HTTPRequestCodeError
- (id)initCode:(int)code error:(NSString *)error {
    self = [super init];
    if (self) {
        self.code = code;
        self.error = error;
    }
    return self;
}
@end

@implementation HTTPHelper

static NSTimeInterval static_timestamp = 0;
static NSTimeInterval static_systemUptime = 0;
+ (NSTimeInterval)timestamp {
    NSProcessInfo *info = [NSProcessInfo processInfo];
    
    return static_timestamp + info.systemUptime - static_systemUptime;
}

+ (void)setTimestamp:(NSTimeInterval)timestamp
{
    if (timestamp > [self timestamp] && static_timestamp > 0) {
        return;
    }
    
    static_timestamp = timestamp;
    NSProcessInfo *info = [NSProcessInfo processInfo];
    static_systemUptime = info.systemUptime;
}

/*! 网络请求成功检查数据
 */
+ (void)detaiDataReponseObject:(NSDictionary<NSString *, id> *)reponseObject
                       success:(void (^)(NSDictionary<NSString *, id> *responseObject))success
                       failure:(void (^)(int code, NSString *error))failure
{
    if (![reponseObject isKindOfClass:[NSDictionary class]]) {
        if (failure) {
            failure(CodeUnKnowErr, defError);
        }
        return;
    }
    id code = [reponseObject valueForKey:@"status"];
    NSString *message = [reponseObject valueForKey:@"message"];
    message = message ? [message description] : defError;
    if (![code respondsToSelector:@selector(intValue)]) {
        if (failure) {
            failure(CodeUnKnowErr, message);
        }
        return;
    }
    
    int errorno = [code intValue];
    if (errorno == CodeSucess) {
        if (success) {
            success(reponseObject);
        }
    } else {
        if (errorno == UserUnLoginCode) {
            //用户未登录
            EDLog(@"----------------------//用户未登录");
            // [[MIUser sharedUser] clean];
            // [[AppDelegate shareObject] tryLogin];
            
            if (failure) {
                failure(errorno, message);
            }
        } else {
            if (errorno<1000){
                message = @"请求错误";
            }
            if (failure) {
                failure(errorno, message);
            }
        }
    }
}

+ (instancetype)sharedObject{return nil;}

/*! 失败时处理错误问题
 */
+ (HTTPRequestCodeError *)handleErrorTaskResponse:(NSURLResponse *)resp error:(NSError *)error
{
    if (error.code == NSURLErrorCancelled) {
        return [[HTTPRequestCodeError alloc] initCode:NSURLErrorCancelled error:@""];
    }
    
    int statusCode = 0;
    NSString *errorMessageDecoded = defError;
    if ([resp isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (id)resp;
        NSDictionary *errorDic = response.allHeaderFields;
        NSString *errorMessage = [errorDic[@"X-Api-Status-Msg"] description];
        errorMessageDecoded = [errorMessage stringByRemovingPercentEncoding];
        if (isNilString(errorMessageDecoded)) {
            errorMessageDecoded = defError;
        }
        statusCode = (int)response.statusCode;
    } else {
        return [[HTTPRequestCodeError alloc] initCode:(int)error.code error:errorMessageDecoded];
    }
    
    switch (statusCode) {
        case 500:
            return [[HTTPRequestCodeError alloc] initCode:statusCode error:errorMessageDecoded];
            
        case 404:
            return [[HTTPRequestCodeError alloc] initCode:statusCode error:errorMessageDecoded];
            
        default:
            return [[HTTPRequestCodeError alloc] initCode:statusCode error:errorMessageDecoded];
    }
}

+ (id)detailParamters:(id)paramters {    
    // des 加密
    if (useDes){
        if (!paramters) paramters = @{};
        NSMutableDictionary *newParamters = [NSMutableDictionary dictionaryWithDictionary:paramters];
        if (!newParamters[@"deviceNo"]) {
            newParamters[@"deviceNo"] = [LXMethod deviceNo];
        }
        if (!newParamters[@"channel"]) {
            newParamters[@"channel"] = [LXMethod registerChannel];
        }
        newParamters[@"ts"] = @"zyxwvabcde";
        
        
        NSMutableDictionary *resultParamters = [@{} mutableCopy];
        resultParamters[@"src"] = @"ios";
        resultParamters[@"version"] = [LXMethod version];
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject: newParamters options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        resultParamters[@"data"] = [DES3Util encryptUseDES: jsonString];
        return resultParamters;
    }
    
    EDLog(@"deeeeee fate error!");
    if (!paramters) paramters = @{};
    NSMutableDictionary *newParamters = [NSMutableDictionary dictionaryWithDictionary:paramters];
    if (!newParamters[@"v"]) {
        NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
        newParamters[@"v"] = [NSString stringWithFormat:@"%@",[infoDic objectForKey:@"CFBundleShortVersionString"]];
    }

    if (!newParamters[@"deviceNo"]) {
        newParamters[@"deviceNo"] = [LXMethod deviceNo];
    }
    if (!newParamters[@"src"]) {
        newParamters[@"src"] = @"ios";
    }
    if (!newParamters[@"channel"]) {
        newParamters[@"channel"] = [LXMethod registerChannel];
    }
    if (!newParamters[@"version"]) {
        newParamters[@"version"] = [LXMethod version];
    }
    if (!newParamters[@"device_model"]) {
        struct utsname systemInfo;
        uname(&systemInfo);
        newParamters[@"device_model"] = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];;
    }
    long int timestamp = [[NSDate date] timeIntervalSince1970];
    newParamters[@"timestamp"] = @(timestamp);
    return newParamters;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
    
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
