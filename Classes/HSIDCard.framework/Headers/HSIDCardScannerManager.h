//
//  HSIDCardScannerManager.h
//  IDCardDemo
//
//  Created by farben on 2020/8/31.
//  Copyright © 2020 farben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HSIDCardScannerInfo.h"

NS_ASSUME_NONNULL_BEGIN
typedef enum : NSUInteger {
    HSNetworkStateTestType = 0,
    HSNetworkStateProductionType,
    HSNetworkStateOtherType,
} HSNetworkStateType;

@protocol HSIDCardScannerManagerDelegate <NSObject>
/**
 返回的解析信息数据
 */
- (void)idCardScannerInfo:(HSIDCardScannerInfo*)idCardInfo;
@end

@interface HSIDCardScannerManager : NSObject
/** 代理 */
@property (nonatomic, weak) id<HSIDCardScannerManagerDelegate> delegate;
/** 网络环境 */
@property (nonatomic, assign) HSNetworkStateType  networkType;

/**
 * 便利初始化,非单例模式
 */
+ (instancetype)shareInstance;
/**
 * 设置网络环境(默认测试环境)
 */
- (void)setCurrentNetWorkType:(HSNetworkStateType)type;
/**
 * 上传需要解析的身份证照片
 * @param image 身份证照(截取之后的图片最优)
 */
- (void)uploadIDCardScannerImage:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
