//
//  PieChartsView.h
//  GoIco
//
//  Created by zhulihong on 2017/10/24.
//  Copyright © 2017年 ico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PieChartsView : UIView

@property (nonatomic, strong) NSArray *pies;
@property (nonatomic, strong) NSArray<UIColor *> *colors;

@property (assign, nonatomic) BOOL showLabel;
@property (nonatomic, assign) BOOL isHollow;
@property (nonatomic, strong) UIFont *font;
@property (strong, nonatomic) NSArray<NSString *> *labelTitles;

- (void)strokeAnimation;

@end
