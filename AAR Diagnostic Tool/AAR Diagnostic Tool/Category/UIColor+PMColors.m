//
//  UIColor+PMColors.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/11/7.
//  Copyright © 2017年 Ford. All rights reserved.
//

#define RGB(r, g, b) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:1.0]
#define RGBA(r, g, b, a) [UIColor colorWithRed:(float)r / 255.0 green:(float)g / 255.0 blue:(float)b / 255.0 alpha:a]

#import "UIColor+PMColors.h"

@implementation UIColor (PMColors)

//Green
+ (UIColor *)levelOneColor
{
    return RGBA(8, 253, 60, 1.0);
}

//Yellow
+ (UIColor *)levelTwoColor
{
    return RGBA(248, 222, 36, 1.0);
}

//Organge
+ (UIColor *)levelThreeColor
{
    return RGBA(248, 136, 46, 1.0);
}

//Red
+ (UIColor *)levelFourColor
{
    return RGBA(255, 36, 36, 1.0);
}

//Purple
+ (UIColor *)levelFiveColor
{
    return RGBA(230, 0, 250, 1.0);
}

//Brown
+ (UIColor *)levelSixColor
{
    return RGBA(120, 38, 38, 1.0);
}

//Grey
+ (UIColor *)adGreyColor
{
    return RGBA(155, 155, 155, 1.0);
}

//StartButton
+ (UIColor *)startButtonColor{
    return RGBA(40, 229, 76, 1.0);
}

//StopButton
+ (UIColor *)stopButtonColor{
    return RGBA(252, 51, 43, 1.0);
}

//rxCellColor
+ (UIColor *)rxCellColor{
    return RGB(240, 240, 240);
}

//txCellColor
+ (UIColor *)txCellColor{
    return RGB(178, 201, 237);
}



@end
