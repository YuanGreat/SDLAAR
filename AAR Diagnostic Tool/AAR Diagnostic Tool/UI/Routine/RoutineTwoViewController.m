//
//  RoutineTwoViewController.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/20.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "RoutineTwoViewController.h"
#import "AAClimateModel.h"
#import "AATool.h"
#import "AADataModel.h"
#import "ADConstants.h"
#import "UIColor+PMColors.h"

NSInteger const refreshTime2 = 30;   //刷新时间
NSInteger const transmissionRate2 = 3;  //增减幅度
NSInteger const maxPM2 = 100;   //PM2.5最大值
NSInteger const minPM2 = 0;  //PM2.5最小值
NSString * const disgnosticMode2 = @"Routine2";

@interface RoutineTwoViewController ()

@property (assign, nonatomic) NSInteger pm;  //pm2.5值
@property (assign , nonatomic) NSInteger count;  //发送次数
@property (assign, nonatomic) NSInteger sendTime;  //发送总共时长

@end

@implementation RoutineTwoViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"BasicRoutineViewController" bundle:nibBundleOrNil];
    if (self) {
        
        self.dataList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Routine 2";
    self.routineDelegate = self;
    self.pm = maxPM2;
   // [self showExteriorPMLabelAndColorThresholdByPM:[NSString stringWithFormat:@"%ld",(long)self.pm]];
}

#pragma mark routineDelegate
- (void)startRoutine{
    if (self.timer != nil) {
        return;
    }
    self.count = 0;
    self.pm = maxPM2;
    
     [self refreshExterior];
    //每隔30S app端向sync端发送数据 每次增加或递减 25ug/m^3
    self.timer = [NSTimer scheduledTimerWithTimeInterval:refreshTime2 target:self selector:@selector(refreshExterior) userInfo:nil repeats:YES];
}

- (void)refreshExterior{
    //到达循环次数和时间上限 app向sync停止发送数据
    self.pm = self.pm - transmissionRate2;
    if (self.pm < 0 || self.sendTime > [[NSUserDefaults standardUserDefaults] integerForKey:KRoutineRunTime] * 60) {
        [self.timer invalidate];
        self.timer = nil;
        self.startButton.enabled = YES;
        self.startButton.backgroundColor = [UIColor startButtonColor];
        self.stopButton.backgroundColor =  [UIColor grayColor];
        self.stopButton.enabled = NO;
        return;
    }
    if (self.count == 1) {
        self.pm = maxPM2;
    }
   
    //更新城市
    NSDictionary *dic = self.cityList[self.count];
    NSString *name_zh = dic[@"NAMECN"];
    NSString *name_en = dic[@"NAMEEN"];
    self.englishCityLabel.text = name_en;
    self.cityLabel.text = name_zh;
    
    //app向sync端更新室外pm2.5值
    AAClimateModel *model = [[AAClimateModel alloc] init];
    if (self.count == 0) {
        model.diagnostic_state = @0;  //initializing
        model.pm_type = @1;  //PM2.5
        model.exterior_pm_value = @1000;
        model.cityname_en = @"";
        model.cityname_zh = @"";
        model.cityname_ko = @"";
        self.pm = maxPM2;       
    }else{
        model.exterior_pm_value = [NSNumber numberWithInteger:self.pm];
        model.diagnostic_state = @2;  //No Issue
        model.cityname_en = name_en;
        model.cityname_zh = name_zh;
        model.pm_type = @1;  //PM2.5
        model.cityname_ko = name_en;
    }
    AADataModel *dataModel = [[AADataModel alloc] init];
    NSArray *array = [AATool currentTime];
    dataModel.date = array[0];
    dataModel.time = array[1];
    dataModel.exterior_PM_value = [NSString stringWithFormat:@"%@",model.exterior_pm_value];
    dataModel.exrerior_PM_diagnostic_state = [NSString stringWithFormat:@"%@",model.diagnostic_state];
    dataModel.cabin_PM_value = @"X";
    dataModel.cabin_PM_diagnostic_state = @"X";
    dataModel.sending_side = @"tx";
    dataModel.ifOpen = @"NO";
    [self.dataList addObject:dataModel];
  
     //上传数据
    [self uploadAARJSONByModel:model];
    [self showExteriorPMLabelAndColorThresholdByPM:dataModel.exterior_PM_value];
    NSLog(@"self.pm before---------- %ld",(long)self.pm);
    NSLog(@"self.pm after ---------- %ld",(long)self.pm);
    
    //模拟接收sync端返回车内pm2.5值
//    AADataModel *dataModel = [[AADataModel alloc] init];
//    NSArray *array = [AATool currentTime];
//    dataModel.date = array[0];
//    dataModel.time = array[1];
//    dataModel.exterior_PM_value = [NSString stringWithFormat:@"%ld",(long)self.pm];
//    dataModel.exrerior_PM_diagnostic_state = model.diagnostic_state;
//    dataModel.cabin_PM_value = [NSString stringWithFormat:@"%ld",(long)(self.count + 30)];
//    dataModel.cabin_PM_diagnostic_state = @"2";
//    dataModel.ifOpen = @"NO";
//    [self.dataList addObject:dataModel];
//    [self showtableViewByModel:dataModel];
    
    //记录发送次数与发送时间
    self.count ++;
    self.sendTime = self.sendTime + refreshTime2;
}

- (void)saveRoutineData{
    //保存sync端向app发送过来的数据
    if (self.dataList.count > 0) {
        AADataModel *model = self.dataList[0];
        NSString *appName = [NSString stringWithFormat:@"%@_%@_%@",disgnosticMode2,model.date,model.time];
        AATool *tool = [[AATool alloc] init];
        NSLog(@"appName ---------- %@",appName);
        NSString *name = [appName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        [tool exportCSV:self.dataList byName:name];
    }
}

- (void)stopRoutine{
    //停止发送
    [self.timer invalidate];
    self.timer = nil;
}










@end
