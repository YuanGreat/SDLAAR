//
//  AATimeCell.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/21.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "AATimeCell.h"
#import "AADataModel.h"
#import "AATool.h"


@interface AATimeCell ()

@property (weak, nonatomic) IBOutlet UIImageView *arrowImage;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet UILabel *exteriorValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *exteriorStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *cabinValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *cabinStateLabel;

@end

@implementation AATimeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.dateLabel.adjustsFontSizeToFitWidth = YES;
    self.secondLabel.adjustsFontSizeToFitWidth = YES;
    self.exteriorValueLabel.adjustsFontSizeToFitWidth = YES;
    self.exteriorStateLabel.adjustsFontSizeToFitWidth = YES;
    self.cabinValueLabel.adjustsFontSizeToFitWidth = YES;
    self.cabinStateLabel.adjustsFontSizeToFitWidth = YES;
    self.exteriorValueLabel.numberOfLines = 0;
    self.exteriorStateLabel.numberOfLines = 0;
    self.cabinValueLabel.numberOfLines = 0;
    self.cabinStateLabel.numberOfLines = 0;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCellByModel:(AADataModel *)model{
    self.dateLabel.text = [NSString stringWithFormat:@"Date: %@",model.date];
    self.secondLabel.text = [NSString stringWithFormat:@"Time: %@",model.time];
    if ([model.ifOpen isEqualToString:@"YES"]) {
        self.exteriorValueLabel.hidden = NO;
        self.exteriorStateLabel.hidden = NO;
        self.cabinValueLabel.hidden = NO;
        self.cabinStateLabel.hidden = NO;
        self.exteriorValueLabel.text = [NSString stringWithFormat:@"Exterior PM Value: %@",model.exterior_PM_value];
        self.exteriorStateLabel.text = [NSString stringWithFormat:@"Exterior PM Diagnostic State: %@",[AATool diagnosticStateByCode:model.exrerior_PM_diagnostic_state]];
        self.cabinValueLabel.text = [NSString stringWithFormat:@"Cabin PM Value: %@",model.cabin_PM_value];
        self.cabinStateLabel.text = [NSString stringWithFormat:@"Cabin PM Diagnostic State: %@",[AATool diagnosticStateByCode:model.cabin_PM_diagnostic_state]];
        self.arrowImage.image = [UIImage imageNamed:@"arrowDown"];
    }else{
        self.exteriorValueLabel.hidden = YES;
        self.exteriorStateLabel.hidden = YES;
        self.cabinValueLabel.hidden = YES;
        self.cabinStateLabel.hidden = YES;
        self.arrowImage.image = [UIImage imageNamed:@"arrowUp"];
    }
}

- (void)changeArrowWithUp:(BOOL)isOpen{
    if (isOpen) {
        self.arrowImage.image = [UIImage imageNamed:@"arrowDown"];
    }else{
        self.arrowImage.image = [UIImage imageNamed:@"arrowUp"];
    }
}

@end
