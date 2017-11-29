//
//  BasicRoutineViewController.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/9/18.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "BasicRoutineViewController.h"
#import "ADUtils.h"
#import <UIKit/UIKit.h>
#import "UIColor+PMColors.h"
#import "AADataModel.h"
#import "AATool.h"
#import "AAPMCell.h"
#import "AATimeCell.h"
#import "SmartDeviceLink.h"
#import "ProxyManager.h"
#import "AAClimateModel.h"

@interface BasicRoutineViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation BasicRoutineViewController{
    ADUtils *myUtil;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableArray *)cityList{
    if (!_cityList) {
        _cityList = [NSMutableArray array];
    }
    return _cityList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//保存
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveData)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
//test draw cirle
    myUtil = [[ADUtils alloc] init];
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 4;
    self.circleExterior = [myUtil drawCirleLayerInRect:CGRectMake(width - 40, 190, 80, 80) byColor:[UIColor levelOneColor]];
    [self.view.layer addSublayer:self.circleExterior];
    self.labelExterior = [myUtil drawLableInRect:CGRectMake(width - 30, 210, 60, 40) withNumber:@""];
    [self.view addSubview:self.labelExterior];
    
    self.circleCarbin = [myUtil drawCirleLayerInRect:CGRectMake(width * 3 - 40, 190, 80, 80) byColor:[UIColor levelSixColor]];
    [self.view.layer addSublayer:self.circleCarbin];
    self.labelCarbin = [myUtil drawLableInRect:CGRectMake(width * 3 - 30, 210 ,60, 40) withNumber:@""];
    [self.view addSubview:self.labelCarbin];
    
    //城市列表
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cityName" ofType:@"plist"];
    // NSLog(@"paths %@",path);
    NSError *error;
    if (error) {
        NSLog(@"====%@",error.localizedDescription);
    }
    NSArray *contentArray = [NSArray arrayWithContentsOfFile:path];
    self.cityList = [NSMutableArray arrayWithArray:contentArray];
    
    NSLog(@"contentArray  ------- %@",contentArray);
    
    //初始化
    self.fileName = 1;
    //注册监听 
    [self registerForNotifications];
}

- (void)registerForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(recieveOnSystemRequest:) name:SDLDidReceiveSystemRequestNotification object:nil];
}

#pragma mark SDL Notifications
- (void)recieveOnSystemRequest:(NSNotification *)notification {
    // Delegate method to handle changes in lockscreen status
    
    NSLog(@"AppDelegate received OnSystemRequest notification: %@", notification);
    NSLog(@"FMCAARMonitor - onSDLSystemRequest: %@", notification);
    
    SDLOnSystemRequest *systemNotification = nil;
    if (notification && notification.userInfo) {
        systemNotification = notification.userInfo[SDLDidReceiveSystemRequestNotification];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([systemNotification.requestType isEqualToEnum:[SDLRequestType CLIMATE]]) {
            if (systemNotification.bulkData) {
                //            [self sendAARData:notification.bulkData];
                //            [AATool ]
                NSDictionary *dic = [AATool dictionaryWithData:systemNotification.bulkData];
                //NSString *string = [AATool dictionaryToJson:dic];
                //接收sync端返回app车内pm2.5值
                AADataModel *dataModel = [[AADataModel alloc] init];
                NSArray *array = [AATool currentTime];
                dataModel.date = array[0];
                dataModel.time = array[1];
                dataModel.exterior_PM_value = self.climateModel.exterior_pm_value;
                dataModel.exrerior_PM_diagnostic_state = self.climateModel.diagnostic_state;
                dataModel.cabin_PM_value = dic[@"cabin_PM_value"];
                dataModel.cabin_PM_diagnostic_state = dic[@"cabin_PM_diagnostic_state"];
                dataModel.ifOpen = @"NO";
                [self.dataList addObject:dataModel];
                [self showtableViewByModel:dataModel];
            }
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)didTapStart:(id)sender {
  //初始化
     [self.dataList removeAllObjects];
     self.fileName = 0;
    
    //设置按钮颜色
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    self.startButton.backgroundColor = [UIColor adGreyColor];
    self.stopButton.backgroundColor =  [UIColor stopButtonColor];
    [_routineDelegate startRoutine];
}

- (IBAction)didTapStop:(id)sender {
    
    //设置按钮颜色
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
    self.startButton.backgroundColor = [UIColor startButtonColor];
    self.stopButton.backgroundColor =  [UIColor grayColor];
    [_routineDelegate stopRoutine];
}

- (void)saveData{
    [_routineDelegate saveRoutineData];
}

//table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AADataModel *model = self.dataList[indexPath.row];
    if ([model.ifOpen isEqualToString:@"YES"]) {
        return 155;
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
    [timeCell configureCellByModel:dataModel];
    
 
//    NSString *displayStr;
    //show displayStr
//    if (self.dataList != nil && [self.dataList count] > 0) {
//        AADataModel *rs = (AADataModel *)[self.dataList objectAtIndex:indexPath.row];
//        displayStr = @"1";
//        //
//    }else{
//        displayStr = @"";
//    }
//
//    [cell.textLabel setFont:[UIFont systemFontOfSize:12]];
//    [cell.textLabel setNumberOfLines:2];
//    [cell.textLabel setLineBreakMode:NSLineBreakByWordWrapping];
//
//    [cell.textLabel setText:displayStr];
    return timeCell;
}

- (void)timeLabelSelected:(UIButton *)sender{
    NSInteger index = sender.titleLabel.text.integerValue;
    
    NSLog(@"index  -------  %ld",index);
    AADataModel *model = self.dataList[index];
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

#pragma mark method
- (void)showPMLabelAndColorThresholdByPM:(NSString *)pm{
    AATool *tool = [[AATool alloc] init];
    UIColor *cirleColor = [tool colorRangeByPM:pm];
    [self.circleExterior setStrokeColor:[cirleColor CGColor]];
    self.labelExterior.text = pm;
}

- (void)showtableViewByModel:(AADataModel *)model{
    AATool *tool = [[AATool alloc] init];
    UIColor *cirleColor = [tool colorRangeByPM:model.exterior_PM_value];
    [self.circleExterior setStrokeColor:[cirleColor CGColor]];
    self.labelExterior.text = model.exterior_PM_value;
    
    UIColor *cirleColor2 = [tool colorRangeByPM:model.cabin_PM_value];
    [self.circleCarbin setStrokeColor:[cirleColor2 CGColor]];
    if (model.cabin_PM_value.floatValue > 500) {
        self.labelCarbin.text = @"500+";
    }else if (model.cabin_PM_value.floatValue < 0){
        self.labelCarbin.text = @"Blank the Field";
    }else{
         self.labelCarbin.text = model.cabin_PM_value;
    }
    
  
    NSLog(@"self.list----------- %ld",self.dataList.count);
    
    [self.dataTable reloadData];
}

- (BOOL)uploadAARJSONByModel:(AAClimateModel *)model{
    __block NSString *putFileState;
   // __block NSString *systemRequestState;
    
    NSData *fileData = [AATool dataWithClimateModel:model];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)self.fileName];;
    ProxyManager *proxyManager = [ProxyManager sharedManager];
    SDLPutFile *putFile = [[SDLPutFile alloc] init];
    putFile.bulkData = fileData;
    putFile.syncFileName = fileName;
    putFile.fileType = [SDLFileType JSON];
    putFile.systemFile = @(NO);
    putFile.persistentFile = @(NO);
    
   __block BOOL ifSuccess = NO;
    [proxyManager.sdlManager sendRequest:putFile withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"responseClass ----  ····%@", NSStringFromClass([response class]));
        
        if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
            
            putFileState = [NSString stringWithFormat:@"putFile返回结果：成功 fileName ---- %@ ",fileName];
            
            SDLSystemRequest *systemRequest = [[SDLSystemRequest alloc] init];
            systemRequest.requestType = [SDLRequestType CLIMATE];
            systemRequest.fileName = fileName;
           
            [proxyManager.sdlManager sendRequest:systemRequest withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
                
                if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
                    ifSuccess = YES;
                }else{
                    
                }
               
            }];
        }else{
            putFileState = @"putFile返回结果：失败";
        }
        
        if (self.fileName == 10) {
            self.fileName = 1;
        }else{
            self.fileName += 1;
        }
    }];
    return ifSuccess;
}

@end