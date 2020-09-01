//
//  STScanEnumHeader.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/3/10.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#ifndef HSIDCardQualityScanEnumHeader_h
#define HSIDCardQualityScanEnumHeader_h

typedef NS_OPTIONS(NSInteger, EMCScanSideOptions) {
    EMCScanSideOptionFront = 1 << 0,
    EMCScanSideOptionBack = 1 << 1,
};

typedef NS_ENUM(NSInteger, HSIDCardQualityCardSide) {
    HSIDCardQualityCardSideUnknow = -1,
    /** 身份证双面 */
    HSIDCardQualityCardSideDouble = 0,
    /** 身份证正面 */
    HSIDCardQualityCardSideFront = 1,
    /** 身份证背面 */
    HSIDCardQualityCardSideBack = 2,
};

typedef NS_ENUM(NSUInteger, HSIDCardQualityScanSide) {
    /**< 身份证正面 */
    HSIDCardQualityCardSideScanFront = 1,
    /**< 身份证背面 */
    HSIDCardQualityCardSideScanBack = 2,
    /**< 自动识别正反面 */
    HSIDCardQualityCardSideScanAuto = 3,
};

typedef NS_ENUM(NSInteger, HSIDCardQualityScanMode) {
    /** 单面扫描 */
    HSIDCardQualityScanModeSingle = 1,
    /** 双面扫描 */
    HSIDCardQualityScanModeDouble = 2,
};

typedef NS_ENUM(NSInteger, HSIDCardQualityImageClassify) {
    /** 正常拍摄 */
    HSIDCardQualityImageClassifyNormal = 0,
    /** 复印件 */
    HSIDCardQualityImageClassifyPhotoCopy = 1,
    /** PS */
    HSIDCardQualityImageClassifyPS = 2,
    /** 屏幕翻拍 */
    HSIDCardQualityImageClassifyReversion = 3,
    /** 其他 */
    HSIDCardQualityImageClassifyOther = 4,
    /** 未知 */
    HSIDCardQualityImageClassifyUnknow = 5,
};

#endif /* STScanEnumHeader_h */
