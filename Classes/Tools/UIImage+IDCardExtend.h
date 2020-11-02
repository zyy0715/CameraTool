//
//  UIImage+IDCardExtend.h
//  JYBDAVCapture
//
//  Created by tianxiuping on 2018/6/27.
//  Copyright © 2018年 XP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UIImage (IDCardExtend)

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;
+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer;
+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage*)image;

-(UIImage *)originalImage;

+ (CVPixelBufferRef)pixelBufferFromCGImage:(UIImage *)image;

//按比例缩放,size是你要把图显示到 多大区域 ,例如:CGSizeMake(300, 400)
+ (UIImage *) imageCompressForSize:(UIImage *)sourceImage targetSize:(CGSize)size;
//指定宽度按比例缩放
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;


@end
