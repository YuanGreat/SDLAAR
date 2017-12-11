//
//  AATool.m
//  AAR Diagnostic Tool
//
//  Created by Dandy.Guan on 2017/11/16.
//  Copyright © 2017年 YuanWei. All rights reserved.
//

#import "AATool.h"
#import "SmartDeviceLink.h"
#import "AAClimateModel.h"
#import <objc/runtime.h>
#import "AppDelegate.h"
#import "AADataModel.h"
#import "UIColor+PMColors.h"
#import "ADConstants.h"
#import "MBManager.h"

@implementation AATool

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSDictionary *)dictionaryWithData:(NSData *)data{
    
      NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return jsonDictionary;
}

+ (NSData *)dataWithClimateModel:(AAClimateModel *)model{
    
    NSDictionary *dic = [NSDictionary dictionary];
   
     NSLog(@"model ------- %@",model.exterior_pm_value);
  
    dic = [AATool entityToDictionary:model];
    NSLog(@"modeldic ------- %@",dic);
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return jsonData;
}

/**
 *  model transform to NSDictionary
 */
+ (NSDictionary *) entityToDictionary:(id)entity{
    Class clazz = [entity class];
    u_int count;
    objc_property_t* properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
        //        const char* attributeName = property_getAttributes(prop);
        //        NSLog(@"%@",[NSString stringWithUTF8String:propertyName]);
        //        NSLog(@"%@",[NSString stringWithUTF8String:attributeName]);
        
        id value =  [entity performSelector:NSSelectorFromString([NSString stringWithUTF8String:propertyName])];
        if(value ==nil)
            [valueArray addObject:[NSNull null]];
        else {
            [valueArray addObject:value];
        }
        //        NSLog(@"%@",value);
    }
    
    free(properties);
    
    NSDictionary* returnDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    NSLog(@"%@", returnDic);
    
    return returnDic;
}

+ (AppDelegate *)getDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)exportCSV:(NSArray *)logArray byName:(NSString *)fileName{
   NSLog(@"appName ---------- %@",fileName);
    NSMutableString *writeStr = [NSMutableString stringWithCapacity:0];
    for (int i = 0; i < logArray.count; i++) {
        AADataModel *model = logArray[i];
        if (i == 0) {
            NSString *log = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",@"date",@"time",@"exterior PM value",@"exrerior PM diagnostic state",@"cabin PM value",@"cabin PM diagnostic state",@"sending side"];
            [writeStr appendString:[NSString stringWithFormat:@"%@ \n",log]];
        }
        NSString *log = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@",model.date,model.time,model.exterior_PM_value,model.exrerior_PM_diagnostic_state,model.cabin_PM_value,model.cabin_PM_diagnostic_state,model.sending_side];
        [writeStr appendString:[NSString stringWithFormat:@"%@\n",log]];
    }
//
//    for (AADataModel *model in logArray) {
//        NSString *log = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@",model.date,model.time,model.exterior_PM_value,model.exrerior_PM_diagnostic_state,model.cabin_PM_value,model.cabin_PM_diagnostic_state];
//        [writeStr appendString:[NSString stringWithFormat:@"%@ \n",log]];
//    }
    
    //Moved this stuff out of the loop so that you write the complete string once and only once.
    NSLog(@"writeString :%@",writeStr);
    
   // NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@.%@",@"Documents/",fileName,@"txt"]];
    
//    NSString *path = [[self applicationDocumentsDirectory].path
//                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileName,@".cvs"]];
    
    NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *strPath=[pathArr lastObject];
    NSString *strFinalPath=[NSString stringWithFormat:@"%@/%@.csv",strPath,fileName];
    
    NSLog(@"path ------------------------ %@",strFinalPath);
    NSError *error = nil;
    BOOL ifSuccess = [writeStr writeToFile:strFinalPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
   
    
    if (ifSuccess) {
        [MBManager showBriefAlert:@"save successful"];
    }else{
        [MBManager showBriefAlert:@"save failed"];
    }
    
    
    if (ifSuccess) {
        //将文件名记录到NSUserDefaults
        //判断之前有无存储过同样的记录
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSArray *array = [userDefaults arrayForKey:KUserDefaultFileName];
        NSLog(@"array ------- %@",array);
        NSMutableArray *arrayAfter = [[NSMutableArray alloc] initWithArray:array];
        if (array.count == 0) {
             [arrayAfter addObject:fileName];
        }
        BOOL ifAlreadyHave = NO;
        NSLog(@"array  %@",array);
        
        
        for (NSString *nameDefault in array) {
            NSLog(@"nameDefault  %@",nameDefault);
            if ([nameDefault isEqualToString:fileName]) {
                ifAlreadyHave = YES;
            }
        }
        //写入fileName
        if (ifAlreadyHave == NO && array.count != 0){
            [arrayAfter addObject:fileName];
        }
        [userDefaults setObject:arrayAfter forKey:KUserDefaultFileName];
        [userDefaults synchronize];
    }
    NSLog(@"ifSuccess ---- %d",ifSuccess);
    NSLog(@"error  ---- %@",[error localizedDescription]);
}

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

- (UIColor *)colorRangeByPM:(NSString *)pm{
    NSString *pmString = [self stringByNotRounding:pm.doubleValue afterPoint:1];
    NSLog(@"pm %@  pmFloat %f pmString%d",pm,pm.floatValue,pm.intValue);
    UIColor *color ;
    
    NSMutableArray *pmArray = [@[@"35",@"75",@"115",@"150",@"250",@"500"] mutableCopy];
    
    if (kCabinArray.count == 4) {
        NSString *pmString = kCabinArray[2];
        NSArray *array = [pmString componentsSeparatedByString:@","];
        if (array.count == 6) {
            BOOL ifNumbersIncrease = YES;
            for (int i = 0; i < array.count - 1; i ++) {
                NSString *oneString = array[i];
                NSString *twoString = array[i + 1];
                if (oneString.intValue > twoString.intValue) {
                    ifNumbersIncrease = NO;
                }
            }
            if (ifNumbersIncrease) {
                pmArray = [NSMutableArray arrayWithArray:array];
            }
        }
    }
    
    NSString *one = pmArray[0];
    NSString *two = pmArray[1];
    NSString *three = pmArray[2];
    NSString *four = pmArray[3];
    NSString *five = pmArray[4];
    NSString *six = pmArray[5];
    
    if (pmString.intValue >= 0 && pmString.intValue <= one.intValue) {
        color = [UIColor levelOneColor];
    }else if (pmString.intValue > one.intValue && pmString.intValue <= two.intValue){
         color = [UIColor levelTwoColor];
    }else if (pmString.intValue > two.intValue && pmString.intValue <= three.intValue){
        color = [UIColor levelThreeColor];
    }else if (pmString.intValue > three.intValue && pmString.intValue <= four.intValue){
        color = [UIColor levelFourColor];
    }else if (pmString.intValue > four.intValue && pmString.intValue <= five.intValue){
        color = [UIColor levelFiveColor];
    }else if (pmString.intValue > five.intValue && pmString.intValue <= six.intValue){
        color = [UIColor levelSixColor];
    }else{
         color = [UIColor adGreyColor];
    }
    return color;
}

//对小数点后两位数会大于0即加1
//price:需要处理的数字，
//position：保留小数点第几位，
-(NSString *)stringByNotRounding:(double)price afterPoint:(int)position{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
}

+ (NSArray *)currentTime{
    NSDate *now = [NSDate date];
    //NSLog(@"now date is: %@", now);
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    NSInteger year = [dateComponent year];
    NSInteger month =  [dateComponent month];
    NSInteger day = [dateComponent day];
    NSInteger hour =  [dateComponent hour];
    NSInteger minute =  [dateComponent minute];
    NSInteger second = [dateComponent second];

    //字符串的转化并且拼接
    NSString *date1=[NSString stringWithFormat:@"%ld/%ld/%ld",(long)month,(long)day,(long)year];
    NSString *date2=[NSString stringWithFormat:@"%ld:%ld:%ld",(long)hour,(long)minute,(long)second];
    NSArray *dateArray = [NSArray arrayWithObjects:date1,date2, nil];
    return dateArray;
}

+ (NSString *)diagnosticExteriorStateByCode:(NSString *)code{
    NSString *stateString;
    switch (code.intValue) {
        case 0:{
            stateString = @"Initializing";
        }
            break;
        case 1:{
            stateString = @"Blank the Field";
        }
            break;
        case 2:{
            stateString = @"No Issue";
        }
            break;
        default:
            break;
    }
    return stateString;
}

+ (NSString *)diagnosticCabinStateByCode:(NSString *)code{
    NSString *stateString;
    switch (code.intValue) {
        case 0:{
            stateString = @"Initializing";
        }
            break;
        case 1:{
            stateString = @"Unsupported";
        }
            break;
        case 2:{
            stateString = @"Clean the Sensor";
        }
            break;
        case 3:{
            stateString = @"Replace the Sensor";
        }
            break;
        case 4:{
            stateString = @"Blank the Field";
        }
            break;
        case 5:{
            stateString = @"No Issue";
        }
            break;
        case 6:{
            stateString = @"Not Used";
        }
            break;
        case 7:{
            stateString = @"Not Used";
        }
            break;
        default:
            break;
    }
    return stateString;
}


//-(void)writeDict:(NSDictionary *)dict forFirst:(BOOL)first{
//
//    NSMutableString *str = [NSMutableString  string];
//
//    //第一次写入字典的key值
//    if (first) {
//
//        for (NSString *key in dict.allKeys) {
//            //"," 换列
//            [str appendString:[NSString stringWithFormat:@"%@,",key]];
//        }
//
//    }
//    //换行
//    [str appendString:@"\n"];
//
//    for (NSString *value in dict.allValues) {
//
//        [str appendString:[NSString stringWithFormat:@"%@,",value]];
//    }
//
//    NSString *path = [[self applicationDocumentsDirectory].path
//                      stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",fileName,@".txt"]];
//    NSLog(@"path ------------------------ %@",path);
//    [writeStr writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
//
//
//    [self writeData:[str dataUsingEncoding:NSUTF8StringEncoding]];
//
//    first = false;
//
//}
////
////-(void)writeArray:(NSArray *)arr{
////
////    id element = arr[0];
////``
////
//-(void)writeData:(NSData *)data{
//
//    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.savePath];
//
//    if (!fileHandle) {
//
//        [data writeToFile:_savePath atomically:YES];
//    }else{
//
//        [fileHandle seekToEndOfFile];
//        [fileHandle writeData:data];
//        [fileHandle closeFile];
//
//    }
//
//}
//
//
//-(instancetype)initWithPath:(NSString *)savePath{
//
//    if (self = [super init]) {
//
//        _savePath = savePath;
//        //首先判断写的路径下有没有文件，有的话移除
//        NSFileManager *manager = [NSFileManager defaultManager];
//        if ([manager fileExistsAtPath:self.savePath]) {
//
//            [manager removeItemAtPath:self.savePath error:NULL];
//        }
//
//    }
//}
//
//
//



/**
 *  将txt转换成读取方便的plist
 */
- (void)readCityTxtToPlist{

//生成txt shengcheng plist
NSString *path = [[NSBundle mainBundle] pathForResource:@"areaid" ofType:@"txt"];

// NSLog(@"paths %@",path);
NSError *error;
if (error) {
    NSLog(@"====%@",error.localizedDescription);
}

//使用NSUTF16StringEncoding,NSASCIIStringEncoding,NSUTF8StringEncoding
//NSString *contents = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
//NSLog(@"contents %@",contents);

NSString *contentString =[contents stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];


// stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

// NSArray *contentsArray = [contentString componentsSeparatedByString:@"\n"];

NSArray *contentsArray = [contentString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

NSLog(@"contents  -----------  %@",contents);
NSLog(@"contentString  -----------  %@",contentString);
NSLog(@"contentsArray  -----------  %@",contentsArray);
NSString *docs = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cityName.plist"] ;

NSMutableArray *arr = [[NSMutableArray alloc] init];

NSInteger idx;
// NSLog(@"contentArray %@   count %ld",contentsArray,contentsArray.count);

for (idx = 1; idx < contentsArray.count; idx++) {
    NSString *keyContent = contentsArray[0];
    NSArray *keyArr = [keyContent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSString *currentContent = [contentsArray objectAtIndex:idx];
    NSArray *timeDataArr = [currentContent componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic setObject:timeDataArr[1] forKey:keyArr[1]];
    [dic setObject:timeDataArr[2] forKey:keyArr[2]];
    [dic setObject:[timeDataArr objectAtIndex:3] forKey:keyArr[3]];
    [dic setObject:[timeDataArr objectAtIndex:4] forKey:keyArr[4]];
    [dic setObject:[timeDataArr objectAtIndex:5] forKey:keyArr[5]];
    [dic setObject:[timeDataArr objectAtIndex:6] forKey:keyArr[6]];
    [dic setObject:[timeDataArr objectAtIndex:7] forKey:keyArr[7]];
    [dic setObject:[timeDataArr objectAtIndex:8] forKey:keyArr[8]];
    [arr addObject:dic];
}
    [arr writeToFile:docs atomically:YES];

    NSLog(@"写入文件  %@",arr);
    NSLog(@"路径  %@",docs);
}

+ (NSString*)convertToJSONData:(id)infoDict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:infoDict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData){
        NSLog(@"Got an error: %@", error);
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];  //去除掉首尾的空白字符和换行字符
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return jsonString;
}

+ (BOOL)ifNullOrNilWithObject:(id)object{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""]) {
            return YES;
        } else {
            return NO;
        }
    } else if ([object isKindOfClass:[NSNumber class]]) {
        if ([object isEqualToNumber:@0]) {
            return YES;
        } else {
            return NO;
        }
    }
    return NO;
}







@end
