//
//  HSIDCardScannerViewController.h
//  IDCardDemo
//
//  Created by farben on 2020/8/11.
//  Copyright © 2020 farben. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HSCustomIDCardScannerController.h"

typedef NS_ENUM(NSUInteger, HSIDCardQualityScanType) {
    HSIDCardQualityScanTypeFront,//身份证正面拍照
    HSIDCardQualityScanTypeBack, //身份证背面拍照
    HSIDCardQualityScanTypeOther,//其他证件拍照,仅返回,不做识别
};

NS_ASSUME_NONNULL_BEGIN
@protocol HSIDCardScannerViewControllerDelegate <NSObject>
/**
 返回的解析信息数据
 */
- (void)idCardScannerInfoImage:(UIImage*)image result:(HSIDCardScannerInfo*)result;

@end

@interface HSIDCardScannerViewController : UIViewController
@property (assign, nonatomic) HSIDCardQualityScanType scanType;
/** 网络环境 */
@property (assign, nonatomic) HSIDOCRNetworkStateType networkType;
@property (nonatomic, weak) id<HSIDCardScannerViewControllerDelegate> idCardScannerViewDelegate;

@end

NS_ASSUME_NONNULL_END
