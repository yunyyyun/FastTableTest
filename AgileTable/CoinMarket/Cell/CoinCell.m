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
#import "CoinView.h"

@interface CoinCell()<UIScrollViewDelegate>

//@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
//@property (strong, nonatomic) IBOutlet UILabel *symbolLabel;
//@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
//@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
//@property (strong, nonatomic) IBOutlet UILabel *marketCapLabel;
//@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
//@property (strong, nonatomic) IBOutlet UILabel *convertPriceLabel;
//@property (strong, nonatomic) IBOutlet UIButton *changePercentButton;
//@property (strong, nonatomic) IBOutlet UIImageView *goingStatusImageView;
@property (weak, nonatomic) IBOutlet PriceHistoryView *priceTrendView;
@property (weak, nonatomic) CoinView *coinView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *leftView;
@property (strong, nonatomic) IBOutlet UIView *rightView;

@end

@implementation CoinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
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

- (void)setDataModel:(DMCurrency *)data
      viewController:(UIViewController *)viewController
           tableView:(UITableView *)tableView{
    [super setDataModel: data viewController: viewController tableView: tableView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width *2 + 100, 0);
        CGFloat w = self.scrollView.frame.size.width;
        CGFloat offsetX = w+[data.pageNum intValue]*w;
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
        self.coinView.frame = CGRectMake(0, 0, self.middleView.frame.size.width, 66);
        [self.scrollView layoutIfNeeded];
        [self.scrollView setNeedsDisplay];
    });
    
    self.currency = data;
    self.coinView.currency = data;
    //[self.logoImageView sd_setImageWithURL:[NSURL URLWithString:data.logo]];
    
//    // 价格变动动画
//    [self updatePriceStatus];
//    if (!data.isAnimated) {
//        NSTimeInterval duration = 2;
//        [data animation:duration];
//        @weakify(self);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 0.02) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            @strongify(self);
//            [self updatePriceStatus];
//        });
//    }
//
//    self.rankLabel.text = data.display_rank;
//    self.rankLabel.textColor = data.rank<4 ? [UIColor yellowColor] : [UIColor colorWithWhite: 191/255.0 alpha:1];
//    if (data.rank>9999){
//        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightRegular];
//        self.rankLabel.text = @"999+";
//    }
//    else if (data.rank<4){
//        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightMedium];
//    }
//    else{
//        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightRegular];
//    }
//    //
//    //
//    BOOL hiddenRank = false;
//    if (data.typeDetail>0)
//        hiddenRank = true;
//    self.rankLabel.hidden = hiddenRank;
//    BOOL hiddenCoinImage = false;
//    if (data.typeDetail>0 && data.typeDetail<4)
//        hiddenCoinImage = true;
//    self.logoImageView.hidden = hiddenCoinImage;
////    self.coinWidth.constant = hiddenCoinImage? 0 : 18;
////    self.leadingSpace.constant = hiddenCoinImage? 0 : 12;
//
//    self.nameLabel.attributedText = data.display_name;
//    self.priceLabel.text = data.display_price;
//    self.volumeLabel.text = data.display_volume;
//    self.convertPriceLabel.text = data.display_convertprice;
//    self.changeLabel.text = data.display_changepercent;
//
//    if ([data.changePercent isKindOfClass: [NSNumber class]]){
//        self.changeImageView.backgroundColor = [data.changePercent doubleValue]>=0 ? [DMConfig sharedObjcet].changeUpColor : [DMConfig sharedObjcet].changeDownColor;
//    }
//    else{
//        self.changeImageView.backgroundColor = [UIColor colorWithWhite:153/255.0 alpha: 0.4];
//    }
    
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

- (CoinView *)coinView{
    if (!_coinView){
        _coinView = [[NSBundle mainBundle] loadNibNamed:@"CoinView" owner:nil options:nil].firstObject;
        _coinView.backgroundColor = [UIColor redColor];
        [self.middleView addSubview: _coinView];
    }
    return _coinView;
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

+ (CGFloat)heightWithData:(DMCurrency *)data width:(CGFloat)width{
    return [data.height doubleValue];
}

@end
