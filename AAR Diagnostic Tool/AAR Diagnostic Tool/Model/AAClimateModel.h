//
//  AAClimateModel.h
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/16.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAClimateModel : NSObject

@property (nonatomic, copy) NSNumber *exterior_pm_value;
@property (nonatomic, copy) NSNumber *diagnostic_state;
@property (nonatomic, copy) NSString *cityname_en;
@property (nonatomic, copy) NSString *cityname_zh;
@property (nonatomic, copy) NSString *cityname_ko;
@property (nonatomic, copy) NSNumber *pm_type;

@end
