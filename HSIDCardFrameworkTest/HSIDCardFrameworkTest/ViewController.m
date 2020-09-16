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
    HSIDCardScannerViewController *vc = [[HSIDCardScannerViewController alloc] init];
    vc.idCardScannerViewDelegate = self;
    vc.scanType = HSIDCardQualityScanTypeFront;//HSIDCardQualityScanTypeOther;
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
    UIImage *scaleImage = [UIImage imageCompressForWidth:image targetWidth:320];
    NSLog(@"缩放图片:%@",scaleImage);
    if (selectIndex == 1) {
        self.frontIV.image = scaleImage;
    }else{
        self.backIV.image = scaleImage;
    }
    NSLog(@"名称: %@ \n身份证: %@ \n有效期(始): %@ \n有效期(终): %@",result.name,result.idCardNum,result.validStartDate,result.validEndDate);
}






@end
