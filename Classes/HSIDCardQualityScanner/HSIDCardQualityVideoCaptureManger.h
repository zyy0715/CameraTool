//
//  HSIDCardQualityVideoCaptureManger.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/4.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "HSIDCardQualityScanEnumHeader.h"

typedef void(^Completed)(UIImage *image,CMSampleBufferRef sampleBuffer);


@protocol HSIDCardQualityVideoCaptureMangerDelegate <NSObject>

- (void)idCardReceiveImage:(UIImage*)currentImage outputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end


@interface HSIDCardQualityVideoCaptureManger : NSObject
@property (nonatomic, weak) id<HSIDCardQualityVideoCaptureMangerDelegate> idCardCaptureManagerDelegate;

@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoOutput;
/** 静态图片输出 */
@property (nonatomic, strong) AVCaptureStillImageOutput * captureImageOutput;
@property (nonatomic, assign) AVCaptureVideoOrientation captureVideoOrientation;
@property (nonatomic, assign) BOOL isScanVerticalCard;
@property (nonatomic, assign) CGRect scanVideoWindowRect;
@property (nonatomic, assign) BOOL isVideoStreamEnable;
@property (nonatomic, assign) NSInteger videoWidth;
@property (nonatomic, assign) NSInteger videoHeight;
@property (nonatomic, assign) HSIDCardQualityScanSide cardScanSide;
@property (nonatomic, copy) Completed complete;
/** 定时器 */
@property (nonatomic, strong) NSTimer * timer;

//延时识别
@property (nonatomic, assign) NSTimeInterval previousTime;
@property (nonatomic, assign) NSTimeInterval delayBetweenMs;

- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation;
- (CGRect)getMaskFrame;

@end
