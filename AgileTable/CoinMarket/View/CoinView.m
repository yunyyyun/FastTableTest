//
//  CoinView.m
//  GoIco
//
//  Created by Violet on 2018/1/29.
//  Copyright © 2018年 ico. All rights reserved.
//

#import "CoinView.h"
#import "CurrencyData.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CoinView ()


@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *changeLabel;
@property (strong, nonatomic) IBOutlet UILabel *volumeLabel;
@property (strong, nonatomic) IBOutlet UILabel *convertPriceLabel;

@property (strong, nonatomic) IBOutlet UIImageView *changeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *goingImageView;
@property (strong, nonatomic) IBOutlet UIImageView *coinImageView;
@property (strong, nonatomic) IBOutlet UILabel *rankLabel;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *coinWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *leadingSpace;

@end

@implementation CoinView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setCurrency:(DMCurrency *)currency{
    _currency = currency;
    // 价格变动动画
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
    
    [self.coinImageView sd_setImageWithURL:[NSURL URLWithString:currency.logo]];
    self.rankLabel.text = currency.display_rank;
    self.rankLabel.textColor = currency.rank<4 ? [UIColor redColor] : [UIColor colorWithWhite: 191/255.0 alpha:1];
    if (currency.rank>9999){
        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightRegular];
        self.rankLabel.text = @"999+";
    }
    else if (currency.rank<4){
        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightMedium];
    }
    else{
        self.rankLabel.font = [UIFont systemFontOfSize:11 weight: UIFontWeightRegular];
    }
    //
    //
    BOOL hiddenRank = false;
//    if (data.typeDetail>0)
//        hiddenRank = true;
//    self.rankLabel.hidden = hiddenRank;
//    BOOL hiddenCoinImage = false;
//    if (data.typeDetail>0 && data.typeDetail<4)
//        hiddenCoinImage = true;
//    self.coinImageView.hidden = hiddenCoinImage;
//    self.coinWidth.constant = hiddenCoinImage? 0 : 18;
//    self.leadingSpace.constant = hiddenCoinImage? 0 : 12;
    
    self.nameLabel.attributedText = currency.display_name;
    self.priceLabel.text = currency.display_price;
    self.volumeLabel.text = currency.display_volume;
    self.convertPriceLabel.text = currency.display_convertprice;
    self.changeLabel.text = currency.display_changepercent;

    if ([currency.changePercent isKindOfClass: [NSNumber class]]){
        self.changeImageView.backgroundColor = [currency.changePercent doubleValue]>=0 ? changeUpColor : changeDownColor;
    }
    else{
        self.changeImageView.backgroundColor = [UIColor colorWithWhite:153/255.0 alpha: 0.4];
    }
}

@end
