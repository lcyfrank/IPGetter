//
//  SGPinger.h
//  HotPostDemo
//
//  Created by 林超阳 on 28/12/2017.
//  Copyright © 2017 林超阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGPinger : NSObject

+ (instancetype)pingerWithHostName:(NSString *)hostName;


/**
 ping

 @param time ms
 */
- (void)pingWithResult:(void (^)(BOOL isSuccess))result timeOut:(unsigned int)time;

@end
