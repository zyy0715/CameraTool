//
//  HSTensorFlowLiteManager.h
//  TensorFlowLite
//
//  Created by farben on 2020/10/13.
//  Copyright © 2020 farben. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TensorFlowLiteObjC/TFLTensorFlowLite.h>
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>



#define TFLModelNameKey @"output_graph_card"
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

///输入张量获取
- (TFLTensor *)inputTensorAtIndex:(NSUInteger)index withBuffer:(CVPixelBufferRef)pixelBuffer shape:(CGFloat)shape;

///输出张量获取
- (TFLTensor *)outputTensorAtIndex:(NSUInteger)index;

///输入数据获取  isQuantized:是否是量化数据 shape:偏移量
- (NSData*)inputDataFromBuffer:(CVPixelBufferRef)pixelBuffer isModelQuantized:(BOOL)isQuantized shapeNum:(CGFloat)shape;
///输出数据解析  offset:概率偏移量(最小概率取值)
- (NSArray *)transTFLTensorOutputData:(TFLTensor *)outpuTensor withName:(NSString*)name offset:(float)offset;
///裁剪和缩放CVPixelBufferRef
- (CVPixelBufferRef)createCroppedPixelBufferRef:(CMSampleBufferRef)sampleBuffer cropRect:(CGRect)cropRect scaleSize:(CGSize)scaleSize;
///缩放图片
- (CVPixelBufferRef)createImage:(UIImage*)image scaleSize:(CGSize)scaleSize PixelBufferRef:(CMSampleBufferRef)sampleBuffer;
///获取截取的图片
- (UIImage *)imageFromSampleBuffer:(CVPixelBufferRef) imageBuffer ;


@end

NS_ASSUME_NONNULL_END
