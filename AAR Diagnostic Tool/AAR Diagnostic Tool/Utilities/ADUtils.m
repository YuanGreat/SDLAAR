//
//  ADUtils.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/11/7.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "ADUtils.h"

@implementation ADUtils

- (CAShapeLayer *)drawCirleLayerInRect:(CGRect)rect byColor:(UIColor *)cirleColor{
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    [circleLayer setPath:[[UIBezierPath bezierPathWithOvalInRect:rect] CGPath]];
    [circleLayer setStrokeColor:[cirleColor CGColor]];
    [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
    [circleLayer setLineWidth:4.0];
    return circleLayer;
}

- (UILabel *)drawLableInRect:(CGRect)rect withNumber:(NSString *)PMNum{
    UILabel *numLabel = [[UILabel alloc] initWithFrame:rect];
    //[numLabel setFont:[UIFont systemFontOfSize:21 weight:UIFontWeightRegular]];
    numLabel.font = [UIFont systemFontOfSize:21];
    [numLabel setText:PMNum];
    [numLabel setTextAlignment:NSTextAlignmentCenter];
    return numLabel;
}




@end
