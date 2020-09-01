//
//  HSIDCardQualityScanView.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/3/15.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "HSIDCardQualityBaseScanView.h"

@interface HSIDCardQualityScanView : HSIDCardQualityBaseScanView
/** 拍照 */
@property (nonatomic, strong) UIButton * photoBtn;
/** 返回 */
@property (nonatomic, strong) UIButton * backBtn;
/** 人像图 */
@property (nonatomic, strong) UIImageView * headIV;
/** 国徽图 */
@property (nonatomic, strong) UIImageView * iconIV;


- (instancetype)initWithFrame:(CGRect)frame
                  windowFrame:(CGRect)windowFrame
                  orientation:(UIInterfaceOrientation)orientation;

- (void)moveWindowDeltaY:(NSInteger)iDeltaY;

- (void)setLabel:(UILabel *)label;

- (void)setLogString:(NSString *)logString;

@end
