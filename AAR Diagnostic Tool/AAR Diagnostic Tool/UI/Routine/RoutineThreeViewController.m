//
//  RoutineThreeViewController.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/20.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "RoutineThreeViewController.h"
#import "AAClimateModel.h"
#import "AATool.h"
#import "AADataModel.h"
#import "ADConstants.h"
#import "UIColor+PMColors.h"

NSInteger const refreshTime3 = 30;   //刷新时间
NSInteger const sendPM3 = 50;   //PM2.5稳定发送值
NSString * const disgnosticMode3 = @"Routine3";

@interface RoutineThreeViewController ()

@property (assign, nonatomic) NSInteger count;  //发送次数
@property (assign, nonatomic) NSInteger sendTime;  //发送总共时长

@end

@implementation RoutineThreeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"BasicRoutineViewController" bundle:nibBundleOrNil];
    if (self) {
        
        self.dataList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Routine 3";
    self.routineDelegate = self;
      //  [self showExteriorPMLabelAndColorThresholdByPM:[NSString stringWithFormat:@"%ld",sendPM3]];
 
}

#pragma mark routineDelegate
- (void)startRoutine{
    if (self.timer != nil) {
        return;
    }
    self.count = 0;
    self.sendTime = 0;
    
     [self refreshExterior];
    //每隔30S app端向sync端发送数据 每次发送数据为50ug/m^3
    self.timer = [NSTimer scheduledTimerWithTimeInterval:refreshTime3 target:self selector:@selector(refreshExterior) userInfo:nil repeats:YES];
}

- (void)refreshExterior{
    //到达时间上限 app向sync停止发送数据
    if (self.sendTime > 60 * [[NSUserDefaults standardUserDefaults] integerForKey:KRoutineRunTime]) {
        [self.timer invalidate];
        self.timer = nil;
        self.startButton.enabled = YES;
        self.startButton.backgroundColor = [UIColor startButtonColor];
        self.stopButton.backgroundColor =  [UIColor grayColor];
        self.stopButton.enabled = NO;
        return;
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
    }else{
        model.exterior_pm_value = [NSNumber numberWithInteger:sendPM3];
        model.diagnostic_state = @2;  //No Issue
        model.cityname_en = name_en;
        model.cityname_zh = name_zh;
        model.cityname_ko = name_en;
        model.pm_type = @1;  //PM2.5
    }
    AADataModel *dataModel = [[AADataModel alloc] init];
    NSArray *array = [AATool currentTime];
    dataModel.date = array[0];
    dataModel.time = array[1];
    dataModel.exterior_PM_value =[NSString stringWithFormat:@"%@",model.exterior_pm_value];
    dataModel.exrerior_PM_diagnostic_state = [NSString stringWithFormat:@"%@",model.diagnostic_state];
    dataModel.cabin_PM_value = @"X";
    dataModel.cabin_PM_diagnostic_state = @"X";
    dataModel.sending_side = @"tx";
    dataModel.ifOpen = @"NO";
    [self.dataList addObject:dataModel];
   
    
    //上传数据
    [self uploadAARJSONByModel:model];
    [self showExteriorPMLabelAndColorThresholdByPM:dataModel.exterior_PM_value];
    
    //模拟接收sync端返回车内pm2.5值
//    AADataModel *dataModel = [[AADataModel alloc] init];
//    NSArray *array = [AATool currentTime];
//    dataModel.date = array[0];
//    dataModel.time = array[1];
//    dataModel.exterior_PM_value = [NSString stringWithFormat:@"%ld",sendPM3];
//    dataModel.exrerior_PM_diagnostic_state = model.diagnostic_state;
//    dataModel.cabin_PM_value = [NSString stringWithFormat:@"%ld",self.count + 30];
//    dataModel.cabin_PM_diagnostic_state = @"2";
//    dataModel.ifOpen = @"NO";
//    
//    [self.dataList addObject:dataModel];
//    [self showtableViewByModel:dataModel];
    
   //记录发送次数与发送时间
    self.count ++;
    self.sendTime = self.sendTime + refreshTime3;
}

- (void)saveRoutineData{
    //保存sync端向app发送过来的数据
    if (self.dataList.count > 0) {
        AADataModel *model = self.dataList[0];
        NSString *appName = [NSString stringWithFormat:@"%@_%@_%@",disgnosticMode3,model.date,model.time];
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
