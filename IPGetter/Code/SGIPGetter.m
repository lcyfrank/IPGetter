//
//  SGIPGetter.m
//  HotPostDemo
//
//  Created by 林超阳 on 26/12/2017.
//  Copyright © 2017 林超阳. All rights reserved.
//

#import "SGIPGetter.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <ifaddrs.h>
#import "SGPinger.h"

typedef struct ifaddrs _ifaddrs;

@interface SGIPGetter ()
{
    BOOL _isRefresh;
    NSTimeInterval _timeout;
}

@property (nonatomic, strong) NSMutableArray <SGPinger *> *pingers;
@property (nonatomic, strong) NSMutableArray *ipResults;  // contain the bool value of each ip in subnet

@end

@implementation SGIPGetter

- (instancetype)init
{
    if (self = [super init]) {
        _timeout = 0.2;
        _isRefresh = YES;
    }
    return self;
}

+ (instancetype)shared
{
    static SGIPGetter *getter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        getter = [[SGIPGetter alloc] init];
    });
    return getter;
}

- (void)configueTimeoutOfEachPing:(NSTimeInterval)seconds
{
    _timeout = seconds;
}

- (void)sg_getDeviceIP:(void (^)(NSArray<NSString *> *))handler
{
    if (_isRefresh) {
        _isRefresh = NO;
        NSArray *_ips = [self getAllNetIps];
        
        NSUInteger ip_count = _ips.count;
        if (ip_count == 0) {
            handler(@[]);
            return;
        }
        
        _ipResults = [NSMutableArray arrayWithCapacity:ip_count];
        _pingers = [NSMutableArray arrayWithCapacity:ip_count];
        [_ips enumerateObjectsUsingBlock:^(NSString * _Nonnull ip, NSUInteger idx, BOOL * _Nonnull stop) {
            SGPinger *pinger = [SGPinger pingerWithHostName:ip];
            [pinger pingWithResult:^(BOOL isSuccess) {
                if (isSuccess) {
                    [_ipResults addObject:ip];
                }
                if (idx + 1 == ip_count) {
                    handler(_ipResults);
                    [_pingers removeAllObjects];
                }
            } timeOut:(unsigned int)(_timeout * 1000)];
            _pingers[idx] = pinger;
        }];
    } else {
        handler(_ipResults);
    }
}

// get all IPs in subnet
- (NSArray <NSString *>*)getAllNetIps
{
    _ifaddrs *interfaces = NULL;
    _ifaddrs *temp_addr = NULL;
    
    NSInteger success = getifaddrs(&interfaces);
    
    NSMutableArray *ips = [NSMutableArray array];
    
    if (success == 0) {
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET ||
                temp_addr->ifa_addr->sa_family == AF_INET6) {
                
                NSString *ifName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                if ([ifName containsString:@"bridge"]) {  // hot post
                    struct sockaddr_in *netmaskSocket = (struct sockaddr_in *)temp_addr->ifa_netmask;  // the socket of netmask
                    const char *netmask = inet_ntoa(netmaskSocket->sin_addr);  // get the netmask
                    NSString *netmaskString = [NSString stringWithUTF8String:netmask];  // get the objc string of netmask
                    
                    if ([netmaskString isEqualToString:@"0.0.0.0"]) {
                        temp_addr = temp_addr->ifa_next;
                        continue;
                    }
                    
                    struct sockaddr_in *hostSocket = (struct sockaddr_in *)temp_addr->ifa_addr;  // the socket of host
                    const char *host = inet_ntoa(hostSocket->sin_addr);
                    NSString *hostString = [NSString stringWithUTF8String:host];  // get the objc string of host

                    NSArray<NSString *> *netmasks = [netmaskString componentsSeparatedByString:@"."];
                    NSArray<NSString *> *hosts = [hostString componentsSeparatedByString:@"."];
                    
                    __block NSInteger ip_min = 0;
                    __block NSInteger ip_max = 0;
                    // enumerate 4 segments of IP
                    [netmasks enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSInteger temp_segment_netmask = [obj integerValue];
                        NSInteger temp_segment_host = [hosts[idx] integerValue];
                        if (temp_segment_netmask == 0) {
                            ip_min += (0 << ((3 - idx) * 8));
                            ip_max += (255 << ((3 - idx) * 8));
                        } else {
                            NSInteger counter = 0;
                            while (temp_segment_netmask != 0 && temp_segment_netmask % 2 == 0) {
                                temp_segment_netmask = temp_segment_netmask >> 1;
                                temp_segment_host = temp_segment_host >> 1;
                                counter++;
                            }
                            temp_segment_host = (temp_segment_host << counter);
                            
                            ip_min += (temp_segment_host << ((3 - idx) * 8));
                            ip_max += ((temp_segment_host + (1 << counter) - 1) << ((3 - idx) * 8));
                        }
                    }];
                    
                    for (NSInteger ip = ip_min; ip <= ip_max - 1; ip++) {
                        NSInteger ip_1 = ip >> 24;
                        NSInteger ip_2 = (ip - (ip_1 << 24)) >> 16;
                        NSInteger ip_3 = (ip - (ip_1 << 24) - (ip_2 << 16)) >> 8;
                        NSInteger ip_4 = ip % 256;
                        NSString *tempIP = [NSString stringWithFormat:@"%ld.%ld.%ld.%ld", ip_1, ip_2, ip_3, ip_4];
                        [tempIP isEqualToString:hostString] ? @"nothing" : [ips addObject:tempIP];
                    }
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    freeifaddrs(interfaces);
    return [ips copy];
}

- (NSArray <NSString *> *)sg_getAvailableInterfacesName
{
    _ifaddrs *interfaces = NULL;
    _ifaddrs *tempInterface = NULL;
    
    NSInteger success = getifaddrs(&interfaces);
    
    NSMutableArray *availableInterfaces = [NSMutableArray array];
    if (success == 0) {
        tempInterface = interfaces;
        while (tempInterface) {
            if (tempInterface->ifa_addr->sa_family == AF_INET ||
                tempInterface->ifa_addr->sa_family == AF_INET6) {
                NSString *ifName = [NSString stringWithUTF8String:tempInterface->ifa_name];
                [availableInterfaces addObject:ifName];
            }
            tempInterface = tempInterface->ifa_next;
        }
    }
    return [availableInterfaces copy];
}

- (void)refresh
{
    _isRefresh = YES;
}


@end
