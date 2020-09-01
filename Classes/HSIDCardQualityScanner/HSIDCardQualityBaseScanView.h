//
//  HSIDCardQualityBaseScanView.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/2/9.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSIDCardQualityMaskView : UIView

@property (nonatomic, assign) CGRect windowRect;
@property (nonatomic, strong) UIColor *vertaxLineColor;
@property (nonatomic, strong) UIColor *sideLineColor;
@property (nonatomic, strong) UIColor *maskColor;
@property (nonatomic, assign) CGFloat maskAlpha;

@end

@protocol HSIDCardQualityBaseScanViewDelegate <NSObject>
- (void)idCardQualityBaseScanViewDidCancel;
@end

@interface HSIDCardQualityBaseScanView : UIView

@property (nonatomic, weak) id<HSIDCardQualityBaseScanViewDelegate> cardScanViewDelegate;
@property (nonatomic, assign) CGRect windowFrame;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, assign) CGAffineTransform interfaceTransform;
@property (nonatomic, strong) HSIDCardQualityMaskView *maskCoverView;

- (instancetype)initWithFrame:(CGRect)frame
                  windowFrame:(CGRect)windowFrame
                  orientation:(UIInterfaceOrientation)orientation;

@end
