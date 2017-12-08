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


- (BOOL)isRegularNumberString
{
    NSString *pattern = @"^[+-]?[0-9]*?\\.?[0-9e-]*?$";
    return [[NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern] evaluateWithObject:self];
}

- (int)legalIntValue {
    if (self.isPureIntString) {
        return self.intValue;
    }
    return INT_MAX;
}

- (NSInteger)legalIntegerValue {
    if (self.isPureIntegerString) {
        return self.integerValue;
    }
    return NSIntegerMax;
}

- (long long)legalLongLongValue {
    if (self.isPureLongLongString) {
        return self.longLongValue;
    }
    return LONG_LONG_MAX;
}

- (float)legalFloatValue {
    if (self.isPureFloatString) {
        return self.floatValue;
    }
    return FLT_MAX;
}

- (double)legalDoubleValue {
    if (self.isPureDoubleString) {
        return self.doubleValue;
    }
    return DBL_MAX;
}

@end
