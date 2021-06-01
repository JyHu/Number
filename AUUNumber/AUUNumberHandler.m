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

@property (copy, nonatomic) id <AUUNumberHandler> (^ numberStringRefactor)(NSString *numberString);

@property (assign, nonatomic) BOOL enableDebuging;

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSNumberFormatter *> *cachedFormatters;

@end

@implementation AUUNumberHandler
{
    dispatch_semaphore_t semaphore_lock_t;
}

+ (instancetype)sharedHandler {
    static AUUNumberHandler *handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = AUUDefaultRoundingHandler();
        handler.enableDebuging = NO;
        handler.cachedFormatters = [[NSMutableDictionary alloc] init];
        handler->semaphore_lock_t = dispatch_semaphore_create(1);
    });
    return handler;
}

+ (id <AUUNumberHandler>)safeNumberStringRefactor:(NSString *)numberString {
    if ([AUUNumberHandler sharedHandler].numberStringRefactor) {
        return [AUUNumberHandler sharedHandler].numberStringRefactor(numberString);
    }
    return (id <AUUNumberHandler>)numberString;
}

- (instancetype)init {
    NSAssert(0, @"Please use initHandlerWithRoundingMode:scale: init the modle.");
    return self;
}

- (instancetype)initHandlerWithRoundingMode:(NSRoundingMode)roundingMode scale:(short)scale {
    if (self = [super init]) {
        self.mode = roundingMode;
        self.roundingScale = scale;
    }

    return self;
}

+ (AUUNumberHandler *)numberHandlerWithExceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation {
    AUUNumberHandler *handler = [[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:[NSDecimalNumberHandler defaultDecimalNumberHandler].scale];
    handler.exceptionHandlerDurationOperation = exceptionDurationOperation;
    return handler;
}

#pragma mark - global setting
#pragma mark -

+ (void)globalNumberHandler:(void (^)(AUUNumberHandler *))numberHandler exceptionHandler:(AUUNumberOperationExceptionHandler)exceptionDurationOperation {
    if (numberHandler) {
        numberHandler([self sharedHandler]);
    }
    if (exceptionDurationOperation) {
        [[self sharedHandler] setExceptionHandlerDurationOperation:[exceptionDurationOperation copy]];
    }
}

+ (void)globalNumberStringRefactorWithNumber:(id <AUUNumberHandler> (^)(NSString *))numberStringRefactor {
    if (numberStringRefactor) {
        [[self sharedHandler] setNumberStringRefactor:[numberStringRefactor copy]];
    }
}

+ (void)enableDebugingMode:(BOOL)enable {
    [AUUNumberHandler sharedHandler].enableDebuging = enable;
}

#pragma mark - NSDecimalNumberBehaviors delegate
#pragma mark -

- (NSRoundingMode)roundingMode {
    return self.mode;
}

- (short)scale {
    return self.roundingScale;
}

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)operation error:(NSCalculationError)error
                                  leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(NSDecimalNumber *)rightOperand {

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
        default:
            break;
    }

    NSString *errorInfo = [NSString stringWithFormat:@"\nException Operation:%@\nError:%@\nLeft Operand:%@\nRight Operand:%@", NSStringFromSelector(operation), errorName, leftOperand, rightOperand];

    NSLog(@"%@", errorInfo);

    if ((error == NSCalculationOverflow && self.raiseOnOverflow) ||
        (error == NSCalculationDivideByZero && self.raiseOnDivideByZero) ||
        ((error == NSCalculationUnderflow || error == NSCalculationLossOfPrecision) && self.raiseOnExactness)) {
        if ([AUUNumberHandler sharedHandler].enableDebuging) {
            NSAssert(0, errorInfo);
        }
    }
    
    if (self.exceptionHandlerDurationOperation) {
        return self.exceptionHandlerDurationOperation(operation, error, leftOperand, rightOperand);
    } else if ([AUUNumberHandler sharedHandler].exceptionHandlerDurationOperation) {
        return [AUUNumberHandler sharedHandler].exceptionHandlerDurationOperation(operation, error, leftOperand, rightOperand);
    }

    if ([AUUNumberHandler sharedHandler].enableDebuging) {
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

@end

AUUNumberHandler * AUURoundingMode(NSRoundingMode roundingMode)
{
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:roundingMode scale:[NSDecimalNumberHandler defaultDecimalNumberHandler].scale];
}

AUUNumberHandler * AUURoundingScale(short scale)
{
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:scale];
}

AUUNumberHandler * AUUDefaultRoundingHandler()
{
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:[NSDecimalNumberHandler defaultDecimalNumberHandler].scale];
}

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

+ (NSDecimalNumber *)safeNumberWithNumberObject:(id<AUUNumberHandler>)numberObject
{
    NSDecimalNumber *safeNumber = nil;
    if (numberObject && [numberObject conformsToProtocol:@protocol(AUUNumberHandler)]) {
        safeNumber = numberObject.decimalNumber;
    }

    if (safeNumber) {
        return safeNumber;
    }

    if ([AUUNumberHandler sharedHandler].enableDebuging) {
        NSAssert(0, @"非法的操作数");
        return nil;
    }

    return (@1).decimalNumber;
}

- (NSDecimalNumber *)decimalNumber {
    return self;
}

#define _CALCULATE_BY_ARRAY_PRODUCT_CHECK_ (value && [value isKindOfClass:[NSArray class]]) ? ((NSArray *)value).product : value.decimalNumber
#define _CALCULATE_BY_ARRAY_SUM_CHECK_     (value && [value isKindOfClass:[NSArray class]]) ? ((NSArray *)value).sum : value.decimalNumber
#define _CALCULATE_BY_NIL_NUMBER_CHECK_ \
    NSDecimalNumber *decimalNumber = value.decimalNumber; \
    if (decimalNumber == nil) { \
        decimalNumber = [behaviors exceptionDuringOperation:_cmd error:NSCalculationByNil leftOperand:self rightOperand:decimalNumber]; \
    }

//========================================================================================================
//===============================================   加法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))add {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value) {
               return self.addWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))addWithBehaviors {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
               _CALCULATE_BY_NIL_NUMBER_CHECK_
               return [self decimalNumberByAdding:decimalNumber withBehavior:behaviors];
    };
}

//========================================================================================================
//===============================================   减法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))subtracting {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value) {
               return self.subtractingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id <NSDecimalNumberBehaviors>))subtractingWithBehaviors {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
               _CALCULATE_BY_NIL_NUMBER_CHECK_
               return [self decimalNumberBySubtracting:decimalNumber withBehavior:behaviors];
    };
}

//========================================================================================================
//===============================================   乘法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))multiplying {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value) {
               return self.multiplyingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))multiplyingWithBehaviors {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
               _CALCULATE_BY_NIL_NUMBER_CHECK_
               return [self decimalNumberByMultiplyingBy:decimalNumber withBehavior:behaviors];
    };
}

//========================================================================================================
//===============================================   除法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))dividing {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value) {
               return self.dividingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))dividingWithBehaviors {
    return ^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
               _CALCULATE_BY_NIL_NUMBER_CHECK_
               return [self decimalNumberByDividingBy:decimalNumber withBehavior:behaviors];
    };
}

//========================================================================================================
//===============================================   乘方   ===============================================

- (NSDecimalNumber *(^)(NSUInteger))raisingToPower {
    return ^NSDecimalNumber *(NSUInteger power) {
               return self.raisingToPowerWithBehaviors(power, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(NSUInteger, id<NSDecimalNumberBehaviors>))raisingToPowerWithBehaviors {
    return ^NSDecimalNumber *(NSUInteger power, id <NSDecimalNumberBehaviors> behaviors) {
               return [self decimalNumberByRaisingToPower:power withBehavior:behaviors];
    };
}

//========================================================================================================
//===============================================   指数   ===============================================

- (NSDecimalNumber *(^)(short))multiplyingByPowerOf10 {
    return ^NSDecimalNumber *(short power) {
               return self.multiplyingByPowerOf10WithBehaviors(power, [AUUNumberHandler sharedHandler]);
    };
}

- (NSDecimalNumber *(^)(short, id<NSDecimalNumberBehaviors>))multiplyingByPowerOf10WithBehaviors {
    return ^NSDecimalNumber *(short power, id <NSDecimalNumberBehaviors> behaviors) {
               return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:behaviors];
    };
}

//=======================================================================================================
//===============================================   平方   ===============================================

- (NSDecimalNumber *)square {
    return self.squareWithBehaviors([AUUNumberHandler sharedHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))squareWithBehaviors {
    return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
               return self.raisingToPowerWithBehaviors(2, behaviors);
    };
}

//========================================================================================================
//===============================================   立方   ===============================================

- (NSDecimalNumber *)cube {
    return self.cubeWithBehaviors([AUUNumberHandler sharedHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))cubeWithBehaviors {
    return ^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
               return self.raisingToPowerWithBehaviors(3, behaviors);
    };
}

//========================================================================================================
//===============================================   绝对值   ===============================================

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
               AUUNumberHandler *handler = AUUDefaultRoundingHandler();
               handler.roundingScale = scale;
               return self.roundingWithBehaviors(handler);
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
               return self.numberStringWithFormatter([[AUUNumberHandler sharedHandler] formatterWithFractionDigits:fractionDigits numberStyle:numberStyle]);
    };
}

- (NSString *(^)(NSNumberFormatter *))numberStringWithFormatter {
    return ^NSString *(NSNumberFormatter *formatter) {
               return formatter ? [formatter stringFromNumber:self] : self.stringValue;
    };
}

@end

#undef _CALCULATE_BY_ARRAY_PRODUCT_CHECK_
#undef _CALCULATE_BY_ARRAY_SUM_CHECK_
#undef _CALCULATE_BY_NIL_NUMBER_CHECK_
