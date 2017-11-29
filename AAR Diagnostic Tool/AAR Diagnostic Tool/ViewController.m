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

@interface ViewController ()<AASDLDelegate>

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *putFileLabel;
@property (weak, nonatomic) IBOutlet UILabel *systemRequestLabel;
@property (weak, nonatomic) IBOutlet UILabel *onSystemRequestLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLable;
@property (nonatomic, assign) __block NSInteger fileNameCount;
//@property (nonatomic,weak) id<AASDLDelegate> aaSDLDelegate;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [ProxyManager sharedManager].aaSDLDelegate = self;
    // Do any additional setup after loading the view, typically from a nib.
    // Observe Proxy Manager state
    [[ProxyManager sharedManager] addObserver:self forKeyPath:NSStringFromSelector(@selector(state)) options:(NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew) context:nil];
    self.fileNameCount = 1;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataAvailable:) name:SDLDidReceiveSystemRequestNotification object:nil];
    
    //注册监听
    [self hsdl_registerForNotifications];
    
}
- (void)hsdl_registerForNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(didChangeLockScreenStatus:) name:ASDLLockScreenStatusNotification object:nil];
    [center addObserver:self selector:@selector(recieveOnSystemRequest:) name:ASDLOnSystemRequestNotification object:nil];
}

#pragma mark SDL Notifications
- (void)didChangeLockScreenStatus:(NSNotification *)notification {
    // Delegate method to handle changes in lockscreen status
    NSLog(@"AppDelegate received didChangeLockScreenStatus notification: %@", notification);
    
}



- (void)dataAvailable:(SDLRPCNotificationNotification *)notification{
    if (![notification.notification isKindOfClass:SDLSystemRequest.class]) {
        return;
    }
}

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
    __block NSString *systemRequestState;
    
    AAClimateModel *model = [[AAClimateModel alloc] init];
    
    model.exterior_pm_value = @"78";
    model.diagnostic_state = @"0";
    model.cityname_en = @"shanghai";
    model.cityname_zh = @"shanghai";
     model.pm_type = @"1";
    
    NSData *fileData = [AATool dataWithClimateModel:model];
 
    ProxyManager *proxyManager = [ProxyManager sharedManager];
    SDLPutFile *putFile = [[SDLPutFile alloc] init];
    putFile.bulkData = fileData;
    putFile.syncFileName = fileName;
    putFile.fileType = [SDLFileType JSON];
    putFile.systemFile = @(NO);
    putFile.persistentFile = @(NO);
    
    [proxyManager.sdlManager sendRequest:putFile withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"responseClass ----  ····%@", NSStringFromClass([response class]));
        
        if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
        
             putFileState = [NSString stringWithFormat:@"putFile返回结果：成功 fileName ---- %@ ",fileName];
                
                SDLSystemRequest *systemRequest = [[SDLSystemRequest alloc] init];
                systemRequest.requestType = [SDLRequestType CLIMATE];
                systemRequest.fileName = fileName;
                //self.onSystemRequestLabel.text = [NSString stringWithFormat:@"fileName ---- %@  systemRequest.requestType ----- %@",fileName,systemRequest.requestType];
            
            
           // [proxyManager.sdlManager sendp]
                [proxyManager.sdlManager sendRequest:systemRequest withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
                    
                  //  self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",response.correlationID,response.resultCode,response.info];
                    if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
                        systemRequestState = @"systemRequest返回结果：成功";
                    }else{
                        systemRequestState = @"systemRequest返回结果：失败 ";
                    }
                    self.systemRequestLabel.text = systemRequestState;
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
    
    
//    SDLOnSystemRequest *notification = [[SDLOnSystemRequest alloc] init];
//    notification.requestType = [SDLRequestType CLIMATE];
//    //        notification.offset = [NSNumber numberWithInt:0];
//    //        notification.url = @"";
//    
// 
//      [self postRPCNotificationNotification:SDLDidReceiveSystemRequestNotification notification:notification];
//    
//
//    
//    SDLSystemRequest *systemRequest = [[SDLSystemRequest alloc] init];
//    systemRequest.requestType = [SDLRequestType CLIMATE];
//    systemRequest.fileName = fileName;
//    self.onSystemRequestLabel.text = [NSString stringWithFormat:@"fileName ---- %@  systemRequest.requestType ----- %@",fileName,systemRequest.requestType];
//
//    
//    [proxyManager.sdlManager sendRequest:systemRequest];
//    
//    
//    
//    
//    
//    [proxyManager.sdlManager sendRequest:systemRequest withResponseHandler:^(__kindof SDLRPCRequest * _Nullable request, __kindof SDLRPCResponse * _Nullable response, NSError * _Nullable error) {
//        
//        self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@ - %@ - %@",response.correlationID,response.resultCode,response.info];
//        if ([response.resultCode isEqualToEnum:[SDLResult SUCCESS]]) {
//            systemRequestState = @"systemRequest返回结果：成功";
//        }else{
//            systemRequestState = @"systemRequest返回结果：失败 ";
//        }
//        self.systemRequestLabel.text = systemRequestState;
//    }];
//
}

- (void)notifyOfNotification:(SDLRPCNotification *)notification {
    if ([notification isKindOfClass:[SDLOnSystemRequest class]]){
        [self onSDLSystemRequest:(SDLOnSystemRequest *)notification];
    }
}

- (void)onSDLSystemRequest:(SDLOnSystemRequest *)notification {
    NSLog(@"FMCAARMonitor - onSDLSystemRequest: %@", notification);
    if ([notification.requestType isEqualToEnum:[SDLRequestType CLIMATE]]) {
        if (notification.bulkData) {
//            [self sendAARData:notification.bulkData];
//            [AATool ]
            NSDictionary *dic = [AATool dictionaryWithData:notification.bulkData];
            NSString *string = [AATool dictionaryToJson:dic];
          //  self.onSystemRequestLabel.text = string;
        }
    }
}

- (void)dealloc {
    @try {
        [[ProxyManager sharedManager] removeObserver:self forKeyPath:NSStringFromSelector(@selector(state))];
    } @catch (NSException __unused *exception) {}
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

- (void)aaOnRegisterAppInterfaceResponse:(SDLRegisterAppInterfaceResponse *)response{
    NSLog(@"RegisterAppInterface response from SDL: %@ with info :%@", response.resultCode, response.info);
    
//    self.onSystemRequestLabel.text = @"AppInterfaceResponse";
//    self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@ --- %@",@"registerApp",response.info];
    if (!response || [response.success isEqual:@0]) {
        NSLog(@"Failed to register with SDL: %@", response);
        return;
    }
    // Check for graphics capability, and upload persistent graphics (app icon) if available
}

- (void)aaOnOnSystemRequest:(SDLOnSystemRequest *)notification{
    NSDictionary *dic = [AATool dictionaryWithData:notification.bulkData];
    NSString *string = [AATool dictionaryToJson:dic];
    self.onSystemRequestLabel.text = @"onRequest";
    self.onSystemRequestLabel.text = [NSString stringWithFormat:@"%@%@",notification.url,notification.bulkData];
}

- (void)aaManagerDidDisconnect{
   self.onSystemRequestLabel.text = @"response";
    
}



@end