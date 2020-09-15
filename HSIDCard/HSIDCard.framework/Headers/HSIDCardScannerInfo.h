//
//  HSIDCardScannerInfo.h
//  IDCardDemo
//
//  Created by farben on 2020/8/31.
//  Copyright © 2020 farben. All rights reserved.
//

#import "HSBaseInfo.h"

NS_ASSUME_NONNULL_BEGIN
/**
CODE_SUCCESS(0, "解析成功"),
CODE_NETWORK(1, "网络访问错误"),
CODE_INIT(2, "初始化失败"),(暂无,安卓OpenCV库使用)
CODE_REJECT(3, "图像模糊"),(暂无,安卓OpenCV库使用)
CODE_NO_NAME(4, "未识别到姓名"),
CODE_CODE_NO_ID_NUM(5, "未识别到身份证号码"),
CODE_NO_STANDARD(6, "确认图片符合规范"),
CODE_EMPTY_CONTENT(7, "识别结果为null"),
CODE_REQUEST_SERVER(8, "与服务器的请求交互错误");
CODE_NO_EFFECTIVE_DATE(9, "未识别到有效日期");
*/
@interface HSIDCardScannerInfo : HSBaseInfo
/** 状态码 */
@property (nonatomic, assign) NSInteger  code;
/** 是否正面解析 */
@property (nonatomic, assign) BOOL  isFront;
/** 是否解析成功 */
@property (nonatomic, assign) BOOL  success;
/** 返回信息 */
@property (nonatomic, strong) NSString * errMsg;
/** 正面解析-名称 */
@property (nonatomic, strong) NSString * name;
/** 正面解析-身份证号 */
@property (nonatomic, strong) NSString * idCardNum;
/** 反面解析-有效日期起始 */
@property (nonatomic, strong) NSString * validStartDate;
/** 反面解析-有效日期结束 */
@property (nonatomic, strong) NSString * validEndDate;
/** 所有信息 */
@property (nonatomic, strong) NSDictionary * allInfo;

@end

NS_ASSUME_NONNULL_END
