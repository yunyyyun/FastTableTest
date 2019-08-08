//
//  LXMethod.h
//  LiangFengYouXin
//
//  Created by facingsun on 2017/3/19.
//  Copyright © 2017年 周峻觉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LXMethod : NSObject

#pragma mark - 获取设备号
+ (NSString *_Nonnull)deviceNo;

#pragma mark - 版本号
+ (NSString *_Nonnull)version;

#pragma mark - 渠道号
+ (NSString *_Nonnull)registerChannel;

#pragma mark - 将从后台获取的版本号，与当前的版本号对比，判断是否要更新app
+ (BOOL)isNeedUpdateApp:(NSString *_Nullable)lastVersion;

#pragma mark - 判断是否是有效的手机号
+ (BOOL)isValidPhone:(NSString *_Nullable)phone;

#pragma mark - 是否全是字母或数字
+ (BOOL)isCharAndNumber:(NSString *_Nullable)content;

#pragma mark - 是否是纯整数
+ (BOOL)isPureInt:(NSString *)string;

#pragma mark - 判断是否是空字符串，过滤掉空格符和换行符
+ (BOOL)isStringEmpty:(NSString *_Nullable)value;

#pragma mark - 计算属性化文本的矩形大小
+ (CGSize)attributedStringSize:(NSAttributedString *_Nullable)text maxSize:(CGSize)size;

#pragma mark - 计算文本的矩形大小
+(CGSize)stringSize:(NSString *_Nullable)text font:(UIFont *_Nullable)font maxSize:(CGSize)size;

#pragma mark - 获取1970到当前的毫秒数
+(NSString *_Nullable)get1970ToNowMS;

#pragma mark -  获取1970到当前的秒数
+(NSString *_Nullable)get1970ToNowSecond;

#pragma mark - 当前时间的字符串形式
+(NSString*_Nullable)getCurrentTimes;

#pragma mark - 将 "YYYY-MM-dd HH:mm" 格式的时间，传化成时间戳字符串
+(NSString *_Nullable)timestampStringWithFormatDateString:(NSString *_Nullable)dateStr;

#pragma mark - 判断是否是同一天
+ (BOOL)isSameDay:(NSDate*_Nullable)date1 date2:(NSDate*_Nullable)date2;

#pragma mark - 保存图片到手机本地
+ (void)saveImageToPhone:(UIImage *_Nullable)image completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;
+ (void)saveImageFileToPhone:(NSURL *_Nullable)fileUrl completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;
+ (void)saveVideoToPhone:(NSURL *_Nullable)fileUrl completionHandler:(nullable void(^)(BOOL success, NSError *__nullable error))completionHandler;

#pragma mark - 判断文件是否已经在沙盒中已经存在？
+(BOOL) isFileExist:(NSString *_Nullable)fileName;

#pragma mark - md5加密
+ (NSString *_Nullable) md5:(NSString *_Nullable) input;

#pragma mark - Find ViewController
+ (UIViewController*_Nullable)findViewController:(UIView *_Nullable)currentView;

#pragma mark - 添加子视图控制器到根视图中
+ (void)addChildViewControllerToRoot:(UIViewController *_Nullable)childController;

#pragma mark - 解析json格式的字符串
+ (nullable id)JSONObjectWithString:(NSString* _Nullable)jsonStrong;

#pragma mark - json格式的数据中，NSJSONSerialization 无法解析其中的特殊字符：如\n 、\r等。用此方法过滤下
+ (NSString *_Nullable)filterJsonString:(NSString *_Nullable)string;

#pragma mark - 服务器传输过来的json格式的数据，NSJSONSerialization 无法解析其中的特殊字符：如\n 、\r等。用此方法过滤下
+ (NSData *_Nullable)filterDataFromNetworking:(NSData *_Nullable)data;

#pragma mark - 获取键盘视图
+ ( UIView * _Nullable )keyboardView;

#pragma mark - 在zone范围内，等比例缩放size,得到一个最大的size
+ (CGSize)sizeToFitThat:(CGSize)size inZone:(CGSize)zone;

#pragma mark - 打开系统设置或其他app
+ (void)openScheme:(NSString *_Nullable)scheme;

/**
 查找子字符串在父字符串中的所有位置
 @param content 父字符串
 @param tab 子字符串
 @return 返回位置数组
 */
+ (NSMutableArray *)calculateSubStringCount:(NSString *)content str:(NSString *)tab;

@end

NS_ASSUME_NONNULL_END
