//
//  SGIPGetter.h
//  HotPostDemo
//
//  Created by 林超阳 on 26/12/2017.
//  Copyright © 2017 林超阳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGIPGetter : NSObject


/**
 get singleton instance
 */
+ (instancetype)shared;

/**
 get all connectable IPs of current device and hotpost
 */
- (void)sg_getDeviceIP:(void (^)(NSArray <NSString *>*ips))handler;

/**
 configure the time out of each ping operation
 default is 0.2 second
 */
- (void)configureTimeoutOfEachPing:(NSTimeInterval)seconds;

/**
 the ip getter will cache the IPs just find right now
 call this method before get IPs when change the network environment
 */
- (void)refresh;

- (NSArray <NSString *> *)sg_getAvailableInterfacesName;



@end
