//
//  NSString+AUUNumberCheck.m
//  AUUNumber
//
//  Created by 胡金友 on 2017/11/18.
//

#import "NSString+AUUNumberCheck.h"

@implementation NSString (AUUNumberCheck)

#define __NumberCheck__(method, type, sel)                                  \
    - (BOOL)method {                                                \
        NSScanner *scanner = [NSScanner scannerWithString:self];    \
        type val;                                                   \
        BOOL res = [scanner sel:&val] && [scanner isAtEnd];         \
        if (res && val == 0) {                                      \
            return [self isRegularNumberString];                    \
        }                                                           \
        return res;                                                 \
    }

__NumberCheck__(isPureIntString, int, scanInt)
__NumberCheck__(isPureIntegerString, NSInteger, scanInteger)
__NumberCheck__(isPureLongLongString, long long, scanLongLong)
__NumberCheck__(isPureUnsignedLongLongString, unsigned long long, scanUnsignedLongLong)
__NumberCheck__(isPureFloatString, float, scanFloat)
__NumberCheck__(isPureDoubleString, double, scanDouble)
__NumberCheck__(isPureHexLongLongString, unsigned long long, scanHexLongLong)
__NumberCheck__(isPureHexFloatString, float, scanHexFloat)
__NumberCheck__(isPureHexDoubleString, double, scanHexDouble)

- (BOOL)isRegularNumberString {
    NSString *pattern = @"^[+-]?[0-9]*?\\.?[0-9e-]*?$";
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern] evaluateWithObject:self];
}

- (int)legalIntValue {
    return self.isPureIntString ? self.intValue : INT_MAX;
}

- (NSInteger)legalIntegerValue {
    return self.isPureIntegerString ? self.integerValue : NSIntegerMax;
}

- (long long)legalLongLongValue {
    return self.isPureLongLongString ? self.longLongValue : LONG_LONG_MAX;
}

- (float)legalFloatValue {
    return self.isPureFloatString ? self.floatValue : FLT_MAX;
}

- (double)legalDoubleValue {
    return self.isPureDoubleString ? self.doubleValue : DBL_MAX;
}

@end
