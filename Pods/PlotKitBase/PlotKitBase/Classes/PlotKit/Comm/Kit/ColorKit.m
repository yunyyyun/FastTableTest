//
//  ColorKit.m
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/18.
//
//

#import "ColorKit.h"

@implementation ColorKit
#pragma mark - ****************** color  *****************

UIColor *colorWithHexWithAlpha(NSInteger hexValue, CGFloat alphaValue) {
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hexValue & 0xFF00) >> 8)) / 255.0
                            blue:((float)(hexValue & 0xFF)) / 255.0
                           alpha:alphaValue];
}

UIColor *colorWithHex(NSInteger hexValue) {
    return colorWithHexWithAlpha(hexValue, 1.0);
}

@end
