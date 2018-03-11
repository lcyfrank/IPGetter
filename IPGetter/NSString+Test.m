//
//  NSString+Test.m
//  IPGetter
//
//  Created by 林超阳 on 2018/3/7.
//  Copyright © 2018 IcePhone. All rights reserved.
//

#import "NSString+Test.h"
#import <objc/runtime.h>

@implementation NSString (Test)

+ (void)load
{
    Method method1 = class_getInstanceMethod([self class], @selector(test_CopyWithZone:));
    Method method2 = class_getInstanceMethod([self class], @selector(copyWithZone:));
    method_exchangeImplementations(method1, method2);
}

- (void)test_CopyWithZone:(NSZone *)zone
{
    NSLog(@"......");
    [self test_CopyWithZone:zone];
}

@end
