//
//  AUUNumberHandler.m
//  Number
//
//  Created by JyHu on 2017/6/11.
//
//

#import "AUUNumberHandler.h"
#import "AUUNumberQuickCreator.h"

@interface AUUNumberHandler ()

/// 四舍五入的方式
@property (assign, nonatomic) NSRoundingMode auu_roundingMode;

/// 保留几位小数
@property (assign, nonatomic) short auu_scale;

/// 数值格式化的管理字典
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumberFormatter *> *cachedFormatters;

@end

@implementation AUUNumberHandler
{
	dispatch_semaphore_t semaphore_lock_t;
}

+ (instancetype)defaultHandler {
	static AUUNumberHandler *handler;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		handler = [[AUUNumberHandler alloc] init];
        handler->semaphore_lock_t = dispatch_semaphore_create(1);
        handler.cachedFormatters = [[NSMutableDictionary alloc] init];
	});
	return handler;
}

+ (instancetype)instanceWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionHandler {
    AUUNumberHandler *handler = [[AUUNumberHandler alloc] init];
    handler.exceptionHandlerDurationOperation = [exceptionHandler copy];
    return handler;
}

- (instancetype)init {
	if (self = [super init]) {
		self.auu_roundingMode = NSRoundPlain;
		self.auu_scale = [NSDecimalNumberHandler defaultDecimalNumberHandler].scale;
	}
	return self;
}

- (instancetype)initHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale {
	if (self = [super init]) {
		self.auu_roundingMode = roundingMode;
		self.auu_scale = scale;
	}

	return self;
}

#pragma mark - NSDecimalNumberBehaviors delegate -

- (NSRoundingMode)roundingMode {
	return self.self.auu_roundingMode;
}

- (short)scale {
	return self.auu_scale;
}

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)operation
        error:(NSCalculationError)error
        leftOperand:(NSDecimalNumber *)leftOperand
        rightOperand:(NSDecimalNumber *)rightOperand {

    /// 如果支持调试，就直接断掉
	if ([AUUNumberHandler defaultHandler].enableDebuging) {
		NSAssert4(0, @"\nException Operation:%@\nError:%@\nLeft Operand:%@\nRight Operand:%@", NSStringFromSelector(operation), [self nameOfCalculateError:error], leftOperand, rightOperand);
	}

    /// 如果设置了自定义处理，就使用自定义处理的结果
    AUUNumberOperationExceptionHandler exceptionHandler = self.exceptionHandlerDurationOperation ?: [AUUNumberHandler defaultHandler].exceptionHandlerDurationOperation;
	if (exceptionHandler) {
		return exceptionHandler(operation, error, leftOperand, rightOperand);
    }
    
    /// 根据不同的错误，提供默认的解决方法，避免导致崩溃的发生
    switch (error) {
        case NSCalculationLossOfPrecision: return rightOperand;
        case NSCalculationUnderflow: return NSDecimalNumber.minimumDecimalNumber;
        case NSCalculationOverflow: return NSDecimalNumber.maximumDecimalNumber;
        case NSCalculationDivideByZero: return leftOperand;
        case NSCalculationByNil: return leftOperand;
        default: return (@1).decimalNumber;
    }
}

/// 给出可视化的错误名称
- (NSString *)nameOfCalculateError:(NSCalculationError)error {
    switch (error) {
        case NSCalculationLossOfPrecision: return @"NSCalculationLossOfPrecision";
        case NSCalculationUnderflow: return @"NSCalculationUnderflow";
        case NSCalculationDivideByZero: return @"NSCalculationDivideByZero";
        case NSCalculationOverflow: return @"NSCalculationOverflow";
        case NSCalculationByNil: return @"NSCalculationByNil";
        default: return @"";
    }
}

- (NSNumberFormatter *)formatterWithFractionDigits:(short)fractionDigits
                                       numberStyle:(NSNumberFormatterStyle)numberStyle {
	NSNumberFormatter *formatter = nil;
	dispatch_semaphore_wait(semaphore_lock_t, DISPATCH_TIME_FOREVER);
	NSString *key = [NSString stringWithFormat:@"%d-%ld", fractionDigits, numberStyle];
	formatter = [self.cachedFormatters objectForKey:key];
	if (formatter == nil) {
		formatter = [[NSNumberFormatter alloc] init];
		formatter.numberStyle = numberStyle;
		formatter.minimumFractionDigits = fractionDigits;
		formatter.maximumFractionDigits = fractionDigits;
		formatter.minimumIntegerDigits = 1;
		[self.cachedFormatters setObject:formatter forKey:key];
	}
	dispatch_semaphore_signal(semaphore_lock_t);
	return formatter;
}

+ (id <AUUNumberHandler>)safeNumberStringRefactor:(NSString *)numberString {
	if ([AUUNumberHandler defaultHandler].numberStringRefactor) {
		return [AUUNumberHandler defaultHandler].numberStringRefactor(numberString);
	}
	return (id <AUUNumberHandler>)numberString;
}

@end

id <AUUNumberHandler> AUUSafeNumber(id <AUUNumberHandler> number)
{
	return [NSDecimalNumber safeNumberWithNumberObject:number];
}

id <AUUNumberHandler> AUUMaxNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2)
{
	return (number1 && number2) ? ([number1.decimalNumber compare:number2.decimalNumber] == NSOrderedDescending ? number1 : number2) : nil;
}

id <AUUNumberHandler> AUUMinNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2)
{
	return (number1 && number2) ? ([number1.decimalNumber compare:number2.decimalNumber] == NSOrderedAscending ? number1 : number2) : nil;
}

NSNumber * AUUMultiplyingByPowerOf10(NSInteger power)
{
	return @(1).multiplyingByPowerOf10(power);
}

#pragma mark - String -

@implementation NSString (AUUNumberHandler)

kAUU_NUMBER_HANDLER_IMPLEMENTATION_QUICK_CREATOR

- (NSDecimalNumber *)decimalNumberWithFormatter:(NSNumberFormatter *)formatter {
	return [[formatter numberFromString:self] decimalNumber];
}

- (NSDecimalNumber *)decimalNumber {
	// 需要数据处理的地方
	id <AUUNumberHandler> refactorValue = [AUUNumberHandler safeNumberStringRefactor:self];
	if (refactorValue) {
		if ([refactorValue isKindOfClass:[NSString class]]) {
			// 避免递归的出现
			return [NSDecimalNumber decimalNumberWithString:(NSString *)refactorValue];
		}
		return refactorValue.decimalNumber;
	}
	return nil;
}

@end

#pragma mark - Number -

@implementation NSNumber (AUUNumberHandler)

kAUU_NUMBER_HANDLER_IMPLEMENTATION_QUICK_CREATOR

- (NSDecimalNumber *)decimalNumber {
	return [NSDecimalNumber decimalNumberWithDecimal:self.decimalValue];
}

@end

#pragma mark - NSArray -

@implementation NSArray (AUUNumberHandler)

- (NSDecimalNumber *)sum {
	NSDecimalNumber *res = nil;
	for (id <AUUNumberHandler> number in self) {
		if (number && [number conformsToProtocol:@protocol(AUUNumberHandler)]) {
			res = res ? res.add(number) : number.decimalNumber;
		}
	}
	return res;
}

- (NSDecimalNumber *)product {
	NSDecimalNumber *res = nil;
	for (id <AUUNumberHandler> number in self) {
		if (number && [number conformsToProtocol:@protocol(AUUNumberHandler)]) {
			res = res ? res.multiplying(number) : number.decimalNumber;
		}
	}
	return res;
}

@end

#pragma mark - Decimal Number -

@implementation NSDecimalNumber (AUUNumberHandler)

+ (NSDecimalNumber *)safeNumberWithNumberObject:(id<AUUNumberHandler>)numberObject {
	NSDecimalNumber *safeNumber = nil;
	if (numberObject && [numberObject conformsToProtocol:@protocol(AUUNumberHandler)]) {
		safeNumber = numberObject.decimalNumber;
	}

	if (safeNumber) {
		return safeNumber;
	}

	if ([AUUNumberHandler defaultHandler].enableDebuging) {
		NSAssert(0, @"非法的操作数");
	}

	return (@1).decimalNumber;
}

- (NSDecimalNumber *)decimalNumber {
	return self;
}

#define _CALCULATE_FUNCTION_(CALCULATE_FUNC, REALIZE_FUNC)                                 \
	- (NSDecimalNumber *(^)(id <AUUNumberHandler>))CALCULATE_FUNC {                   \
		return ^NSDecimalNumber *(id <AUUNumberHandler> value) {            \
			       return self.CALCULATE_FUNC ## WithBehaviors(value, [AUUNumberHandler defaultHandler]); \
		};                                                                  \
	}                                                                       \
	- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))CALCULATE_FUNC ## WithBehaviors {      \
		return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {   \
			       NSDecimalNumber *decimalNumber = value.decimalNumber;                                    \
			       if (decimalNumber == nil) {                                                              \
				       return [behaviors exceptionDuringOperation:_cmd error:NSCalculationByNil leftOperand:self rightOperand:decimalNumber]; \
			       }                                                                                        \
			       return [self REALIZE_FUNC:decimalNumber withBehavior:behaviors];                         \
		};                                                                                                  \
	}

//================================================================================
//================================   加 减 乘 除   =================================

_CALCULATE_FUNCTION_(add, decimalNumberByAdding)                /// 加法
_CALCULATE_FUNCTION_(subtracting, decimalNumberBySubtracting)   /// 减法
_CALCULATE_FUNCTION_(multiplying, decimalNumberByMultiplyingBy) /// 乘法
_CALCULATE_FUNCTION_(dividing, decimalNumberByDividingBy)       /// 除法

//===============================================================================
//================================   乘方   =====================================

- (NSDecimalNumber *(^)(NSUInteger))raisingToPower {
	return ^NSDecimalNumber *(NSUInteger power) {
		       return self.raisingToPowerWithBehaviors(power, [AUUNumberHandler defaultHandler]);
	};
}

- (NSDecimalNumber *(^)(NSUInteger, id<NSDecimalNumberBehaviors>))raisingToPowerWithBehaviors {
	return ^NSDecimalNumber *(NSUInteger power, id <NSDecimalNumberBehaviors> behaviors) {
		       return [self decimalNumberByRaisingToPower:power withBehavior:behaviors];
	};
}

//===========================================================================
//================================   指数   =================================

- (NSDecimalNumber *(^)(short))multiplyingByPowerOf10 {
	return ^NSDecimalNumber *(short power) {
		       return self.multiplyingByPowerOf10WithBehaviors(power, [AUUNumberHandler defaultHandler]);
	};
}

- (NSDecimalNumber *(^)(short, id<NSDecimalNumberBehaviors>))multiplyingByPowerOf10WithBehaviors {
	return ^NSDecimalNumber *(short power, id <NSDecimalNumberBehaviors> behaviors) {
		       return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:behaviors];
	};
}

//==========================================================================
//=================================   平方   ================================

- (NSDecimalNumber *)square {
	return self.squareWithBehaviors([AUUNumberHandler defaultHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))squareWithBehaviors {
	return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
		       return self.raisingToPowerWithBehaviors(2, behaviors);
	};
}

//==========================================================================
//=================================   立方   ===============================

- (NSDecimalNumber *)cube {
	return self.cubeWithBehaviors([AUUNumberHandler defaultHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))cubeWithBehaviors {
	return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
		       return self.raisingToPowerWithBehaviors(3, behaviors);
	};
}

//=======================================================================
//================================   绝对值   =============================

- (NSDecimalNumber *)abs {
	if ([self compare:@(0)] == NSOrderedAscending) {
		return self.multiplying(@(-1));
	}
	return self;
}

#pragma mark - rounding -

- (NSDecimalNumber *(^)(short))roundingWithScale {
	return ^NSDecimalNumber *(short scale) {
		       return self.roundingWithBehaviors([[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:scale]);
	};
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))roundingWithBehaviors {
	return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
		       return [self decimalNumberByRoundingAccordingToBehavior:behaviors];
	};
}

#pragma mark - to string -

- (NSString *(^)(short))numberStringWithFractionDigits {
	return ^NSString *(short fractionDigits) {
		       return self.numberStringWith(fractionDigits, NSNumberFormatterNoStyle);
	};
}

- (NSString *(^)(short))decimalStringWithFractionDigits {
	return ^NSString *(short fractionDigits) {
		       return self.numberStringWith(fractionDigits, NSNumberFormatterDecimalStyle);
	};
}

- (NSString *(^)(short, NSNumberFormatterStyle))numberStringWith {
	return ^NSString *(short fractionDigits, NSNumberFormatterStyle numberStyle) {
		       return self.numberStringWithFormatter([[AUUNumberHandler defaultHandler] formatterWithFractionDigits:fractionDigits numberStyle:numberStyle]);
	};
}

- (NSString *(^)(NSNumberFormatter *))numberStringWithFormatter {
	return ^NSString *(NSNumberFormatter *formatter) {
		       return formatter ? [formatter stringFromNumber:self] : self.stringValue;
	};
}

@end

#undef _CALCULATE_FUNCTION_
