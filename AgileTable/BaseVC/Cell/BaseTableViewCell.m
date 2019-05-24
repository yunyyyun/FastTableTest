//
//  BaseTableViewCell.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface BaseTableViewCell ()

@property (nonatomic, assign) BOOL isBottomLineLeftSet;

@property (nonatomic, assign) CGFloat dragStart;
@property (nonatomic, strong) UIPanGestureRecognizer *rightActionPanGesture;

@end

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self _setupUI];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _setupUI];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _setupUI];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)_setupUI
{
    self.backgroundColor = [UIColor whiteColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // 分割线
    if (!self.isBottomLineLeftSet)
        self.bottomLineLeft = -1;
    
    // 手势
    if (self.rightPanSpace > 0)
        self.rightActionPanGesture.enabled = true;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.swipStatus = CellSwipStatusNone;
    [self resetContentView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat heightSeparatorLine = 0.5;
    UIColor *colorSeparatorLine = [UIColor colorWithWhite:102/155.0 alpha: 0.3];

    int bottomLineLeft = self.bottomLineLeft;
    int bottomLineRight = self.bottomLineRight;
    if (self.tempBottomLineLeft)
        bottomLineLeft = self.tempBottomLineLeft.intValue;
    if (self.tempBottomLineRight)
        bottomLineRight = self.tempBottomLineRight.intValue;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    if (bottomLineLeft >= 0) {
        CGContextMoveToPoint(c , bottomLineLeft, self.bounds.size.height - heightSeparatorLine);
        CGContextAddLineToPoint(c, self.bounds.size.width - bottomLineRight, self.bounds.size.height - heightSeparatorLine);
    }
    CGContextSetLineWidth(c, heightSeparatorLine);
    CGContextSetStrokeColorWithColor(c, colorSeparatorLine.CGColor);
    CGContextStrokePath(c);
}

/*!重画
 */
#define SetValue(_xx, xx) if (_xx==xx) return;\
_xx=xx; [self setNeedsDisplay];
- (void)setBottomLineLeft:(int)bottomLineLeft{
    self.isBottomLineLeftSet = true;
    SetValue(_bottomLineLeft, bottomLineLeft);
}
- (void)setBottomLineRight:(int)bottomLineRight{
    self.isBottomLineLeftSet = true;
    SetValue(_bottomLineRight, bottomLineRight);
}

- (void)setTempBottomLineLeft:(NSNumber *)tempBottomLineLeft{
    SetValue(_tempBottomLineLeft, tempBottomLineLeft);
}
- (void)setTempBottomLineRight:(NSNumber *)tempBottomLineRight{
    SetValue(_tempBottomLineRight, tempBottomLineRight);
}

+ (BOOL)isAvalublePresentabletDataModel:(id)data
{
    NSString *protocolName = [NSString stringWithFormat:@"%@Presentable", NSStringFromClass([self class])];
    if (![data conformsToProtocol:NSProtocolFromString(protocolName)]) {
        NSLog(@"在%@中data:%@没有实现:%@",NSStringFromClass([self class]),data,protocolName);
        return false;
    }
    
    return true;
}

/*!设置数据
 */
- (void)setDataModel:(id)data
      viewController:(UIViewController *)viewController
           tableView:(UITableView *)tableView
{
#ifdef INAPP
    self.backgroundColor = [AppColorConfig sharedObjcet].cellColor;
#endif
    _viewController = viewController;
    _tableView = tableView;
}

- (void)didSelectCell
{
    [self resetContentView];
}

+ (CGFloat)heightWithData:(id)data width:(CGFloat)width {
    return 44;
}

#pragma mark 左滑效果
- (void)setRightPanSpace:(CGFloat)rightPanSpace
{
    _rightPanSpace = rightPanSpace;
    self.rightActionPanGesture.enabled = rightPanSpace > 0;
}

- (UIPanGestureRecognizer *)rightActionPanGesture
{
    if (!_rightActionPanGesture) {
        _rightActionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(gestureHappened:)];
        _rightActionPanGesture.delegate = self;
        _rightActionPanGesture.enabled = false;
        [self.contentView addGestureRecognizer:_rightActionPanGesture];
    }
    
    return _rightActionPanGesture;
}

- (void)gestureHappened:(UIPanGestureRecognizer *)sender
{
    CGPoint translatedPoint = [sender translationInView:self];
    switch (sender.state)
    {
        case UIGestureRecognizerStatePossible:
            break;
        case UIGestureRecognizerStateBegan:
            self.dragStart = sender.view.center.x;
            [self resetOtherCellContentView];
            break;
        case UIGestureRecognizerStateChanged:
            [self updatePanProgress:MIN(1, MAX((self.contentView.frame.size.width / 2 - self.contentView.center.x ) / self.rightPanSpace, 0))];
            self.contentView.center = CGPointMake(self.dragStart + translatedPoint.x, self.contentView.center.y);
            break;
        case UIGestureRecognizerStateEnded:
            if (self.contentView.frame.size.width / 2 - self.contentView.center.x > self.rightPanSpace) {
                [self gestureAction];
            } else {
                [self resetContentView];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
    }
}

- (void)gestureAction
{
    self.swipStatus = CellSwipStatusAction;
    if (self.contentView.center.x == self.contentView.frame.size.width / 2) return;
    
    CGFloat bounceTime1 = 0.25;
    [UIView animateWithDuration:bounceTime1
                     animations:^{
                         self.contentView.center = CGPointMake(self.contentView.frame.size.width / 2 - self.rightPanSpace, self.contentView.center.y);
                     } completion:^(BOOL finished) {
                     }];
}

- (void)resetContentView
{
    self.swipStatus = CellSwipStatusNone;
    if (self.contentView.frame.origin.x == 0) return;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.center = CGPointMake(self.contentView.frame.size.width / 2, self.contentView.center.y);
    } completion:nil];
}

- (void)resetOtherCellContentView
{
    for (BaseTableViewCell *cell in [self.tableView visibleCells]) {
        if ([cell respondsToSelector:@selector(resetContentView)] && cell != self)
            [cell resetContentView];
    }
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        // Find the current vertical scrolling velocity
        CGFloat velocity = [(UIPanGestureRecognizer *)gestureRecognizer velocityInView:gestureRecognizer.view].y;
        
        // Return YES if no scrolling up
        return fabs(velocity) <= 0.2;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    if ( gestureRecognizer == self.rightActionPanGesture) {
        CGPoint translation = [gestureRecognizer translationInView:self.superview];
        return fabs(translation.y) <= fabs(translation.x) && (translation.x < 0 || self.swipStatus == CellSwipStatusAction);
    }
    else {
        return YES;
    }
}

- (void)updatePanProgress:(CGFloat)progress;//子类继承，左滑到rightPanSpace距离的进度，0~1
{
}

@end
