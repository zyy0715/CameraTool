//
//  HSIDCardQualityScanView.m
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/3/15.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#import "HSIDCardQualityScanView.h"
#import "HSIDCardQualityDefineHeader.h"

NSInteger const STIdCardViewLabelFrontSize = 15;

#define HScaleX  (380.0/1880.0)
#define HScaleY  (500.0/1173.0)

#define GScaleX  (310.0/1880.0)
#define GScaleY  (333.0/1173.0)


@interface HSIDCardQualityScanView ()

@property (nonatomic, strong) UILabel *labelScan;
/** 提示 */
@property (nonatomic, strong) UILabel * noticeLabel;


@end

@implementation HSIDCardQualityScanView

- (instancetype)initWithFrame:(CGRect)frame
                  windowFrame:(CGRect)windowFrame
                  orientation:(UIInterfaceOrientation)orientation {
    self = [super initWithFrame:frame windowFrame:windowFrame orientation:orientation];
    if (!self) {
        return self;
    }
    _labelScan = [[UILabel alloc] init];
    _labelScan.text = @"点击取景框对焦";
    [_labelScan setBackgroundColor:[UIColor clearColor]];
    [_labelScan setTextColor:[UIColor whiteColor]];
    [_labelScan setFont:[UIFont systemFontOfSize:STIdCardViewLabelFrontSize]];
    [_labelScan setFrame:CGRectMake(0, 0, HSIDCardQuality_SCREEN_WIDTH, 40)];

    _labelScan.center = CGPointMake(CGRectGetMidX(self.windowFrame), CGRectGetMidY(self.windowFrame));
    [_labelScan setTextAlignment:NSTextAlignmentCenter];
    [_labelScan setNumberOfLines:10];

    [self addSubview:_labelScan];

    _noticeLabel = [[UILabel alloc] init];
    [_noticeLabel setBackgroundColor:[UIColor clearColor]];
    [_noticeLabel setTextColor:[UIColor whiteColor]];
    [_noticeLabel setFont:[UIFont systemFontOfSize:STIdCardViewLabelFrontSize]];
    [_noticeLabel setFrame:CGRectMake(CGRectGetMinX(self.windowFrame), CGRectGetMaxY(self.windowFrame)+10, CGRectGetWidth(self.windowFrame), 80)];
    [_noticeLabel setTextAlignment:NSTextAlignmentLeft];
    [_noticeLabel setNumberOfLines:5];

//    if (orientation == UIInterfaceOrientationPortrait) {
//        _labelScan.center = CGPointMake(CGRectGetMidX(self.windowFrame), CGRectGetMidY(self.windowFrame));
//    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
//        _labelScan.center = CGPointMake(CGRectGetMidX(self.windowFrame), CGRectGetMidY(self.windowFrame));
//    } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
//        _labelScan.center = CGPointMake(CGRectGetMidX(self.windowFrame), CGRectGetMidY(self.windowFrame));
//    }

    [self addSubview:_noticeLabel];


    [self.photoBtn setFrame:CGRectMake(0, 0, 60, 60)];
    [self.photoBtn setCenter:CGPointMake(CGRectGetMidX(self.frame), CGRectGetHeight(self.frame)-60)];
    [self addSubview:self.photoBtn];

    [self.backBtn setFrame:CGRectMake(0, 0, 30, 30)];
    [self.backBtn setCenter:CGPointMake(30, CGRectGetMinY(self.frame)+40)];
    [self addSubview:self.backBtn];

    CGFloat hx = CGRectGetMaxX(self.windowFrame)-CGRectGetWidth(self.windowFrame) * HScaleX;
    CGFloat hy = CGRectGetMinY(self.windowFrame)+CGRectGetHeight(self.windowFrame) * HScaleY;
    [self.headIV setFrame:CGRectMake(0, 0, 84, 100)];
    [self.headIV setCenter:CGPointMake(hx, hy)];
    [self addSubview:self.headIV];

    CGFloat gx = CGRectGetMinX(self.windowFrame)+CGRectGetWidth(self.windowFrame) * GScaleX;
    CGFloat gy = CGRectGetMinY(self.windowFrame)+CGRectGetHeight(self.windowFrame) * GScaleY;
    [self.iconIV setFrame:CGRectMake(0, 0, 60, 63)];
    [self.iconIV setCenter:CGPointMake(gx, gy)];
    [self addSubview:self.iconIV];

    return self;
}

- (void)moveWindowDeltaY:(NSInteger)iDeltaY //  fDeltaY == 0 in center , < 0 move up, > 0 move down
{
    CGRect rectFrame = self.windowFrame;
    if (rectFrame.size.height < rectFrame.size.width) {
        rectFrame.origin.y += (CGFloat) iDeltaY;
    }
    self.windowFrame = rectFrame;
    _labelScan.center =
        CGPointMake(CGRectGetMidX(self.windowFrame), self.windowFrame.origin.y  + 30);
    _noticeLabel.frame = CGRectMake(CGRectGetMinX(self.windowFrame), CGRectGetMaxY(self.windowFrame)+10, CGRectGetWidth(self.windowFrame), 80);
    [self setNeedsDisplay];
}

- (void)setLabel:(UILabel *)label {
    _noticeLabel.text = label.text;
    _noticeLabel.textColor = label.textColor;
    [_noticeLabel setNeedsDisplay];
}

- (void)setLogString:(NSString *)logString {
    //    NSLog(@"%@",logString);
}

- (UIButton *)photoBtn{
    if (nil == _photoBtn) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"photograph"] forState:UIControlStateNormal];
        _photoBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        //_photoBtn.hidden = YES;
    }
    return _photoBtn;
}

- (UIButton *)backBtn{
    if (nil == _backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //[_photoBtn setTitle:@"拍照" forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"nav_btn_back"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

- (UIImageView *)iconIV{
    if (nil == _iconIV) {
        _iconIV = [[UIImageView alloc]init];
        _iconIV.image = [UIImage imageNamed:@"idIcon"];
        _iconIV.hidden = YES;
    }
    return _iconIV;
}

- (UIImageView *)headIV{
    if (nil == _headIV) {
        _headIV = [[UIImageView alloc]init];
        _headIV.image = [UIImage imageNamed:@"idHead"];
        _headIV.hidden = YES;
    }
    return _headIV;
}



@end
