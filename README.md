# IPGetter
Get other connectable IP in subnet of HotPost.

Use the *SimplePing* provided by *Apple*.

### How to use

```objc
[[SGIPGetter shared] sg_getDeviceIP:^(NSArray<NSString *> *ips) {
    NSLog(@"%@", ips);
}];
```


