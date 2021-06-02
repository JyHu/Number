//
//  AUUDecimal.h
//  NumberTests
//
//  Created by 胡金友 on 2021/6/2.
//

#import <Foundation/Foundation.h>
#import <AUUNumber/AUUNumber.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUUDecimal : NSObject <AUUNumberHandler>

+ (instancetype)numberWithValue:(NSInteger)value offset:(NSInteger)offset;

@property (assign, nonatomic) NSInteger value;
@property (assign, nonatomic) NSInteger offset;

@end

NS_ASSUME_NONNULL_END
