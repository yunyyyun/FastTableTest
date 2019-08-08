//
//  UIButton+EnlargeEdge.h
//  TZYJ_IPhone
//
//  Created by 邵运普 on 2017/9/15.
//
//

#import <UIKit/UIKit.h>

@interface UIButton (EnlargeEdge)

- (void)setEnlargeEdge:(CGFloat)size;
- (void)setEnlargeEdge:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

@end
