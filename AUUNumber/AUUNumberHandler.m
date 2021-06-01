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

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumberFormatter *> *cachedFormatters;

@end

@implementation AUUNumberHandler
{
	dispatch_semaphore_t semaphore_lock_t;
}

+ (instancetype)shared {
	static AUUNumberHandler *handler;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		handler = [[AUUNumberHandler alloc] init];
	});
	return handler;
}

- (instancetype)init {
	if (self = [super init]) {
		self->semaphore_lock_t = dispatch_semaphore_create(1);
		self.cachedFormatters = [[NSMutableDictionary alloc] init];
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

#pragma mark - NSDecimalNumberBehaviors delegate
#pragma mark -

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

	NSString *errorName = @"";
	switch (error) {
	case NSCalculationLossOfPrecision:
		errorName = @"NSCalculationLossOfPrecision";
		break;
	case NSCalculationUnderflow:
		errorName = @"NSCalculationUnderflow";
		break;
	case NSCalculationDivideByZero:
		errorName = @"NSCalculationDivideByZero";
		break;
	case NSCalculationOverflow:
		errorName = @"NSCalculationOverflow";
		break;
	case NSCalculationByNil:
		errorName = @"NSCalculationByNil";
		break;
	default:
		break;
	}

	if ([AUUNumberHandler shared].enableDebuging) {
		NSAssert4(0, @"\nException Operation:%@\nError:%@\nLeft Operand:%@\nRight Operand:%@", NSStringFromSelector(operation), errorName, leftOperand, rightOperand);
	}

	if ([AUUNumberHandler shared].exceptionHandlerDurationOperation) {
		return [AUUNumberHandler shared].exceptionHandlerDurationOperation(operation, error, leftOperand, rightOperand);
	}

	if ([AUUNumberHandler shared].enableDebuging) {
		return nil;
	}

	if (leftOperand && [leftOperand isKindOfClass:[NSNumber class]] && [leftOperand compare:@0] != NSOrderedSame) {
		return leftOperand;
	}

	if (rightOperand && [rightOperand isKindOfClass:[NSNumber class]] && [rightOperand compare:@0] != NSOrderedSame) {
		return rightOperand;
	}

	return (@1).decimalNumber;
}

- (NSNumberFormatter *)formatterWithFractionDigits:(short)fractionDigits numberStyle:(NSNumberFormatterStyle)numberStyle {
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
	if ([AUUNumberHandler shared].numberStringRefactor) {
		return [AUUNumberHandler shared].numberStringRefactor(numberString);
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

#pragma mark - String
#pragma mark -

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

#pragma mark - Number
#pragma mark -

@implementation NSNumber (AUUNumberHandler)

kAUU_NUMBER_HANDLER_IMPLEMENTATION_QUICK_CREATOR

- (NSDecimalNumber *)decimalNumber {
	return [NSDecimalNumber decimalNumberWithDecimal:self.decimalValue];
}

@end

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

#pragma mark - Decimal Number
#pragma mark -

@implementation NSDecimalNumber (AUUNumberHandler)

+ (NSDecimalNumber *)safeNumberWithNumberObject:(id<AUUNumberHandler>)numberObject {
	NSDecimalNumber *safeNumber = nil;
	if (numberObject && [numberObject conformsToProtocol:@protocol(AUUNumberHandler)]) {
		safeNumber = numberObject.decimalNumber;
	}

	if (safeNumber) {
		return safeNumber;
	}

	if ([AUUNumberHandler shared].enableDebuging) {
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
			       return self.CALCULATE_FUNC ## WithBehaviors(value, [AUUNumberHandler shared]); \
		};                                                                  \
	}                                                                       \
	- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))CALCULATE_FUNC ## WithBehaviors {      \
		return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {   \
			       NSDecimalNumber *decimalNumber = value.decimalNumber;                                    \
			       if (decimalNumber == nil) {                                                              \
				       decimalNumber = [behaviors exceptionDuringOperation:_cmd error:NSCalculationByNil leftOperand:self rightOperand:decimalNumber]; \
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
		       return self.raisingToPowerWithBehaviors(power, [AUUNumberHandler shared]);
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
		       return self.multiplyingByPowerOf10WithBehaviors(power, [AUUNumberHandler shared]);
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
	return self.squareWithBehaviors([AUUNumberHandler shared]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))squareWithBehaviors {
	return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
		       return self.raisingToPowerWithBehaviors(2, behaviors);
	};
}

//==========================================================================
//=================================   立方   ===============================

- (NSDecimalNumber *)cube {
	return self.cubeWithBehaviors([AUUNumberHandler shared]);
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

#pragma mark - rounding
#pragma mark -

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

#pragma mark - to string
#pragma mark -

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
		       return self.numberStringWithFormatter([[AUUNumberHandler shared] formatterWithFractionDigits:fractionDigits numberStyle:numberStyle]);
	};
}

- (NSString *(^)(NSNumberFormatter *))numberStringWithFormatter {
	return ^NSString *(NSNumberFormatter *formatter) {
		       return formatter ? [formatter stringFromNumber:self] : self.stringValue;
	};
}

@end

#undef _CALCULATE_FUNCTION_
