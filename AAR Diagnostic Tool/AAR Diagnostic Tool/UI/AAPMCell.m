//
//  AAPMCell.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/21.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "AAPMCell.h"
#import "AADataModel.h"
#import "AATool.h"

@interface AAPMCell ()

@property (weak, nonatomic) IBOutlet UILabel *exteriorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *exteriorStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cabinValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *cabinStateLabel;

@end

@implementation AAPMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellByModel:(AADataModel *)model{
    self.exteriorValueLabel.text = [NSString stringWithFormat:@"Exterior PM Value: %@",model.exterior_PM_value];
 self.exteriorStateLabel.text = [NSString stringWithFormat:@"Exterior PM Diagnostic State: %@",[AATool diagnosticStateByCode:model.exrerior_PM_diagnostic_state]];
    self.cabinValueLabel.text = [NSString stringWithFormat:@"Cabin PM Value: %@",model.cabin_PM_value];
    self.cabinStateLabel.text = [NSString stringWithFormat:@"Cabin PM Diagnostic State: %@",[AATool diagnosticStateByCode:model.cabin_PM_diagnostic_state]];
    
}

@end
