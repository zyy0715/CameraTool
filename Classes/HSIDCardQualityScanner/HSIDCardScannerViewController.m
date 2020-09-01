//
//  HSIDCardScannerViewController.m
//  IDCardDemo
//
//  Created by farben on 2020/8/11.
//  Copyright © 2020 farben. All rights reserved.
//

#import "HSIDCardScannerViewController.h"
#import "HSCustomIDCardScannerController.h"
#import "UIImage+IDCardExtend.h"


///字符串判空
#define SAFE_STRING(string) (string != nil) ? (string) : (string = @"")
#define IS_EMPTY_STRING(string) (string == nil ||[string isEqualToString:@""])? YES : NO
@interface HSIDCardScannerViewController ()
<
HSIDCardQualityScannerDelegate,
HSIDCardQualityScannerControllerDelegate,
HSIDCardScannerManagerDelegate
>
@property (strong, nonatomic) HSCustomIDCardScannerController *idCardQualityScanner;
@property (nonatomic, assign) BOOL clearAllOnFailed;
@property (nonatomic, assign) HSIDCardQualityScanSide scanSide;
/** 当前图片 */
@property (nonatomic, strong) UIImage * currentImage;
/** SDK管理类 */
@property (nonatomic, strong) HSIDCardScannerManager * manager;

@end

@implementation HSIDCardScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initCamcraSetting];
}

///初始化相机设置
- (void)initCamcraSetting{
    AVCaptureVideoOrientation videoOrientation = AVCaptureVideoOrientationPortrait;
    HSIDCardQualityScanSide scanSide = HSIDCardQualityCardSideScanFront;
    HSIDCardQualityScanMode scanMode = HSIDCardQualityScanModeSingle;
    switch (self.scanType) {
        case HSIDCardQualityScanTypeFront:
            scanSide = HSIDCardQualityCardSideScanFront;
            scanMode = HSIDCardQualityScanModeSingle;
            break;
        case HSIDCardQualityScanTypeBack:
            scanSide = HSIDCardQualityCardSideScanBack;
            scanMode = HSIDCardQualityScanModeSingle;
            break;
        default:
            break;
    }
    self.scanSide = scanSide;
    self.clearAllOnFailed = YES;
    self.idCardQualityScanner = [[HSCustomIDCardScannerController alloc] initWithOrientation:videoOrientation delegate:self];

    HSIDCardQualityScanView *rootView = self.idCardQualityScanner.idCardScanView;
    CGFloat width = 315;
    CGFloat height = 200;
    rootView.windowFrame = CGRectMake((CGRectGetWidth(self.view.frame) - width) * 0.5, (CGRectGetHeight(self.view.frame) - height) * 0.5, width, height);
    HSIDCardQualityMaskView *maskView = [[HSIDCardQualityMaskView alloc] init];
    maskView.windowRect = rootView.windowFrame;
    [rootView.maskCoverView removeFromSuperview];
    [rootView addSubview:maskView];
    rootView.maskCoverView = maskView;
    maskView.frame = rootView.bounds;
    [rootView setLabel:[UILabel new]];

    [self addChildViewController:self.idCardQualityScanner];
    [self.view addSubview:self.idCardQualityScanner.view];
    [self.idCardQualityScanner setScanSide:scanSide scanMode:scanMode clearAllOnFailed:self.clearAllOnFailed];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.idCardQualityScanner.view.frame = self.view.bounds;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)restartScan {
    if (self.clearAllOnFailed) {
        [self.idCardQualityScanner refreshScanSideTextWithSide:self.scanSide];
    }
}

#pragma mark -- HSIDCardQualityScannerControllerDelegate
- (void)idCardReceiveDeveiceError:(HSIDOCRIDCardQualityDeveiceError)deveiceError {
    [self dismissViewControllerAnimated:YES completion:nil];
    self.idCardQualityScanner = nil;

    switch (deveiceError) {
        case HSIDOCRIDCardQuality_E_CAMERA: {
            NSString * errorMessage = @"相机权限检测失败\n请前往设置－隐私－相机中开启相机权限";
        } break;
        case HSIDOCRIDCardQuality_WILL_RESIGN_ACTIVE: {
            NSString * errorMessage = @"取消检测";
        } break;
    }
}

- (void)idCardReceiveImage:(UIImage *)currentImage{
    NSLog(@"获取的图片:%@",currentImage);
    self.currentImage = currentImage;
    self.manager = [HSIDCardScannerManager shareInstance];
    self.manager.delegate = self;
    ///image: 拍照后的图片,最好是截取过以后身份证照片
    [self.manager uploadIDCardScannerImage:currentImage];
}

#pragma mark -- HSIDCardScannerManagerDelegate
/// 返回的解析信息数据
- (void)idCardScannerInfo:(HSIDCardScannerInfo*)idCardInfo{
    NSLog(@"返回解析数据: %@",idCardInfo);
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
       [mainQueue addOperationWithBlock:^{
           if (self.idCardScannerViewDelegate &&
               [self.idCardScannerViewDelegate respondsToSelector:@selector(idCardScannerInfo:image:)]) {
               [self.idCardScannerViewDelegate idCardScannerInfo:idCardInfo image:self.currentImage];
           }
       }];
}

- (void)idCardQualityScannerDidCancel {
    self.idCardQualityScanner = nil;
}

///停止获取图片
- (void)stop{
    [self.idCardQualityScanner stop];
}


@end