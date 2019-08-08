//
//  CoinCell.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CoinCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PriceHistoryView.h"

@interface CoinCell()<UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *symbolLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UILabel *marketCapLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *convertPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *changePercentButton;
@property (strong, nonatomic) IBOutlet UIImageView *goingStatusImageView;
@property (weak, nonatomic) IBOutlet PriceHistoryView *priceTrendView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;

@end

@implementation CoinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.changePercentButton.layer.cornerRadius = 2;
    // self.isAlphaSelect = true;
    
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = false;
    self.scrollView.bounces = false;
    
    self.leftView.layer.borderColor = [UIColor grayColor].CGColor;
    self.leftView.layer.cornerRadius = 12;
    self.leftView.layer.borderWidth = 1;
    
    self.middleView.layer.borderColor = [UIColor grayColor].CGColor;
    self.middleView.layer.cornerRadius = 12;
    self.middleView.layer.borderWidth = 1;
}

- (void)setDataModel:(CurrencyData *)data
      viewController:(UIViewController *)viewController
           tableView:(UITableView *)tableView{
    [super setDataModel: data viewController: viewController tableView: tableView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width *2 + 100, 0);
        CGFloat w = self.scrollView.frame.size.width;
        CGFloat offsetX = w+[data.pageNum intValue]*w;
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
        [self.scrollView layoutIfNeeded];
        [self.scrollView setNeedsDisplay];
    });
    
    self.currency = data;
    NSURL *url = [NSURL URLWithString: data.logo];
    if (url){
        [self.logoImageView sd_setImageWithURL:url ];
    }
    self.symbolLabel.text = data.symbol;
    self.nameLabel.text = data.alias;
    self.rankLabel.text = [NSString stringWithFormat: @"%@", data.rank];
    self.symbolLabel.text = data.symbol;
    self.marketCapLabel.text = [NSString stringWithFormat: @"市值 ¥%@", data.marketCapCnyDisplay];
    self.priceLabel.text = [NSString stringWithFormat: @"$%@", data.priceUsdDisplay];
    self.convertPriceLabel.text = [NSString stringWithFormat: @"≈¥%@", data.priceCnyDisplay];
    
    double percentChange24h = [data.percentChange24h doubleValue];
    NSString *percentChange24hStr = [NSString stringWithFormat: @"%.2f%%", percentChange24h *100];
    if (![percentChange24hStr containsString: @"-"]){
        percentChange24hStr = [NSString stringWithFormat: @"+%@", percentChange24hStr];
    }
    [self.changePercentButton setTitle: percentChange24hStr forState: UIControlStateNormal];
    if (percentChange24h>=0){
        self.changePercentButton.backgroundColor = changeUpColor;
    }
    else{
        self.changePercentButton.backgroundColor = changeDownColor;
    }
    
    //价格变动动画
    [self updatePriceStatus];
    if (![data.isAnimated isEqualToNumber: isInAnimation]) {
        NSTimeInterval duration = 2;
        [data animation:duration];
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 0.02) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self updatePriceStatus];
        });
    }
    
    _priceTrendView.showVolume = false;
    _priceTrendView.showTime = true;
    _priceTrendView.scrollable = true;
    _priceTrendView.showPrice = true;
    
    [self setupTrendView: nil];
}

- (IBAction)setupTrendView:(id)sender {
    if (_currency.trendDatas.count <1){
        UIButton *btn = (UIButton *) sender;
        NSInteger tag = btn.tag;
        int count = (int)tag;
        if (count==0){
            count = 30;
        }
        NSMutableArray<HistoryPriceData *> *datas = [[NSMutableArray alloc] init];
        for (int i=0; i<count; ++i){ // 模拟价格趋势数据
            double price = 47.3 + (arc4random() % 100)/1000.0;
            double time = 1553662837 + i*574000;
            double volume = 10133900000 + arc4random() % 9133900000;
            HistoryPriceData *d0 = [HistoryPriceData dataWithPrice:price time: time volume: volume];
            [datas addObject: d0];
        }
        
        _currency.trendDatas = datas;
        _priceTrendView.layer.masksToBounds = false;
    }
    _priceTrendView.datas = _currency.trendDatas;
}

- (IBAction)onOpen:(UIButton *)sender {
    if ([self.currency.height isEqualToNumber: @cellDefaultHeight]){
        self.currency.height = @400;
    }
    else if ([self.currency.height isEqualToNumber: @400]){
        self.currency.height = @cellDefaultHeight;
    }
    else{
        self.currency.height = @cellDefaultHeight;
    }
    
    [self reload];
}

- (void) reload{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [self.tableView indexPathForCell: self];
        if (indexPath)
            [self.tableView reloadRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationFade];
    });
}

- (IBAction)goToDetail:(UIButton *)sender {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.viewController.navigationController pushViewController: vc animated: true];
}

- (void)updatePriceStatus
{
    if ([self.currency.lastChange doubleValue] >=  minVailedPrice){
        self.priceLabel.textColor = changeUpColor;
        self.goingStatusImageView.image = changeUpImage;
        self.goingStatusImageView.hidden = false;
    }
    else if ([self.currency.lastChange doubleValue] <= -minVailedPrice){
        self.priceLabel.textColor = changeDownColor;
        self.goingStatusImageView.image = changeDownImage;
        self.goingStatusImageView.hidden = false;
    }
    else{
        self.priceLabel.textColor = [UIColor darkTextColor];
        self.goingStatusImageView.hidden = true;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = scrollView.frame.size.width;
    EDLog(@"scrollViewDidScroll: %lf_%lf", scrollView.contentOffset.x, width);
    int page = (scrollView.contentOffset.x >= width ? 0 : -1);
    self.middleView.alpha = scrollView.contentOffset.x / width;
    self.leftView.alpha = 1 - self.middleView.alpha;
    _currency.pageNum = @(page);
    if (page==0){
        if (![self.currency.height isEqualToNumber: @cellDefaultHeight]){
            self.currency.height = @cellDefaultHeight;
            [self reload];
        }
    }
}

+ (CGFloat)heightWithData:(CurrencyData *)data width:(CGFloat)width{
    return [data.height doubleValue];
}

@end
