//
//  CoinDetailViewController.m
//  AgileTable
//
//  Created by mengyun on 2019/5/26.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CoinDetailViewController.h"

@interface CoinDetailViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CurrencyData *currency;

@end

@implementation CoinDetailViewController

+ (CoinDetailViewController *)viewControllerWithCurrency: (CurrencyData *)currency{
    CoinDetailViewController *detailVC = [[CoinDetailViewController alloc] init];
    detailVC.currency = currency;
    detailVC.hidesBottomBarWhenPushed = true;
    return detailVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.currency.symbol;
    self.titleLabel.text = @"详情页面 todo";
}

- (UILabel *)titleLabel{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(100, 100, 200, 100)];
        [self.view addSubview: _titleLabel];
    }
    return _titleLabel;
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
