//
//  HSIDCardQualityVideoCaptureManger.m
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/4.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <libkern/OSAtomic.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import <sys/utsname.h>
#import "HSIDCardQualityVideoCaptureManger.h"
#include "HSIDCardQualityDefineHeader.h"
#import "UIImage+IDCardExtend.h"

@interface HSIDCardQualityVideoCaptureManger () <AVCaptureVideoDataOutputSampleBufferDelegate> {
    dispatch_queue_t queue;
    volatile uint32_t state;
    volatile int32_t channel;
    volatile int8_t m_iTakeSnapAndStop;
    NSLock * lock;
    dispatch_semaphore_t signal;
    dispatch_time_t overTime;
    CMSampleBufferRef buffer;
    UIImage *currentImage;
}

@end

@implementation HSIDCardQualityVideoCaptureManger

- (instancetype)init {
    self = [super init];
    if (self) {
        // create AVCaptureVideoDataOutput
        self.captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
        self.captureVideoOutput.alwaysDiscardsLateVideoFrames = YES;
        self.captureVideoOutput.videoSettings =
            @{(id) kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
        // create GCD queue
        queue = dispatch_queue_create("HSIDCardQualityVideoQueue", NULL);
        [self.captureVideoOutput setSampleBufferDelegate:self queue:queue];

        self.captureImageOutput = [[AVCaptureStillImageOutput alloc] init];
        self.captureImageOutput.outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
        self.isVideoStreamEnable = YES;
        signal = dispatch_semaphore_create(0);
        overTime = dispatch_time(DISPATCH_TIME_NOW, 4.0f * NSEC_PER_SEC);
    }
    return self;
}

- (void)initTimer{
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timeAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)setVideoOrientation:(AVCaptureVideoOrientation)orientation {
    [[self.captureVideoOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:orientation];
    self.captureVideoOrientation = orientation;
    if (self.isScanVerticalCard) {
        self.captureVideoOrientation = AVCaptureVideoOrientationPortrait;
        self.scanVideoWindowRect = HSIDCardQuality_VIDEO_WINDOW_V;
        self.videoWidth = 720;
        self.videoHeight = 1280;

    } else if (orientation == AVCaptureVideoOrientationPortrait) {
        self.scanVideoWindowRect = HSIDCardQuality_VIDEO_WINDOW_H;
        self.videoWidth = 720;
        self.videoHeight = 1280;
    } else {
        self.scanVideoWindowRect = HSIDCardQuality_VIDEO_WINDOW_V;
        self.videoWidth = 1280;
        self.videoHeight = 720;
    }
}

- (CGRect)getMaskFrame {
    if (self.captureVideoOrientation == AVCaptureVideoOrientationPortrait) {
        return HSIDCardQuality_MASK_WINDOW_H;
    }
    return HSIDCardQuality_MASK_WINDOW_V;
}

///时间函数
- (void)timeAction:(NSTimer*)timer{
    NSLog(@"上传图片");
    NSLog(@"Timer %@", [NSThread currentThread]);
    if (nil != currentImage) {
        if (self.complete) {
            self.complete(currentImage);
        }
        if (self.idCardCaptureManagerDelegate &&
            [self.idCardCaptureManagerDelegate respondsToSelector:@selector(idCardReceiveImage:)]) {
            [self.idCardCaptureManagerDelegate idCardReceiveImage:currentImage];
        }
    }
}
#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput //! OCLint
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection { //! OCLint
    if (!self.isVideoStreamEnable) {
        return;
    }
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        NSLog(@"图片失效!");
        return;
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    currentImage = [UIImage getImageStream:imageBuffer];
    NSLog(@"图片数据:%@",currentImage);
    if (self.complete) {
        self.complete(currentImage);
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
}

- (void)recognizeWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    self.isVideoStreamEnable = YES;
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        return;
    }
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    currentImage = [UIImage getImageStream:imageBuffer];
    NSLog(@"获取图片数据");
}

@end
