//
//  ViewController.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/16.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "ViewController.h"
#import "ProxyManager.h"
#import "SmartDeviceLink.h"
#import "AAClimateModel.h"
#import "AATool.h"
#import "SDLProxy.h"
#import "RoutineOneViewController.h"
#import "RoutineTwoViewController.h"
#import "RoutineThreeViewController.h"
#import "RoutineFourViewController.h"
#import "HistoryDataViewController.h"
#import "ConfigurationViewController.h"
#import "AADataModel.h"
#import "ADConstants.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *putFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemRequestLabel;
@property (weak, nonatomic) IBOutlet UILabel *onSystemRequestLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLable;
@property (nonatomic, assign) __block NSInteger fileNameCount;
//@property (nonatomic,weak) id<AASDLDelegate> aaSDLDelegate;
@property (weak, nonatomic) id <SDLProxyListener> proxyListener;
@property (assign, nonatomic) NSInteger count;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Observe Proxy Manager state
    [[ProxyManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    self.fileNameCount = 1;
    self.count = 0;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self registerForNotifications];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    @try {
        [[ProxyManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
    } @catch (NSException __unused *exception) {}
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark SDL Notifications
- (void)registerForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(recieveOnSystemRequest:) name:SDLDidReceiveSystemRequestNotification object:nil];
}

- (void)recieveOnSystemRequest:(NSNotification *)notification {
    self.count ++;
    SDLOnSystemRequest *systemNotification = nil;
    if (notification && notification.userInfo) {
        systemNotification = notification.userInfo[SDLNotificationUserInfoObject];
    }
    self.onSystemRequestLabel.text = [NSString stringWithFormat:@"count --- %ld",(long)self.count];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([systemNotification.requestType isEqualToEnum:[SDLRequestType CLIMATE]]) {
            if (systemNotification.bulkData) {
                NSDictionary *dic = [AATool dictionaryWithData:systemNotification.bulkData];
                //接收sync端返回app车内pm2.5值
                NSString *cabin_pm_value = [NSString stringWithFormat:@"%@",dic[@"cabin_pm_value"]];
                NSString *diagnostic_state =  [NSString stringWithFormat:@"%@",dic[@"diagnostic_state"]];
                NSString *colorRange =  [NSString stringWithFormat:@"%@",dic[@"color_range_thresholds"]];
                NSString *pm_type =  [NSString stringWithFormat:@"%@",dic[@"pm_type"]];
               
                kCabinArray = [NSMutableArray array];
                kCabinArray = [@[cabin_pm_value,diagnostic_state,colorRange,pm_type ] mutableCopy];
                // self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@",dic];
                //             self.onSystemRequestLabel.text = [NSString stringWithFormat:@"count --- %ld cabin_pm_value -- %@ diagnostic_state ----%@  pm_type ----- %@ ",(long)self.count,cabin_pm_value,diagnostic_state,pm_type];
            }
        }
    });
}

#pragma test page
- (IBAction)connectButtonWasPressed:(id)sender {
    ProxyState state = [ProxyManager sharedManager].state;
    switch (state) {
        case ProxyStateStopped: {
            [[ProxyManager sharedManager] startIAP];
        } break;
        case ProxyStateSearchingForConnection: {
            [[ProxyManager sharedManager] reset];
        } break;
        case ProxyStateConnected: {
            [[ProxyManager sharedManager] reset];
        } break;
        default: break;
    }
}

- (IBAction)dataButtonWasPressed:(id)sender {
    
    NSString *fileName = [NSString stringWithFormat:@"%ld", self.fileNameCount];
    
    __block NSString *putFileState;
    __block NSString *systemRequestState = @"00";
    
    AAClimateModel *model = [[AAClimateModel alloc] init];
    
    model.exterior_pm_value = @78;
    model.diagnostic_state = @0;
    model.cityname_en = @"shanghai";
    model.cityname_zh = @"shanghai";
    model.pm_type = @1;
    
    NSData *fileData = [AATool dataWithClimateModel:model];
    
    ProxyManager *proxyManager = [ProxyManager sharedManager];
    SDLPutFile *putFile = [[SDLPutFile alloc] init];
    putFile.bulkData = fileData;
    putFile.syncFileName = fileName;
    putFile.fileType = [SDLFileType JSON];
    putFile.systemFile = @(NO);
    putFile.persistentFile = @(NO);
    
    // self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@",proxyManager.sdlManager.hmiLevel];
    
    [proxyManager.sdlManager sendRequest:putFile withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"responseClass ----  ····%@", NSStringFromClass([response class]));
        
        if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
            
            putFileState = [NSString stringWithFormat:@"putFile返回结果：成功 fileName ---- %@ ",fileName];
            
            SDLSystemRequest *systemRequest = [[SDLSystemRequest alloc] init];
            systemRequest.requestType = [SDLRequestType CLIMATE];
            systemRequest.fileName = fileName;
            self.onSystemRequestLabel.text = [NSString stringWithFormat:@"fileName ---- %@  systemRequest.requestType ----- %@",fileName,systemRequest.requestType];
            [proxyManager.sdlManager sendRequest:systemRequest withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
                        systemRequestState = @"systemRequest返回结果：成功";
                    }else{
                        systemRequestState = @"systemRequest返回结果：失败 ";
                    }
                    self.systemRequestLabel.text = systemRequestState;
                });
            }];
            
        }else{
            putFileState = @"putFile返回结果：失败";
        }
        
        self.putFileLabel.text = putFileState;
        
        
        if (self.fileNameCount == 10) {
            self.fileNameCount = 1;
        }else{
            self.fileNameCount += 1;
        }
    }];
    
}



#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(state))]) {
        ProxyState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        [self proxyManagerDidChangeState:newState];
    }
}

#pragma mark - Private Methods
- (void)proxyManagerDidChangeState:(ProxyState)newState {
    UIColor* newColor = nil;
    NSString* newTitle = nil;
    
    switch (newState) {
        case ProxyStateStopped: {
            newColor = [UIColor redColor];
            newTitle = @"Connect";
        } break;
        case ProxyStateSearchingForConnection: {
            newColor = [UIColor blueColor];
            newTitle = @"Stop Searching";
        } break;
        case ProxyStateConnected: {
            newColor = [UIColor greenColor];
            newTitle = @"Disconnect";
        } break;
        default: break;
    }
    
    if (newColor || newTitle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.connectButton setBackgroundColor:newColor];
            [self.connectButton setTitle:newTitle forState:UIControlStateNormal];
        });
    }
}

- (IBAction)didTapConfiguration:(id)sender {
    ConfigurationViewController *confVC = [[ConfigurationViewController alloc] init];
    [self.navigationController pushViewController:confVC animated:YES];
}

- (IBAction)didTapHistoryData:(id)sender {
    HistoryDataViewController *dataVC = [[HistoryDataViewController alloc] init];
    [self.navigationController pushViewController:dataVC animated:YES];
}

- (IBAction)didTapRoutineOne:(id)sender {
    RoutineOneViewController *vc = [[RoutineOneViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapRountineTwo:(id)sender {
    RoutineTwoViewController *vc = [[RoutineTwoViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapRountineThree:(id)sender {
    RoutineThreeViewController *vc = [[RoutineThreeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)didTapRountineFour:(id)sender {
    RoutineFourViewController *vc = [[RoutineFourViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -  SDLManagerDelegate




@end
