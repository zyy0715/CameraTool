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
#import "HSTensorFlowLiteManager.h"

NSInteger const STIdCardScannerScanBoundary = 64;


@interface HSCustomIDCardScannerController ()
<
HSIDCardQualityVideoCaptureMangerDelegate,
HSIDCardScannerManagerDelegate
>
{
    BOOL isNext;
    NSInteger skipCount;
}
@property (assign, nonatomic) HSIDCardQualityCardSide cardSide;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSOperationQueue *mainQueue;
@property (nonatomic, strong) UILabel *label;
/** 照片 */
@property (nonatomic, strong) UIImage * photoImage;
/** 显示拍照正反面 */
@property (nonatomic, assign) HSIDCardQualityScanSide scanSide;

/** SDK管理类 */
@property (nonatomic, strong) HSIDCardScannerManager * manager;

/** 图片传回block */
@property (nonatomic, copy) Completed block;

/** Tensorflowlite */
@property (nonatomic, strong) HSTensorFlowLiteManager * TFLManager;
/** 图片 */
@property (nonatomic, strong) UIImageView * bgIV;

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
    isNext = NO;
    skipCount = 0;
    self.view.backgroundColor = [UIColor whiteColor];
    self.videoCaptureManger.idCardCaptureManagerDelegate = self;
    [self.videoCaptureManger setVideoOrientation:self.captureOrientation];

    self.idCardScanView = [[HSIDCardQualityScanView alloc] initWithFrame:self.view.bounds
                                                             windowFrame:super.uiWindowRect
                                                             orientation:super.interfaceOrientation];
    self.idCardScanView.cardScanViewDelegate = self;
    [self.view addSubview:self.idCardScanView];
    
    self.idCardScanView.photoBtn.hidden = YES;
    [self.idCardScanView.photoBtn addTarget:self action:@selector(photoBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.idCardScanView.backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];

    self.manager = [HSIDCardScannerManager shareInstance];
    self.manager.delegate = self;
//    [self.manager setDefaultConfig:@{@"name":self.name,@"idCardNum":self.idCardNum}];
    [self.manager setDefaultConfig:@{}];
    if (self.networkType == HSIDOCRNetworkStateProductionType) {
        [self.manager setCurrentNetWorkType:HSNetworkStateProductionType];
    }else{
        [self.manager setCurrentNetWorkType:HSNetworkStateTestType];
    }
    
    self.idCardScanView.infoIV.hidden = YES;
    self.idCardScanView.errorLabel.hidden = NO;
    self.idCardScanView.errorLabel.text = @"";
    self.idCardScanView.showIV.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}
- (void)start {
    if (!self.videoCapture.captureSession.isRunning) {
        [self.videoCapture.captureSession startRunning];
    }
}
///拍照功能
- (void)photoBtnAction:(UIButton*)sender{
    NSString *title = [sender titleForState:UIControlStateNormal];
    if ([@"重拍" containsString:title]) {
        [self switchCurrentView:NO];
        [self start];
        return;
    }
    WS(ws);
    self.block = ^(UIImage *image,CMSampleBufferRef sampleBuffer) {
        NSLog(@"图片++++++++++++");
        if (nil != image) {
            [ws performSelector:@selector(stop) onThread:[NSThread mainThread] withObject:nil waitUntilDone:NO];
            [ws getCurrentImage:image outputSampleBuffer:sampleBuffer];
        }
    };
    self.videoCaptureManger.complete = self.block;

     //关闭拍照
//     [self stop];
}
#pragma mark -- HSIDCardQualityVideoCaptureMangerDelegate
- (void)idCardReceiveImage:(UIImage*)currentImage outputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
//    NSLog(@"+++++++获取到的图片++++++++");
    if (isNext) {
        if (skipCount >= SKIPCOUNT) {
            isNext = NO;
        }
        skipCount++;
        return;
    }
    skipCount = 0;
    isNext = YES;
    [self getCurrentImage:currentImage outputSampleBuffer:sampleBuffer];
}

///返回功能判断
- (void)backPreviousController{
    if (self.presentingViewController||[self.navigationController.viewControllers.firstObject isEqual:self]){
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
///返回功能
- (void)backBtnAction:(UIButton*)sender{
    [self backPreviousController];
    [self stop];
}
- (void)getCurrentImage:(UIImage*)image  outputSampleBuffer:(CMSampleBufferRef)sampleBuffer{
//    self.videoCaptureManger.complete = nil;
    CGFloat widthScale = image.size.width/HSIDCardQuality_SCREEN_WIDTH;
    CGFloat heightScale = image.size.height/HSIDCardQuality_SCREEN_HEIGHT;
    CGFloat defaultWidth = (CGRectGetWidth(super.uiWindowRect)*widthScale);
    CGFloat defaultHeight = (CGRectGetHeight(super.uiWindowRect)*heightScale);
    CGFloat defaultY = CGRectGetMinY(super.uiWindowRect)*heightScale;
    CGRect rect = CGRectMake(CGRectGetMinX(super.uiWindowRect)+10,defaultY, defaultWidth, defaultHeight);
    image = [UIImage getSubImage:rect inImage:image];
    NSLog(@"切图: %@",NSStringFromCGRect(rect));
    self.photoImage = image;
    ///对图片进行缩放处理
//    self.photoImage = [UIImage imageCompressForWidth:image targetWidth:320];
    //Uint8 128*72     Float32  224*224
    CVPixelBufferRef pixelBuffer = [self.TFLManager createImage:image scaleSize:CGSizeMake(128, 72) PixelBufferRef:sampleBuffer];
    TFLTensor *inputTensor = [self.TFLManager inputTensorAtIndex:0];
    [self.TFLManager inputDataFromBuffer:pixelBuffer with:inputTensor];
    TFLTensor *outputTensor = [self.TFLManager outputTensorAtIndex:0];
    NSArray *results = [self.TFLManager transTFLTensorOutputData:outputTensor withName:outputTensor.name offset:0.75];
    if (results.count == 0) {
        isNext = NO;
        return;
    }
    NSDictionary *result = results.firstObject;
    NSString *className = result[TFLClassNameKey];
    NSNumber *condince = result[TFLConfidenceKey];
    NSLog(@"结果集:%@",results);
    NSLog(@"结果:%@ -- 概率:%@",className,condince);
    if ([@"front" isEqualToString:className]&&(self.scanSide == HSIDCardQualityCardSideScanFront)) {
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            [self.manager uploadIDCardScannerImage:self.photoImage];
        }];
    }else if ([@"reverse" isEqualToString:className]&&(self.scanSide == HSIDCardQualityCardSideScanBack)){
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            [self.manager uploadIDCardScannerImage:self.photoImage];
        }];
    }else if([@"other" isEqualToString:className]&&(self.scanSide == HSIDCardQualityCardSideScanAuto)){
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            HSIDCardScannerInfo *idCardInfo = [[HSIDCardScannerInfo alloc]init];
            idCardInfo.code = 0;
            idCardInfo.errMsg = @"其他证件拍照,无需识别";
            [self checkCurrentImageWithSuccess:self.photoImage result:idCardInfo];
        }];
    }else{
        isNext = NO;
    }
   
//    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//    [mainQueue addOperationWithBlock:^{
//        self.bgIV.image = scaleImage;
//    }];
    
    ///image: 拍照后的图片,最好是截取过以后身份证照片
//    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//    [mainQueue addOperationWithBlock:^{
//        [self.manager uploadIDCardScannerImage:self.photoImage];
//    }];
}

///切换当前UI显示
- (void)switchCurrentView:(BOOL)isError{
    self.idCardScanView.showIV.hidden = !isError;
    self.idCardScanView.infoIV.hidden = !isError;
    self.idCardScanView.errorLabel.hidden = !isError;
    if (isError) {
        [self.idCardScanView.photoBtn setTitle:@"重拍" forState:UIControlStateNormal];
    }else{
        [self.idCardScanView.photoBtn setTitle:@"" forState:UIControlStateNormal];
    }
}

///检测图片失败
- (void)checkCurrentImageWithFailed:(UIImage*)image result:(HSIDCardScannerInfo*)result{
    self.idCardScanView.showIV.image = image;
    self.idCardScanView.errorLabel.text = [NSString stringWithFormat:@"%@",result.errMsg];
    [self switchCurrentView:YES];
}
///检测图片成功
- (void)checkCurrentImageWithSuccess:(UIImage*)image result:(HSIDCardScannerInfo*)result{
    if (self.idCardScannerControllerDelegate &&
        [self.idCardScannerControllerDelegate respondsToSelector:@selector(idCardReceiveImage:result:)]) {
        [self.idCardScannerControllerDelegate idCardReceiveImage:image result:result];
    }
    [self backBtnAction:nil];
}

#pragma mark -- HSIDCardScannerManagerDelegate
/// 返回的解析信息数据
- (void)idCardScannerInfo:(HSIDCardScannerInfo*)idCardInfo{
    NSLog(@"返回解析数据: %@",idCardInfo.errMsg);
    NSInteger index = idCardInfo.code;
    if (index != 0) {
        isNext = NO;
        NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            self.idCardScanView.infoIV.hidden = NO;
            self.idCardScanView.errorLabel.text = [NSString stringWithFormat:@"%@",idCardInfo.errMsg];
        }];
        return;
    }
    if (idCardInfo.isFront) {
        if (self.scanSide != HSIDCardQualityCardSideScanFront) {
            isNext = NO;
            return;
        }
    }else{
        if (self.scanSide != HSIDCardQualityCardSideScanBack) {
            isNext = NO;
            return;
        }
    }
    
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        NSLog(@"++++++当前数值+++++++:%@",@(index));
        [self checkCurrentImageWithSuccess:self.photoImage result:idCardInfo];
    }];
}



//关闭相机
- (void)stop{
    if (self.videoCapture.captureSession.isRunning) {
        [self.videoCapture.captureSession stopRunning];
    }
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
    self.scanSide = scanSide;
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
    [self backPreviousController];
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

///添加模型识别

- (HSTensorFlowLiteManager *)TFLManager{
    if (nil == _TFLManager) {
        _TFLManager = [HSTensorFlowLiteManager shareInstance];
    }
    return _TFLManager;
}




@end
