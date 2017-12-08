//
//  AUUNumberHandler.h
//  Number
//
//  Created by JyHu on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
#import "AUUNumberHandlerProtocol.h"

/*
 比较两个数值，并返回其中的最大值
 要比较的数值必须是实现了`AUUNumberHandler`协议的数据类型
 返回值是比较后的结果，类型为原类型
 */
id <AUUNumberHandler> AUUMaxNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2);
/*
 比较两个数值，并返回其中的最小值
 要比较的数值必须是实现了`AUUNumberHandler`协议的数据类型
 返回值是比较后的结果，类型为原类型
 */
id <AUUNumberHandler> AUUMinNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2);

/**
 1 * 10^power
 */
NSNumber * AUUMultiplyingByPowerOf10(NSInteger power);


/**
 添加`NSString`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
 */
@interface NSString (AUUNumberHandler) <AUUNumberHandler>
@end

/**
 添加`NSNumber`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
 */
@interface NSNumber (AUUNumberHandler) <AUUNumberHandler>
@end

/**
 添加`NSDecimalNumber`的`category`，并实现`AUUNumberHandler`协议，用以实现多种类型间的直接计算
 */
@interface NSDecimalNumber (AUUNumberHandler) <AUUNumberHandler>
@end



//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




/**
 处理数值计算时出错的block

 @param operation 数值计算的方法
 @param error 错误的类型
 @param leftOperand 左边的计算数值
 @param rightOperant 右边的计算数值
 @return 经过容错处理后的正常数值
 */
typedef NSDecimalNumber *(^AUUNumberOperationExceptionHandler)(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant);

@interface AUUNumberHandler : NSObject <NSDecimalNumberBehaviors>

@property (assign, nonatomic) NSRoundingMode mode;      // 四舍五入的方式
@property (assign, nonatomic) short roundingScale;              // 保留几位小数
@property (assign, nonatomic) BOOL raiseOnExactness;
@property (assign, nonatomic) BOOL raiseOnOverflow;
@property (assign, nonatomic) BOOL raiseOnDivideByZero;

- (instancetype)initHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale;

/**
 一个初始化的方式

 @param exceptionDurationOperation 用来提供给外部处理异常时的block
 @return self
 */
+ (AUUNumberHandler *)numberHandlerWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation;

// 提供给外部使用，用于解决计算错误得问题
@property (copy, nonatomic) AUUNumberOperationExceptionHandler exceptionHandlerDurationOperation;

/**
 全局的错误兼容处理方法，外部使用的时候只需要在一个地方写一次就行

 @param numberHandler 对于handler的处理
 @param exceptionDurationOperation 全局的错误处理方法
 */
+ (void)globalNumberHandler:(void (^)(AUUNumberHandler *numberHandler))numberHandler
           exceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation;

/**
 全局的字符串数值处理方法，因为内部计算时都是使用NSDecimalNumber进行的，所以对于字符串需要进行转换，如果外部需要对字符串数值做处理的话，就需要使用这个方法

 @param numberStringRefactor 数值转换的全局处理方法
 */
+ (void)globalNumberStringRefactorWithNumber:(id <AUUNumberHandler> (^)(NSString *numberString))numberStringRefactor;

/**
 设置是否需要全局的调试方法
 */
+ (void)enableDebugingMode:(BOOL)enable;

@end

AUUNumberHandler *AUURoundingMode(NSRoundingMode roundingMode);
AUUNumberHandler *AUURoundingScale(short scale);

AUUNumberHandler *AUUDefaultRoundingHandler(void);
