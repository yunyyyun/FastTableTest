//
//  NSString+Formatter.m
//  GoIco
//
//  Created by Andy on 2017/8/12.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSString+Formatter.h"
#import "Config.h"

NSString *removeLastZero(NSString *dStr) {
    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:dStr];
    return [dn stringValue];
}

NSString *dotChange(double change) {
    return change >= 0 ? @"+":@"";
}

NSString *formarterLimitPrice(double price ) {
    NSString *head = @"";
    NSString *tail = @"";
    if (price<0){
        head = @"-";
        price = 0-price;
    }
    if (ABS(price) < 0.00000001) {
        return @"0";
    }
    
    if (ABS(price) < 1) {
        tail = formarterPrice(price, 8);
    }
    else if (ABS(price) < 1000) {
        tail = formarterPrice(price, 4);
    }
    else if(ABS(price) < 10000){
        tail = formarterPrice(price, 2);
    }
    else {
        tail = formarterPrice(price, 0);
    }
    return [NSString stringWithFormat:@"%@%@", head, tail];
}

NSString *formarterLimitPriceWithScale(double price, int scale) {
    NSString *head = @"";
    NSString *tail = @"";
    if (price<0){
        head = @"-";
        price = 0-price;
    }
    if (ABS(price) < 0.00000001) {
        return @"0";
    }
    if (scale==-1){
        scale = 9;
    }
    tail = formarterPrice(price, scale);
    return [NSString stringWithFormat:@"%@%@", head, tail];
}

// dot:精度, comma:千分符, mode:四舍五入模式
NSString *formarterPriceMode(double price, NSInteger dot, BOOL comma,NSRoundingMode mode) {
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithDecimal:@(price).decimalValue];
    NSDecimalNumberHandler *roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:mode
                                                                                                      scale:dot
                                                                                           raiseOnExactness:NO
                                                                                            raiseOnOverflow:NO
                                                                                           raiseOnUnderflow:NO
                                                                                        raiseOnDivideByZero:NO];
    NSString *tempStr =[[number decimalNumberByRoundingAccordingToBehavior:roundingBehavior] stringValue];
    if (!comma)
        return tempStr;
    
    NSArray *stringArr = [tempStr componentsSeparatedByString:@"."];
    NSMutableString *stringDot = [NSMutableString string];
    NSString *string = stringArr.firstObject;
    NSString *prefix = @"";
    if ([string hasPrefix:@"-"]) {
        string = [string substringFromIndex:1];
        prefix = @"-";
    }
    for (int idx = 1; 3 < string.length; idx ++) {
        [stringDot insertString:[NSString stringWithFormat:@",%@", [string substringFromIndex:string.length - 3]] atIndex:0];
        string = [string substringToIndex:string.length - 3];
    }
    [stringDot insertString:string atIndex:0];
    if (stringArr.count > 1) {
        [stringDot appendFormat:@".%@", stringArr.lastObject];
    }
    [stringDot insertString:prefix atIndex:0];

    return stringDot;
}

NSString *formarterPrice(double price, NSInteger dot) {
    return formarterPriceMode(price, dot, true, NSRoundPlain);
}

NSString *formarterPriceNoDot(double price, NSInteger dot) {
    return formarterPriceMode(price, dot, false, NSRoundPlain);
}

double priceFromString(NSString *string)
{
    NSString *number = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@".0123456789"] invertedSet]] componentsJoinedByString:@""];

    return [number doubleValue];
}

NSString *formatterWan(double value)
{
    NSString *volumeString = nil;
    
    BOOL ISCNY = true;
    if (ISCNY) {
        if (value >= 100000000) {
            volumeString = [NSString stringWithFormat:@"%.2f亿",value / 100000000.];
        } else if (value >= 10000) {
            volumeString = [NSString stringWithFormat:@"%.2f万",value / 10000.];
        } else {
            volumeString = formarterLimitPrice(value);
        }
    } else {
        if (value >= 1000. * 1000 * 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fb",value / (1000. * 1000 * 1000)];
        } else if (value >= 1000 * 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fm",value / (1000. * 1000)];
        } else if (value >= 1000) {
            volumeString = [NSString stringWithFormat:@"%.2fk",value / 1000.];
        } else {
            volumeString = formarterLimitPrice(value);
        }
    }
    
    return volumeString;
}

NSString *formatterKlinePrice(double price) {
    if (ABS(price) < 0.0000000001) { // 0.00000001
        return @"0";
    }
    if (price < 0.00000001) {
        return formarterPrice(price, 10);
    }
    if (price < 0.001) {
        return formarterPrice(price, 8);
    }
    if (price < 1) {
        return formarterPrice(price, 6);
    }
    if (price < 100) {
        return formarterPrice(price, 4);
    }
    if (price > 1000000) {
        return formatterWan(price);
    }
    
    return formarterPrice(price, 2);
}

double getPriceLetterDot(double price)
{
    if (floor(price) == price)
        return 1;
    if (fabs(round(price * 10) / 10. - price) < DOUBLE_ZERO_ERROR)
        return 0.1;
    if (fabs(round(price * 100) / 100. - price) < DOUBLE_ZERO_ERROR)
        return 0.01;
    if (fabs(round(price * 1000) / 1000. - price) < DOUBLE_ZERO_ERROR)
        return 0.001;
    if (fabs(round(price * 10000) / 10000. - price) < DOUBLE_ZERO_ERROR)
        return 0.0001;
    if (fabs(round(price * 100000) / 100000. - price) < DOUBLE_ZERO_ERROR)
        return 0.00001;
    if (fabs(round(price * 1000000) / 1000000. - price) < DOUBLE_ZERO_ERROR)
        return 0.000001;
    if (fabs(round(price * 10000000) / 10000000. - price) < DOUBLE_ZERO_ERROR)
        return 0.0000001;
    if (fabs(round(price * 100000000) / 100000000. - price) < DOUBLE_ZERO_ERROR)
        return 0.00000001;
    
    return 0.00000001;
}



@implementation NSString (Formatter)

+ (NSString *)spaceNumber:(long long)number dot:(int)dot
{
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = dot;
    formatter.minimumFractionDigits = dot;
    return [formatter stringFromNumber:@(number)];
}

- (NSString *)addPrefixWithPercent:(double)percent
{
    return [NSString stringWithFormat:@"%@%@",percent>0 ? @"+":@"", self];
}

+ (NSString *)spaceNumber:(long long)number {
    NSNumberFormatter * formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [formatter stringFromNumber:@(number)];
}

- (NSString *)URLDecode
{
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)URLEncode
{
    return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

- (NSDictionary *)getUrlParamters
{
    NSMutableDictionary *paramters = [NSMutableDictionary dictionary];
    [[self componentsSeparatedByString:@"&"] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *keyValue = [obj componentsSeparatedByString:@"="];
        
        NSString *key = keyValue.firstObject;
        if ([key isKindOfClass:[NSString class]] && keyValue.count == 2) {
            paramters[key] = keyValue.lastObject;
        }
    }];
    
    return paramters;
}

+ (NSString *)timeWithTimeIntervalString:(NSTimeInterval)timeString
{
    return [self timeymdhsWithTimeIntervalString:timeString formatter:@"yyyy-MM-dd"];
}

+ (NSString *)timeWithHourMinTimeIntervalString:(NSTimeInterval)timeString
{
    return [self timeymdhsWithTimeIntervalString:timeString formatter:@"HH:mm"];
}
+ (NSString *)timeWithMonthDayTimeIntervalString:(NSTimeInterval)timeString
{
    return [self timeymdhsWithTimeIntervalString:timeString formatter:@"MM-dd"];
}

+ (NSString *)randomChar:(NSInteger)count {
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSString * result = [[NSMutableString alloc] initWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
}

//yyyy-MM-dd a HH:mm:ss EEEE
+ (NSString *)timeymdhsWithTimeIntervalString:(NSTimeInterval)timeString formatter:(NSString *)formater
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone =  [NSTimeZone localTimeZone];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formater];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:timeString];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)timeymdhsWithTimeIntervalString:(NSTimeInterval)timeString
{
    return [self timeymdhsWithTimeIntervalString:timeString formatter:@"yyyy-MM-dd HH:mm"];
}

- (NSString *)md5
{
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call

	NSMutableString *hash = [NSMutableString string];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
		[hash appendFormat:@"%02X", result[i]];
	return [hash lowercaseString];
}

- (NSString *)sha
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    //使用对应的CC_SHA1,CC_SHA256,CC_SHA384,CC_SHA512的长度分别是20,32,48,64
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    //使用对应的CC_SHA256,CC_SHA384,CC_SHA512
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

/**
 *  加密方式,MAC算法: HmacSHA256
 *  @param key       秘钥
 *  @return 加密后的字符串
 */
- (NSString *)hmacSHA256WithKey:(NSString *)key
{
    NSData *HMACData = [self dataHmacSHA256WithKey:key];
    const unsigned char *buffer = (const unsigned char *)[[self dataHmacSHA256WithKey:key] bytes];
    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
    for (int i = 0; i < HMACData.length; ++i){
        [HMAC appendFormat:@"%02x", buffer[i]];
    }
    
    return HMAC;
}

- (NSData *)dataHmacSHA256WithKey:(NSString *)key
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [self cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];

    return HMACData;
}

- (NSString *)hmacMD5WithKey:(NSString *)keyStr
{
    const char *cKey  = [keyStr cStringUsingEncoding:NSUTF8StringEncoding];
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    const unsigned int blockSize = 64;
    char ipad[blockSize];
    char opad[blockSize];
    char keypad[blockSize];
    
    unsigned int keyLen = (unsigned int)strlen(cKey);
    CC_MD5_CTX ctxt;
    if (keyLen > blockSize) {
        CC_MD5_Init(&ctxt);
        CC_MD5_Update(&ctxt, cKey, keyLen);
        CC_MD5_Final((unsigned char *)keypad, &ctxt);
        keyLen = CC_MD5_DIGEST_LENGTH;
    }
    else {
        memcpy(keypad, cKey, keyLen);
    }
    
    memset(ipad, 0x36, blockSize);
    memset(opad, 0x5c, blockSize);
    
    int i;
    for (i = 0; i < keyLen; i++) {
        ipad[i] ^= keypad[i];
        opad[i] ^= keypad[i];
    }
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, ipad, blockSize);
    CC_MD5_Update(&ctxt, cData, (CC_LONG)strlen(cData));
    unsigned char md5[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(md5, &ctxt);
    
    CC_MD5_Init(&ctxt);
    CC_MD5_Update(&ctxt, opad, blockSize);
    CC_MD5_Update(&ctxt, md5, CC_MD5_DIGEST_LENGTH);
    CC_MD5_Final(md5, &ctxt);
    
    const unsigned int hex_len = CC_MD5_DIGEST_LENGTH*2+2;
    char hex[hex_len];
    for(i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        snprintf(&hex[i*2], hex_len-i*2, "%02x", md5[i]);
    }
    
    NSData *HMAC = [[NSData alloc] initWithBytes:hex length:strlen(hex)];
    NSString *hash = [[NSString alloc] initWithData:HMAC encoding:NSUTF8StringEncoding];
    return hash;
}

//返回大小写字母和数字
+ (NSString *)randomLetterAndNumber:(int)count
{
    //定义一个包含数字，大小写字母的字符串
    NSString * strAll = @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    //定义一个结果
    NSString * result = [[NSMutableString alloc]initWithCapacity:count];
    for (int i = 0; i < count; i++)
    {
        //获取随机数
        NSInteger index = arc4random() % (strAll.length-1);
        char tempStr = [strAll characterAtIndex:index];
        result = (NSMutableString *)[result stringByAppendingString:[NSString stringWithFormat:@"%c",tempStr]];
    }
    
    return result;
}

+ (NSString *)formatPercentFromChange:(id)change{
    if (change == nil)
        return @"--";
    NSString *str;
    if ([change isKindOfClass: [NSString class]]){
        NSString *s = (NSString *)change;
        if ([s containsString: @"%%"]){
            str = s;
        }
        else{
            str = [NSString stringWithFormat:@"%@%%", s];
        }
    }
    else if([change isKindOfClass: [NSNumber class]]){
        double changeValue = 100*[change doubleValue];
        str = [NSString stringWithFormat:@"%.2lf%%", changeValue];
    }
    if ([str containsString: @"-"] || [str containsString: @"+"]){
    }
    else{
        str = [NSString stringWithFormat:@"+%@", str];
    }
    return str;
}

@end
