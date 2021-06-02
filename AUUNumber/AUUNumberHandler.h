//
//  AUUNumberHandler.h
//  Number
//
//  Created by JyHu on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
#import <AUUNumber/AUUNumberHandlerProtocol.h>

#define NSCalculationByNil 100

/// 在数值计算的时候，如果操作数为nil，比如 nil.add(@2)，这样会导致程序崩溃，而且进入不了计算处
/// 理的安全处理阶段，所以如果需要避免这种情况，可以使用这个方法，比如：
///        AUUSafeNumber(nilNumber).add(@3).multiplying(@23)
///
/// @param number 一个有效的数值
id <AUUNumberHandler> AUUSafeNumber(id <AUUNumberHandler> number);

/// 比较两个数值，并返回其中的最大值
/// 要比较的数值必须是实现了`AUUNumberHandler`协议的数据类型
/// 返回值是比较后的结果，类型为原类型
id <AUUNumberHandler> AUUMaxNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2);

/// 比较两个数值，并返回其中的最小值
/// 要比较的数值必须是实现了`AUUNumberHandler`协议的数据类型
/// 返回值是比较后的结果，类型为原类型
id <AUUNumberHandler> AUUMinNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2);

/// 1 * 10^power
/// @param power 平方数
NSNumber * AUUMultiplyingByPowerOf10(NSInteger power);

/// 添加`NSString`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
@interface NSString (AUUNumberHandler) <AUUNumberHandler>

/// 根据给定的formatter转换字符串为`NSDecimalNumber`
/// @param formatter 自定义的formatter
- (NSDecimalNumber *)decimalNumberWithFormatter:(NSNumberFormatter *)formatter;

@end

/// 添加`NSNumber`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
@interface NSNumber (AUUNumberHandler) <AUUNumberHandler>
@end

/// 添加`NSDecimalNumber`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
@interface NSDecimalNumber (AUUNumberHandler) <AUUNumberHandler>

/// 安全的数值转换的方法，用以避免操作数为空的情况
/// @param numberObject 需要安全处理的数值对象
+ (NSDecimalNumber *)safeNumberWithNumberObject:(id <AUUNumberHandler>)numberObject;

@end

@interface NSArray (AUUNumberHandler)

/// 求和，如果某个元素未实现`AUUNumberHandler`协议，则会被跳过
@property (retain, nonatomic, readonly) NSDecimalNumber *sum;

/// 求积，如果某个元素未实现`AUUNumberHandler`协议，则会被跳过
@property (retain, nonatomic, readonly) NSDecimalNumber *product;

@end

/// 处理数值计算时出错的block
/// @param operation 数值计算的方法
/// @param error 错误的类型
/// @param leftOperand 左边的计算数值
/// @param rightOperant 右边的计算数值
/// @return 经过容错处理后的正常数值
typedef NSDecimalNumber *(^AUUNumberOperationExceptionHandler)(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant);

/// 处理字符串类型数值转换的block
typedef id <AUUNumberHandler> (^AUUNumberStringRefactor)(NSString *numberString);

/// 默认的计算错误处理类
/// 如果在执行计算的时候未指定`behaviors`，会默认的用这个类作为错误数据的处理类，
/// 针对以下不同的错误提供指定的解决方案
/// @discussion `NSCalculationLossOfPrecision: return rightOperand;`
/// @discussion `NSCalculationUnderflow: return NSDecimalNumber.minimumDecimalNumber;`
/// @discussion `NSCalculationOverflow: return NSDecimalNumber.maximumDecimalNumber;`
/// @discussion `NSCalculationDivideByZero: return leftOperand;`
/// @discussion `NSCalculationByNil: return leftOperand;`
@interface AUUNumberHandler : NSObject <NSDecimalNumberBehaviors>

/// 单例
+ (instancetype)defaultHandler;

/// 设置是否需要全局的调试方法
/// @warning 只针对defaultHandler有效
@property (assign, nonatomic) BOOL enableDebuging;

/// 字符串转数字的特殊处理
/// 比如有的字符串是12'23处理成数值会是12.23，或者 0x0A会处理成 10 等登
@property (copy, nonatomic) AUUNumberStringRefactor numberStringRefactor;

/// 提供给外部使用，用于解决计算错误得问题
/// 返回值为计算结果
@property (copy, nonatomic) AUUNumberOperationExceptionHandler exceptionHandlerDurationOperation;

/// 临时计算使用快速创建实例对象的方法
+ (instancetype)instanceWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionHandler;
+ (instancetype)instanceWithNumberStringRefactor:(AUUNumberStringRefactor)numberStringRefactor;
+ (instancetype)instanceWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionHandler
                        numberStringRefactor:(AUUNumberStringRefactor)numberStringRefactor;

@end
