//
//  AATool.h
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/16.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AAClimateModel;
@class AppDelegate;

@interface AATool : NSObject

/**
 *  json格式字符串转字典
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;


/**
 *  字典转json格式字符串
 */
+ (NSString *)dictionaryToJson:(NSDictionary *)dic;

/**
 *  json data转字典
 */
+ (NSDictionary *)dictionaryWithData:(NSData *)data;

/**
 *  AAClimateModel转json data
 */
+ (NSData *)dataWithClimateModel:(AAClimateModel *)model;

/**
 *  AAClimateModel转json data
 */
+ (AppDelegate *)getDelegate;

/**
 *  iOS make CVS file (NSArray include AADataModel)
 */
- (void)exportCSV:(NSArray *)logArray byName:(NSString *)fileName;

/**
 *  Color Range Thresholds
 */
- (UIColor *)colorRangeByPM:(NSString *)pm;

/**
 *  获取当前时间 数组第一个元素MM/DD/YY 数组第二个元素HH:MM:SS
 */
+ (NSArray *)currentTime;

/**
 *  诊断状态显示
 */
+ (NSString *)diagnosticStateByCode:(NSString *)code;

/**
 *  csv writer 初始化
 *
 *  @param savePath 保存路径，路径中的文件扩展名是：.csv
 */
-(instancetype)initWithPath:(NSString *)savePath;

/**
 *  将一个数组保存为csv文件
 *  支持数组是元素是：数组、字典、字符串
 *
 *  @param arr 要写入的数组
 */
-(void)writeArray:(NSArray *)arr;

/**
 *  将一个字典保存为csv文件，字典的key和value必须为字符串
 *  支持一个数组中保存着多个字典，并且字典的key是相同的，那么key只保存一次。first的值为true
 *
 *  @param dict  要保存的字典
 *  @param first 是不是第一次保存
 */
-(void)writeDict:(NSDictionary *)dict forFirst:(BOOL)first;

/**
 *  删除UserDefault文件
 */







@end
