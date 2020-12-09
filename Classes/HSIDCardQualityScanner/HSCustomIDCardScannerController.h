//
//  HSCustomIDCardScannerController.h
//  IDCardDemo
//
//  Created by farben on 2020/8/11.
//  Copyright © 2020 farben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSIDCardQualityScannerController.h"
#import "HSIDCardQualityScanEnumHeader.h"
#import "HSIDCardQualityScanView.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 @protocol HSIDCardQualityScannerDelegate

 @abstract
 定义了 HSIDCardQualityScanner 的代理，接收 HSIDCardQualityScanner 回调的扫描结果或扫描中出现的异常。
 */
@protocol HSIDCardQualityScannerDelegate <NSObject>

@optional
/**
 处理在 Sample 中点击取消键后的操作
 */
- (void)idCardQualityScannerDidCancel;

@end


@interface HSCustomIDCardScannerController : HSIDCardQualityScannerController
<
HSIDCardQualityBaseScanViewDelegate
>

@property (nonatomic, weak) id<HSIDCardQualityScannerDelegate> idCardScannerDelegate;

/**
 HSIDCardQualityScanner 的 View
 */
@property (nonatomic, strong) HSIDCardQualityScanView *idCardScanView;
/** 网络环境 */
@property (assign, nonatomic) HSIDOCRNetworkStateType networkType;

/*!
 @method initWithOrientation:apiKey:apiSecret:
 @abstract HSIDCardQualityScanner 的包含扫描方向及 apiKey 和 apiSecret 的初始化方法。

 @param orientation 视频的初始化方向

 @param delegate  回调代理

 @return 身份证扫描实例

 @discussion
 初始化方向支持：

 AVCaptureVideoOrientationPortrait

 AVCaptureVideoOrientationLandscapeRight

 AVCaptureVideoOrientationLandscapeLeft

 这三种视频初始化方向
 */
- (instancetype)initWithOrientation:(AVCaptureVideoOrientation)orientation
                           delegate:
                               (id<HSIDCardQualityScannerDelegate,HSIDCardQualityScannerControllerDelegate>)delegate;

/*!
 @method moveScanWindowUpFromCenterWithDelta:
 @abstract 调整取景框的位置
 用于开发者自定义取景框，从中央上上下移动是为了在不同屏幕上的适配问题(仅限于竖屏)用于和定义的界面保持一致

 @param moveDelta 取景框从中央位置上下移动的偏移量

 @discussion <0： 取景框从中央位置上移    >0： 取景框从中央位置下移
 */
- (void)moveScanWindowUpFromCenterWithDelta:(NSInteger)moveDelta;

/**
 设置扫描面

 @param scanSide 正面反面或任意面扫描
 @param scanMode 单面或双面扫描
 @param clearAllOnFailed 是否在扫描失败或超时情况下，清除所有已缓存的数据
 */

- (void)setScanSide:(HSIDCardQualityScanSide)scanSide
            scanMode:(HSIDCardQualityScanMode)scanMode
    clearAllOnFailed:(BOOL)clearAllOnFailed;

/// 刷新扫描提示内容
/// @param scanSide 正面反面或任意面扫描
- (void)refreshScanSideTextWithSide:(HSIDCardQualityScanSide)scanSide;

//关闭相机
- (void)stop;



@end

NS_ASSUME_NONNULL_END
