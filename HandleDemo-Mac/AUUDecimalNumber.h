//
//  AUUDecimalNumber.h
//  HandleDemo-Mac
//
//  Created by 胡金友 on 2017/12/7.
//

#import <Foundation/Foundation.h>
#import "AUUNumber.h"



/*
 
 测试的类，实现了AUUNumberHandler协议以后就能跟其他的各种数据类型之间直接进行数值的计算
 
 */




@interface AUUDecimalNumber : NSObject <AUUNumberHandler>

+ (instancetype)numberWithValue:(NSInteger)value offset:(NSInteger)offset;

@property (assign, nonatomic) NSInteger value;
@property (assign, nonatomic) NSInteger offset;

@end
