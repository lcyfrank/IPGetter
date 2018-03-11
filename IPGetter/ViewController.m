//
//  ViewController.m
//  IPGetter
//
//  Created by 林超阳 on 19/01/2018.
//  Copyright © 2018 IcePhone. All rights reserved.
//

#import "ViewController.h"
#import "SGIPGetter.h"
#import "NSString+Test.h"

#define kHeaderMask @"ffd8"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // config each ping timeout
    // default is 0.2 second
    [[SGIPGetter shared] configueTimeoutOfEachPing:0.5];
    
    // get all IPs operation
    [[SGIPGetter shared] sg_getDeviceIP:^(NSArray<NSString *> *ips) {
        NSLog(@"%@", ips);
    }];

}

@end
