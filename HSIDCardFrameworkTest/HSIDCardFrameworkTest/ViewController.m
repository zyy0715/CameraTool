//
//  ViewController.m
//  HSIDCardFrameworkTest
//
//  Created by farben on 2020/8/31.
//  Copyright © 2020 farben. All rights reserved.
//

#import "ViewController.h"
#import "HSIDCardScannerViewController.h"
#import "UIImage+IDCardExtend.h"
@interface ViewController ()<
HSIDCardScannerViewControllerDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *frontIV;
@property (weak, nonatomic) IBOutlet UIButton *frontBtn;
@property (weak, nonatomic) IBOutlet UIImageView *backIV;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation ViewController
{
    NSInteger selectIndex;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"iOS OCR SDKDemo";
    NSLog(@"版本号:%@",HSIDCardVersion);
}

- (IBAction)frontBtnAction:(id)sender {
    [self takePicActionWithType:1];
}

- (IBAction)backBtnAction:(id)sender {
    [self takePicActionWithType:2];
}

///拍照
- (void)takePicActionWithType:(NSInteger)type{
    selectIndex = type;
    HSIDCardScannerViewController *vc = [[HSIDCardScannerViewController alloc] initWithName:@"Test" idCardNum:@"32211222"];
    vc.idCardScannerViewDelegate = self;
    ///设置请求环境,默认测试环境
    vc.networkType = HSIDOCRNetworkStateTestType;
    ///设置拍照正反面
    vc.scanType = HSIDCardQualityScanTypeFront;
    if (type != 1) {
        vc.scanType = HSIDCardQualityScanTypeBack;
    }
    [self.navigationController pushViewController:vc animated:YES];
    
    
    return;
    if (@available(iOS 13, *)) {
        //全屏
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        //禁用下滑返回
        vc.modalInPresentation = true;
    }
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -- HSIDCardScannerViewControllerDelegate
- (void)idCardScannerInfoImage:(UIImage*)image result:(nonnull HSIDCardScannerInfo *)result{
    NSLog(@"原始图片:%@",image);
      NSString *resultStr = nil;
     if (selectIndex == 1) {
         self.frontIV.image = image;
      resultStr = [NSString stringWithFormat:@"姓名:%@\n号码:%@\n详细:%@\n",result.name,result.idCardNum,[self stringFromDict:result.allInfo]];
     }else{
         self.backIV.image = image;
      resultStr = [NSString stringWithFormat:@"开始:%@\n结束:%@\n详细:%@\n",result.validStartDate,result.validEndDate,[self stringFromDict:result.allInfo]];
     }
      UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"结果" message:resultStr preferredStyle:(UIAlertControllerStyleAlert)];
      NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
      paraStyle.alignment = NSTextAlignmentLeft;
      NSMutableAttributedString *atrStr = [[NSMutableAttributedString alloc] initWithString:resultStr attributes:@{NSParagraphStyleAttributeName:paraStyle,NSFontAttributeName:[UIFont systemFontOfSize:13.0]}];
     
      [alert setValue:atrStr forKey:@"attributedMessage"];
      UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
         //
      }];
      [alert addAction:action];
      [self presentViewController:alert animated:YES completion:nil];
}
///字典转JSON字符串
- (NSString*)stringFromDict:(NSDictionary*)dict{
      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:0];
      NSString *dataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
      return dataStr;
}
///JSON字符串转字典
+ (NSDictionary *)dictionaryFromString:(NSString *)jsonString {
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






@end
