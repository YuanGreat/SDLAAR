//
//  HistoryDetailController.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/22.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "HistoryDetailController.h"
#import <UIKit/UIKit.h>
#import "UIColor+PMColors.h"
#import "AADataModel.h"
#import "AATool.h"
#import "AAPMCell.h"
#import "AATimeCell.h"

@interface HistoryDetailController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) NSMutableArray *dataList;
@end

@implementation HistoryDetailController

- (instancetype)initHistoryDetailControllerByDataList:(NSArray *)dataList{
    self = [super init];
    if (self) {
        self.dataList = [NSMutableArray arrayWithArray:dataList];
        
        NSLog(@"self.dataList%@",self.dataList);
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataTable = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.dataTable.delegate = self;
    self.dataTable.dataSource = self;
    [self.view addSubview:self.dataTable];
}

//table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AADataModel *model = self.dataList[indexPath.row];
    if ([model.ifOpen isEqualToString:@"YES"]) {
        return 105;
    }else{
        return 40;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AATimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"timeCell"];
    if (timeCell == nil) {
        timeCell = [[[NSBundle mainBundle] loadNibNamed:@"AATimeCell" owner:nil options:nil] firstObject];
    }
    [timeCell.selectedButton setTitle:[NSString stringWithFormat:@"%ld",indexPath.row] forState:UIControlStateNormal];
    [timeCell.selectedButton addTarget:self action:@selector(timeLabelSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    AADataModel *dataModel = [[AADataModel alloc] init];
    dataModel = self.dataList[indexPath.row];
    
    NSLog(@"dataModel.sending_side  -----------  %@",dataModel.sending_side);
    
    
    [timeCell configureCellByModel:dataModel];
    return timeCell;
}

- (void)timeLabelSelected:(UIButton *)sender{
    NSInteger index = sender.titleLabel.text.integerValue;
    
    AADataModel *model = self.dataList[index];
    
    NSLog(@"index  -------  %ld    model.type %@",index,model.sending_side);
    if ([model.ifOpen isEqualToString:@"NO"]) {
        model.ifOpen = @"YES";
    }else{
        model.ifOpen = @"NO";
    }
    [self.dataList replaceObjectAtIndex:index withObject:model];
    [self.dataTable reloadData];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}




@end
