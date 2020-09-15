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
    HSIDCardQualityScanTypeFront,
    HSIDCardQualityScanTypeBack,
    HSIDCardQualityScanTypeOther,
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
@property (nonatomic, weak) id<HSIDCardScannerViewControllerDelegate> idCardScannerViewDelegate;

@end

NS_ASSUME_NONNULL_END
