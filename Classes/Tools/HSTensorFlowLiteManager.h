//
//  HSTensorFlowLiteManager.h
//  TensorFlowLiteObjcDemo
//
//  Created by farben on 2020/10/26.
//  Copyright © 2020 tanzhiwu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TensorFlowLiteObjC/TFLTensorFlowLite.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>

#define TFLModelNameKey @"output_graph_uint8"
#define TFLModelTypeKey @"tflite"

#define TFLLabelsNameKey @"output_labels_card"
#define TFLLabelsTypeKey @"txt"


#define TFLClassNameKey @"TFLClassNameKey"
#define TFLConfidenceKey @"TFLConfidenceKey"
#define TFLIndexKey @"TFLIndexKey"


NS_ASSUME_NONNULL_BEGIN

@interface HSTensorFlowLiteManager : NSObject

///便捷获取实例方法(非单例)
+ (instancetype)shareInstance;

///TensorFlow识别器
@property (strong, nonatomic) TFLInterpreter *interpreter;

///将给定索引处的输入张量调整为指定的形状（无符号正整数数组）
- (BOOL)resizeInputTensorAtIndex:(NSUInteger)index
                         toShape:(NSArray<NSNumber *> *)shape;

///输入张量获取
- (TFLTensor *)inputTensorAtIndex:(NSUInteger)index;

///输入数据传入(CVPixelBufferRef)  inputTensor:输入张量对象
- (void)inputDataFromBuffer:(CVPixelBufferRef)pixelBuffer
                       with:(TFLTensor*)inputTensor;

///输出张量获取
- (TFLTensor *)outputTensorAtIndex:(NSUInteger)index;

///输出数据解析  offset:概率偏移量(最小概率取值)
- (NSArray *)transTFLTensorOutputData:(TFLTensor *)outpuTensor
                             withName:(NSString*)name
                               offset:(float)offset;

///根据图片获取 CVPixelBufferRef 并进行按比例缩放
- (CVPixelBufferRef)createImage:(UIImage*)oImage
                      scaleSize:(CGSize)scaleSize
                 PixelBufferRef:(CMSampleBufferRef)sampleBuffer;

///裁剪和缩放CVPixelBufferRef
- (CVPixelBufferRef)createCroppedPixelBufferRef:(CMSampleBufferRef)sampleBuffer
                                       cropRect:(CGRect)cropRect
                                      scaleSize:(CGSize)scaleSize;


@end

NS_ASSUME_NONNULL_END
