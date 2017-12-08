//
//  AUUDecimalNumber.m
//  HandleDemo-Mac
//
//  Created by 胡金友 on 2017/12/7.
//

#import "AUUDecimalNumber.h"

@implementation AUUDecimalNumber

+ (instancetype)numberWithValue:(NSInteger)value offset:(NSInteger)offset {
    AUUDecimalNumber *number = [[AUUDecimalNumber alloc] init];
    number.value = value;
    number.offset = offset;
    return number;
}

- (NSDecimalNumber *)decimalNumber {
    return @(self.value).dividing(AUUMultiplyingByPowerOf10(self.offset));
}

kAUUNumberImplementationQuickCreator

@end
