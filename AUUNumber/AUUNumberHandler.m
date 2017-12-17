//
//  AUUNumberHandler.m
//  Number
//
//  Created by JyHu on 2017/6/11.
//
//

#import "AUUNumberHandler.h"
#import "AUUNumberQuickCreator.h"


id <AUUNumberHandler> AUUSafeNumber(id <AUUNumberHandler> number) {
    return number && [number conformsToProtocol:@protocol(AUUNumberHandler)] ? (number.decimalNumber ?: @1) : @1;
}


@interface AUUNumberHandler ()

@property (copy, nonatomic) id <AUUNumberHandler> (^numberStringRefactor)(NSString *numberString);

@property (assign, nonatomic) BOOL enableDebuging;

@end

@implementation AUUNumberHandler

+ (instancetype)sharedHandler {
    static AUUNumberHandler *handler;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = AUUDefaultRoundingHandler();
        handler.enableDebuging = NO;
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

+ (void)globalNumberStringRefactorWithNumber:(id <AUUNumberHandler> (^)(NSString *))numberStringRefactor
{
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
    if (self.exceptionHandlerDurationOperation) {
        return self.exceptionHandlerDurationOperation(operation, error, leftOperand, rightOperand);
    } else if ([AUUNumberHandler sharedHandler].exceptionHandlerDurationOperation) {
        return [AUUNumberHandler sharedHandler].exceptionHandlerDurationOperation(operation, error, leftOperand, rightOperand);
    }
    
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
    
    if ((error == NSCalculationOverflow && self.raiseOnOverflow)||
        (error == NSCalculationDivideByZero && self.raiseOnDivideByZero) ||
        ((error == NSCalculationUnderflow || error == NSCalculationLossOfPrecision) && self.raiseOnExactness)) {
        
        if ([AUUNumberHandler sharedHandler].enableDebuging) {
            NSAssert(0, errorInfo);
        }
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

@end

AUUNumberHandler *AUURoundingMode(NSRoundingMode roundingMode) {
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:roundingMode scale:[NSDecimalNumberHandler defaultDecimalNumberHandler].scale];
}
AUUNumberHandler *AUURoundingScale(short scale) {
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:scale];
}

AUUNumberHandler *AUUDefaultRoundingHandler() {
    return [[AUUNumberHandler alloc] initHandlerWithRoundingMode:NSRoundPlain scale:[NSDecimalNumberHandler defaultDecimalNumberHandler].scale];
}









//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






id <AUUNumberHandler> AUUMaxNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2) {
    return (number1 && number2) ? ([number1.decimalNumber compare:number2.decimalNumber] == NSOrderedDescending ? number1 : number2) : nil;
}

id <AUUNumberHandler> AUUMinNumber(id <AUUNumberHandler> number1, id <AUUNumberHandler> number2) {
    return (number1 && number2) ? ([number1.decimalNumber compare:number2.decimalNumber] == NSOrderedAscending ? number1 : number2) : nil;
}

NSNumber * AUUMultiplyingByPowerOf10(NSInteger power) {
    return @(1).multiplyingByPowerOf10(power);
}

#pragma mark - String
#pragma mark -

@implementation NSString (AUUNumberHandler)

kAUU_NUMBER_HANDLER_IMPLEMENTATION_QUICK_CREATOR

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

#pragma mark - Decimal Number
#pragma mark -

@implementation NSDecimalNumber (AUUNumberHandler)

- (NSDecimalNumber *)decimalNumber {
    return self;
}

//========================================================================================================
//===============================================   加法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))add {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value){
        return self.addWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))addWithBehaviors {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByAdding:value.decimalNumber withBehavior:behaviors];
    } copy];
}

//========================================================================================================
//===============================================   减法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))subtracting {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value) {
        return self.subtractingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id <NSDecimalNumberBehaviors>))subtractingWithBehaviors {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberBySubtracting:value.decimalNumber withBehavior:behaviors];
    } copy];
}

//========================================================================================================
//===============================================   乘法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))multiplying {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value) {
        return self.multiplyingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))multiplyingWithBehaviors {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByMultiplyingBy:value.decimalNumber withBehavior:behaviors];
    } copy];
}

//========================================================================================================
//===============================================   除法   ===============================================

- (NSDecimalNumber *(^)(id <AUUNumberHandler>))dividing {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value) {
        return self.dividingWithBehaviors(value, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(id <AUUNumberHandler>, id<NSDecimalNumberBehaviors>))dividingWithBehaviors {
    return [^NSDecimalNumber *(id <AUUNumberHandler> value, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByDividingBy:value.decimalNumber withBehavior:behaviors];
    } copy];
}

//========================================================================================================
//===============================================   乘方   ===============================================

- (NSDecimalNumber *(^)(NSUInteger))raisingToPower {
    return [^NSDecimalNumber *(NSUInteger power) {
        return self.raisingToPowerWithBehaviors(power, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(NSUInteger, id<NSDecimalNumberBehaviors>))raisingToPowerWithBehaviors {
    return [^NSDecimalNumber *(NSUInteger power, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByRaisingToPower:power withBehavior:behaviors];
    } copy];
}

//========================================================================================================
//===============================================   指数   ===============================================

- (NSDecimalNumber *(^)(short))multiplyingByPowerOf10 {
    return [^NSDecimalNumber *(NSUInteger power) {
        return self.multiplyingByPowerOf10WithBehaviors(power, [AUUNumberHandler sharedHandler]);
    } copy];
}

- (NSDecimalNumber *(^)(short, id<NSDecimalNumberBehaviors>))multiplyingByPowerOf10WithBehaviors {
    return [^NSDecimalNumber *(short power, id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByMultiplyingByPowerOf10:power withBehavior:behaviors];
    } copy];
}

//=======================================================================================================
//===============================================   平方   ===============================================

- (NSDecimalNumber *)square {
    return self.squareWithBehaviors([AUUNumberHandler sharedHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))squareWithBehaviors {
    return [^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
        return self.raisingToPowerWithBehaviors(2, behaviors);
    } copy];
}

//========================================================================================================
//===============================================   立方   ===============================================

- (NSDecimalNumber *)cube {
    return self.cubeWithBehaviors([AUUNumberHandler sharedHandler]);
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))cubeWithBehaviors {
    return [^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
        return self.raisingToPowerWithBehaviors(3, behaviors);
    } copy];
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
    return [^NSDecimalNumber *(short scale) {
        AUUNumberHandler *handler = AUUDefaultRoundingHandler();
        handler.roundingScale = scale;
        return self.roundingWithBehaviors(handler);
    } copy];
}

- (NSDecimalNumber *(^)(id<NSDecimalNumberBehaviors>))roundingWithBehaviors {
    return [^NSDecimalNumber *(id <NSDecimalNumberBehaviors> behaviors) {
        return [self decimalNumberByRoundingAccordingToBehavior:behaviors];
    } copy];
}

#pragma mark - to string
#pragma mark -

- (NSString *(^)(short))numberStringWithFractionDigits {
    return [^NSString *(short fractionDigits) {
        return self.numberStringWith(fractionDigits, NSNumberFormatterNoStyle);
    } copy];
}

- (NSString *(^)(short))decimalStringWithFractionDigits {
    return [^NSString *(short fractionDigits) {
        return self.numberStringWith(fractionDigits, NSNumberFormatterDecimalStyle);
    } copy];
}

- (NSString *(^)(short, NSNumberFormatterStyle))numberStringWith {
    return [^NSString *(short fractionDigits, NSNumberFormatterStyle numberStyle) {
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        formatter.numberStyle = numberStyle;
        formatter.minimumFractionDigits = fractionDigits;
        formatter.maximumFractionDigits = fractionDigits;
        formatter.minimumIntegerDigits = 1;
        return self.numberStringWithFormatter(formatter);
    } copy];
}

- (NSString *(^)(NSNumberFormatter *))numberStringWithFormatter {
    return [^NSString *(NSNumberFormatter *formatter) {
        return formatter ? [formatter stringFromNumber:self] : self.stringValue;
    } copy];
}

@end

