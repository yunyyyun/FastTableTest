
//
//  SizeAndNumberKit.h
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/18.
// 数字相关工具 number money
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

/**
 *    Precision Types
 */

#define FLOAT_ZERO_ERROR       0.0000001   //浮点0值误差
#define PRICE_ZERO_ERROR       0.0001      //浮点0价格误差


@interface NumberKit : NSObject


#pragma mark - 与0比较，考虑精度
BOOL lowerThanOrEqualToZero(double value);

BOOL zeroValue(double value);

/**
 *  将double类型的数据，按照保留decimals个小数后，返回格式化的字符串
 *  规则：四舍五入
 */
NSString *formatNumberWithDoubleAndDecimals(double doubleValue ,NSInteger decimals);

#pragma mark - ********* format price money
/**
 *  大额资产数据转换成千亿、亿、万等，还是参考恒生的做法
 *
 *  @param priceValue 一般是大额资产数据
 *  @param digits     小数位数
 */
NSString *formatBigPriceValueWithDigits(long double priceValue, NSInteger digits);

@end

