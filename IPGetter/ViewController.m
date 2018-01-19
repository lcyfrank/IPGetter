//
//  ViewController.m
//  IPGetter
//
//  Created by 林超阳 on 19/01/2018.
//  Copyright © 2018 IcePhone. All rights reserved.
//

#import "ViewController.h"
#import "SGIPGetter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    [[SGIPGetter shared] sg_getDeviceIP:^(NSArray<NSString *> *ips) {
        NSLog(@"%@", ips);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
