//
//  HistoryDetailController.h
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/22.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryDetailController : UIViewController

@property (nonatomic,strong) UITableView *dataTable;

- (instancetype)initHistoryDetailControllerByDataList:(NSArray *)dataList;

@end
