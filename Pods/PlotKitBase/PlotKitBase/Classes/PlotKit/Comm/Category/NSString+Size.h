//
//  NSString+Size.h
//  CGAEvents
//
//  Created by zhulihong on 16/10/17.
//  Copyright © 2016年 zhulihong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NSString *formarterLimitPrice_pkb(double price );

NSString *formatterKlinePrice_pkb(double price);

NSString *removeLastZero_pkb(NSString *dStr);

NSString *formatterWan_pkb(double value);

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Size)

- (CGFloat) widthWithFont:(UIFont *)font;
+(NSString *)formatterVolumeWith: (double )volume;

@end

NS_ASSUME_NONNULL_END
