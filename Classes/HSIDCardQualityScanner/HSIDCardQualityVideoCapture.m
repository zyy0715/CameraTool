//
//  HSIDCardQualityVideoCapture.m
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/3.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "HSIDCardQualityVideoCapture.h"

@implementation HSIDCardQualityVideoCapture

- (instancetype)init {
    self = [super init];
    if (!self) {
        return self;
    }
    _captureSession = [[AVCaptureSession alloc] init];

    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    _captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack]; //取得后置摄像头
    NSError *error;
    _captureDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_captureDevice error:&error];
    // add input to capture session
    [_captureSession beginConfiguration];
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    [_captureSession commitConfiguration];

    return self;
}
#pragma mark - public method
- (void)addCaptureOutput:(AVCaptureOutput *)output {
    [_captureSession beginConfiguration];
    if ([_captureSession canAddOutput:output]) {
        [_captureSession addOutput:output];
    }
    [_captureSession commitConfiguration];
}

- (void)removeCaptureOutput:(AVCaptureOutput *)output {
    [_captureSession beginConfiguration];
    [_captureSession removeOutput:output];
    [_captureSession commitConfiguration];
}

- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

@end
