# Number



## 说明

一个简单、方便的数值计算库，封装了系统的`NSDecimalNumber`，方便数值计算与扩展，避免精度的丢失。

## 使用

直接使用`cocoapods`添加引用： `pod 'Number'`

使用的时候可以直接对`NSString`、`NSNumber`、`NSDecimalNumber`类型的数做数值的加减乘除等运算。

已经加入的方法：

- 加法
- 减法
- 乘法
- 除法
- 求方
- 乘以10的n次方
- 平方
- 立方
- 绝对值
- 四舍五入
- 字符串带精度转换

### 简单计算

```objective-c
NSString *a = @"10.2";
NSNumber *b = @20.3;
NSDecimalNumber *c = [[NSDecimalNumber alloc] initWithFloat:30.4];

NSDecimalNumber *res = a.add(b).multiplying(c);
NSString *resStr = res.numberStringWithScale(3);

NSLog(@"res %@   resStr %@", res.stringValue, resStr);

// 结果：  res 927.19999   resStr 927.200
```

需要注意的是，这里的计算，没有按照加减乘除的优先级做处理，都是从前往后挨个计算。

### 数值转换

在对字符串做数值计算的时候，经常会出现比较特殊的数字，比如：

- 科学计数法`1,340,100`，
- 期货里的利率合约的价格`200'384`

在转换成`NSDecimalNumber`的时候会失败(但是科学计数法没有问题，比如10e-6这样的)，所以，提供了一个外部使用的全局方法来避免这种情况：

```objective-c
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
    
    return @1;
}];
```

返回值可以是上面说过的三种数据类型的数值。

### 容错处理

在数值计算的时候，难免出现一些错误，比如：

- `a.add(b)`
- `(@1).add(nil)`
- … 

当出现这种情况的时候，轻者导致计算出错，严重的直接导致APP Crash，为了避免这种问题，也可以这么处理：

```objective-c
[AUUNumberHandler globalNumberHandler:^(AUUNumberHandler *numberHandler) {
    numberHandler.roundingScale = 5;
    numberHandler.mode = NSRoundPlain;
    numberHandler.raiseOnOverflow = YES;
} exceptionHandler:^NSDecimalNumber *(SEL operation, NSCalculationError error, NSDecimalNumber *leftOperand, NSDecimalNumber *rightOperant) {
    return (@1).decimalNumber;
}];
```

当然了这里只是一个简单的处理，这个`block`里有计算出错的所有信息，所以你能够据此给出一个更合理的计算结果。

这也是一个全局的方法，如果你想为某个计算单独的写上一个错误处理方法的话，也可以使用`xxxxWithBehaviors`系列方法，初始化并传入`AUUNumberHandler`即可。

## 扩展

为了做到各种类型(继承了`NSObject`根类的)的数据都能直接进行计算，这里在`AUUNumberHandlerProtocol`里声明了一系列的操作方法，只需要实现这个协议里的方法即可，可以看一下测试项目里的`AUUDecimalNumber`这个测试类。

在前面所说的三种类型`NSString`、`NSNumber`、`NSDecimalNumber`即是已经实现了这些协议方法，你导入了这个库后即可直接使用。

