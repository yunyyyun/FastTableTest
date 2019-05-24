//
//  TitleCell.m
//  AgileTable
//
//  Created by mengyun on 2019/5/19.
//  Copyright © 2019 mengyun. All rights reserved.
//

#import "TitleCell.h"

@interface TitleCell()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation TitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setDataModel:(id)data viewController:(UIViewController *)viewController tableView:(UITableView *)tableView{
    [super setDataModel: data viewController: viewController tableView: tableView];
    self.titleLabel.text = data;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
