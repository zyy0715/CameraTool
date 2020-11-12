//
//  HSIDCardQualityDefineHeader.h
//  LibSTCardScan
//
//  Created by zhanghenan on 2017/3/13.
//  Copyright © 2017年 SenseTime. All rights reserved.
//

#ifndef HSIDCardQualityDefineHeader_h
#define HSIDCardQualityDefineHeader_h

#define HSIDCardQuality_VIDEO_WINDOW_H CGRectMake(0, 415, 720, 450)
#define HSIDCardQuality_VIDEO_WINDOW_V CGRectMake(160, 60, 960, 600)
//#define HSIDCardQuality_VIDEO_WINDOW_H_L (CGRectMake(160, 60, 960, 600))

#define HSIDCardQuality_MASK_WINDOW_H CGRectMake(40, 440, 640, 400)
#define HSIDCardQuality_MASK_WINDOW_V CGRectMake(240, 110, 800, 500)

#define HSIDCardQuality_MASK_WINDOW_VERTICALCARD CGRectMake(110, 240, 500, 800)
//#define  HSIDCardQuality_MASK_WINDOW_VERTICALCARD (CGRectMake(65, 205, 570, 870))

#define HSIDCardQuality_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define HSIDCardQuality_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

///设备型号判断
#define Device_Width  [[UIScreen mainScreen] bounds].size.width//获取屏幕宽高
#define Device_Height [[UIScreen mainScreen] bounds].size.height
#define NSVH (MAX(Device_Width, Device_Height)  >= 812 ? 44 : 20)

///字符串判空
#define SAFE_STRING(string) (string != nil) ? (string) : (string = @"")
#define IS_EMPTY_STRING(string) (string == nil ||[string isEqualToString:@""])? YES : NO

#define scale5W(w)          w / (double)320
#define scale5H(h)          h / (double)568

#define scaleW(w)           w / (double)375
#define scaleH(h)           h / (double)667

#define scalePW(w)          w / (double)414
#define scalePH(h)          h / (double)736

#define scaleXW(w)          w / (double)375
#define scaleXH(h)          h / (double)812

#define HSIDCardQuality_VIEDO_WIDTH (720.0)
#define HSIDCardQuality_VIDEO_HEIGHT (1280.0)

#define HSIDCardQuality_IS_IPHONE ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define SS(strongSelf)  __strong __typeof(&*self) strongSelf = self;

#define STSCALEW HSIDCardQuality_SCREEN_WIDTH/320.0
#define STSCALEH HSIDCardQuality_SCREEN_HEIGHT/568.0

#define SKIPCOUNT 40

#endif /* STDefineHeader_h */
