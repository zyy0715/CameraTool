//
//  HSIDCardQualityScannerController.m
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/3.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "HSIDCardQualityScannerController.h"
#import "HSIDCardQualityScanEnumHeader.h"
#import "HSIDCardQualityDefineHeader.h"

typedef void (^propertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface HSIDCardQualityScannerController ()

@end

@implementation HSIDCardQualityScannerController

#pragma mark - life cycle

- (instancetype)initWithOrientation:(AVCaptureVideoOrientation)orientation {
    self = [super init];
    if (self) {
        _captureOrientation = orientation;
        _videoCapture = [[HSIDCardQualityVideoCapture alloc] init];
        _videoCaptureManger = [[HSIDCardQualityVideoCaptureManger alloc] init];
        [_videoCaptureManger setVideoOrientation:orientation];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)loadView {
    [super loadView];
    [self.videoCapture addCaptureOutput:self.videoCaptureManger.captureVideoOutput];
    [self.videoCapture addCaptureOutput:self.videoCaptureManger.captureImageOutput];
    self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.view.contentMode = UIViewContentModeScaleAspectFill;
    self.view.layer.masksToBounds = YES;
    self.view.contentMode = UIViewContentModeScaleAspectFill;

    AVCaptureVideoPreviewLayer *previewLayer =
        [AVCaptureVideoPreviewLayer layerWithSession:self.videoCapture.captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    previewLayer.backgroundColor = [[UIColor blackColor] CGColor];
    previewLayer.frame = CGRectMake(0, 0, HSIDCardQuality_SCREEN_WIDTH, HSIDCardQuality_SCREEN_HEIGHT);
    previewLayer.connection.videoOrientation = self.captureOrientation;

    [self.view.layer addSublayer:previewLayer];

    [self addNotificationToCaptureDevice:self.videoCapture.captureDevice];
    [self addView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                     completionHandler:^(BOOL granted) {
                                         if (granted) {
                                             [self start];

                                         } else {
                                             NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
                                             [mainQueue addOperationWithBlock:^{
                                                 [self receiveErrorCode:HSIDOCRIDCardQuality_E_CAMERA];
                                             }];
                                         }
                                     }];
            break;
        }
        case AVAuthorizationStatusAuthorized: {
            [self start];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted: {
            [self receiveErrorCode:HSIDOCRIDCardQuality_E_CAMERA];
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addView {
    CGRect uiWindowScanRect;
    CGRect videoWindowScanRect;
    switch (self.captureOrientation) {
        case AVCaptureVideoOrientationPortrait: {
            videoWindowScanRect = [self.videoCaptureManger getMaskFrame];
            uiWindowScanRect = CGRectMake(videoWindowScanRect.origin.x / self.videoCaptureManger.videoWidth *
                                              HSIDCardQuality_SCREEN_WIDTH,
                                          videoWindowScanRect.origin.y / self.videoCaptureManger.videoHeight *
                                              HSIDCardQuality_SCREEN_HEIGHT,
                                          videoWindowScanRect.size.width / self.videoCaptureManger.videoWidth *
                                              HSIDCardQuality_SCREEN_WIDTH,
                                          videoWindowScanRect.size.height / self.videoCaptureManger.videoHeight *
                                              HSIDCardQuality_SCREEN_HEIGHT);
            self.interfaceOrientation = UIInterfaceOrientationPortrait;
        } break;
        case AVCaptureVideoOrientationLandscapeLeft: {
            videoWindowScanRect = [self.videoCaptureManger getMaskFrame];
            uiWindowScanRect =
                CGRectMake(videoWindowScanRect.origin.x / self.videoCaptureManger.videoWidth *
                                   HSIDCardQuality_SCREEN_HEIGHT * 16 / 9 +
                               (HSIDCardQuality_SCREEN_WIDTH - HSIDCardQuality_SCREEN_HEIGHT * 16 / 9) * 0.5,
                           videoWindowScanRect.origin.y / self.videoCaptureManger.videoHeight *
                               HSIDCardQuality_SCREEN_HEIGHT,
                           videoWindowScanRect.size.width / self.videoCaptureManger.videoWidth *
                               HSIDCardQuality_SCREEN_HEIGHT * 16 / 9,
                           videoWindowScanRect.size.height / self.videoCaptureManger.videoHeight *
                               HSIDCardQuality_SCREEN_HEIGHT);
            self.interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
        } break;
        case AVCaptureVideoOrientationLandscapeRight: {
            videoWindowScanRect = [self.videoCaptureManger getMaskFrame];
            uiWindowScanRect =
                CGRectMake(videoWindowScanRect.origin.x / self.videoCaptureManger.videoWidth *
                                   HSIDCardQuality_SCREEN_HEIGHT * 16 / 9 +
                               (HSIDCardQuality_SCREEN_WIDTH - HSIDCardQuality_SCREEN_HEIGHT * 16 / 9) * 0.5,
                           videoWindowScanRect.origin.y / self.videoCaptureManger.videoHeight *
                               HSIDCardQuality_SCREEN_HEIGHT,
                           videoWindowScanRect.size.width / self.videoCaptureManger.videoWidth *
                               HSIDCardQuality_SCREEN_HEIGHT * 16 / 9,
                           videoWindowScanRect.size.height / self.videoCaptureManger.videoHeight *
                               HSIDCardQuality_SCREEN_HEIGHT);
            self.interfaceOrientation = UIInterfaceOrientationLandscapeRight;
        } break;

        default: {
            videoWindowScanRect = [self.videoCaptureManger getMaskFrame];
            uiWindowScanRect = CGRectMake(videoWindowScanRect.origin.x / self.videoCaptureManger.videoWidth *
                                              HSIDCardQuality_SCREEN_WIDTH,
                                          videoWindowScanRect.origin.y / self.videoCaptureManger.videoHeight *
                                              HSIDCardQuality_SCREEN_HEIGHT,
                                          videoWindowScanRect.size.width / self.videoCaptureManger.videoWidth *
                                              HSIDCardQuality_SCREEN_WIDTH,
                                          videoWindowScanRect.size.height / self.videoCaptureManger.videoHeight *
                                              HSIDCardQuality_SCREEN_HEIGHT);
            self.interfaceOrientation = UIInterfaceOrientationPortrait;
        } break;
    }
    self.uiWindowRect = uiWindowScanRect;
}
- (void)start {
    if (!self.videoCapture.captureSession.isRunning) {
        [self.videoCapture.captureSession startRunning];
    }
}


- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice { //! OCLint
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
}

- (void)changeDeviceProperty:(propertyChangeBlock)propertyChange {
    if (!propertyChange) {
        return;
    }
    AVCaptureDevice *captureDevice = [self.videoCapture.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    } else {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@", error.localizedDescription);
    }
}

- (void)receiveErrorCode:(HSIDOCRIDCardQualityDeveiceError)errorCode {
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    [mainQueue addOperationWithBlock:^{
        if (self.idCardScannerControllerDelegate &&
            [self.idCardScannerControllerDelegate respondsToSelector:@selector(idCardReceiveDeveiceError:)]) {
            [self.idCardScannerControllerDelegate idCardReceiveDeveiceError:errorCode];
        }
    }];
}

#pragma mark - Forbid Rotate

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; //只支持这一个方向(正常的方向)
}

- (void)moveScanWindowUpFromCenterWithDelta:(NSInteger)delta { //! OCLint
    if (!(self.captureOrientation == AVCaptureVideoOrientationPortrait)) {
        return;
    }
}

@end
