//
//  SGIPGetter.h
//  HotPostDemo
//
//  Created by 林超阳 on 26/12/2017.
//  Copyright © 2017 林超阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGIPGetter : NSObject

+ (instancetype)shared;

- (void)refresh;
- (void)sg_getDeviceIP:(void (^)(NSArray <NSString *>*ips))handler;

@end
