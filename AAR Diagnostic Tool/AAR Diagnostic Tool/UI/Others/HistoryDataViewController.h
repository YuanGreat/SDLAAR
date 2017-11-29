//
//  HistoryDataViewController.h
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/9/22.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "ViewController.h"

@interface HistoryDataViewController : ViewController<UITableViewDelegate,UITableViewDataSource>

- (IBAction)didTapDeleteAllData:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UITableView *dataListTable;

@property (nonatomic, strong) NSMutableArray *historyDataList;

@end
