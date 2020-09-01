//
//  HSIDCardQualityVideoCapture.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/3.
//  Copyright © 2017年 SenseTime. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

@interface HSIDCardQualityVideoCapture : NSObject

@property (nonatomic, strong, readonly) AVCaptureSession *captureSession;
@property (nonatomic, strong, readonly) AVCaptureDevice *captureDevice;
@property (nonatomic, strong, readonly) AVCaptureDeviceInput *captureDeviceInput;
//@property(nonatomic, assign) AVCaptureDevicePosition    devicePosition;

- (void)addCaptureOutput:(AVCaptureOutput *)output;
- (void)removeCaptureOutput:(AVCaptureOutput *)output;
@end
