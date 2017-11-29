//
//  ConfigurationViewController.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/8/25.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "ConfigurationViewController.h"
#import "AppDelegate.h"
#import "ADConstants.h"
#import "AATool.h"

@interface ConfigurationViewController ()

@end

@implementation ConfigurationViewController{
    NSArray *runTimeArr;
    AppDelegate *delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    delegate = [AATool getDelegate];
    self.runTimePicker.delegate = self;
    self.runTimePicker.dataSource = self;
    
    self.navigationItem.title = @"Configuration";
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"save" style:UIBarButtonItemStylePlain target:self action:@selector(saveAndExit)];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    [self loadData];
}


- (void)loadData
{
    delegate.routineRunTime = [[NSUserDefaults standardUserDefaults] integerForKey:KRoutineRunTime];
    [self.ExistRuntimeLabel setText:[NSString stringWithFormat:@"Routine Run Time =  %ld minute(s)",delegate.routineRunTime]];
    
    runTimeArr = [NSArray arrayWithObjects:@"1",@"2",@"3",@"5",@"10",@"15",@"20",@"25",@"30", nil];
    
    NSInteger tIndex = [runTimeArr indexOfObject:[NSString stringWithFormat:@"%ld",delegate.routineRunTime]];
    [self.runTimePicker selectRow:tIndex inComponent:0 animated:YES];
    
}

- (void)saveAndExit
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:delegate.routineRunTime forKey:KRoutineRunTime];
    [userDefaults synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma PickerViewDelete

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    [numLabel setTextColor:[UIColor darkGrayColor]];
    if (component == 0) {
        numLabel.text = runTimeArr[row];
    }else{
        numLabel.text = runTimeArr[row];
    }
    return numLabel;
}

#pragma PickerViewDataDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [runTimeArr count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    delegate.routineRunTime = [[runTimeArr objectAtIndex:row] integerValue];
    [self.ExistRuntimeLabel setText:[NSString stringWithFormat:@"Routine Run Time =  %ld minute(s)",delegate.routineRunTime]];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [runTimeArr objectAtIndex:row];
}

@end
