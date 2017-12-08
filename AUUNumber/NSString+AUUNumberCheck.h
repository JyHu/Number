//
//  NSString+AUUNumberCheck.h
//  AUUNumber
//
//  Created by 胡金友 on 2017/11/18.
//

#import <Foundation/Foundation.h>

@interface NSString (AUUNumberCheck)

@property (assign, nonatomic, readonly) BOOL isPureIntString;
@property (assign, nonatomic, readonly) BOOL isPureIntegerString;
@property (assign, nonatomic, readonly) BOOL isPureLongLongString;
@property (assign, nonatomic, readonly) BOOL isPureUnsignedLongLongString;
@property (assign, nonatomic, readonly) BOOL isPureFloatString;
@property (assign, nonatomic, readonly) BOOL isPureDoubleString;

@property (assign, nonatomic, readonly) BOOL isPureHexLongLongString;       // Optionally prefixed with "0x" or "0X"
@property (assign, nonatomic, readonly) BOOL isPureHexFloatString;          // Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix.
@property (assign, nonatomic, readonly) BOOL isPureHexDoubleString;         // Corresponding to %a or %A formatting. Requires "0x" or "0X" prefix.

@property (assign, nonatomic, readonly) BOOL isRegularNumberString;     // 使用正则去判断是否是数字

@property (assign, nonatomic, readonly) int legalIntValue;              // INT_MAX
@property (assign, nonatomic, readonly) NSInteger legalIntegerValue;    // NSIntegerMax
@property (assign, nonatomic, readonly) long long legalLongLongValue;   // LONG_LONG_MAX
@property (assign, nonatomic, readonly) float legalFloatValue;          // FLT_MAX
@property (assign, nonatomic, readonly) double legalDoubleValue;        // DBL_MAX


@end
