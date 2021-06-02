//
//  AUUDecimal.m
//  NumberTests
//
//  Created by 胡金友 on 2021/6/2.
//

#import "AUUDecimal.h"

@implementation AUUDecimal

+ (instancetype)numberWithValue:(NSInteger)value offset:(NSInteger)offset {
    AUUDecimal *number = [[AUUDecimal alloc] init];
    number.value = value;
    number.offset = offset;
    return number;
}

- (NSDecimalNumber *)decimalNumber {
    return @(self.value).multiplying(AUUMultiplyingByPowerOf10(self.offset));
}

kAUU_NUMBER_HANDLER_IMPLEMENTATION_QUICK_CREATOR

@end
