//
//  AUUNumberHandler.h
//  Number
//
//  Created by JyHu on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
#import "AUUNumberHandlerProtocol.h"

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

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/// 处理数值计算时出错的block
/// @param operation 数值计算的方法
/// @param error 错误的类型
/// @param leftOperand 左边的计算数值
/// @param rightOperant 右边的计算数值
/// @return 经过容错处理后的正常数值
typedef NSDecimalNumber *(^AUUNumberOperationExceptionHandler)(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant);

@interface AUUNumberHandler : NSObject <NSDecimalNumberBehaviors>

@property (assign, nonatomic) NSRoundingMode mode;      // 四舍五入的方式
@property (assign, nonatomic) short roundingScale;              // 保留几位小数

/// 初始化方法
/// @param roundingMode 四舍五入方式
/// @param scale 保留小数位数
- (instancetype)initHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale;

///  一个初始化的方式
/// @param exceptionDurationOperation 用来提供给外部处理异常时的block
+ (AUUNumberHandler *)numberHandlerWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation;

/// 提供给外部使用，用于解决计算错误得问题
@property (copy, nonatomic) AUUNumberOperationExceptionHandler exceptionHandlerDurationOperation;

/// 全局的错误兼容处理方法，外部使用的时候只需要在一个地方写一次就行
/// @param numberHandler 对于handler的处理
/// @param exceptionDurationOperation 全局的错误处理方法
+ (void)globalNumberHandler:(void (^)(AUUNumberHandler *numberHandler))numberHandler
           exceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation;

/// 全局的字符串数值处理方法，因为内部计算时都是使用NSDecimalNumber进行的，
/// 所以对于字符串需要进行转换，如果外部需要对字符串数值做处理的话，就需要使用这个方法
/// @param numberStringRefactor 数值转换的全局处理方法
+ (void)globalNumberStringRefactorWithNumber:(id <AUUNumberHandler> (^)(NSString *numberString))numberStringRefactor;

/// 设置是否需要全局的调试方法
+ (void)enableDebugingMode:(BOOL)enable;

@end

AUUNumberHandler * AUURoundingMode(NSRoundingMode roundingMode);
AUUNumberHandler * AUURoundingScale(short scale);
AUUNumberHandler * AUUDefaultRoundingHandler(void);
