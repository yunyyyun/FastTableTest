//
//  LXMethod.m
//  LiangFengYouXin
//
//  Created by facingsun on 2017/3/19.
//  Copyright © 2017年 周峻觉. All rights reserved.
//

#import "LXMethod.h"
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <Photos/Photos.h>
#import "UDID.h"

@implementation LXMethod

+ (NSString *)deviceNo {
    return [UDID udid];
}

+ (NSString *)version {
    id currentVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"%@", currentVersion];
}

+ (NSString *)registerChannel {
//    NSString *rc = [BKQAPPConfigurationManager manager].registerChannel;
//    if (rc) {
//        return rc;
//    } else {
//        return RegisterChannel;
//    }
    return  @"official-ios";
}

#pragma mark - 将从后台获取的版本号，与当前的版本号对比，判断是否要更新app
+ (BOOL)isNeedUpdateApp:(NSString *)lastVersion
{
    NSString *currentVersion = [[[NSBundle mainBundle]infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSArray *cVersion = [currentVersion componentsSeparatedByString:@"."];
    
    NSArray* lversion = [lastVersion componentsSeparatedByString:@"."];
    
    for (int i = 0; i < lversion.count; i++) {
        if ([lversion[i] integerValue] > [cVersion[i] integerValue]) {
            return YES;
        } else if ([lversion[i] integerValue] < [cVersion[i] integerValue]) {
            return NO;
        }
    }
    return NO;
}

#pragma mark - 判断是否是有效的手机号
+ (BOOL)isValidPhone:(NSString *_Nullable)phone {
    //手机号以13，15，18开头，八个 \d 数字字符
//    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(1[0-9][0-9]))\\d{8}$";
    NSString *phoneRegex = @"^((1[3-9][0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL result  = [phoneTest evaluateWithObject:phone];
    return result;
}

/** 是否全是字母或数字 */
+ (BOOL)isCharAndNumber:(NSString *)content
{
    if (content == nil || content.length == 0) return NO;
    NSString *regex =@"[A-Za-z0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:content];
}

+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - 判断是否是空字符串，过滤掉空格符和换行符
+ (BOOL)isStringEmpty:(NSString *)value
{
    BOOL result = FALSE;
    if (!value || [value isKindOfClass:[NSNull class]])
    {
        // null object
        result = TRUE;
    }
    else
    {
        NSString *trimedString = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([value isKindOfClass:[NSString class]] && [trimedString length] == 0)
        {
            // empty string
            result = TRUE;
        }
    }
    
    return result;
}

#pragma mark --计算 属性化文本的矩形大小
+ (CGSize)attributedStringSize:(NSAttributedString *)text maxSize:(CGSize)size{
    if ([text isKindOfClass:[NSNull class]] || text == nil || text.length == 0) {
        return CGSizeZero;
    }

    return [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
}

#pragma mark --计算文本的矩形大小
+(CGSize)stringSize:(NSString *)text font:(UIFont *)font maxSize:(CGSize)size{
    if ([text isKindOfClass:[NSNull class]] || text == nil || text.length == 0) {
        return CGSizeZero;
    }
    return [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:[NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName, nil] context:nil].size;
}
#pragma mark --获取1970到当前的毫秒数
+(NSString *)get1970ToNowMS{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
    //    double i=time;      //NSTimeInterval返回的是double类型
    ////NSLog(@"time:%.0f",time);
    return [NSString stringWithFormat:@"%.0f",time];
}

#pragma mark --获取1970到当前的秒数
+(NSString *)get1970ToNowSecond{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970];
    //    double i=time;      //NSTimeInterval返回的是double类型
    ////NSLog(@"time:%.0f",time);
    return [NSString stringWithFormat:@"%.0f",time];
}

#pragma mark - 当前时间的字符形式
+(NSString*)getCurrentTimes{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    [formatter setDateFormat:@"YYYY/MM/dd HH:mm:ss"];
    
    //现在时间,你可以输出来看下是什么格式
    
    NSDate *datenow = [NSDate date];
    
    //----------将nsdate按formatter格式转成nsstring
    
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    
    NSLog(@"currentTimeString =  %@",currentTimeString);
    
    return currentTimeString;
    
}

+(NSString *)timestampStringWithFormatDateString:(NSString *)dateStr
{
    if([LXMethod isStringEmpty:dateStr] == YES){
        return @"";
    }else{
        //@"YYYY-MM-dd HH:mm"
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm";
        NSDate* startDate = [dateFormatter dateFromString:dateStr];
        
        NSTimeInterval interval = startDate.timeIntervalSince1970;
        
        //取正分钟数
        //NSTimeInterval interval = self.stopDate.timeIntervalSince1970 - (NSInteger)self.stopDate.timeIntervalSince1970%60;
        NSString* timeInterval = [NSString stringWithFormat:@"%.f", interval];
        return timeInterval;
    }
}

/**
 *  是否为同一天
 */
+ (BOOL)isSameDay:(NSDate*)date1 date2:(NSDate*)date2
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

+ (void)deleteFileWithLocalPath:(NSString *)path
{
    if ([path hasPrefix:@"http"]) {
        return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSFileManager* manager = [NSFileManager defaultManager];
        NSError* error;
        [manager removeItemAtPath:path error:&error];
        if (error) {
            NSLog(@"%s,删除文件出错：%@",__func__, error);
        }
    });
}

//判断文件是否已经在沙盒中已经存在？
+(BOOL) isFileExist:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    NSLog(@"这个文件已经存在：%@",result?@"是的":@"不存在");
    return result;
}

//md5加密
+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr,(CC_LONG)strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

#pragma mark - Find ViewController
+ (UIViewController*)findViewController:(UIView *)currentView
{
    for (UIView* next = [currentView superview]; next; next = next.superview)
    {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]){
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark - 添加子视图控制器到根视图中
+ (void)addChildViewControllerToRoot:(UIViewController *)childController
{
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.window.rootViewController addChildViewController:childController];
    [appDelegate.window addSubview:childController.view];
}

+ (void)deleteChildViewControllerFromRoot:(UIViewController *)childController
{
    [childController removeFromParentViewController];
}

//解析json格式的字符串
+ (nullable id)JSONObjectWithString:(NSString*)jsonStrong{
    NSData *data = [jsonStrong dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id obj = [NSJSONSerialization JSONObjectWithData:data
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        if (jsonStrong) {  //数据不为空，过滤一下，再解析一遍
            NSString* string = [LXMethod filterJsonString:jsonStrong];
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSError *er;
            obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&er];
            if (er) {
                NSLog(@"json解析失败：%@",err);
                return nil;
            }
            return obj;
        }
        return nil;
    }
    return obj;
}

//json格式的数据中，NSJSONSerialization 无法解析其中的特殊字符：如\n 、\r等。用此方法过滤下
+ (NSString *)filterJsonString:(NSString *)string
{
    NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jsonString == nil) {
        NSData* utf8Data = [LXMethod replaceNoUtf8:data];
        jsonString = [[NSString alloc] initWithData:utf8Data encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"    " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\\"
                                                       withString:@"\\\\\\\\" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r"
                                                       withString:@"\\\\r" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n"
                                                       withString:@"\\\\n" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t"
                                                       withString:@"\\\\t" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    
    //如果最后两个字符（{"wtys":[...]}后面的字符）是\n或\r，删除它
    NSString* temp = [jsonString substringWithRange:NSMakeRange(jsonString.length - 2, 2)];
    if ([temp isEqualToString:@"\\n"] || [temp isEqualToString:@"\\r"])
    {
        jsonString = [jsonString stringByReplacingCharactersInRange:NSMakeRange(jsonString.length - 2, 2) withString:@""];
    }
    temp = [jsonString substringWithRange:NSMakeRange(jsonString.length - 2, 2)];
    if ([temp isEqualToString:@"\\n"] || [temp isEqualToString:@"\\r"])
    {
        jsonString = [jsonString stringByReplacingCharactersInRange:NSMakeRange(jsonString.length - 2, 2) withString:@""];
    }
    
    return jsonString;
}

//服务器传输过来的json格式的数据，NSJSONSerialization 无法解析其中的特殊字符：如\n 、\r等。用此方法过滤下
+ (NSData *)filterDataFromNetworking:(NSData *)data
{
    /* 处理转义字符的例子
     NSString *jsonString = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\v" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\f" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\b" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\a" withString:@""];
     jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\e" withString:@""];
     NSLog(@"networking string:%@", jsonString);
     */
    
    NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (jsonString == nil) {
        NSData* utf8Data = [LXMethod replaceNoUtf8:data];
        jsonString = [[NSString alloc] initWithData:utf8Data encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"    " withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\\\\"
                                                       withString:@"\\\\\\\\" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r"
                                                       withString:@"\\\\r" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n"
                                                       withString:@"\\\\n" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\t"
                                                       withString:@"\\\\t" options:NSRegularExpressionSearch
                                                            range:NSMakeRange(0, [jsonString length])];
    
    //如果最后两个字符（{"wtys":[...]}后面的字符）是\n或\r，删除它
    NSString* temp = [jsonString substringWithRange:NSMakeRange(jsonString.length - 2, 2)];
    if ([temp isEqualToString:@"\\n"] || [temp isEqualToString:@"\\r"])
    {
        jsonString = [jsonString stringByReplacingCharactersInRange:NSMakeRange(jsonString.length - 2, 2) withString:@""];
    }
    temp = [jsonString substringWithRange:NSMakeRange(jsonString.length - 2, 2)];
    if ([temp isEqualToString:@"\\n"] || [temp isEqualToString:@"\\r"])
    {
        jsonString = [jsonString stringByReplacingCharactersInRange:NSMakeRange(jsonString.length - 2, 2) withString:@""];
    }
    
    return [jsonString dataUsingEncoding:NSUTF8StringEncoding];
}

/*
 如果一个字节小于0x80，那么他就是一个字符；
 如果大于C0小于E0，表示2个字节组成的utf8字符（第一个是110开头的，第二个是10开头的）；
 如果大于E0小于F0，表示3个字节组成的utf8字符（第一个是1110开头的，第二个是10开头的，第三个是10开头的）；
 以此类推，如果不符合utf-8规则，则表示一个非法字符，只要替换这样的字符即可。utf8最多6个字符.
 参考网址：http://blog.csdn.net/cuibo1123/article/details/40938225
 */

//替换非utf8字符
//注意：如果是三字节utf-8，第二字节错误，则先替换第一字节内容(认为此字节误码为三字节utf8的头)，然后判断剩下的两个字节是否非法；
#pragma mark - 此实现可用但不够严谨，需要进行优化
+ (NSData *)replaceNoUtf8:(NSData *)data
{
    char aa[] = {'.','.','.','.','.','.'};                      //utf8最多6个字符，当前方法未使用
    NSMutableData *md = [NSMutableData dataWithData:data];
    int loc = 0;
    while(loc < [md length])
    {
        char buffer;
        [md getBytes:&buffer range:NSMakeRange(loc, 1)];
        if((buffer & 0x80) == 0)
        {
            loc++;
            continue;
        }
        else if((buffer & 0xE0) == 0xC0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                continue;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else if((buffer & 0xF0) == 0xE0)
        {
            loc++;
            [md getBytes:&buffer range:NSMakeRange(loc, 1)];
            if((buffer & 0xC0) == 0x80)
            {
                loc++;
                [md getBytes:&buffer range:NSMakeRange(loc, 1)];
                if((buffer & 0xC0) == 0x80)
                {
                    loc++;
                    continue;
                }
                loc--;
            }
            loc--;
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
        else
        {
            //非法字符，将这个字符（一个byte）替换为A
            [md replaceBytesInRange:NSMakeRange(loc, 1) withBytes:aa length:1];
            loc++;
            continue;
        }
    }
    
    return md;
}

//获取键盘试图
+ (UIView *)keyboardView
{
    UIWindow* tempWindow;
    
    //Because we cant get access to the UIKeyboard throught the SDK we will just use UIView.
    //UIKeyboard is a subclass of UIView anyways
    UIView* keyboard;
    
    //NSLog(@"windows %ld", (unsigned long)[[[UIApplication sharedApplication]windows]count]);
    
    //Check each window in our application
    for(int c = 0; c < [[[UIApplication sharedApplication] windows] count]; c ++)
    {
        //Get a reference of the current window
        tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:c];
        
        //Get a reference of the current view
        for(int i = 0; i < [tempWindow.subviews count]; i++)
        {
            keyboard = [tempWindow.subviews objectAtIndex:i];
            //NSLog(@"view: %@, on index: %d, class: %@", [keyboard description], i, [[tempWindow.subviews objectAtIndex:i] class]);
            if([[keyboard description] hasPrefix:@"(lessThen)UIKeyboard"] == YES)
            {
                //If we get to this point, then our UIView "keyboard" is referencing our keyboard.
                return keyboard;
            }
        }
        
        for(UIView* potentialKeyboard in tempWindow.subviews)
            // if the real keyboard-view is found, remember it.
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                if([[potentialKeyboard description] hasPrefix:@"<UILayoutContainerView"] == YES)
                    keyboard = potentialKeyboard;
            }
            else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2) {
                if([[potentialKeyboard description] hasPrefix:@"<UIPeripheralHost"] == YES)
                    keyboard = potentialKeyboard;
            }
            else {
                if([[potentialKeyboard description] hasPrefix:@"<UIKeyboard"] == YES)
                    keyboard = potentialKeyboard;
            }
    }
    
    return keyboard;
}

+ (void)saveImageToPhone:(UIImage *)image completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success,error);
    }];
}

+ (void)saveImageFileToPhone:(NSURL *)fileUrl completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success,error);
    }];
}

+ (void)saveVideoToPhone:(NSURL *)fileUrl completionHandler:(void (^)(BOOL, NSError * _Nullable))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:fileUrl];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        completionHandler(success,error);
    }];
}

+ (CGSize)sizeToFitThat:(CGSize)size inZone:(CGSize)zone
{
    if (zone.width == 0 || zone.height == 0 || size.width == 0 || size.height == 0) {
        return CGSizeZero;
    }
    
    if (size.width/size.height < zone.width/zone.height) {
        CGFloat height = zone.height;
        CGFloat width = height*(size.width/size.height);
        return CGSizeMake(width, height);
    }else{
        CGFloat width = zone.width;
        CGFloat height = width*(size.height/size.width);
        return CGSizeMake(width, height);
    }
}

//打开系统设置或其他app
+ (void)openScheme:(NSString *)scheme {
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:scheme];
    
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:^(BOOL success) {
               NSLog(@"Open %@: %d",scheme,success);
           }];
    } else {
        BOOL success = [application openURL:URL];
        NSLog(@"Open %@: %d",scheme,success);
    }
}

/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
+ (NSMutableArray*)calculateSubStringCount:(NSString *)content str:(NSString *)tab {
    int location = 0;
    NSMutableArray *locationArr = [NSMutableArray new];
    NSRange range = [content rangeOfString:tab];
    if (range.location == NSNotFound){
        return locationArr;
    }
    //声明一个临时字符串,记录截取之后的字符串
    NSString * subStr = content;
    while (range.location != NSNotFound) {
        if (location == 0) {
            location += range.location;
        } else {
            location += range.location + tab.length;
        }
        //记录位置
        NSNumber *number = [NSNumber numberWithUnsignedInteger:location];
        [locationArr addObject:number];
        //每次记录之后,把找到的字串截取掉
        subStr = [subStr substringFromIndex:range.location + range.length];
//        NSLog(@"subStr %@",subStr);
        range = [subStr rangeOfString:tab];
//        NSLog(@"rang %@",NSStringFromRange(range));
    }
    return locationArr;
}

@end
