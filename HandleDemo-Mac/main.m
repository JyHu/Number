//
//  main.m
//  HandleDemo-Mac
//
//  Created by JyHu on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
#import <AUUNumber/AUUNumber.h>
#import "AUUDecimalNumber.h"

void tlog(id fmt, ...) {
    va_list args;
    va_start(args, fmt);
    printf("%s\n", [[NSString alloc] initWithFormat:fmt arguments:args].UTF8String);
    va_end(args);
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        
        id<AUUNumberHandler> n = @"100".dividing(@0);
        n = n.dividing(nil);
        n = n.subtracting(nil);
        n = n.multiplying(nil);
        n = n.dividing(nil);
        
        AUUNumberHandler *handler = [AUUNumberHandler shared];
        
        [handler setNumberStringRefactor:^id<AUUNumberHandler>(NSString *numberString) {
            NSString *fac = numberString;
            if ([fac containsString:@","]) {
                fac = [fac stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
            
            if ([fac containsString:@"'"]) {
                fac = [fac stringByReplacingOccurrencesOfString:@"." withString:@""];
            }
            
            if (fac.isPureFloatString) {
                return fac;
            }
            
            if ([numberString containsString:@"b"]) {
                return @"bbb";
            }
            
            return @1;
        }];
        
        [handler setExceptionHandlerDurationOperation:^NSDecimalNumber *(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant) {
            NSLog(@"计算数值出错 %@ %@ %@", NSStringFromSelector(operation), leftOperand, rightOperant);
            return @(2).decimalNumber;
        }];
        
        tlog(@"数字字符串");
        tlog(@"345.34 --> %@, 343.2432435 - > %@", @(345.34).numberStringWithFractionDigits(4), @"343.2432435".numberStringWithFractionDigits(4));
        tlog(@"343.3434545 --> %@", @(343.3434545).roundingWithScale(3).stringValue);
        tlog(@"%@", @"87.230912423".roundingWithBehaviors([NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]));
        
        tlog(@"\n\n错误计算1，在转换中纠错");
        tlog(@"aaa + 3 --> %@", @"aaa".add(@3).stringValue);
        
        tlog(@"\n\n错误计算2，在计算出错时纠错");
        tlog(@"bbb + 5 --> %@", @"bbb".add(@5).stringValue);
    }
    return 0;
}

