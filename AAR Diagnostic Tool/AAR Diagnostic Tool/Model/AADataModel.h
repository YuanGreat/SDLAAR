//
//  AADataModel.h
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/20.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AADataModel : NSObject

@property (nonatomic, copy) NSString *date; //MM/DD/YY
@property (nonatomic, copy) NSString *time; //HH:MM:SS
@property (nonatomic, copy) NSString *exterior_PM_value;
@property (nonatomic, copy) NSString *exrerior_PM_diagnostic_state;
@property (nonatomic, copy) NSString *cabin_PM_value;
@property (nonatomic, copy) NSString *cabin_PM_diagnostic_state;
@property (nonatomic, copy) NSString *ifOpen;


@end
