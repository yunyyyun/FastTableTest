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
    
    NSURL *url = [NSURL URLWithString: data.logo];
    if (url){
        [self.logoImageView sd_setImageWithURL:url ];
    }
    self.symbolLabel.text = data.symbol;
    self.nameLabel.text = data.alias;
    self.rankLabel.text = [NSString stringWithFormat: @"%@", data.rank];
    self.symbolLabel.text = data.symbol;
    self.marketCapLabel.text = [NSString stringWithFormat: @"市值 ¥%@", data.marketCapCnyDisplay];
    self.priceLabel.text = data.priceUsdDisplay;
    self.convertPriceLabel.text = [NSString stringWithFormat: @"≈¥%@", data.priceCnyDisplay];
    
    double percentChange24h = [data.percentChange24h doubleValue];
    NSString *percentChange24hStr = [NSString stringWithFormat: @"%.2f%%", percentChange24h *100];
    if (![percentChange24hStr containsString: @"-"]){
        percentChange24hStr = [NSString stringWithFormat: @"+%@", percentChange24hStr];
    }
    [self.changePercentButton setTitle: percentChange24hStr forState: UIControlStateNormal];
    if (percentChange24h>=0){
        self.changePercentButton.backgroundColor = [UIColor colorWithRed: 235/255.0 green: 47/255.0 blue: 47/255.0 alpha: 0.9];
    }
    else{
        self.changePercentButton.backgroundColor = [UIColor colorWithRed: 0/255.0 green: 167/255.0 blue: 50/255.0 alpha: 0.9];
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