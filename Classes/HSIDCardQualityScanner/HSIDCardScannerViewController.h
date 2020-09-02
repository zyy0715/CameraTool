//
//  HSIDCardScannerViewController.h
//  IDCardDemo
//
//  Created by farben on 2020/8/11.
//  Copyright © 2020 farben. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, HSIDCardQualityScanType) {
    HSIDCardQualityScanTypeFront,
    HSIDCardQualityScanTypeBack,
};

NS_ASSUME_NONNULL_BEGIN
@protocol HSIDCardScannerViewControllerDelegate <NSObject>
/**
 返回的解析信息数据
 */
- (void)idCardScannerInfoImage:(UIImage*)image;

@end

@interface HSIDCardScannerViewController : UIViewController
@property (assign, nonatomic) HSIDCardQualityScanType scanType;
@property (nonatomic, weak) id<HSIDCardScannerViewControllerDelegate> idCardScannerViewDelegate;

@end

NS_ASSUME_NONNULL_END
