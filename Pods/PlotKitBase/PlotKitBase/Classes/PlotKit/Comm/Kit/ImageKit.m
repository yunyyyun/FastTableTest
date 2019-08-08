//
//  ImageKit.m
//  TZYJ_IPhone
//
//  Created by Mernushine on 17/4/18.
//
//

#import "ImageKit.h"

@implementation ImageKit

UIImage *imageWithColor(UIColor *color) {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

UIImage *imageWithName(NSString *imageName) {
    if (!imageName || imageName.length == 0) {
        return nil;
    }
    
    return [UIImage imageNamed:imageName];
    
    /*
     NSString *imageSuffix = @".png";
     if ([imageName hasSuffix:imageSuffix]) {
     return [UIImage imageNamed:imageName inBundle:nil compatibleWithTraitCollection:nil];
     }
     
     imageName = [NSString stringWithFormat:@"%@.png", imageName];
     
     return [UIImage imageNamed:imageName inBundle:nil compatibleWithTraitCollection:nil];
     */
}

@end
