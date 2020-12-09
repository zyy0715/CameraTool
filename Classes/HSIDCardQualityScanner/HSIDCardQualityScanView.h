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
/** 拍照后识别失败图片 */
@property (nonatomic, strong) UIImageView * showIV;
/** 错误信息label */
@property (nonatomic, strong) UILabel * errorLabel;
/** info图标 */
@property (nonatomic, strong) UIImageView * infoIV;
/** 图片尺寸 */
@property (nonatomic, strong) UILabel * showLabel;


- (instancetype)initWithFrame:(CGRect)frame
                  windowFrame:(CGRect)windowFrame
                  orientation:(UIInterfaceOrientation)orientation;

- (void)moveWindowDeltaY:(NSInteger)iDeltaY;

- (void)setLabel:(UILabel *)label;

- (void)setLogString:(NSString *)logString;

@end
