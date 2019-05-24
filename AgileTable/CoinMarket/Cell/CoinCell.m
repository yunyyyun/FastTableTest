//
//  CoinCell.m
//  AgileTable
//
//  Created by mengyun on 2019/5/17.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "CoinCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CoinCell()

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *symbolLabel;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;
@property (strong, nonatomic) IBOutlet UILabel *marketCapLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *convertPriceLabel;
@property (strong, nonatomic) IBOutlet UIButton *changePercentButton;
@property (strong, nonatomic) IBOutlet UIImageView *goingStatusImageView;

@end

@implementation CoinCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.changePercentButton.layer.cornerRadius = 2;
    self.isAlphaSelect = true;
}

- (void)setDataModel:(CurrencyData *)data
      viewController:(UIViewController *)viewController
           tableView:(UITableView *)tableView{
    [super setDataModel: data viewController: viewController tableView: tableView];
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

+ (CGFloat)heightWithData:(id)data width:(CGFloat)width{
    return 66;
}

@end
