//
//  ADUtils.h
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/11/7.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ADUtils : NSObject

- (CAShapeLayer *)drawCirleLayerInRect:(CGRect)rect byColor:(UIColor *)cirleColor;
- (UILabel *)drawLableInRect:(CGRect)rect withNumber:(NSString *)PMNum;

@end
