//
//  RoutineOneViewController.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/9/18.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "RoutineOneViewController.h"
#import "AAClimateModel.h"
#import "AATool.h"
#import "AADataModel.h"
#import "ADConstants.h"
#import "UIColor+PMColors.h"
#import "SmartDeviceLink.h"
#import "ProxyManager.h"           

NSInteger const refreshTime = 5;   //刷新时间
NSInteger const transmissionRate = 25;  //增减幅度
NSInteger const maxPM = 300;   //PM2.5最大值
NSInteger const minPM = 0;  //PM2.5最小值
NSString * const disgnosticMode = @"Routine1";
//NSString *const ASDLLockScreenStatusNotification = @"com.sdl.notification.sdlchangeLockScreenStatus";
//NSString *const ASDLNotificationUserInfoObject = @"com.sdl.notification.keys.sdlnotificationObject";
//NSString *const ASDLOnSystemRequestNotification =  @"com.sdl.notification.keys.sdlonSystemRequestObject";

@interface RoutineOneViewController ()

@property (assign , nonatomic) NSInteger count;  //发送次数

@property (assign, nonatomic) NSInteger pm;  //pm2.5值

@property (assign, nonatomic) NSInteger circleTime;  //轮回次数，先递减后增加，共4次

@property (assign, nonatomic) NSInteger sendTime;  //发送总共时长
@end

@implementation RoutineOneViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"BasicRoutineViewController" bundle:nibBundleOrNil];
    if (self) {
        self.dataList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Routine 1";
    self.routineDelegate = self;
    self.pm = maxPM;
    [self showPMLabelAndColorThresholdByPM:[NSString stringWithFormat:@"%ld",(long)self.pm]];
}

#pragma mark routineDelegate
- (void)startRoutine{
    self.count = 0;
    self.pm = maxPM;
    self.circleTime = 1;
    self.sendTime = 0;
 
    //每隔30S app端向sync端发送数据 每次增加或递减 25ug/m^3
    self.timer = [NSTimer scheduledTimerWithTimeInterval:refreshTime target:self selector:@selector(refreshExterior) userInfo:nil repeats:YES];
}

- (void)refreshExterior{
    //到达循环次数和时间上限 app向sync停止发送数据
    if (self.circleTime == 5 || self.sendTime > 60 * self.sendTime > 60 * [[NSUserDefaults standardUserDefaults] integerForKey:KRoutineRunTime]) {
        [self.timer invalidate];
        self.timer = nil;
        self.startButton.enabled = YES;
        self.startButton.backgroundColor = [UIColor startButtonColor];
        self.stopButton.backgroundColor =  [UIColor grayColor];
        self.stopButton.enabled = NO;
        return;
    }

    //模拟递减
    if (self.circleTime == 1 || self.circleTime == 3) {
        self.pm = self.pm - transmissionRate;
    }
    //模拟递增
    else if (self.circleTime == 2 || self.circleTime == 4) {
        self.pm = self.pm + transmissionRate;
    }
    if (self.count == 1) {
        self.pm = maxPM;
    }
    
   //更新城市
    NSDictionary *dic = self.cityList[self.count];
    NSString *name_zh = dic[@"NAMECN"];
    NSString *name_en = dic[@"NAMEEN"];
    self.cityLabel.text = [NSString stringWithFormat:@"%@ %@",name_zh,name_en];
    
    //app向sync端更新室外pm2.5值
   AAClimateModel *model = [[AAClimateModel alloc] init];
    if (self.count == 0) {
        model.diagnostic_state = @"0";  //initializing
        model.pm_type = @"1";  //PM2.5
        model.exterior_pm_value = @"";
        model.cityname_en = @"";
        model.cityname_zh = @"";
        
    }else{
    model.exterior_pm_value = [NSString stringWithFormat:@"%ld",(long)self.pm];
    model.diagnostic_state = @"2";  //No Issue
    model.cityname_en = name_en;
    model.cityname_zh = name_zh;
    model.pm_type = @"1";  //PM2.5
    }
    AADataModel *dataModel = [[AADataModel alloc] init];
    NSArray *array = [AATool currentTime];
    dataModel.date = array[0];
    dataModel.time = array[1];
    dataModel.exterior_PM_value = model.exterior_pm_value;
    dataModel.exrerior_PM_diagnostic_state = model.diagnostic_state;
    dataModel.cabin_PM_value = @"X";
    dataModel.cabin_PM_diagnostic_state = @"X";
    dataModel.sending_side = @"tx";
    dataModel.ifOpen = @"NO";
    [self.dataList addObject:dataModel];
    [self showtableViewByModel:dataModel];
    
    //上传数据
    [self uploadAARJSONByModel:model];
    [self showPMLabelAndColorThresholdByPM:[NSString stringWithFormat:@"%ld",(long)self.pm]];
   
    //记录循环次数
    if (self.pm == 0) {
        self.circleTime = self.circleTime + 1;
    }else if (self.pm == 300 && self.circleTime != 1){
        self.circleTime = self.circleTime + 1;
    }
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
    self.sendTime = self.sendTime + refreshTime;
}

- (void)saveRoutineData{
    //保存sync端向app发送过来的数据
    if (self.dataList.count > 0) {
        AADataModel *model = self.dataList[0];
        NSString *appName = [NSString stringWithFormat:@"%@_%@_%@",disgnosticMode,model.date,model.time];
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
