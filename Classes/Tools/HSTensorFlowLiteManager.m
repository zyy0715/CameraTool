//项目名称: TensorFlowLiteObjcDemo
//名称：HSTensorFlowLiteManager.m
//创建者：farben
//创建时间：2020/10/26
//描述：HSTensorFlowLiteManager



#import "HSTensorFlowLiteManager.h"
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface HSTensorFlowLiteManager()
@property (nonatomic, strong) CIContext *context;//自定义裁剪需要
//延时识别
@property (nonatomic, assign) NSTimeInterval previousTime;
@property (nonatomic, assign) NSTimeInterval delayBetweenMs;

@end


@implementation HSTensorFlowLiteManager
#pragma mark - System Methods/LifeCycle
+ (instancetype)shareInstance{
    HSTensorFlowLiteManager * manager = [[HSTensorFlowLiteManager alloc]init];
    return manager;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        
        NSError *error = nil;
        NSString *path = [[NSBundle mainBundle] pathForResource:TFLModelNameKey ofType:TFLModelTypeKey];
        //初始化识别器,需要传入训练模型的路径,还可以传options
        self.interpreter = [[TFLInterpreter alloc] initWithModelPath:path error:&error];
        NSLog(@"输入数:%@ -- 输出数:%@",@(self.interpreter.inputTensorCount),@(self.interpreter.outputTensorCount));
        if (![self.interpreter allocateTensorsWithError:&error]) {
            NSLog(@"Create interpreter error: %@", error);
        }
    }
    return self;
}

#pragma mark - Public Methods
///将给定索引处的输入张量调整为指定的形状（无符号正整数数组）
- (BOOL)resizeInputTensorAtIndex:(NSUInteger)index
                         toShape:(NSArray<NSNumber *> *)shape{
    NSError *error = nil;
    BOOL result = [self.interpreter resizeInputTensorAtIndex:index toShape:shape error:&error];
    if (nil != error) {
        NSLog(@"resizeInputTensorError: %@", error);
        assert(error);
    }
    return result;
}

///输入张量获取
- (TFLTensor *)inputTensorAtIndex:(NSUInteger)index{
    NSError *error;
    TFLTensor *inputTensor = [self.interpreter inputTensorAtIndex:0 error:&error];
    if (error) {
        NSLog(@"InputTensorError: %@", error);
        assert(error);
    }
    return inputTensor;
}

///输入数据传入(CVPixelBufferRef)  inputTensor:输入张量对象
- (void)inputDataFromBuffer:(CVPixelBufferRef)pixelBuffer with:(TFLTensor*)inputTensor{
    NSError *error;
    NSData *data = [self inputDataFromBuffer:pixelBuffer isModelQuantized:(inputTensor.dataType==TFLTensorDataTypeUInt8)];
    [inputTensor copyData:data error:&error];
    if (error) {
        NSLog(@"copyDataError: %@", error);
        assert(error);
    }
    [self.interpreter invokeWithError:&error];
    if (error) {
        NSLog(@"invokeWithError: %@", error);
        assert(error);
    }
}

///输出张量获取
- (TFLTensor *)outputTensorAtIndex:(NSUInteger)index{
    NSError *error;
    TFLTensor *outputTensor = [self.interpreter outputTensorAtIndex:0 error:&error];
    if (error) {
           NSLog(@"OutputTensorError: %@", error);
           assert(error);
    }
    return outputTensor;
}


///输出数据解析  offset:概率偏移量(最小概率取值)
- (NSArray *)transTFLTensorOutputData:(TFLTensor *)outpuTensor withName:(NSString*)name offset:(float)offset{
    NSMutableArray * arry = [NSMutableArray array];
    NSError *error;
    NSData *data = [outpuTensor dataWithError:&error];
    if (error) {
        NSLog(@"错误:%@",error);
    }
//    NSLog(@"OutputData: %@",data);
//    NSLog(@"Name: %@",outpuTensor.name);
    
//    NSArray *shape = [outpuTensor shapeWithError:&error];
    //NSLog(@"Shape: %@",shape);
    if (error) {
        NSLog(@"错误:%@",error);
    }
    if (outpuTensor.dataType == TFLTensorDataTypeUInt8) {
        if ([outpuTensor.name isEqualToString:name]) {
            TFLQuantizationParameters *ps = outpuTensor.quantizationParameters;
            UInt8 buf[data.length];
            [data getBytes:buf length:data.length];
            for (int i = 0; i< data.length; i++) {
                float result = ps.scale *  (float)(buf[i]-ps.zeroPoint);
                [arry addObject:[NSNumber numberWithFloat:result]];
            }
        }
    }else{
        if ([outpuTensor.name isEqualToString:name]) {
//        解析方式:
//            float output[3U];
//            [data getBytes:output length:(sizeof(float) * 3U)];
//            for (int i = 0; i< 3; i++) {
//                [arry addObject:[NSNumber numberWithFloat:output[i]]];
//            }
            NSArray *array = [self getOutputResuts:data];
            [arry addObjectsFromArray:array];
        }
    }
    NSLog(@"概率结果集:%@",arry);
    NSArray *results = [self formatTensorResultWith:arry offset:offset];
    return results;
    return nil;
}

///格式化结果数据
- (NSArray*)formatTensorResultWith:(NSArray *)outputArray offset:(float)offset{
    NSMutableArray *arry = [NSMutableArray arrayWithCapacity:5];
    NSArray *labels = [self loadLabels];
    for (int i = 0; i< outputArray.count; i++) {
        NSMutableDictionary *mDic = [NSMutableDictionary dictionaryWithCapacity:3];
        CGFloat confidence = [outputArray[i] floatValue];
        if (offset > 0) {
            if (confidence < offset) {
                continue;
            }
        }
        NSInteger index = MIN(i, (outputArray.count-1));
        if (index < 0) {
            continue;
        }
        NSString *className = labels[index];
        [mDic setObject:@(i) forKey:TFLIndexKey]; ///官方模型需要+1;
        [mDic setObject:@(confidence) forKey:TFLConfidenceKey];
        [mDic setObject:className forKey:TFLClassNameKey];
        [arry addObject:mDic];
    }
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:TFLConfidenceKey ascending:NO];
    [arry sortUsingDescriptors:@[sort]];
    return arry;
}

- (NSArray*)getOutputResuts:(NSData*)outputData{
    NSAssert(outputData.length%4 == 0, @"getOutputResuts: (outputData.length模4 != 0)");
    NSMutableArray *arry = [NSMutableArray arrayWithCapacity:3.0];
    NSUInteger count = floor(outputData.length/4);
    float output[count];
    [outputData getBytes:output length:(sizeof(float) * count)];
    for (int i = 0; i< count; i++) {
        [arry addObject:[NSNumber numberWithFloat:output[i]]];
    }
    return [arry copy];
}


#pragma mark - Private Methods
///输入数据获取
- (NSData*)inputDataFromBuffer:(CVPixelBufferRef)pixelBuffer isModelQuantized:(BOOL)isQuantized{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char* sourceData = (unsigned char*)(CVPixelBufferGetBaseAddress(pixelBuffer));
    if (!sourceData) {
        return nil;
    }
    size_t width =  CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    size_t sourceRowBytes = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    int destinationChannelCount = 3;
    size_t destinationBytesPerRow = destinationChannelCount * width;
    vImage_Buffer inbuff = {sourceData, height, width, sourceRowBytes};
    unsigned char *destinationData = malloc(height * destinationBytesPerRow);
    if (destinationData == nil) {
        return nil;
    }
    vImage_Buffer  outbuff = {destinationData,height,width,destinationBytesPerRow};
    if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA){
        vImageConvert_BGRA8888toRGB888(&inbuff, &outbuff, kvImageNoFlags);
    }else if (CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32ARGB){
        vImageConvert_ARGB8888toRGB888(&inbuff, &outbuff, kvImageNoFlags);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVPixelBufferRelease(pixelBuffer);//记得释放资源
    NSData *data = [[NSData alloc] initWithBytes:outbuff.data length:outbuff.rowBytes *height];
    if (destinationData != NULL) {
        free(destinationData);
        destinationData = NULL;
    }
    if (isQuantized) {
        return  data;
    }
    
    Byte *bytesPtr = (Byte *)[data bytes];
    //针对不是量化模型,需要转换成float类型的数据
    NSMutableData *rgbData = [[NSMutableData alloc] initWithCapacity:0];
    for (int i = 0; i < data.length; i++) {
        Byte byte = (Byte)bytesPtr[i];
        float bytf = (float)byte / 255.0;
        [rgbData appendBytes:&bytf length:sizeof(float)];
    }
    return rgbData;
}

///根据图片获取 CVPixelBufferRef 并进行按比例缩放
- (CVPixelBufferRef)createImage:(UIImage*)oImage scaleSize:(CGSize)scaleSize PixelBufferRef:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCGImage:oImage.CGImage];
    
    CGFloat scaleX = scaleSize.width / CGRectGetWidth(image.extent);
    CGFloat scaleY = scaleSize.height / CGRectGetHeight(image.extent);
    
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type != kCVPixelFormatType_32BGRA) {
        return nil;
    }
    
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    // Due to the way [CIContext:render:toCVPixelBuffer] works, we need to translate the image so the cropped section is at the origin
    image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(-image.extent.origin.x *0.5, -image.extent.origin.y *0.5)];
    
    CVPixelBufferRef output = NULL;
    //有时候裁剪缩放过后会出现像素偏差,导致模型无法识别
//    CVPixelBufferCreate(nil,
//                        CGRectGetWidth(image.extent),
//                        CGRectGetHeight(image.extent),
//                        CVPixelBufferGetPixelFormatType(pixelBuffer),
//                        nil,
//                        &output);
    CVPixelBufferCreate(nil,
                        scaleSize.width,
                        scaleSize.height,
    CVPixelBufferGetPixelFormatType(pixelBuffer),
    nil,
    &output);
   
    if (!self.context) {
        self.context = [CIContext context];
    }
    if (output != NULL) {
        [self.context render:image toCVPixelBuffer:output];
    }
    return output;
}

///裁剪和缩放CVPixelBufferRef
- (CVPixelBufferRef)createCroppedPixelBufferRef:(CMSampleBufferRef)sampleBuffer cropRect:(CGRect)cropRect scaleSize:(CGSize)scaleSize{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    size_t imageWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t imageHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    CGRect videoRect = CGRectMake(0, 0, imageWidth, imageHeight);
    CGSize cropSize = CGSizeMake(cropRect.size.width, cropRect.size.width);
    CGRect centerCroppingRect = AVMakeRectWithAspectRatioInsideRect(cropSize, videoRect);
    
    CIImage *image = [CIImage imageWithCVImageBuffer:pixelBuffer];
    image = [image imageByCroppingToRect:centerCroppingRect];
    
    CGFloat scaleX = scaleSize.width / CGRectGetWidth(image.extent);
    CGFloat scaleY = scaleSize.height / CGRectGetHeight(image.extent);
    
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    if (type != kCVPixelFormatType_32BGRA) {
        return nil;
    }
    
    image = [image imageByApplyingTransform:CGAffineTransformMakeScale(scaleX, scaleY)];
    
    // Due to the way [CIContext:render:toCVPixelBuffer] works, we need to translate the image so the cropped section is at the origin
    image = [image imageByApplyingTransform:CGAffineTransformMakeTranslation(-image.extent.origin.x *0.5, -image.extent.origin.y *0.5)];
    
    CVPixelBufferRef output = NULL;
    //有时候裁剪缩放过后会出现像素偏差,导致模型无法识别
//    CVPixelBufferCreate(nil,
//                        CGRectGetWidth(image.extent),
//                        CGRectGetHeight(image.extent),
//                        CVPixelBufferGetPixelFormatType(pixelBuffer),
//                        nil,
//                        &output);
    CVPixelBufferCreate(nil,
                        scaleSize.width,
                        scaleSize.height,
    CVPixelBufferGetPixelFormatType(pixelBuffer),
    nil,
    &output);
   
    if (!self.context) {
        self.context = [CIContext context];
    }
    if (output != NULL) {
        [self.context render:image toCVPixelBuffer:output];
    }
    return output;
}

- (UIImage *)imageFromSampleBuffer:(CVPixelBufferRef) imageBuffer {
    // 为媒体数据设置一个CMSampleBuffer的Core Video图像缓存对象
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // 锁定pixel buffer的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // 得到pixel buffer的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // 得到pixel buffer的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到pixel buffer的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的RGB颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphics context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // 根据这个位图context中的像素数据创建一个Quartz image对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // 释放context和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // 用Quartz image创建一个UIImage对象image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // 释放Quartz image对象
    CGImageRelease(quartzImage);
    
    return (image);
}

///获取模型对应标签数组
- (NSArray *)loadLabels
{
    NSURL *path = [[NSBundle mainBundle] URLForResource:TFLLabelsNameKey withExtension:TFLLabelsTypeKey];
    if (path == nil) {
        return nil;
    }
    NSString *contents  = [NSString stringWithContentsOfURL:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [contents componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
    return array;
}



#pragma mark - Setter Getter Methods
- (CIContext *)context{
    if (!_context) {
        _context = [CIContext context];
    }
    return _context;
}



#pragma mark - LifeCycle-dealloc
- (void)dealloc
{
    NSLog(@"%s - 释放了!",object_getClassName(self));
}



@end

