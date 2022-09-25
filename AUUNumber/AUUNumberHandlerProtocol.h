//
//  AUUNumberHandlerProtocol.h
//  Number
//
//  Created by JyHu on 2017/6/16.
//
//

#import <Foundation/Foundation.h>

/*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 a + b = c
 a - b = c
 a * b = c
 a / b = c

 约定:
    `a` : 操作数
    `b` : 被操作数
    `c` : 计算结果

 在数值计算过程中，实际即方法的调用中，如果操作数为nil，那么会出现程序崩溃，因为一个空指针是
 没法调用一个OC方法的，所以，如果不能够保证操作数是一个有效的数值的话，可使用`AUUSafeNumber`去
 处理一个操作数。
 对于被操作数，相当于是一个入参，如果进行数值操作的话，会报`NSDecimalNumberBehaviors`的错，
 这个错误留了一个全局的方法和一个局部的方法去处理。

 总的来说，操作数与被操作数，都需要实现`AUUNumberHandler`协议，因为这个库是封装的`NSDecimalNumber`的
 操作，也即所有的对象都是`NSDecimalNumber`类型的，所以，如果需要将一个数值当做被操作数的话，就必须要实现这个协议。

 `AUUNumberHandlerBaseOperator`和其子协议`AUUNumberHandlerOperator`都是对于数值计算方法的扩充，
 如果相当做操作数，直接发起数值计算，则需要实现自己需要的协议方法。
 这两个协议中的所有属性都是只读的而且是必须要实现的，使用block也是为了方便的进行入参操作。

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

/*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 对数字的基础转换，如果想要对自己的数据类型也支持直接的被计算的话，可以实现这个协议方法

 实际上就是说，这个库所有对于数值的计算，都是封装的`NSDecimalNumber`里的计算方式，所以，
 如果自己有实现了转换`NSDecimalNumber`的方法的话，当然也可以不需要实现这个协议方法

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

#pragma mark - 数字的基础转换 -

@protocol AUUNumberHandler <NSObject>

@required

/**
 转换成数值对象
 */
@property (retain, nonatomic, readonly) NSDecimalNumber *decimalNumber;

/*
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 对于数值的基础运算，包括加、减、乘、除四则运算

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 */

#pragma mark - 数字的基础运算，包括加减乘除 -

/**
 加法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ add)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ addWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 减法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ subtracting)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ subtractingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 乘法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ multiplying)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ multiplyingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/**
 除法
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ dividing)(id <AUUNumberHandler> value);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ dividingWithBehaviors)(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors);

/*
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

对于`AUUNumberHandlerBaseOperator`的扩展，声明了一些更高一级的数学运算

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
*/

#pragma mark - 数字的一些扩展运算 -
/**
 n次方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ raisingToPower)(NSUInteger power);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ raisingToPowerWithBehaviors)(NSUInteger power, id <NSDecimalNumberBehaviors> behaviors);

/**
 乘以10的n次方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ multiplyingByPowerOf10)(short power);
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ multiplyingByPowerOf10WithBehaviors)(short power, id <NSDecimalNumberBehaviors> behaviors);

/**
 平方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *square;
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ squareWithBehaviors)(id <NSDecimalNumberBehaviors> behaviors);

/**
 立方
 */
@property (copy, nonatomic, readonly) NSDecimalNumber *cube;
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ cubeWithBehaviors)(id <NSDecimalNumberBehaviors> behaviors);

/**
 绝对值
 */
@property (retain, nonatomic, readonly) NSDecimalNumber *abs;

#pragma mark - rounding methods -

/**
 小数四舍五入，使用四舍五入模式

 scale 四舍五入时保留的小数位数
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ roundingWithScale)(short scale);

/**
 小数四舍五入

 decimalHandler 四舍五入的行为
 */
@property (copy, nonatomic, readonly) NSDecimalNumber * (^ roundingWithBehaviors)(id <NSDecimalNumberBehaviors> decimalHandler);

/**
 数字字符串

 fractionDigits 保留几位小数，如果小数位数不够，则会补0
 */
@property (copy, nonatomic, readonly) NSString * (^ numberStringWithFractionDigits)(short fractionDigits);
@property (copy, nonatomic, readonly) NSString * (^ decimalStringWithFractionDigits)(short fractionDigits);
@property (copy, nonatomic, readonly) NSString * (^ numberStringWithFormatter)(NSNumberFormatter *formatter);
@property (copy, nonatomic, readonly) NSString * (^ numberStringWith)(short fractionDigits, NSNumberFormatterStyle numberFormatter);

@end

