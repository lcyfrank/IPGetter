//
//  SGPinger.m
//  HotPostDemo
//
//  Created by 林超阳 on 28/12/2017.
//  Copyright © 2017 林超阳. All rights reserved.
//

#import "SGPinger.h"
#import "SimplePing.h"
#include <netdb.h>

@interface SGPinger () <SimplePingDelegate> {
    BOOL _connected;
}

@property (nonatomic, strong) SimplePing *pinger;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) void (^resultBlock)(BOOL isSuccess);

@end

@implementation SGPinger

+ (instancetype)pingerWithHostName:(NSString *)hostName
{
    return [[self alloc] initWithHostName:hostName];
}

- (instancetype)initWithHostName:(NSString *)hostName
{
    if (self = [super init]) {
        _connected = NO;
        self.pinger = [[SimplePing alloc] initWithHostName:hostName];
        self.pinger.addressStyle = SimplePingAddressStyleICMPv4;
        self.pinger.delegate = self;
    }
    return self;
}

- (void)pingWithResult:(void (^)(BOOL isSuccess))result timeOut:(unsigned int)time
{
    self.resultBlock = [result copy];
    [self.pinger start];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:time / 1000.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [self timerScheduled];
    }];
}

#pragma mark - delegate
- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    if (error) {
//        NSLog(@"send ping error. [%@]", [error localizedDescription]);
        [self stop];
    }
}

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    int err;
    NSString *result = nil;
    char hostStr[1025];
    
    if (address != nil) {
        err = getnameinfo(address.bytes, (socklen_t) address.length, hostStr, sizeof(hostStr), NULL, 0, 32);
        if (err == 0) {
            result = @(hostStr);
        }
    }
    
//    NSLog(@"PING %@", result);
    for (NSInteger i = 0; i < 5; i++) {
        [self.pinger sendPingWithData:nil];
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
//    NSLog(@"unexpected packet, size=%zu", (size_t) packet.length);
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    _connected = YES;
    [self stop];
//    NSLog(@"#%u received, size=%zu", (unsigned int) sequenceNumber, (size_t) packet.length);
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
//    NSLog(@"#%u sent", (unsigned int) sequenceNumber);
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
//    NSLog(@"#%u send failed", (unsigned int) sequenceNumber);
}

- (void)timerScheduled
{
    [self stop];
}

- (void)stop
{
    [self.pinger stop];
    [self.timer invalidate];
    self.resultBlock(_connected);
}

@end
