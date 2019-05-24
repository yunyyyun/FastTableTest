//
//  MYTabBarViewController.m
//  AgileTable
//
//  Created by mengyun on 2019/5/24.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "MYTabBarViewController.h"
#import "YYFPSLabel.h"

@interface MYTabBarViewController ()
@property (nonatomic, strong) YYFPSLabel *fpsLabel;
@end

@implementation MYTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (fpsEnabled)
        [self testFPSLabel];
}

#pragma mark - FPS demo

- (void)testFPSLabel {
    _fpsLabel = [YYFPSLabel new];
    _fpsLabel.frame = CGRectMake(4, 318, 50, 30);
    [_fpsLabel sizeToFit];
    [self.view addSubview:_fpsLabel];
    
    // 如果直接用 self 或者 weakSelf，都不能解决循环引用问题
    
    // 移除也不能使 label里的 timer invalidate
    //        [_fpsLabel removeFromSuperview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
