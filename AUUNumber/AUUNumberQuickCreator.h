//
//  AUUNumberQuickCreator.h
//  Number
//
//  Created by 胡金友 on 2017/12/8.
//

#ifndef AUUNumberQuickCreator_h
#define AUUNumberQuickCreator_h






/*
 
 
 `kAUUNumberImplementationQuickCreator` 宏，用来快速实现`AUUNumberHandler`中的一些简单重复的协议方法，
 但是`decimalNumber`的这个属性的`get`方法必须自己实现
 
 
 
 */









#define __DecimalHandle__(type, func)                           \
            - (NSDecimalNumber *(^)(type))func {                \
                return [^NSDecimalNumber *(type value) {        \
                    return self.decimalNumber.func(value);      \
                } copy];                                        \
            }

#define __DecimalHandleWithBehaviors__(type, func)                                              \
            - (NSDecimalNumber *(^)(type, id<NSDecimalNumberBehaviors>))func {                  \
                return [^NSDecimalNumber *(type value, id <NSDecimalNumberBehaviors> behaviors) {                \
                    return self.decimalNumber.func(value, behaviors);                           \
                } copy];                                                                        \
            }

#define __DecimalString__(type, func)                       \
            - (NSString *(^)(type))func {                   \
                return [^NSString *(type value) {           \
                    return self.decimalNumber.func(value);  \
                } copy];                                    \
            }

/*
 实现了 AUUNumberHandler 协议的宏，包含一些数值的操作，方便别处使用
 */
#define kAUUNumberImplementationQuickCreator                                                    \
            /*          加法          */                                                         \
            __DecimalHandle__(id <AUUNumberHandler>, add)                                       \
            __DecimalHandleWithBehaviors__(id <AUUNumberHandler>, addWithBehaviors)             \
            /*          减法          */                                                         \
            __DecimalHandle__(id <AUUNumberHandler>, subtracting)                               \
            __DecimalHandleWithBehaviors__(id <AUUNumberHandler>, subtractingWithBehaviors)     \
            /*          乘法          */                                                         \
            __DecimalHandle__(id <AUUNumberHandler>, multiplying)                               \
            __DecimalHandleWithBehaviors__(id <AUUNumberHandler>, multiplyingWithBehaviors)     \
            /*          除法          */                                                         \
            __DecimalHandle__(id <AUUNumberHandler>, dividing)                                  \
            __DecimalHandleWithBehaviors__(id <AUUNumberHandler>, dividingWithBehaviors)        \
            /*          乘方          */                                                         \
            __DecimalHandle__(NSUInteger, raisingToPower)                                       \
            __DecimalHandleWithBehaviors__(NSUInteger, raisingToPowerWithBehaviors)             \
            /*          指数          */                                                         \
            __DecimalHandle__(short, multiplyingByPowerOf10)                                    \
            __DecimalHandleWithBehaviors__(short, multiplyingByPowerOf10WithBehaviors)          \
            /*          平方          */                                                         \
            - (NSDecimalNumber *)square { return self.raisingToPower(2); }                      \
            __DecimalHandle__(id <NSDecimalNumberBehaviors>, squareWithBehaviors)               \
            /*          立方          */                                                         \
            - (NSDecimalNumber *)cube { return self.raisingToPower(3); }                        \
            __DecimalHandle__(id <NSDecimalNumberBehaviors>, cubeWithBehaviors)                 \
            /*         绝对值         */                                                         \
            - (NSDecimalNumber *)abs { return self.decimalNumber.abs; }                         \
            /*          舍入          */                                                         \
            __DecimalHandle__(short, roundingWithScale)                                         \
            __DecimalHandle__(id <NSDecimalNumberBehaviors>, roundingWithBehaviors)             \
            /*        转字符串        */                                                         \
            __DecimalString__(short, numberStringWithFractionDigits)                            \
            __DecimalString__(short, decimalStringWithFractionDigits)                           \
            __DecimalString__(NSNumberFormatter *, numberStringWithFormatter)                   \
            - (NSString *(^)(short, NSNumberFormatterStyle))numberStringWith {                  \
                return [^NSString *(short fractionDigits, NSNumberFormatterStyle numberStyle) { \
                    return self.decimalNumber.numberStringWith(fractionDigits, numberStyle);    \
                } copy];                                                                        \
            }



#endif /* AUUNumberQuickCreator_h */
