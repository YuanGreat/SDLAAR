//
//  HistoryDataViewController.m
//  AARDiagnosticTestApp
//
//  Created by Stella on 2017/9/22.
//  Copyright © 2017年 Ford. All rights reserved.
//

#import "HistoryDataViewController.h"
#import "AAHistoryCell.h"
#import "ADConstants.h"
#import "HistoryDetailController.h"
#import "AADataModel.h"

@interface HistoryDataViewController ()

@end

@implementation HistoryDataViewController

- (NSMutableArray *)historyDataList{
    if (!_historyDataList) {
        _historyDataList = [NSMutableArray array];
    }
    return _historyDataList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"History Data List"];
    [self getListData];
    NSLog(@"hiatoryDataList ------  %@",_historyDataList);
}

- (void)getListData{
    [self.historyDataList removeAllObjects];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSArray *nameArray = [userDefaults arrayForKey:KUserDefaultFileName];
    
    NSLog(@"nameArray -----%@",nameArray);
    if (nameArray.count > 0) {
        for (NSString *fileName in nameArray) {
            NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *strPath=[pathArr lastObject];
            NSString *strFinalPath=[NSString stringWithFormat:@"%@/%@.csv",strPath,fileName];
            NSString *fileString = [NSString stringWithContentsOfFile:strFinalPath encoding:NSUTF8StringEncoding error:nil];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:fileString forKey:fileName];
            NSLog(@"fileName ------  %@  fileString ------- %@",fileName,fileString);
            [self.historyDataList addObject:dic];
        }
    }
}

//table view delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.historyDataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AAHistoryCell *historyCell = [tableView dequeueReusableCellWithIdentifier:@"historyCell"];
    
    NSDictionary *dic = self.historyDataList[indexPath.row];
    NSString *fileName = dic.allKeys[0];
    NSLog(@"fileName ------- %@",fileName);
   
    if (historyCell == nil) {
        historyCell = [[[NSBundle mainBundle] loadNibNamed:@"AAHistoryCell" owner:nil options:nil] firstObject];
    }
     [historyCell configureCellByName:fileName];
    
    return historyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = self.historyDataList[indexPath.row];
    NSString *fileName = dic.allKeys[0];
    NSString *fileString = dic[fileName];
    NSArray *fileArray = [fileString componentsSeparatedByString:@"\n"];
    NSLog(@"fileArray ------ %@",fileArray);
    
//    NSString *keyString = fileArray[0];
//    NSArray *keyArray = [keyString componentsSeparatedByString:@","];
    NSMutableArray *dataArray = [NSMutableArray array];
    for (int i = 1; i < fileArray.count - 1; i++) {
        NSString *valueString = fileArray[i];
        NSArray *valueArray = [valueString componentsSeparatedByString:@","];
        AADataModel *model = [[AADataModel alloc] init];
        model.date = valueArray[0];
        model.time = valueArray[1];
        model.exterior_PM_value = valueArray[2];
        model.exrerior_PM_diagnostic_state = valueArray[3];
        model.cabin_PM_value = valueArray[4];
        model.cabin_PM_diagnostic_state = valueArray[5];
        model.sending_side = valueArray[6];
        model.ifOpen = @"NO";
        [dataArray addObject:model];
    }
    
    HistoryDetailController *detailVC = [[HistoryDetailController alloc] initHistoryDetailControllerByDataList:dataArray];
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)didTapDeleteAllData:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确定删除所有数据" message:nil preferredStyle:UIAlertControllerStyleAlert];
    // Create the actions.
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //删除数据信息
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        //删除所有文件
        NSArray *nameArray = [defaults arrayForKey:KUserDefaultFileName];
        NSLog(@"nameArray -----%@",nameArray);
        if (nameArray.count > 0) {
            for (NSString *fileName in nameArray) {
                NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *strPath = [pathArr lastObject];
                NSString *strFinalPath=[NSString stringWithFormat:@"%@/%@.txt",strPath,fileName];
              NSFileManager *fileMgr = [NSFileManager defaultManager];
                BOOL isExit = [fileMgr fileExistsAtPath:strFinalPath];
                if (isExit) {
                    //
                    NSError *err;
                    [fileMgr removeItemAtPath:strFinalPath error:&err];
                }
            }
        }
        //删除所有文件名
        [defaults removeObjectForKey:KUserDefaultFileName];
        [defaults synchronize];
        [self getListData];
        [self.dataListTable reloadData];
    }];
    
    // Add the actions.
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return   UITableViewCellEditingStyleDelete;
}

/*改变删除按钮的title*/
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

/*删除用到的函数*/
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==UITableViewCellEditingStyleDelete){
//        [self.arrayValue   removeObjectAtIndex:[indexPathrow]];  //删除数组里的数据
        //删除数据信息
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        //删除选中文件
        NSArray *nameArray = [defaults arrayForKey:KUserDefaultFileName];
        NSString *fileName = nameArray[indexPath.row];
        NSArray *pathArr=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *strPath = [pathArr lastObject];
        NSString *strFinalPath=[NSString stringWithFormat:@"%@/%@.txt",strPath,fileName];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL isExit = [fileMgr fileExistsAtPath:strFinalPath];
        if (isExit) {
            NSError *err;
            [fileMgr removeItemAtPath:strFinalPath error:&err];
        }
       
        //删除选中文件名
        NSMutableArray *afterArray = [NSMutableArray arrayWithArray:nameArray];
        [afterArray removeObjectAtIndex:indexPath.row];
    
        [defaults setObject:afterArray forKey:KUserDefaultFileName];
        [defaults synchronize];
        
          [self getListData];
          [self.dataListTable reloadData];
       // [tableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
    }
}




@end
