//
//  HSCustomIDCardScannerController.m
//  IDCardDemo
//
//  Created by farben on 2020/8/11.
//  Copyright © 2020 farben. All rights reserved.
//

#import "HSCustomIDCardScannerController.h"
#import "HSIDCardQualityDefineHeader.h"
#import "UIImage+IDCardExtend.h"
NSInteger const STIdCardScannerScanBoundary = 64;


@interface HSCustomIDCardScannerController ()<HSIDCardQualityVideoCaptureMangerDelegate>
@property (assign, nonatomic) HSIDCardQualityCardSide cardSide;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSOperationQueue *mainQueue;
@property (nonatomic, strong) UILabel *label;
/** 照片 */
@property (nonatomic, strong) UIImage * photoImage;


@end

@implementation HSCustomIDCardScannerController

- (instancetype)initWithOrientation:(AVCaptureVideoOrientation)orientation
                           delegate:
                               (id<HSIDCardQualityScannerDelegate, HSIDCardQualityScannerControllerDelegate>)delegate {
    self = [super initWithOrientation:orientation];
    if (!self) {
        return self;
    }
    if (_idCardScannerDelegate != delegate) {
        _idCardScannerDelegate = delegate;
    }
    if (self.idCardScannerControllerDelegate != delegate) {
        self.idCardScannerControllerDelegate = delegate;
    }
    _mainQueue = [NSOperationQueue mainQueue];


    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoCaptureManger.idCardCaptureManagerDelegate = self;
    [self.videoCaptureManger setVideoOrientation:self.captureOrientation];

    self.idCardScanView = [[HSIDCardQualityScanView alloc] initWithFrame:self.view.bounds
                                                             windowFrame:super.uiWindowRect
                                                             orientation:super.interfaceOrientation];
    self.idCardScanView.cardScanViewDelegate = self;
    [self.view addSubview:self.idCardScanView];
    [self.idCardScanView.photoBtn addTarget:self action:@selector(photoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.idCardScanView.backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

///拍照功能
- (void)photoBtnAction:(UIButton*)sender{
    WS(ws);
    self.videoCaptureManger.complete = ^(UIImage *image) {
        NSLog(@"图片++++++++++++");
        if (nil != image) {
            ws.photoImage = image;
            [ws getCurrentImage:ws.photoImage];
        }
    };
    //关闭拍照
    [self stop];

}
#pragma mark -- HSIDCardQualityVideoCaptureMangerDelegate
- (void)idCardReceiveImage:(UIImage*)currentImage{
    NSLog(@"+++++++获取到的图片++++++++");
    self.photoImage = currentImage;
    [self getCurrentImage:self.photoImage];
}

///返回功能
- (void)backBtnAction:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self stop];
}
- (void)getCurrentImage:(UIImage*)image{
    CGFloat widthScale = image.size.width / HSIDCardQuality_SCREEN_WIDTH;
    CGFloat heightScale = image.size.height / HSIDCardQuality_SCREEN_HEIGHT;
    CGRect rect = CGRectMake(CGRectGetMinX(super.uiWindowRect)+10, CGRectGetMinY(super.uiWindowRect)+220, (CGRectGetWidth(super.uiWindowRect)*widthScale), (CGRectGetHeight(super.uiWindowRect)*heightScale));
    image = [UIImage getSubImage:rect inImage:image];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
       [mainQueue addOperationWithBlock:^{
           if (self.idCardScannerControllerDelegate &&
               [self.idCardScannerControllerDelegate respondsToSelector:@selector(idCardReceiveImage:)]) {
               [self.idCardScannerControllerDelegate idCardReceiveImage:image];
           }
       }];
}

//关闭相机
- (void)stop{
    if (self.videoCapture.captureSession.isRunning) {
        [self.videoCapture.captureSession stopRunning];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setScanSide:(HSIDCardQualityScanSide)scanSide
            scanMode:(HSIDCardQualityScanMode)scanMode
    clearAllOnFailed:(BOOL)clearAllOnFailed {
    [self refreshScanSideTextWithSide:scanSide];
}

- (void)refreshScanSideTextWithSide:(HSIDCardQualityScanSide)scanSide {
    self.label = [[UILabel alloc] init];
    self.label.textColor = [UIColor whiteColor];
    NSString *textStr = @"";
    switch (scanSide) {
        case HSIDCardQualityCardSideScanFront:
            textStr = @"提示:\n1.请将身份证人面像与边框对齐\n2.请在确保照片清晰时按下拍照键";
            self.idCardScanView.headIV.hidden = NO;
            self.idCardScanView.iconIV.hidden = YES;
            break;
        case HSIDCardQualityCardSideScanBack:
            textStr = @"提示:\n1.请将身份证国徽与边框对齐\n2.请在确保照片清晰时按下拍照键";
            self.idCardScanView.headIV.hidden = YES;
            self.idCardScanView.iconIV.hidden = NO;
            break;
        case HSIDCardQualityCardSideScanAuto:
            textStr = @"请将身份证任意面放入扫描框内 \n 尝试对其边缘";
            break;
    }

    self.label.text = textStr;
    [self.idCardScanView setLabel:self.label];
}

#pragma mark - Recognizer Delegate
- (void)idCardScanQualityInfoUpdateWithIncompleteScore:(CGFloat)incompleteScore
                                         dimLightScore:(CGFloat)dimLightScore
                                        highLightScore:(CGFloat)highLightScore
                                           normalScore:(CGFloat)normalScore
                                           blurryScore:(CGFloat)blurryScore
                                         occludedScore:(CGFloat)occludedScore
                                              cardSide:(HSIDCardQualityCardSide)cardSide {
    [self.mainQueue addOperationWithBlock:^{
        NSString *qualityInfoString = [NSString
            stringWithFormat:@" 身份证质量检测结果 \n side:%@ \n incompleteScore:%.4f \n "
                             @"dimLightScore:%.4f \n highLightScore:%.4f \n normalScore:%.4f \n blurryScore:%.4f \n "
                             @"occludedScore:%.4f  ",
                             [self praseCardSideToString:cardSide],
                             incompleteScore,
                             dimLightScore,
                             highLightScore,
                             normalScore,
                             blurryScore,
                             occludedScore];
        [self.idCardScanView setLogString:qualityInfoString];
    }];
}

- (void)tipsText {
    NSString *textStr = nil;
    if (self.cardSide == HSIDCardQualityCardSideFront) {
        textStr = @"请将身份证背面放入扫描框内 \n 尝试对其边缘";
    } else {
        textStr = @"请将身份证正面放入扫描框内 \n 尝试对其边缘";
    }
    self.label.text = textStr;
    self.label.textColor = [UIColor whiteColor];
    [self.idCardScanView setLabel:self.label];
}

- (void)timerInvalidate {
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
}
- (void)moveScanWindowUpFromCenterWithDelta:(NSInteger)moveDelta {
    if (!(self.videoCaptureManger.captureVideoOrientation == AVCaptureVideoOrientationPortrait)) {
        return;
    }
    CGFloat realHeight = HSIDCardQuality_SCREEN_HEIGHT;
    NSInteger moveValue = moveDelta;

    BOOL ismoveValueNagative = moveValue < 0;

    if ((self.idCardScanView.windowFrame.origin.y + moveValue) < STIdCardScannerScanBoundary && ismoveValueNagative) {
        moveValue = -self.idCardScanView.windowFrame.origin.y + STIdCardScannerScanBoundary;
    }
    if ((self.idCardScanView.windowFrame.origin.y + self.idCardScanView.windowFrame.size.height + moveValue +
             STIdCardScannerScanBoundary >
         realHeight) &&
        !ismoveValueNagative) {
        moveValue = realHeight - self.idCardScanView.windowFrame.origin.y -
            self.idCardScanView.windowFrame.size.height - STIdCardScannerScanBoundary;
    }

    if ((self.videoCaptureManger.scanVideoWindowRect.origin.y +
         (CGFloat) moveValue / realHeight * (CGFloat) self.videoCaptureManger.videoHeight) < 0) {
        moveValue = -1 * self.videoCaptureManger.scanVideoWindowRect.origin.y /
            (CGFloat) self.videoCaptureManger.videoHeight * realHeight;
    }

    if ((self.videoCaptureManger.scanVideoWindowRect.origin.y +
             (CGFloat) moveValue / realHeight * (CGFloat) self.videoCaptureManger.videoHeight +
             self.videoCaptureManger.scanVideoWindowRect.size.height >
         (CGFloat) self.videoCaptureManger.videoHeight)) {
        moveValue = realHeight -
            self.videoCaptureManger.scanVideoWindowRect.origin.y / (CGFloat) self.videoCaptureManger.videoHeight *
                realHeight;
    }

    CGRect tmpRect = self.videoCaptureManger.scanVideoWindowRect;
    if (self.videoCaptureManger.videoHeight > self.videoCaptureManger.videoWidth) {
        NSInteger iFitIPhone4Size = 0;
        // For fit ip4 ratio
        if (realHeight == 480) {
            iFitIPhone4Size = 200;
        }
        tmpRect.origin.y +=
            (CGFloat) moveValue / realHeight * ((CGFloat) self.videoCaptureManger.videoHeight - iFitIPhone4Size);
    }
    self.videoCaptureManger.scanVideoWindowRect = tmpRect;
    [self.idCardScanView moveWindowDeltaY:moveValue];
}

- (void)idCardQualityBaseScanViewDidCancel {
    if (self.idCardScannerDelegate &&
        [self.idCardScannerDelegate respondsToSelector:@selector(idCardQualityScannerDidCancel)]) {
        [self.idCardScannerDelegate idCardQualityScannerDidCancel];
    }
    [self timerInvalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)willResignActive {
    if ([self isCurrentViewOnScreen] && self.idCardScannerControllerDelegate &&
        [self.idCardScannerControllerDelegate respondsToSelector:@selector(idCardReceiveDeveiceError:)]) {
        [self.idCardScannerControllerDelegate idCardReceiveDeveiceError:HSIDOCRIDCardQuality_WILL_RESIGN_ACTIVE];
    }
}

- (BOOL)isCurrentViewOnScreen {
    return self.isViewLoaded && self.view.window;
}

- (NSString *)praseCardSideToString:(HSIDCardQualityCardSide)cardSide {
    switch (cardSide) {
        case HSIDCardQualityCardSideUnknow:
            return @"unknow";
        case HSIDCardQualityCardSideDouble:
            return @"double";
        case HSIDCardQualityCardSideFront:
            return @"front";
        case HSIDCardQualityCardSideBack:
            return @"back";
    }
    return @"unknow";
}






@end
