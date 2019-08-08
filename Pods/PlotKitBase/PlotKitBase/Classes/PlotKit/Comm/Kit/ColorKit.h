//
//  ColorKit.h
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/18.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@interface ColorKit : NSObject
#pragma mark - ****************** color  *****************
/**
 * @prama hexValue 例如0xfafafa
 * @prama alphaValue 0 ~ 1
 */
UIColor *colorWithHexWithAlpha(NSInteger hexValue, CGFloat alphaValue);
/**
 * @prama hexValue 例如0xfafafa
 */
UIColor *colorWithHex(NSInteger hexValue);

@end
