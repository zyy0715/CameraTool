//
//  ViewController.m
//  HSIDCardFrameworkTest
//
//  Created by farben on 2020/8/31.
//  Copyright © 2020 farben. All rights reserved.
//

#import "ViewController.h"
#import "HSIDCardScannerViewController.h"
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
    if (@available(iOS 13, *)) {
        //全屏
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        //禁用下滑返回
        vc.modalInPresentation = true;
    }
    vc.scanType = HSIDCardQualityScanTypeFront;
    if (type != 1) {
        vc.scanType = HSIDCardQualityScanTypeBack;
    }
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal ;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark -- HSIDCardScannerViewControllerDelegate
- (void)idCardScannerInfoImage:(UIImage*)image{
    NSLog(@"获取到的图片:%@",image);

}






@end
