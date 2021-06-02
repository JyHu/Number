//
//  NumberTests.m
//  NumberTests
//
//  Created by 胡金友 on 2021/6/2.
//

#import <XCTest/XCTest.h>
#import <AUUNumber/AUUNumber.h>
#import "AUUDecimal.h"

@interface NumberTests : XCTestCase

@end

@implementation NumberTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    
#define NUMBER_EQUAL(N1, N2) XCTAssert([N1 compare:@(N2)] == NSOrderedSame);
        
    [[AUUNumberHandler defaultHandler] setNumberStringRefactor:^id<AUUNumberHandler>(NSString *numberString) {
        NSString *fac = numberString;
        if ([fac containsString:@","]) {
            fac = [fac stringByReplacingOccurrencesOfString:@"," withString:@""];
        }
        
        if ([fac containsString:@"'"]) {
            fac = [fac stringByReplacingOccurrencesOfString:@"'" withString:@"."];
        }
        
        /// 默认写死了，就不写16 -> 10的算法了
        if ([numberString containsString:@"0xA"]) {
            return @10;
        }
        
        if (fac.isPureFloatString) {
            return fac;
        }
        
        return @10;
    }];
    
    NSArray <id <AUUNumberHandler>> *testErrorNumbers = @[
        @"10",  /// 正常数值字符串
        @"1,0", /// 特殊数值字符串
        @"10'0", /// 特殊数值字符串
        @"0xA", /// 16进制数值字符串
        @"test", /// 错误数值字符串
        @10, /// 正常数值对象
        [NSDecimalNumber numberWithInt:10], /// 科学技术数值对象
        [AUUDecimal numberWithValue:1 offset:1] /// 自定义的数值对象
    ];
    
    for (id <AUUNumberHandler> testNum in testErrorNumbers) {
        /// 测试 10 + nil
        NUMBER_EQUAL(testNum.add(nil), 10)
        
        /// 测试 10 - nil
        NUMBER_EQUAL(testNum.subtracting(nil), 10)
        
        /// 测试 10 * nil
        NUMBER_EQUAL(testNum.multiplying(nil), 10)
        
        /// 测试 10 / nil
        NUMBER_EQUAL(testNum.dividing(nil), 10)
        
        /// 测试 10 / 0
        NUMBER_EQUAL(testNum.dividing(@0), 10)
        
        /// 测试 10^2
        NUMBER_EQUAL(testNum.square, 100)
        
        /// 测试 10^3
        NUMBER_EQUAL(testNum.cube, 1000)
        
        /// 测试 1 * 10^2
        NUMBER_EQUAL(testNum.raisingToPower(2), 100)
        
        /// 测试 1 * 10^3
        NUMBER_EQUAL(testNum.raisingToPower(3), 1000)
        
    }
    
    /// 测试数值总数
    NSInteger numCount = testErrorNumbers.count;
    
    /// 遍历所有数值做互相的混合运算
    for (NSInteger i = 0; i < numCount; i ++) {
        for (NSInteger j = 0; j < numCount; j ++) {
            id <AUUNumberHandler> num1 = testErrorNumbers[i];
            id <AUUNumberHandler> num2 = testErrorNumbers[j];
            
            NUMBER_EQUAL(num1.add(num2), 20)
            NUMBER_EQUAL(num1.subtracting(num2), 0)
            NUMBER_EQUAL(num1.multiplying(num2), 100)
            NUMBER_EQUAL(num1.dividing(num2), 1)
        }
    }
    
    /// 取绝对值
    NUMBER_EQUAL(@"-1000".abs, 1000)
    
    /// 混合运算
    NUMBER_EQUAL(@"20".add(testErrorNumbers.product).dividing(testErrorNumbers.sum), (pow(10, numCount) + 20) / (numCount * 10))
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
