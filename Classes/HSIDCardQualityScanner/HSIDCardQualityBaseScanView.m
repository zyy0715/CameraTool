//
//  HSIDCardQualityBaseScanView.m
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/9.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "HSIDCardQualityBaseScanView.h"
#import "HSIDCardQualityDefineHeader.h"
@interface HSIDCardQualityBaseScanView ()

@end

@implementation HSIDCardQualityBaseScanView

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
                  windowFrame:(CGRect)windowFrame
                  orientation:(UIInterfaceOrientation)orientation {
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    self.orientation = orientation;
    self.windowFrame = windowFrame;
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    self.autoresizesSubviews = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight) ? YES : NO;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // important for rotate
    CGFloat newHeight = windowFrame.size.height * [self modifyYRatio];
    CGFloat newY = windowFrame.origin.y - (newHeight - windowFrame.size.height) / 2.0;
    self.windowFrame = CGRectMake(windowFrame.origin.x, newY, windowFrame.size.width, newHeight);
    switch (self.orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            self.interfaceTransform = CGAffineTransformMakeRotation(M_PI_2 * 3);
            break;
        case UIInterfaceOrientationLandscapeRight:
            self.interfaceTransform = CGAffineTransformMakeRotation(M_PI_2);
            break;
        case UIInterfaceOrientationPortrait:
        default:
            self.interfaceTransform = CGAffineTransformMakeRotation(0);
            break;
    }
    _maskCoverView = [[HSIDCardQualityMaskView alloc] initWithFrame:self.bounds];
    _maskCoverView.windowRect = self.windowFrame;
    [self addSubview:_maskCoverView];

    return self;
}

- (CGFloat)modifyYRatio {
    CGFloat videoRatio;
    if (self.orientation == UIInterfaceOrientationPortrait) {
        videoRatio = HSIDCardQuality_VIEDO_WIDTH / HSIDCardQuality_VIDEO_HEIGHT;
    } else {
        videoRatio = HSIDCardQuality_VIDEO_HEIGHT / HSIDCardQuality_VIEDO_WIDTH;
    }

    CGFloat uiRatio = CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds);
    CGFloat ratio = uiRatio / videoRatio;
    return MIN(1, ratio);
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    _maskCoverView.windowRect = self.windowFrame;
    [_maskCoverView setNeedsDisplay];
}

@end

@interface HSIDCardQualityMaskView ()

@property (assign, nonatomic) CGContextRef context;

@end

@implementation HSIDCardQualityMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.vertaxLineColor = [UIColor colorWithRed:119 / 255.0 green:119 / 255.0 blue:119 / 255.0 alpha:1.0];
        self.maskAlpha = 1.0;
        self.maskColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    self.context = UIGraphicsGetCurrentContext();
    [self.maskColor setFill];
    CGContextFillRect(self.context, self.bounds);

    [self.vertaxLineColor set];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.windowRect cornerRadius:10];
    [path fillWithBlendMode:kCGBlendModeClear alpha:1.0];
    path.lineWidth = 2;
    [path stroke];
}

@end
