//
//  STOCRIDCardQualityEnumTypeHeader.h
//  STOCRIDCardQualityEnumTypeHeader
//
//  Created by huoqiuliang on 2018/2/28.
//  Copyright © 2018年 sensetime. All rights reserved.
//

#ifndef STOCRIDCardQualityEnumTypeHeader_h
#define STOCRIDCardQualityEnumTypeHeader_h

/**
 *  HSIDOCRIDCardQuality运行结果
 */
typedef NS_ENUM(NSInteger, HSIDOCRIDCardQualityResult) {
    /** 正常运行 */
    HSIDOCRIDCardQuality_OK = 0,
    /** 授权文件不合法 */
    HSIDOCRIDCardQuality_E_LICENSE_INVALID = 1,
    /** 授权文件不存在 */
    HSIDOCRIDCardQuality_E_LICENSE_FILE_NOT_FOUND = 2,
    /** 授权文件绑定包名错误 */
    HSIDOCRIDCardQuality_E_LICENSE_BUNDLE_ID_INVALID = 3,
    /** 授权文件过期 */
    HSIDOCRIDCardQuality_E_LICENSE_EXPIRE = 4,
    /** 授权文件与SDK版本不匹配 */
    HSIDOCRIDCardQuality_E_LICENSE_VERSION_MISMATCH = 5,
    /** 授权文件不支持当前平台 */
    HSIDOCRIDCardQuality_E_LICENSE_PLATFORM_NOT_SUPPORTED = 6,
    /** 模型文件不合法 */
    HSIDOCRIDCardQuality_E_MODEL_INVALID = 7,
    /** 模型文件不存在 */
    HSIDOCRIDCardQuality_E_MODEL_FILE_NOT_FOUND = 8,
    /** 模型文件过期 */
    HSIDOCRIDCardQuality_E_MODEL_EXPIRE = 9,
    /** 参数设置不合法 */
    HSIDOCRIDCardQuality_E_INVALID_ARGUMENT = 10,
    /** 检测扫描超时 */
    HSIDOCRIDCardQuality_E_TIMEOUT = 11,
    /** API账户信息错误。*/
    HSIDOCRIDCardQuality_E_API_KEY_INVALID = 12,
    /** 服务器访问错误 */
    HSIDOCRIDCardQuality_E_SERVER_ACCESS = 13,
    /** 服务器访问超时 */
    HSIDOCRIDCardQuality_E_SERVER_TIMEOUT = 14,
    /** 调用API状态错误 */
    HSIDOCRIDCardQuality_E_CALL_API_IN_WRONG_STATE = 15,
    /** 运行失败 */
    HSIDOCRIDCardQuality_E_FAILED = 16,
    /** 授权文件能力不支持 */
    HSIDOCRIDCardQuality_E_CAPABILITY_NOT_SUPPORTED = 17,
    /** 云端识别错误 */
    HSIDOCRIDCardQuality_E_SERVER_DETECT_FAILED = 18,
    /** API_KEY 或 API_SECRET 为空 */
    HSIDOCRIDCardQuality_E_API_KEY_SECRET_NULL = 19,
};

/**
 *  设备错误的类型
 */
typedef NS_ENUM(NSUInteger, HSIDOCRIDCardQualityDeveiceError) {
    /** 相机权限获取失败 */
    HSIDOCRIDCardQuality_E_CAMERA = 0,
    /** 应用即将被挂起 */
    HSIDOCRIDCardQuality_WILL_RESIGN_ACTIVE,
};

/**
 *  网络请求云端的详细状态码
 */
typedef NS_ENUM(NSInteger, HSIDOCRIDCardQualityCloudInternalCode) {
    /** 云端返回未知错误码  */
    HSIDOCRIDCardQuality_CLOUD_UNKNOWN_CODE = -1,
    /** default，不涉及云端请求时默认返回码  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_DEFAULT = 0,
    /** success  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_SUCCESS = 1000,
    /** api_key值为空  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_API_KEY_MISSING = 9001,
    /** 无效的api_key */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_INVALID_API_KEY = 9002,
    /** api_key被禁用 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_API_KEY_IS_DISABLED = 9003,
    /** api_key已过期   */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_API_KEY_HAS_EXPIRED = 9004,
    /** 无该功能权限 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_PERMISSION_DENIED = 9005,
    /** bundle_id值为空 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_BUNDLE_ID_MISSING = 9006,
    /** bundle_id被禁用     */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_BUNDLE_ID_IS_DISABLED = 9007,
    /** 每日调用已达限制  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_DAILY_RATE_LIMIT_EXCEEDED = 9008,
    /** 未传入应用签名  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_APP_SIGN_MISSING = 9009,
    /** 应用签名验证失败 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_INVALID_APP_SIGN = 9010,
    /** 数据一致性验证失败  */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_INVALID_SIGNATURE = 9011,
    /** bundle_id验证失败 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_INVALID_BUNDLE_ID = 9012,
    /** 内部错误，请联系商汤支持人员 */
    HSIDOCRIDCardQuality_CLOUD_INTERNAL_SENSETIME_ERROR = 9100,
};

#endif /* STOCRIDCardQualityEnumTypeHeader_h */
