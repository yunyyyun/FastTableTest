//
//  ImageKit.h
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/18.
//
//

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE || TARGET_OS_TV
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@interface ImageKit : NSObject

UIImage *imageWithColor(UIColor *color);

UIImage *imageWithName(NSString *imageName);

@end
