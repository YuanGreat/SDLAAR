//
//  BasicRoutineViewController.h
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/9/18.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "ViewController.h"

@class AADataModel;
@class AAClimateModel;

@protocol RoutineDelegate <NSObject>

@optional
- (void)startRoutine;
- (void)saveRoutineData;
- (void)stopRoutine;

@end

@interface BasicRoutineViewController : ViewController<UITableViewDelegate,UITableViewDataSource,RoutineDelegate>

@property (nonatomic,weak) id<RoutineDelegate> routineDelegate;

@property (nonatomic,weak) IBOutlet UITableView *dataTable;

@property (nonatomic,strong) NSMutableArray *dataList; //数据数组

@property (nonatomic,strong) NSMutableArray *cityList; //城市数组

@property (nonatomic,copy) NSString *cityName;  //城市名

@property (nonatomic, strong) NSTimer *timer; //计时器

@property (nonatomic, strong) CAShapeLayer *circleExterior;  //室外阈值颜色

@property (nonatomic, strong) CAShapeLayer *circleCarbin;  //室内阈值颜色

@property (nonatomic, strong) UILabel *labelExterior;   //室外PM2.5值label

@property (nonatomic, strong) UILabel *labelCarbin;  //室内PM2.5值label

//@property (nonatomic, strong) AAClimateModel *climateModel; //室外空气数据

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;

@property (nonatomic, assign) __block NSInteger fileName; //文件名

@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

/**
 *  阀值颜色
 */
- (void)showPMLabelAndColorThresholdByPM:(NSString *)pm ;

/**
 *  展示空气数据信息
 */
- (void)showtableViewByModel:(AADataModel *)model;

/**
 *  开始发送与结束发送数据
 */
- (IBAction)didTapStart:(id)sender;
- (IBAction)didTapStop:(id)sender;

/**
 *  app向sync上传室外空气质量数据
 */
- (BOOL)uploadAARJSONByModel:(AAClimateModel *)model;

/**
 *  注册监听
 */
- (void)registerForNotifications;




@end
