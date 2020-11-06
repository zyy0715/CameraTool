//
//  HSIDCardQualityScannerController.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/3.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSIDCardQualityVideoCapture.h"
#import "HSIDCardQualityVideoCaptureManger.h"
#import "HSIDCardQualityBaseScanView.h"
#import "HSOCRIDCardQualityEnumTypeHeader.h"
#import <HSIDCard/HSIDCard.h>

@protocol HSIDCardQualityScannerControllerDelegate <NSObject>

- (void)idCardReceiveDeveiceError:(HSIDOCRIDCardQualityDeveiceError)deveiceError;
- (void)idCardReceiveImage:(UIImage*)currentImage result:(HSIDCardScannerInfo*)result;

@end

/**
 身份证扫描的父类 Controller
 */
@interface HSIDCardQualityScannerController : UIViewController

@property (nonatomic, weak) id<HSIDCardQualityScannerControllerDelegate> idCardScannerControllerDelegate;
@property (nonatomic, strong) HSIDCardQualityVideoCapture *videoCapture;
@property (nonatomic, strong) HSIDCardQualityVideoCaptureManger *videoCaptureManger;
@property (nonatomic, strong) HSIDCardQualityBaseScanView *videoCaptureView;
@property (nonatomic, assign) CGRect uiWindowRect;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) AVCaptureVideoOrientation captureOrientation;

/** 姓名 */
@property (nonatomic, strong) NSString * name;
/** 身份证 */
@property (nonatomic, strong) NSString * idCardNum;

- (instancetype)initWithOrientation:(AVCaptureVideoOrientation)orientation;

- (void)moveScanWindowUpFromCenterWithDelta:(NSInteger)delta;

//- (void)receiveErrorCode:(NSInteger)errorCode;
@end
