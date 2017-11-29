//
//  ConfigurationViewController.h
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/8/25.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigurationViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *ExistRuntimeLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *runTimePicker;

@end
