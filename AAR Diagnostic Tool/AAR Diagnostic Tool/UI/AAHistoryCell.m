//
//  AAHistoryCell.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/22.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "AAHistoryCell.h"
#import "AADataModel.h"

@interface AAHistoryCell ()

@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation AAHistoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configureCellByName:(NSString *)name{
    NSArray *array = [name componentsSeparatedByString:@"_"];
//    Routine1_11_27_2017_13:51:51
    NSString *minuteString = array.lastObject;
   // NSArray *minuteArray = [minuteString componentsSeparatedByString:@":"];
    NSLog(@"array --------- %@",array);
    
    self.typeLabel.text = [NSString stringWithFormat:@"%@",array[0]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@.%@.%@ %@",array[1],array[2],array[3],minuteString];
}


@end
