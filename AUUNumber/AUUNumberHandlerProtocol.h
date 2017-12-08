//
//  AUUNumberHandlerProtocol.h
//  Number
//
//  Created by JyHu on 2017/6/16.
//
//

#import <Foundation/Foundation.h>

@protocol AUUNumberHandler <NSObject>

@required

/**
 转换成数值对象
 */
@property (retain, nonatomic, readonly) NSDecimalNumber *decimalNumber;

/**
 加法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^add)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^addWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 减法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^subtracting)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^subtractingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 乘法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^multiplying)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^multiplyingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 除法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^dividing)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^dividingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 n次方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^raisingToPower)(NSUInteger power);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^raisingToPowerWithBehaviors)(NSUInteger power, id <NSDecimalNumberBehaviors> behaviors);

/**
 乘以10的n次方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^multiplyingByPowerOf10)(short power);
@property (copy, nonatomic, readonly) NSDecimalNumber *(^multiplyingByPowerOf10WithBehaviors)(short power, id <NSDecimalNumberBehaviors> behaviors);

/**
 平方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *square;
@property (copy, nonatomic, readonly) NSDecimalNumber *(^squareWithBehaviors)(id <NSDecimalNumberBehaviors> behaviors);

/**
 立方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *cube;
@property (copy, nonatomic, readonly) NSDecimalNumber *(^cubeWithBehaviors)(id <NSDecimalNumberBehaviors> behaviors);

/**
 绝对值
 */
@property (retain, nonatomic, readonly) NSDecimalNumber *abs;


#pragma mark - rounding methods
#pragma mark -


/**
 小数四舍五入，使用四舍五入模式
 
 scale 四舍五入时保留的小数位数
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^roundingWithScale)(short scale);

/**
 小数四舍五入
 
 decimalHandler 四舍五入的行为
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *(^roundingWithBehaviors)(id <NSDecimalNumberBehaviors> decimalHandler);

/**
 数字字符串
 
 fractionDigits 保留几位小数，如果小数位数不够，则会补0
 */
@property (copy, nonatomic, readonly) NSString *(^numberStringWithFractionDigits)(short fractionDigits);
@property (copy, nonatomic, readonly) NSString *(^decimalStringWithFractionDigits)(short fractionDigits);
@property (copy, nonatomic, readonly) NSString *(^numberStringWithFormatter)(NSNumberFormatter *formatter);
@property (copy, nonatomic, readonly) NSString *(^numberStringWith)(short fractionDigits, NSNumberFormatterStyle numberFormatter);

@end
