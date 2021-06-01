//
//  main.m
//  HandleDemo-Mac
//
//  Created by JyHu on 2017/6/11.
//
//

#import <Foundation/Foundation.h>
#import "AUUNumber.h"
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
        
        NSLog(@"%@", @(0).numberStringWithFractionDigits(1));
        
        [AUUNumberHandler globalNumberStringRefactorWithNumber:^id(NSString *numberString) {
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
        
        [AUUNumberHandler globalNumberHandler:^(AUUNumberHandler *numberHandler) {
            numberHandler.roundingScale = 5;
            numberHandler.mode = NSRoundPlain;
            numberHandler.raiseOnOverflow = YES;
        } exceptionHandler:^NSDecimalNumber *(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant) {
            if (error == NSCalculationByNil) {
                return (@1).decimalNumber;
            }
            return (@1).decimalNumber;
        }];
        
        @"111".multiplying(nil);
        
        for (NSInteger i = 0; i < 10000; i ++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                tlog(@"数字字符串");
                tlog(@"345.34 --> %@, 343.2432435 - > %@", @(345.34).numberStringWithFractionDigits(4), @"343.2432435".numberStringWithFractionDigits(4));
                tlog(@"343.3434545 --> %@", @(343.3434545).roundingWithScale(3).stringValue);
                tlog(@"%@", @"87.230912423".roundingWithBehaviors([NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:3 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO]));
                
                AUUNumberHandler *numberHandler = AUUDefaultRoundingHandler();
                numberHandler.roundingScale = 5;
                
                tlog(@"3,4343.292345927349 --> %@", @"3,4343.292345927349".roundingWithBehaviors(numberHandler));
                
                AUUNumberHandler *defaultHandler = AUUDefaultRoundingHandler();
                defaultHandler.exceptionHandlerDurationOperation = ^NSDecimalNumber *(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant) {
                    return [NSDecimalNumber decimalNumberWithString:@"23"];
                };
                tlog(@"5555 / 0 = %@", @"5555".dividingWithBehaviors(@0, defaultHandler));
                
                tlog(@"\n\n绝对值");
                tlog(@"-3434.3434 --> %@", @"-3434.3434".abs.stringValue);
                
                tlog(@"\n\n加法");
                tlog(@"233.23 + 3434  -->  %@", @(233.23).add(@"3434").stringValue);
                
                tlog(@"\n\n减法");
                tlog(@"3435 - 901.2301 --> %@", @"3435".subtracting(@901.2301).stringValue);
                
                tlog(@"\n\n乘法");
                tlog(@"301.23 * 2.07 --> %@", @(301.23).multiplying(@56.2345234));
                
                tlog(@"\n\n除法");
                tlog(@"901.91 / 17.9 --> %@", [[NSDecimalNumber alloc] initWithFloat:901.91].dividing(@"17.9").stringValue);
                tlog(@"8901 / 25 --> %@", @"8901".dividing(@25).stringValue);
                tlog(@"68810.1092 / 111.111 --> %@", @"68810.1092".dividing(@111.111).roundingWithScale(2).stringValue);
                
                tlog(@"\n\n乘方");
                tlog(@"6.02 ^ 2 --> %@", @"6.02".raisingToPower(2));
                tlog(@"7923.08888 ^ 3.0111 --> %@", @"7923.08888".raisingToPower(3.0111).roundingWithScale(4).stringValue);
                
                tlog(@"\n\n乘10的n次方");
                tlog(@"870.1324 * 10 ^ 5 --> %@", @"870.1324".multiplyingByPowerOf10(5).stringValue);
                
                tlog(@"\n\n平方");
                tlog(@"78 ^ 2 --> %@", @(78).square.stringValue);
                
                tlog(@"\n\n立方");
                tlog(@"41 ^ 3 --> %@", @"41".cube.stringValue);
                
                tlog(@"\n\n特殊计数法计算");
                tlog(@"1,000 + 2,000,000 --> %@", @"1,000".add(@"2,000,000").stringValue);
                
                tlog(@"\n\n利率合约计算");
                tlog(@"10000'0008 + 200'6666 --> %@", @"10000'0008".add(@"200'6666").stringValue);
                
                tlog(@"\n\n错误计算1，在转换中纠错");
                tlog(@"aaa + 3 --> %@", @"aaa".add(@3).stringValue);
                
                tlog(@"\n\n错误计算2，在计算出错时纠错");
                tlog(@"bbb + 5 --> %@", @"bbb".add(@5).stringValue);
                
                tlog(@"\n\n对数组做计算");
                tlog(@"(20 + (10, 30, 400->1)) * (2, 3) / (3, 5) = %@", @"20".add(@[@10, @"30", [AUUDecimalNumber numberWithValue:400 offset:1]].sum).multiplying(@[@2, @3].product).dividing(@[@3, @5].product).stringValue);
                
                tlog(@"\n\n对象之间的数值计算");
                AUUDecimalNumber *dec1 = [AUUDecimalNumber numberWithValue:224 offset:3];
                AUUDecimalNumber *dec2 = [AUUDecimalNumber numberWithValue:1232 offset:2];
                AUUDecimalNumber *dec3 = [AUUDecimalNumber numberWithValue:53434 offset:4];
                AUUDecimalNumber *dec4 = [AUUDecimalNumber numberWithValue:349012 offset:5];
                tlog(@"(224->3 + 1232->2) * 53434->4 / 349012->5 = %@", dec1.add(dec2).multiplying(dec3).dividing(dec4).numberStringWithFractionDigits(3));
            });
        }
    }
    return 0;
}

